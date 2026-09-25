import XCTest
@testable import OblienKit
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class WorkspaceControlTests: XCTestCase {
    override func tearDown() { ControlURLProtocol.handler = nil; super.tearDown() }

    private func transport(auth: OblienAuth = .scopedToken("test-session"), retries: Int = 0) -> Transport {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [ControlURLProtocol.self]
        return Transport(config: .init(auth: auth, baseURL: URL(string: "https://example.test")!,
                                      runtimeURL: URL(string: "https://runtime.test")!, maxRetries: retries),
                         session: URLSession(configuration: config))
    }

    func testDiskRequestUsesStableIdempotencyAndDoesNotWaitInHTTP() async throws {
        let requests = RequestStore()
        ControlURLProtocol.handler = { request in
            requests.append(request)
            return .init(body: #"{"success":true,"accepted":true,"operation":{"id":"op1","state":"queued"},"disk":{"id":"disk1","state":"queued"}}"#)
        }
        let api = DisksAPI(transport: transport())
        let result = try await api.create(.init(name: "files", sizeMb: 64, namespace: "team"), options: .init(idempotencyKey: "same-action"))
        XCTAssertEqual(result.operation?.id, "op1")
        let body = try requests.body(at: 0)
        XCTAssertEqual(body["idempotency_key"] as? String, "same-action")
        XCTAssertEqual(body["wait_ready"] as? Bool, false)
        XCTAssertEqual(body["size_mb"] as? Int, 64)
        XCTAssertEqual(body["namespace"] as? String, "team")
        XCTAssertEqual(requests.values.first?.value(forHTTPHeaderField: "Authorization"), "Bearer test-session")
    }

    func testDiskAttachEncodesRuntimeTargetAndSinglePathComponent() async throws {
        let requests = RequestStore()
        ControlURLProtocol.handler = { request in requests.append(request); return .init(body: #"{"operation":{"id":"op","state":"done"}}"#) }
        _ = try await DisksAPI(transport: transport()).attach("disk/with?query", .init(workspaceId: "w1", readOnly: true, role: "data", target: "macos"))
        XCTAssertTrue(try XCTUnwrap(requests.values.first?.url?.absoluteString).contains("disk%2Fwith%3Fquery/attach"))
        let body = try requests.body(at: 0)
        XCTAssertEqual(body["read_only"] as? Bool, true)
        XCTAssertEqual(body["workspace_id"] as? String, "w1")
        XCTAssertEqual(body["target"] as? String, "macos")
    }

    func testUnkeyedCreationIsNotRetriedAfterServerError() async throws {
        let requests = RequestStore()
        ControlURLProtocol.handler = { request in requests.append(request); return .init(status: 503, body: #"{"code":"busy","message":"Try later"}"#) }
        do {
            _ = try await WorkloadsAPI(transport: transport(retries: 3), workspaceId: "w1").create(.init(cmd: ["echo", "hello"]))
            XCTFail("Expected server failure")
        } catch let error as OblienError { XCTAssertEqual(error.status, 503) }
        XCTAssertEqual(requests.values.count, 1)
    }

    func testKeyedDiskRetryReusesExactlyTheSameBody() async throws {
        let requests = RequestStore()
        ControlURLProtocol.handler = { request in
            requests.append(request)
            if requests.values.count == 1 { return .init(status: 503, body: #"{"message":"Temporary failure"}"#) }
            return .init(body: #"{"operation":{"id":"op","state":"done"}}"#)
        }
        _ = try await DisksAPI(transport: transport(retries: 1)).create(.init(name: "files", sizeMb: 64), options: .init(idempotencyKey: "stable"))
        XCTAssertEqual(requests.values.count, 2)
        XCTAssertEqual(try requests.body(at: 0)["idempotency_key"] as? String, try requests.body(at: 1)["idempotency_key"] as? String)
    }

    func testWorkloadWireEnvironmentAndRetention() throws {
        let params = WorkloadCreateParams(cmd: ["sh", "-c", "echo ready"], env: [.init(key: "MESSAGE", value: "a=b")],
            restartPolicy: .never, extra: .object(["custom_flag": .bool(true)]), workingDir: "/app", target: "local", maxLogSizeMb: 5, logRetentionHours: 24)
        let body = try XCTUnwrap(JSONSerialization.jsonObject(with: OblienJSON.encode(params)) as? [String: Any])
        XCTAssertEqual(body["env"] as? [String], ["MESSAGE=a=b"])
        XCTAssertEqual(body["working_dir"] as? String, "/app")
        XCTAssertEqual(body["restart_policy"] as? String, "never")
        XCTAssertEqual(body["max_log_size_mb"] as? Int, 5)
        XCTAssertEqual(body["custom_flag"] as? Bool, true)
        XCTAssertNil(body["extra"])
        let decoded = try OblienJSON.decode(Workload.self, Data(#"{"id":1,"state":"running","restart_policy":"never","env":["MESSAGE=a=b"],"pid":17,"origin":"user"}"#.utf8))
        XCTAssertEqual(decoded.id, "1")
        XCTAssertEqual(decoded.state, "running")
        XCTAssertEqual(decoded.env?.first?.value, "a=b")
        XCTAssertEqual(decoded.pid, 17)
    }

    func testMalformedWorkloadListIsAnErrorInsteadOfAnEmptyList() async throws {
        ControlURLProtocol.handler = { _ in .init(body: #"{"workloads":"unsupported"}"#) }
        do { _ = try await WorkloadsAPI(transport: transport(), workspaceId: "w1").list(); XCTFail("Expected decoding failure") }
        catch let error as OblienError { XCTAssertEqual(error.kind, .decoding) }
    }

    func testNetworkAndDomainCurrentFields() throws {
        let network = try OblienJSON.decode(Network.self, Data(#"{"allow_internet":true,"egress":["*"],"outbound_country_code":"US","outbound_proxy":{"host":"203.0.113.1","port":443,"protocol":"https","has_credentials":true},"private_links":[{"id":"w2"}]}"#.utf8))
        XCTAssertEqual(network.egress, ["*"])
        XCTAssertEqual(network.outboundProxy?.hasCredentials, true)
        XCTAssertEqual(network.privateLinks?.first?.id, "w2")
        let domain = try OblienJSON.decode(DomainInfo.self, Data(#"{"customDomain":"example.com","includeWww":true,"sslStatus":"active","port":3000}"#.utf8))
        XCTAssertEqual(domain.customDomain, "example.com")
        XCTAssertEqual(domain.sslStatus, "active")
        let check = try OblienJSON.decode(DomainCheck.self, Data(#"{"verified":false,"required_records":{"cname":{"host":"app","target":"preview.test"},"txt":{"host":"_verify","value":"proof"}},"errors":["CNAME missing"]}"#.utf8))
        XCTAssertEqual(check.requiredRecords?.txt?.value, "proof")
    }

    func testDesktopAndSSHReadDistinctCredentialShapes() throws {
        let desktop = try OblienJSON.decode(DesktopInstallation.self, Data(#"{"phase":"installing","installed":false,"stage":"attaching","choices":[{"id":"cinnamon","label":"Cinnamon","minimum_memory_mb":2048}]}"#.utf8))
        XCTAssertEqual(desktop.choices?.first?.minimumMemoryMb, 2048)
        let ssh = try OblienJSON.decode(SSHStatus.self, Data(#"{"supported":true,"ssh_enabled":true,"ssh_password":"temporary-test-password","password_affects_desktop":true,"auth_methods":["password","publickey"],"connection":{"command":"ssh root@workspace","scp_upload":"scp example"}}"#.utf8))
        XCTAssertEqual(ssh.sshPassword, "temporary-test-password")
        XCTAssertEqual(ssh.connectionInfo?.scpUpload, "scp example")
        XCTAssertEqual(ssh.passwordAffectsDesktop, true)
    }

    func testArchiveVersionAcceptsNumberAndString() throws {
        let a = try OblienJSON.decode(Archive.self, Data(#"{"version":2,"size":100}"#.utf8))
        let b = try OblienJSON.decode(Archive.self, Data(#"{"version":"3","size_bytes":200}"#.utf8))
        XCTAssertEqual(a.version, "2")
        XCTAssertEqual(b.version, "3")
    }

    func testExplicitIdentityClearAndDiskBasedCreation() throws {
        let update = WorkspaceUpdateParams(name: "Workspace", clearSlug: true, clearLogo: true)
        let body = try XCTUnwrap(JSONSerialization.jsonObject(with: OblienJSON.encode(update)) as? [String: Any])
        XCTAssertTrue(body["slug"] is NSNull)
        XCTAssertTrue(body["logo"] is NSNull)
        XCTAssertNil(body["clear_slug"])
        let create = WorkspaceCreateParams(config: .init(rootDiskId: "root1", disks: [.init(diskId: "data1", mountPath: "/data")]), waitReady: false, idempotencyKey: "create1")
        let created = try XCTUnwrap(JSONSerialization.jsonObject(with: OblienJSON.encode(create)) as? [String: Any])
        XCTAssertNil(created["image"])
        XCTAssertEqual((created["config"] as? [String: Any])?["root_disk_id"] as? String, "root1")
    }

    func testDecodingFailureNeverIncludesCredentialBody() throws {
        do {
            _ = try OblienJSON.decode(DesktopSSHConnection.self, Data(#"{"token":"do-not-disclose","ssh":{"password":"private-secret"}}"#.utf8))
            XCTFail("Expected decoding failure")
        } catch {
            XCTAssertFalse(error.localizedDescription.contains("do-not-disclose"))
            XCTAssertFalse(error.localizedDescription.contains("private-secret"))
        }
    }

    func testLogStreamFramesSplitUnicodeAndClearEvents() async throws {
        let payload = Data(":heartbeat\r\ndata: {\"line\":\"α first\",\"timestamp\":\"now\"}\r\n\r\ndata: {\"cleared\":true}\n\ndata: {\"line\":\"  indented  \"}\n\n".utf8)
        let stream = AsyncThrowingStream<Data, Error> { c in for byte in payload { c.yield(Data([byte])) }; c.finish() }
        var batches: [LogBatch] = []
        for try await event in sseEvents(stream) { batches.append(try LogBatch.decode(Data(event.data.utf8))) }
        XCTAssertEqual(batches.count, 3)
        XCTAssertEqual(batches[0].entries.first?.line, "α first")
        XCTAssertEqual(batches[1].cleared, true)
        XCTAssertEqual(batches[2].entries.first?.line, "  indented  ")
    }

    func testManagementStreamRefreshesOnceOn401() async throws {
        let requests = RequestStore()
        ControlURLProtocol.handler = { request in
            requests.append(request)
            if request.value(forHTTPHeaderField: "Authorization") == "Bearer old" { return .init(status: 401, body: #"{"message":"Expired"}"#) }
            return .init(body: "data: {\"line\":\"ready\"}\n\n")
        }
        let api = WorkloadsAPI(transport: transport(auth: .bearerSession { $0 ? "fresh" : "old" }), workspaceId: "w1")
        var lines: [String] = []
        for try await batch in api.logsStream("job") { lines += batch.entries.map(\.line) }
        XCTAssertEqual(lines, ["ready"])
        XCTAssertEqual(requests.values.count, 2)
    }

    func testWorkloadStatsDecodeGatewayBatchesAndLegacyDirectRecords() async throws {
        let requests = RequestStore()
        ControlURLProtocol.handler = { request in
            requests.append(request)
            return .init(body: "data: {\"type\":\"subscribed\",\"vm_id\":\"workspace\"}\n\ndata: {\"type\":\"stats\",\"0\":{\"id\":7,\"state\":\"running\",\"cpu_percent\":0,\"rss_bytes\":\"4096\",\"pid\":42,\"ports\":[3000],\"new_measurement\":3}}\n\n")
        }
        let api = WorkloadsAPI(transport: transport(), workspaceId: "workspace")
        var measurements: [WorkloadProcessStats] = []
        for try await batch in api.processStatsStream() { measurements += batch }
        let measurement = try XCTUnwrap(measurements.first)
        XCTAssertEqual(measurement.id, "7")
        XCTAssertEqual(measurement.cpuPercent, 0)
        XCTAssertEqual(measurement.memoryBytes, 4096)
        XCTAssertEqual(measurement.pid, 42)
        XCTAssertEqual(measurement.ports, [3000])
        XCTAssertEqual(measurement.additionalProperties["new_measurement"], .number(3))
        XCTAssertEqual(requests.values.first?.url?.path, "/workspace/workspace/workloads/stats/stream")

        let legacy = try APIJSON.decode(JSONValue.self, Data(#"{"status":"running","cpu_usage":2.5,"memory_usage":1024}"#.utf8))
        let direct = try XCTUnwrap(WorkloadProcessStats.batch(legacy, fallbackID: "job")?.first)
        XCTAssertEqual(direct.id, "job")
        XCTAssertEqual(direct.cpuPercent, 2.5)
        XCTAssertEqual(direct.memoryBytes, 1024)
        XCTAssertThrowsError(try WorkloadProcessStats.batch(legacy))
        XCTAssertEqual(try WorkloadProcessStats.batch(.array([])), [])
        XCTAssertEqual(try WorkloadProcessStats.batch(.object(["type": .string("stats")])), [])
        XCTAssertNil(try WorkloadProcessStats.batch(.object(["event": .string("heartbeat")])))
        let envelope = try APIJSON.decode(JSONValue.self, Data(#"{"event":"stats","data":[{"id":"enveloped","cpu_percent":1}]}"#.utf8))
        XCTAssertEqual(try WorkloadProcessStats.batch(envelope)?.first?.id, "enveloped")
    }

    func testDesktopInspectionDoesNotEnableDisabledRuntime() async throws {
        let requests = RequestStore()
        ControlURLProtocol.handler = { request in requests.append(request); return .init(status: 403, body: #"{"code":"disabled","message":"Runtime access is disabled"}"#) }
        let runtime = RuntimeClient(transport: transport(), workspaceId: "w1", runtimeURL: URL(string: "https://runtime.test")!, ttl: 300, enableIfNeeded: false)
        do { _ = try await runtime.desktop.status(); XCTFail("Expected disabled access") } catch {}
        XCTAssertEqual(requests.values.count, 1)
        XCTAssertEqual(requests.values.first?.httpMethod, "GET")
        XCTAssertTrue(requests.values.first?.url?.path.hasSuffix("/token") == true)
    }
}

private final class RequestStore: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [URLRequest] = []
    var values: [URLRequest] { lock.lock(); defer { lock.unlock() }; return storage }
    func append(_ request: URLRequest) { lock.lock(); storage.append(request); lock.unlock() }
    func body(at index: Int) throws -> [String: Any] {
        let request = values[index]
        var data = request.httpBody ?? Data()
        if data.isEmpty, let stream = request.httpBodyStream {
            stream.open(); defer { stream.close() }
            var buffer = [UInt8](repeating: 0, count: 4096)
            while stream.hasBytesAvailable { let n = stream.read(&buffer, maxLength: buffer.count); if n <= 0 { break }; data.append(contentsOf: buffer.prefix(n)) }
        }
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }
}
private final class ControlURLProtocol: URLProtocol, @unchecked Sendable {
    struct Reply { var status = 200; var body: String }
    static var handler: ((URLRequest) throws -> Reply)?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            let reply = try XCTUnwrap(Self.handler)(request)
            let response = HTTPURLResponse(url: request.url!, statusCode: reply.status, httpVersion: "HTTP/1.1", headerFields: ["Content-Type":"application/json"])!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: Data(reply.body.utf8))
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
    override func stopLoading() {}
}
