import Foundation
import XCTest
@testable import OblienKit

/// Explicit opt-in. Creates its own workspace and disks, records their IDs for recovery,
/// and deletes only those fixtures. Existing account workspaces are never modified.
final class WorkspaceControlLiveTests: XCTestCase {
    func testDisposableWorkspaceControls() async throws {
        guard let tokenFile = ProcessInfo.processInfo.environment["OBLIEN_LIVE_TOKEN_FILE"] else {
            throw XCTSkip("Set OBLIEN_LIVE_TOKEN_FILE to run the disposable control-plane check.")
        }
        let token = try String(contentsOfFile: tokenFile, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
        let client = OblienClient(token: token)
        let directory = URL(fileURLWithPath: ProcessInfo.processInfo.environment["OBLIEN_LIVE_ARTIFACT_DIR"] ?? NSTemporaryDirectory())
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        var receipt = ["idempotency_key": UUID().uuidString]
        var diskIDs: [String] = []
        func save() throws {
            let data = try JSONSerialization.data(withJSONObject: ["workspace": receipt, "disks": diskIDs], options: [.prettyPrinted, .sortedKeys])
            try data.write(to: directory.appendingPathComponent("workspace-controls-fixture.json"), options: .atomic)
        }
        try save()
        let workspace = try await client.workspaces.create(.init(image: "oblien/ubuntu:24.04", name: "Mindwire SDK verification",
            mode: .permanent, config: .init(cpus: 1, memoryMb: 2048, diskSizeMb: 4096), waitReady: false, idempotencyKey: receipt["idempotency_key"]))
        receipt["id"] = workspace.id; try save()
        let handle = client.workspace(workspace.id)
        var failure: Error?
        var stage = "workspace readiness"
        do {
            print("Checking disposable workspace \(workspace.id)")
            _ = try await handle.waitUntilReady(timeout: 360)
            let resources = try await handle.resources.get()
            XCTAssertEqual(resources.memoryMb, 2048)
            _ = try await handle.lifecycle.get()
            _ = try await handle.network.update(.init(allowInternet: true, ingressPorts: [3047], egress: ["*"]))
            let network = try await handle.network.get()
            XCTAssertEqual(network.ingressPorts, [3047])
            print("Workspace resources and network verified")

            stage = "runtime reachability"
            let runtime = try await handle.runtime()
            // Management readiness can precede propagation to the runtime gateway.
            // Poll a read before sending commands; never replay a lost mutation.
            let runtimeDeadline = Date().addingTimeInterval(60)
            while try await !runtime.health() {
                guard Date() < runtimeDeadline else {
                    throw OblienError(kind: .transport, status: nil, code: "RUNTIME_READY_TIMEOUT",
                                      message: "The new workspace runtime did not become reachable.", details: nil)
                }
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
            stage = "runtime commands"
            let prepared = try await runtime.exec.run(["/bin/sh", "-lc", "mkdir -p /tmp/mindwire-verification && printf 'fixture\\n' > /tmp/mindwire-verification/check"], timeoutSeconds: 30, execMode: .foreground)
            XCTAssertEqual(prepared.exitCode, 0)
            var streamedOutput = ""
            for try await event in runtime.exec.stream(["/bin/sh", "-lc", "printf 'mindwire-exec-α\\n'"], timeoutSeconds: 30, keepLogs: false) {
                if let text = event.text { streamedOutput += text }
            }
            XCTAssertTrue(streamedOutput.contains("mindwire-exec-α"))
            stage = "native runtime files and streams"
            try await verifyNativeRuntime(runtime)
            stage = "workload creation and statistics"
            let workloadCommand = ["/bin/sh", "-lc", "pwd; sleep 5; printf 'mindwire-live-α\\n'; sleep 120"]
            let workload = try await handle.workloads.create(.init(name: "SDK log check", cmd: workloadCommand,
                env: [.init(key: "SDK_CHECK", value: "a=b")], restartPolicy: .never, workingDir: "/tmp"))
            let wid = try XCTUnwrap(workload.id)
            let processes = try await handle.workloads.list()
            XCTAssertTrue(processes.contains { $0.id == wid })
            let measured = try await firstProcessStats(handle.workloads.processStatsStream(), id: wid)
            XCTAssertEqual(measured?.id, wid)
            stage = "workload settings and logs"
            _ = try await handle.workloads.patch(wid, .init(name: "SDK updated log check", restartPolicy: .never, maxRestarts: 0))
            let updated = try await handle.workloads.get(wid)
            XCTAssertEqual(updated.name, "SDK updated log check")
            XCTAssertEqual(updated.command ?? updated.cmd, workloadCommand)
            XCTAssertEqual(updated.env?.first(where: { $0.key == "SDK_CHECK" })?.value, "a=b")
            let followed = try await retainedAndLiveLogs(handle.workloads.followLogs(wid), matching: "mindwire-live-α")
            XCTAssertTrue(followed)
            let logs = try await handle.workloads.logEntries(wid)
            XCTAssertTrue(logs.entries.contains { $0.line.contains("/tmp") })
            do {
                _ = try await handle.workloads.logConfig(wid)
                try await handle.workloads.setLogRetention(wid, maxLogSizeMb: 1, logRetentionHours: 1)
                try await handle.workloads.clearLogs(wid)
                print("Workload log retention and clearing verified")
            } catch let error as OblienError where error.status == 409 && error.message?.contains("updated workspace runtime") == true {
                print("Backend capability unavailable: workload log retention/clear requires a newer Oblien runtime")
            }
            try await handle.workloads.stop(wid)
            try await handle.workloads.delete(wid)
            print("Workload creation, settings, live statistics/logs, stop and delete verified")

            stage = "public ports and access"
            let port = try await handle.publicAccess.expose(port: 3047, label: "SDK verification")
            XCTAssertEqual(port.port, 3047)
            let ports = try await handle.publicAccess.list()
            XCTAssertTrue(ports.contains { $0.port == 3047 })
            try await handle.publicAccess.revoke(port: 3047)
            _ = try await handle.domains.get()
            _ = try await handle.ssh.status()
            _ = try await handle.runtimeAccess.status()
            print("Public ports and access status verified")

            stage = "disk lifecycle"
            let created = try await client.disks.create(.init(name: "Mindwire SDK disk verification", sizeMb: 64), options: .init(waitUntilReady: true))
            let disk = try XCTUnwrap(created.disk)
            diskIDs.append(disk.id); try save()
            XCTAssertEqual(created.operation?.state, "done")
            try await handle.stop()
            let attached = try await client.disks.attach(disk.id, .init(workspaceId: workspace.id, mountPath: "/data/sdk-check"), options: .init(waitUntilReady: true))
            XCTAssertEqual(attached.operation?.state, "done")
            let attachedDisks = try await handle.disks.list()
            XCTAssertTrue(attachedDisks.disks.contains { $0.id == disk.id })
            try await handle.wake()
            let write = try await runtime.exec.run(["/bin/sh", "-lc", "test -d /data/sdk-check && printf 'persistent' > /data/sdk-check/check && cat /data/sdk-check/check"], timeoutSeconds: 30, execMode: .foreground)
            XCTAssertEqual(write.stdout?.trimmingCharacters(in: .whitespacesAndNewlines), "persistent")
            try await handle.stop()
            _ = try await client.disks.detach(disk.id, workspaceId: workspace.id, options: .init(waitUntilReady: true))
            _ = try await client.disks.resize(disk.id, sizeMb: 96, options: .init(waitUntilReady: true))
            let resized = try await client.disks.get(disk.id)
            XCTAssertEqual(resized.sizeMb, 96)
            print("Disk create, attach, persistent files, detach and resize verified")

            let desktop = try await handle.desktop.installation()
            if let choice = desktop.choices?.first {
                let accepted = try await handle.desktop.install(desktop: choice.id)
                var status = accepted
                let deadline = Date().addingTimeInterval(240)
                while status.phase == "installing", Date() < deadline {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                    status = try await handle.desktop.installation()
                }
                XCTAssertEqual(status.installed, true)
                let stopped = try await handle.get()
                XCTAssertEqual(stopped.info?.status, "stopped")
                try await handle.wake()
                try await runtime.desktop.enable()
                let access = try await runtime.desktop.status()
                XCTAssertTrue(access.supported)
                XCTAssertTrue(access.enabled)
                let grant = try await handle.desktop.sshConnection()
                XCTAssertEqual(grant.ssh.host, "ssh.oblien.com")
                XCTAssertEqual(grant.vnc.port, 5900)
                try await runtime.desktop.disable()
                print("Prepared desktop, stopped-state preservation, enable, native SSH grant and disable verified")
            } else {
                print("Desktop preparation unavailable for this fixture: \(desktop.phase)")
            }
        } catch { print("Live check failed during \(stage)"); failure = error }

        do {
            try await handle.delete()
            for id in diskIDs { _ = try await client.disks.delete(id, options: .init(waitUntilReady: true)) }
            receipt["cleaned"] = "true"; try save()
            print("Disposable workspace and disks removed")
        } catch {
            print("Fixture cleanup needs retry; IDs are in the live artifact directory")
            if failure == nil { failure = error }
        }
        if let failure { throw failure }
    }

    private func retainedAndLiveLogs(_ stream: AsyncThrowingStream<LogBatch, Error>, matching: String) async throws -> Bool {
        try await withThrowingTaskGroup(of: Bool.self) { group in
            group.addTask {
                var lines: [String] = []
                var first = true
                for try await batch in stream {
                    if first { guard batch.cleared else { return false }; first = false }
                    if batch.cleared { lines.removeAll() }
                    lines += batch.entries.map(\.line)
                    if lines.contains(where: { $0.contains(matching) }) {
                        return lines.filter { $0 == "/tmp" }.count == 1
                    }
                }
                return false
            }
            group.addTask { try await Task.sleep(nanoseconds: 30_000_000_000); return false }
            defer { group.cancelAll() }
            return try await group.next() ?? false
        }
    }

    private func firstProcessStats(_ stream: AsyncThrowingStream<[WorkloadProcessStats], Error>, id: String) async throws -> WorkloadProcessStats? {
        try await withThrowingTaskGroup(of: WorkloadProcessStats?.self) { group in
            group.addTask {
                for try await batch in stream { if let value = batch.first(where: { $0.id == id }) { return value } }
                return nil
            }
            group.addTask { try await Task.sleep(nanoseconds: 20_000_000_000); return nil }
            defer { group.cancelAll() }
            return try await group.next() ?? nil
        }
    }

    private func verifyNativeRuntime(_ runtime: RuntimeClient) async throws {
        let root = "/tmp/mindwire-verification"
        let file = root + "/sdk-native.txt"
        let info = try await runtime.info()
        XCTAssertFalse(info.os.isEmpty)
        let targets = try await runtime.targets()
        XCTAssertFalse(targets.targets.isEmpty)
        let healthy = try await runtime.health()
        XCTAssertTrue(healthy)
        _ = try await runtime.files.write(fullPath: file, content: "first\nnative-file-α\n", mode: "0644")
        let content = try await runtime.files.read(path: file, startLine: 2, endLine: 2, withLineNumbers: true)
        XCTAssertTrue(content.content.contains("native-file-α"))
        let files = try await runtime.files.list(.init(path: root, nested: true, includeContent: true,
            maxDepth: 2, useGitignore: false, flatten: true, includeHash: true, includeExtensions: true, maxContentBudget: 4096))
        XCTAssertTrue(files.entries.contains { $0.name == "sdk-native.txt" })
        _ = try await runtime.files.stat(path: file)
        _ = try await runtime.search.install()
        let search = try await runtime.search.files(.init(query: "sdk-native", path: root, caseSensitive: true, maxResults: 5))
        XCTAssertTrue(search.files.contains { $0.hasSuffix("sdk-native.txt") })
        _ = try await runtime.search.content(.init(query: "native-file-α", path: root, regex: false, maxResults: 5, contextLines: 1))

        let archive = try await runtime.transfer.download(paths: [file])
        var data = Data()
        for try await chunk in archive.chunks { data.append(chunk) }
        XCTAssertEqual(data.prefix(2), Data([0x1f, 0x8b]))
        let uploadBytes = data
        _ = try await runtime.transfer.upload(dest: root + "/restored", totalBytes: Int64(data.count), stream: { InputStream(data: uploadBytes) })
        let restored = try await runtime.exec.run(["/bin/sh", "-lc", "find /tmp/mindwire-verification/restored -name sdk-native.txt -exec cat {} \\;"], timeoutSeconds: 10, execMode: .foreground)
        XCTAssertTrue(restored.stdout?.contains("native-file-α") == true)

        let mux = try await runtime.ws(options: .init(reconnect: false))
        defer { mux.close() }
        let open = expectation(description: "Native runtime socket opens")
        mux.onOpen = { open.fulfill() }
        let output = expectation(description: "Native PTY returns command output")
        let changed = expectation(description: "Watcher receives a real file change")
        let capture = LiveSocketCapture()
        mux.onTerminalOutput = { _, bytes in
            if capture.append(bytes, until: "mindwire-terminal-α") { output.fulfill() }
        }
        mux.onWatcherEvent = { event in
            if case .change(let value) = event, value.path.hasSuffix("watched.txt"), capture.markWatcher() { changed.fulfill() }
        }
        mux.connect()
        await fulfillment(of: [open], timeout: 15)
        let terminal = try await runtime.terminal.create(cols: 80, rows: 24, shell: "/bin/sh", scrollbackSize: 65536)
        let watcher = try await runtime.watcher.create(.init(path: root, excludes: ["restored"]))
        mux.resizeTerminal(terminal.id, cols: 100, rows: 30)
        mux.writeTerminalInput(terminal.id, "printf 'mindwire-terminal-%s\\n' 'α'\n")
        _ = try await runtime.files.write(fullPath: root + "/watched.txt", content: "event")
        await fulfillment(of: [output, changed], timeout: 15)
        let scrollback = try await runtime.terminal.scrollbackInfo(terminal.id)
        XCTAssertFalse(scrollback.scrollback.isEmpty)
        try await runtime.terminal.close(terminal.id)
        try await runtime.watcher.delete(watcher.id)
        try await runtime.files.delete(path: root + "/watched.txt")
        print("Native files/search/transfer, runtime discovery, terminal input/output and watcher events verified")
    }
}

private final class LiveSocketCapture: @unchecked Sendable {
    private let lock = NSLock()
    private var bytes = Data()
    private var outputSeen = false
    private var watcherSeen = false
    func append(_ value: Data, until marker: String) -> Bool {
        lock.lock(); defer { lock.unlock() }
        guard !outputSeen else { return false }
        bytes.append(value)
        if String(decoding: bytes, as: UTF8.self).contains(marker) { outputSeen = true; return true }
        return false
    }
    func markWatcher() -> Bool {
        lock.lock(); defer { lock.unlock() }
        if watcherSeen { return false }
        watcherSeen = true; return true
    }
}
