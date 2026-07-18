import XCTest
@testable import OblienKit

final class OblienKitTests: XCTestCase {
    private let dec = JSONDecoder()
    private func snakeDecode<T: Decodable>(_ t: T.Type, _ json: String) throws -> T {
        try OblienJSON.decode(t, Data(json.utf8))
    }

    func testCreateParamsEncodeSnakeCase() throws {
        let params = WorkspaceCreateParams(image: "node-20", name: "demo",
                                           config: .init(cpus: 1, memoryMb: 512, diskSizeMb: 1024))
        let data = try OblienJSON.encode(params)
        let obj = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(obj["image"] as? String, "node-20")
        let config = try XCTUnwrap(obj["config"] as? [String: Any])
        XCTAssertEqual(config["memory_mb"] as? Int, 512)
        XCTAssertEqual(config["disk_size_mb"] as? Int, 1024)
    }

    func testWorkspaceDecodeLenient() throws {
        let ws = try snakeDecode(Workspace.self, #"""
        {"id":"ws_1","name":"demo","image":"node-20","info":{"status":"running","is_running":true},
         "resources":{"cpus":2,"memory_mb":2048,"disk_size_mb":4096,"status":"running"}}
        """#)
        XCTAssertEqual(ws.id, "ws_1")
        XCTAssertTrue(ws.isRunning)
        XCTAssertEqual(ws.resources?.memoryMb, 2048)
        XCTAssertEqual(ws.resources?.diskSizeMb, 4096)
    }

    func testResourceUpdateResultDecode() throws {
        let r = try snakeDecode(ResourceUpdateResult.self,
            #"{"success":true,"updated":{"cpus":4,"memory_mb":4096,"disk_size_mb":8192},"relaunched":true}"#)
        XCTAssertEqual(r.updated.cpus, 4)
        XCTAssertEqual(r.relaunched, true)
    }

    func testExposedPortDecode() throws {
        let p = try snakeDecode(ExposedPort.self,
            #"{"port":3000,"hash":"abc","label":"web","url":"https://abc.preview.oblien.com"}"#)
        XCTAssertEqual(p.port, 3000)
        XCTAssertEqual(p.url, "https://abc.preview.oblien.com")
    }

    func testExecTaskDecode() throws {
        let t = try snakeDecode(ExecTask.self,
            #"{"id":"t1","status":"exited","exit_code":0,"stdout":"hi\n","guest_pid":42}"#)
        XCTAssertEqual(t.exitCode, 0)
        XCTAssertEqual(t.stdout, "hi\n")
        XCTAssertEqual(t.guestPid, 42)
    }

    func testFileEntryExtensionKey() throws {
        let e = try snakeDecode(FileEntry.self,
            #"{"name":"main.swift","path":"/app/main.swift","type":"file","size":12,"extension":"swift"}"#)
        XCTAssertEqual(e.fileExtension, "swift")
        XCTAssertFalse(e.isDirectory)
    }

    func testTerminalIdAcceptsNumberOrString() throws {
        XCTAssertEqual(try snakeDecode(TerminalCreateResult.self, #"{"id":5}"#).id, 5)
        XCTAssertEqual(try snakeDecode(TerminalCreateResult.self, #"{"id":"7"}"#).id, 7)
    }

    func testErrorKindMapping() {
        XCTAssertEqual(OblienError.kind(forStatus: 402, code: "SANDBOX_LIMIT_REACHED"), .paymentRequired)
        XCTAssertEqual(OblienError.kind(forStatus: 404, code: nil), .notFound)
        XCTAssertEqual(OblienError.kind(forStatus: 429, code: nil), .rateLimited)
        XCTAssertEqual(OblienError.kind(forStatus: 503, code: nil), .server)
        XCTAssertTrue(OblienError(kind: .server, status: 500, code: nil, message: nil, details: nil).isRetryable)
        XCTAssertFalse(OblienError(kind: .notFound, status: 404, code: nil, message: nil, details: nil).isRetryable)
    }

    func testScopedTokenDecode() throws {
        let tok = try snakeDecode(ScopedToken.self,
            #"{"success":true,"token":"eyJ...","expiresAt":"2026-03-15T12:15:00.000Z","scope":"namespace","ttl":900}"#)
        XCTAssertEqual(tok.scope, "namespace")
        XCTAssertEqual(tok.ttl, 900)
    }

    /// Compile-checks the full microVM flow (create → boot → install daemon → exec → terminal)
    /// against the real SDK surface. Hits the network only when `OBLIEN_LIVE` is set.
    func testEndToEndMicroVMFlowCompiles() async throws {
        guard ProcessInfo.processInfo.environment["OBLIEN_LIVE"] != nil else { return }
        try await Self.runMicroVMFlow(OblienClient(clientId: "id", clientSecret: "secret"))
    }

    private static func runMicroVMFlow(_ client: OblienClient) async throws {
        // 1. Create + boot a microVM.
        let ws = try await client.workspaces.create(
            .init(image: "node-20", name: "agent-box", config: .init(cpus: 2, memoryMb: 2048, diskSizeMb: 4096))
        )
        let box = client.workspace(ws.id)
        try await box.start()

        // 2. Runtime data plane (gateway JWT auto-enabled + cached).
        let rt = try await box.runtime()

        // 3a. Install the daemon — the sandbox pulls + launches it.
        let install = try await rt.exec.run(["bash", "-lc", """
        mkdir -p ~/.pocket-agent && \
        curl -fsSL https://dl.oblien.com/pocket-agent/0.1.0/pocket-agentd-linux-amd64 -o ~/.pocket-agent/pocket-agentd && \
        chmod +x ~/.pocket-agent/pocket-agentd && \
        ADDR=127.0.0.1:8790 AGENT_TYPE=claude-code setsid nohup ~/.pocket-agent/pocket-agentd >~/.pocket-agent/daemon.log 2>&1 &
        echo started
        """])
        _ = (install.stdout, install.exitCode)

        // 3b. ...or push files / a binary directly.
        _ = try await rt.files.write(fullPath: "/root/start.sh", content: "#!/bin/sh\n", createDirs: true)
        try await rt.files.upload(dest: "/root", tarGz: Data())

        // 4. Talk to the in-sandbox daemon over the runtime (curl 127.0.0.1:8790).
        let health = try await rt.exec.run(["bash", "-lc", "curl -sS 127.0.0.1:8790/healthz"])
        _ = health.stdout

        // 5. Networking + snapshots + metrics.
        _ = try await box.publicAccess.expose(port: 3000, label: "web")
        try await box.snapshots.snapshot(after: "stop")
        _ = try await box.metrics.stats()

        // 6. Live terminal over the binary WebSocket.
        let term = try await rt.openTerminal(cols: 80, rows: 24)
        term.onData = { _ in }
        term.send("ls -la\n")
        term.resize(cols: 100, rows: 30)
        term.close()
    }
}
