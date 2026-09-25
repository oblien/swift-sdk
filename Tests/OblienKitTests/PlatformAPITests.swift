import Foundation
import XCTest
@testable import OblienKit
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class PlatformAPITests: XCTestCase {
    private var session: URLSession!
    private let records = HTTPRecords()
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [PlatformURLProtocol.self]
        session = URLSession(configuration: config)
    }
    override func tearDown() { session.invalidateAndCancel(); PlatformURLProtocol.handler = nil; super.tearDown() }
    private func client(auth: OblienAuth = .scopedToken("account-token"), retries: Int = 0) -> OblienClient {
        OblienClient(.init(auth: auth, baseURL: URL(string: "https://api.test")!, runtimeURL: URL(string: "https://runtime.test")!,
                           maxRetries: retries, cdnURL: URL(string: "https://cdn.test/api")!), session: session)
    }
    private func stub(_ reply: @escaping (URLRequest) throws -> PlatformURLProtocol.Reply) {
        PlatformURLProtocol.handler = { [records] request in records.append(request); return try reply(request) }
    }

    func testNamespaceMixedWireNamesAndExplicitNull() async throws {
        stub { _ in .json(#"{"success":true,"data":{"id":"ns1","client_id":"1","name":"Team","slug":"team","status":"active","type":"production","is_default":1,"created_at":"now","updated_at":"now"}}"#) }
        let namespace = try await client().namespaces.create(.init(name: "Team", isDefault: true,
            resourceLimits: .init(maxWorkspaces: .value(3), maxRamMb: .null)))
        XCTAssertTrue(namespace.isDefault)
        let body = try records.body(0)
        XCTAssertEqual(body["isDefault"] as? Bool, true)
        XCTAssertNil(body["is_default"])
        let limits = try XCTUnwrap(body["resource_limits"] as? [String: Any])
        XCTAssertEqual(limits["max_workspaces"] as? Int, 3)
        XCTAssertTrue(limits["max_ram_mb"] is NSNull)
        XCTAssertNil(limits["max_vcpus"])
        stub { _ in .json(#"{"success":true}"#) }
        _ = try await client().namespaces.delete("team/a?x=1", deleteWorkspaces: true)
        XCTAssertTrue(records.values.last!.url!.absoluteString.contains("team%2Fa%3Fx%3D1"))
        XCTAssertEqual(try records.body(1)["deleteWorkspaces"] as? Bool, true)
    }

    func testRoutesPreserveEveryActionAndCamelCaseFlags() async throws {
        stub { _ in .json(#"{"success":true,"hostname":"app.test","version":2,"config":{"v":1,"root":"/","flags":{}}}"#) }
        let rules: [RouteRule] = [
            .init(match: .init(path: "/api", type: .prefix), action: .proxy(.init(workspace: "ws1", port: 3000, stripPrefix: true))),
            .init(match: .init(path: "/old"), action: .redirect(.init(status: 308, to: "/new"))),
            .init(match: .init(path: "/app"), action: .rewrite(.init(to: "/index.html"))),
            .init(match: .init(path: "/"), action: .headers(.init(set: [.init(key: "X-Test", value: "yes")])) )
        ]
        var input = RoutesInput(routes: rules, cleanUrls: true, trailingSlash: "strip", spa: true)
        input.static = .init(page: "web")
        _ = try await client().routes.set("app.test", input)
        let body = try records.body(0)
        XCTAssertEqual(body["cleanUrls"] as? Bool, true)
        XCTAssertNil(body["clean_urls"])
        XCTAssertEqual((body["static"] as? [String: String])?["page"], "web")
        let encodedRules = try XCTUnwrap(body["routes"] as? [[String: Any]])
        XCTAssertEqual((encodedRules[0]["action"] as? [String: Any])?["stripPrefix"] as? Bool, true)
        XCTAssertEqual(encodedRules.compactMap { ($0["action"] as? [String: Any])?["kind"] as? String }, ["proxy", "redirect", "rewrite", "headers"])
    }

    func testCDNUploadSeparatesAccountAndEdgeCredentials() async throws {
        stub { request in
            if request.url!.host == "api.test" {
                return .json(#"{"success":true,"token":"cdn-scoped","scope":"user","permissions":["upload"],"namespace":"team","expiresIn":"1h"}"#)
            }
            return .json(#"{"success":true,"file_id":"1","url":"https://cdn.test/file","filename":"sample.txt","size":5,"mime":"text/plain","variants":[],"recorded":true}"#)
        }
        let result = try await client().cdn.upload(.init(data: Data("hello".utf8), filename: "sample.txt", contentType: "text/plain"),
            .init(namespace: "team", variants: .init(keepOriginal: true), tag: "test"))
        XCTAssertEqual(result.fileId, "1")
        XCTAssertEqual(records.values.map { $0.value(forHTTPHeaderField: "Authorization") }, ["Bearer account-token", "Bearer cdn-scoped"])
        XCTAssertEqual(URLComponents(url: records.values[1].url!, resolvingAgainstBaseURL: false)?.percentEncodedPath, "/api/")
        XCTAssertTrue(records.values[1].value(forHTTPHeaderField: "Content-Type")!.contains("multipart/form-data; boundary="))
        let upload = String(decoding: records.bodies[1], as: UTF8.self)
        XCTAssertTrue(upload.contains("name=\"file\"; filename=\"sample.txt\""))
        XCTAssertTrue(upload.contains("\r\n\r\nhello\r\n"))
        XCTAssertFalse(upload.contains("account-token"))
        let tokenBody = try records.body(0)
        XCTAssertEqual((tokenBody["variants"] as? [String: Any])?["keepOriginal"] as? Bool, true)
        XCTAssertNil((tokenBody["variants"] as? [String: Any])?["maxBytes"])
    }

    func testBillingNullPatchIsCamelCaseAndMutationsDoNotReplay() async throws {
        stub { _ in .init(status: 503, bytes: Data(#"{"message":"Try later"}"#.utf8)) }
        do { _ = try await client(retries: 3).billing.setPolicy("team/a", .init(quotaLimit: .null, overdraft: 4)); XCTFail("Expected failure") }
        catch let error as OblienError { XCTAssertEqual(error.status, 503) }
        XCTAssertEqual(records.values.count, 1)
        let body = try records.body(0)
        XCTAssertTrue(body["quotaLimit"] is NSNull)
        XCTAssertNil(body["quota_limit"])
        XCTAssertNil(body["suspendThreshold"])
    }

    func testPushSendUsesOnlyTheSendTokenAndReturnsDeliveryErrors() async throws {
        stub { _ in .json(#"{"success":true,"delivered":0,"failed":1,"devices":1,"errors":[{"code":"messaging/invalid-argument","message":"Invalid","count":1}]}"#) }
        let result = try await client(auth: .bearerSession { _ in XCTFail("Must not acquire a user token to send"); return "bad" })
            .notifications.send(token: "send-only", .init(title: "Ready", data: ["chat_id": .string("c1")]))
        XCTAssertEqual(result.errors?.first?.count, 1)
        XCTAssertEqual(records.values[0].value(forHTTPHeaderField: "Authorization"), "Bearer send-only")
    }

    func testExecStreamsJSONEnvelopesWithBase64OutputAndAllOptions() async throws {
        stub { _ in .init(bytes: Data("event: task_id\ndata: {\"task_id\":\"7\"}\n\nevent: stdout\ndata: {\"data\":\"zrEgcmVhZHkNCg==\"}\n\nevent: exit\ndata: {\"exit_code\":0,\"pid\":42}\n\n".utf8), contentType: "text/event-stream") }
        let runtime = RuntimeClient(token: "runtime", baseURL: URL(string: "https://runtime.test")!, session: session)
        var events: [ExecStreamEvent] = []
        for try await event in runtime.exec.stream(["echo", "α ready"], timeoutSeconds: 20, execMode: .direct, ttlSeconds: 30, keepLogs: false) { events.append(event) }
        XCTAssertEqual(events.map(\.kind), [.taskId, .stdout, .exit])
        XCTAssertEqual(events[0].taskId, "7")
        XCTAssertEqual(events[1].text, "α ready\r\n")
        XCTAssertEqual(events[2].pid, 42)
        XCTAssertEqual(events[2].exitCode, 0)
        XCTAssertEqual(records.values[0].url!.path, "/exec/stream")
        let body = try records.body(0)
        XCTAssertEqual(body["keep_logs"] as? Bool, false)
        XCTAssertEqual(body["exec_mode"] as? String, "direct")
        XCTAssertEqual(body["ttl_seconds"] as? Int, 30)
        for try await _ in runtime.exec.subscribe("7") { }
        XCTAssertEqual(records.values[1].httpMethod, "GET")
        XCTAssertEqual(URLComponents(url: records.values[1].url!, resolvingAgainstBaseURL: false)?.queryItems?.first?.value, "7")
    }

    func testProxyPreservesUpstream401WithoutRepeatingPOST() async throws {
        stub { _ in .init(status: 401, bytes: Data("upstream unauthorized".utf8), headers: ["WWW-Authenticate": "Basic realm=test"]) }
        let runtime = RuntimeClient(token: "runtime", baseURL: URL(string: "https://runtime.test")!, session: session)
        let proxy = runtime.proxy(3000, host: "127.0.0.1")
        let result = try await proxy.fetch("/hello?q=a", method: "POST", body: Data("payload".utf8), contentType: "text/plain")
        XCTAssertEqual(result.status, 401)
        XCTAssertEqual(String(decoding: result.body, as: UTF8.self), "upstream unauthorized")
        XCTAssertEqual(records.values.count, 1)
        XCTAssertEqual(records.values[0].url!.path, "/proxy/hello")
        XCTAssertEqual(records.values[0].value(forHTTPHeaderField: "X-Oblien-Proxy-Target"), "127.0.0.1:3000")
        let request = try await proxy.webSocketRequest(path: "/socket", protocols: ["events"])
        XCTAssertEqual(request.url!.scheme, "wss")
        XCTAssertFalse(request.url!.absoluteString.contains("runtime" + "&token"))
        XCTAssertNil(URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems?.first { $0.name == "token" })
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer runtime")
    }

    func testRuntimeTargetsShareCredentialsAndDesktopStaysAtRoot() async throws {
        stub { request in
            switch request.url!.path {
            case "/workspace/ws/runtime-api-access": return .json(#"{"enabled":true}"#)
            case "/workspace/ws/runtime-api-access/token": return .json(#"{"token":"runtime"}"#)
            case "/runtimes/macos/exec": return .json(#"{"id":"1","stdout":"ready","exit_code":0}"#)
            case "/desktop/status": return .json(#"{"supported":true,"enabled":true,"available":true,"credentials":false}"#)
            default: XCTFail("Unexpected path \(request.url!.path)"); return .json("{}")
            }
        }
        let client = client()
        let first = try await client.workspace("ws").runtime()
        let second = try await client.workspace("ws").runtime()
        XCTAssertTrue(first === second)
        let mac = try first.forTarget("macos")
        async let a = mac.exec.run(["echo", "1"])
        async let b = mac.exec.run(["echo", "2"])
        _ = try await (a, b)
        _ = try await mac.desktop.status()
        XCTAssertEqual(records.values.filter { $0.url!.path.hasSuffix("/token") }.count, 1)
        XCTAssertFalse(records.values.contains { $0.url!.path.hasSuffix("/enable") })
        XCTAssertEqual(mac.websocketURL().path, "/runtimes/macos/ws")
    }

    func testAllFileListingOptionsAndDeletionMethod() async throws {
        stub { request in request.url!.path == "/files" ? .json(#"{"path":"/","entries":[],"count":0}"#) : .json(#"{"success":true}"#) }
        let runtime = RuntimeClient(token: "runtime", baseURL: URL(string: "https://runtime.test")!, session: session)
        _ = try await runtime.files.list(.init(path: "/a b", nested: true, includeContent: true, maxDepth: 4,
            useGitignore: false, ignorePatterns: ".git", light: false, flatten: true, includeHash: true,
            includeExtensions: true, codeFilesOnly: true, pathFilter: "src", includeExt: "swift", maxContentBudget: 5000))
        let query = Dictionary(uniqueKeysWithValues: URLComponents(url: records.values[0].url!, resolvingAgainstBaseURL: false)!.queryItems!.map { ($0.name, $0.value!) })
        XCTAssertEqual(query.count, 14)
        XCTAssertEqual(query["use_gitignore"], "false")
        XCTAssertEqual(query["max_content_budget"], "5000")
        try await runtime.files.delete(path: "/a b/file")
        XCTAssertEqual(records.values[1].httpMethod, "POST")
        XCTAssertEqual(try records.body(1)["path"] as? String, "/a b/file")
    }

    func testTransferUsesBinaryStreamAndExtractsUploadResult() async throws {
        let archive = Data([0x1f, 0x8b, 0x08, 0x00])
        stub { request in
            if request.url!.path.hasSuffix("/download") { return .init(bytes: archive, contentType: "application/gzip", headers: ["Content-Length": "4"]) }
            return .json(#"{"success":true,"dest":"/data","files_extracted":2}"#)
        }
        let runtime = RuntimeClient(token: "runtime", baseURL: URL(string: "https://runtime.test")!, session: session)
        let response = try await runtime.transfer.download(paths: ["/data"], excludePatterns: ["*.cache"])
        var received = Data()
        for try await chunk in response.chunks { received.append(chunk) }
        XCTAssertEqual(received, archive)
        XCTAssertEqual(response.totalBytes, 4)
        XCTAssertEqual(records.values[0].value(forHTTPHeaderField: "Accept"), "application/gzip")
        let result = try await runtime.transfer.upload(dest: "/data", tarGz: archive)
        XCTAssertEqual(result.filesExtracted, 2)
        XCTAssertEqual(records.values[1].value(forHTTPHeaderField: "Content-Type"), "application/gzip")
        XCTAssertEqual(records.values[1].value(forHTTPHeaderField: "Authorization"), "Bearer runtime")
    }

    func testWorkspaceCreationOptionsAreFlattenedAndFailureIsStructured() async throws {
        stub { request in
            if request.httpMethod == "POST" { return .json(#"{"workspace":{"id":"ws","ready":false,"provisioning":{"state":"queued","phase":"queued","error":null}}}"#) }
            return .json(#"{"workspace":{"id":"ws","provisioning":{"state":"failed","phase":"failed","error":{"code":"SETUP_FAILED","message":"Preparation failed"}}}}"#)
        }
        let client = client()
        _ = try await client.workspaces.create(.init(image: "test", config: .init(cpus: 1, env: [.init(key: "VALUE", value: "a=b")],
            idle: .init(suspendAfter: .string("15m")), macos: .init(storage: "nvme"), command: "echo ready",
            additionalProperties: ["future_option": .bool(true)]), waitReady: false, idempotencyKey: "stable", cpus: 4))
        let body = try records.body(0), config = try XCTUnwrap(body["config"] as? [String: Any])
        XCTAssertNil(body["cpus"])
        XCTAssertEqual(config["cpus"] as? Int, 4)
        XCTAssertEqual(config["cmd"] as? String, "echo ready")
        XCTAssertEqual(config["env"] as? [String], ["VALUE=a=b"])
        XCTAssertEqual(config["future_option"] as? Bool, true)
        do { _ = try await client.workspaces.waitUntilReady("ws", options: .init(timeout: 1, pollInterval: 0.01)); XCTFail("Expected provisioning failure") }
        catch let error as OblienError { XCTAssertEqual(error.code, "SETUP_FAILED") }
    }

    func testMultiplexedSocketDeliversTerminalAndWatcherEvents() throws {
        let mux = TerminalMux(webSocketURL: URL(string: "wss://runtime.test/ws")!, token: "test")
        var output = Data(), exited = false, overflow = false, invalid = false
        mux.attach(3) { output.append($0) }
        mux.onTerminalExit = { id, code in exited = id == 3 && code == 0 }
        mux.onWatcherEvent = { event in if case .overflow(let value) = event { overflow = value.watcherId == "watch1" } }
        mux.onError = { _ in invalid = true }
        mux.handle(.data(Data([3, 65, 66])))
        mux.handle(.string(#"{"channel":"terminal","type":"exit","id":"3","code":0}"#))
        mux.handle(.string(#"{"channel":"watcher","type":"overflow","watcher_id":"watch1","message":"Rescan"}"#))
        XCTAssertEqual(output, Data("AB".utf8)); XCTAssertTrue(exited); XCTAssertTrue(overflow)
        mux.send(259, Data("wrong terminal".utf8))
        XCTAssertTrue(invalid)
    }

    func testDatabaseRepresentationsDoNotSilentlyEmptyResults() throws {
        let events = try APIJSON.decode(Webhook.self, Data(#"{"id":1,"url":"https://test/hook","events":"[\"vm.stopped\"]","active":1}"#.utf8))
        XCTAssertTrue(events.active)
        XCTAssertEqual(events.events.first?.rawValue, "vm.stopped")
        let stats = try APIJSON.decode(CdnStats.self, Data(#"{"totalFiles":1,"totalSize":"100","activeFiles":"1","activeSize":"100","uploadedFiles":"1","urlFiles":"0"}"#.utf8))
        XCTAssertEqual(stats.totalSize, 100)
        XCTAssertThrowsError(try APIJSON.decode(CdnStats.self, Data(#"{"totalFiles":"not a number"}"#.utf8)))
    }

    func testChangingIdentityDoesNotChangeAnExistingHandle() async throws {
        stub { _ in .json(#"{"workspace":{"id":"ws"}}"#) }
        var client = client()
        let old = client.workspace("ws")
        client.setToken("tenant-token")
        _ = try await client.workspace("ws").get()
        _ = try await old.get()
        client.restoreAuth()
        _ = try await client.workspace("ws").get()
        XCTAssertEqual(records.values.map { $0.value(forHTTPHeaderField: "Authorization") }, ["Bearer tenant-token", "Bearer account-token", "Bearer account-token"])
    }

    func testRawProxyStreamPreservesErrorsHeadersAndBytes() async throws {
        stub { _ in .init(status: 401, bytes: Data([0, 255, 10]), contentType: "application/octet-stream", headers: ["X-Upstream": "denied"]) }
        let runtime = RuntimeClient(token: "runtime-token", baseURL: URL(string: "https://runtime.test")!, session: session)
        let response = try await runtime.proxy(3047).fetchStream("/events", method: "POST", headers: ["Accept": "application/octet-stream"], body: Data("request".utf8))
        var data = Data()
        for try await chunk in response.chunks { data.append(chunk) }
        XCTAssertEqual(response.status, 401)
        XCTAssertEqual(data, Data([0, 255, 10]))
        XCTAssertEqual(response.headers.first { $0.key.lowercased() == "x-upstream" }?.value, "denied")
        XCTAssertEqual(records.values.count, 1)
        XCTAssertEqual(records.values[0].value(forHTTPHeaderField: "Accept"), "application/octet-stream")
    }

    func testRedirectPoliciesAndCrossOriginCredentialRemoval() throws {
        let task = session.dataTask(with: URL(string: "https://runtime.test/proxy/start")!)
        defer { task.cancel() }
        let response = HTTPURLResponse(url: task.originalRequest!.url!, statusCode: 302, httpVersion: "HTTP/1.1", headerFields: nil)!
        var redirected = URLRequest(url: URL(string: "https://external.test/landing")!)
        for name in ["Authorization", "X-Client-ID", "X-Client-Secret", "X-Oblien-Proxy-Target"] { redirected.setValue("secret", forHTTPHeaderField: name) }
        let follow = HTTPRedirectDelegate(policy: .follow)
        follow.urlSession(session, task: task, willPerformHTTPRedirection: response, newRequest: redirected) { request in
            XCTAssertNotNil(request)
            XCTAssertNil(request?.value(forHTTPHeaderField: "Authorization"))
            XCTAssertNil(request?.value(forHTTPHeaderField: "X-Client-Secret"))
            XCTAssertNil(request?.value(forHTTPHeaderField: "X-Oblien-Proxy-Target"))
        }
        for policy in [HTTPRedirectPolicy.manual, .error] {
            let delegate = HTTPRedirectDelegate(policy: policy)
            delegate.urlSession(session, task: task, willPerformHTTPRedirection: response, newRequest: redirected) { XCTAssertNil($0) }
            XCTAssertEqual(delegate.redirectFailure != nil, policy == .error)
        }
    }

    func testNativeStreamUploadAndExecInputRetainOperationResults() async throws {
        stub { request in
            if request.url!.path.contains("/input") { return .json(#"{"success":true,"bytes_written":3}"#) }
            return .json(#"{"success":true,"dest":"/tmp","files_extracted":2}"#)
        }
        let runtime = RuntimeClient(token: "runtime-token", baseURL: URL(string: "https://runtime.test")!, session: session)
        let result = try await runtime.transfer.upload(dest: "/tmp", totalBytes: 3, stream: { InputStream(data: Data([1, 2, 3])) })
        XCTAssertEqual(result.filesExtracted, 2)
        XCTAssertEqual(records.bodies[0], Data([1, 2, 3]))
        XCTAssertEqual(records.values[0].value(forHTTPHeaderField: "Content-Length"), "3")
        let written = try await runtime.exec.input("7", "abc")
        XCTAssertEqual(written["bytes_written"]?.intValue, 3)
        XCTAssertEqual(records.values[1].value(forHTTPHeaderField: "Content-Type"), "application/octet-stream")
    }

    func testTypedMetadataEnvelopeAndMalformedArchiveList() async throws {
        stub { _ in .json(#"{"success":true}"#) }
        _ = try await client().workspace("ws").metadata.patch(metadata: ["project": "one"])
        XCTAssertEqual(try records.body(0)["metadata"] as? [String: String], ["project": "one"])
        do { _ = try await client().workspaces.archived(); XCTFail("Malformed archive results must not look empty") }
        catch let error as OblienError { XCTAssertEqual(error.kind, .decoding) }
    }

    func testExtensibleWorkspaceModelsPreserveUnknownFields() throws {
        let network = try OblienJSON.decode(Network.self, Data(#"{"allow_internet":true,"new_control":{"enabled":true},"futureCamelOption":{"keepKey":1}}"#.utf8))
        XCTAssertEqual(network.allowInternet, true)
        XCTAssertEqual(network.additionalProperties["new_control"]?["enabled"]?.boolValue, true)
        let encoded = try JSONDecoder().decode(JSONValue.self, from: OblienJSON.encode(network))
        XCTAssertEqual(encoded["futureCamelOption"]?["keepKey"]?.intValue, 1)
        let domain = try OblienJSON.decode(DomainInfo.self, Data(#"{"customDomain":"app.test","includeWww":true,"sslStatus":"active","new_control":1}"#.utf8))
        XCTAssertEqual(domain.customDomain, "app.test")
        XCTAssertEqual(domain.includeWww, true)
        XCTAssertEqual(domain.additionalProperties["new_control"]?.intValue, 1)
        let terminal = try OblienJSON.decode(TerminalCreateResult.self, Data(#"{"id":"4","alive":true,"scrollback_size":65536,"exit_code":0}"#.utf8))
        XCTAssertEqual(terminal.scrollbackSize, 65536)
        XCTAssertEqual(terminal.alive, true)
    }

    func testRuntimeSocketWaitsForCallbacksBeforeConnecting() async throws {
        let runtime = RuntimeClient(token: "runtime-token", baseURL: URL(string: "https://runtime.test")!, session: session)
        let mux = try await runtime.ws()
        let tasks = await session.allTasks
        XCTAssertTrue(tasks.isEmpty, "Creating a socket must leave time to install callbacks before the connection starts")
        XCTAssertFalse(mux.connected)
    }

    func testWorkspaceQuotaIncludesPoolsAndTypedCreditEstimate() async throws {
        stub { request in
            if request.url!.path.hasSuffix("quota") {
                return .json(#"{"plan":"pro","planLabel":"Pro","canCreate":true,"maxWorkspaces":10,"currentWorkspaces":2,"limits":{"cpus":8,"memory_mb":16384},"pool_usage":{"count":2,"cpus":4,"memory_mb":4096,"disk_size_mb":40960},"running_pool":{"cpus":16},"running_pool_usage":{"cpus":2},"new_limit":12}"#)
            }
            return .json(#"{"estimate":{"min":1,"avg":2,"max":3},"period":"hour"}"#)
        }
        let api = client().workspaces
        let quota = try await api.getQuota()
        XCTAssertEqual(quota.planLabel, "Pro")
        XCTAssertEqual(quota.maxWorkspaces, 10)
        XCTAssertEqual(quota.poolUsage?.memoryMb, 4096)
        XCTAssertEqual(quota.runningPool?.cpus, 16)
        XCTAssertEqual(quota.additionalProperties["new_limit"]?.intValue, 12)
        let estimate = try await api.estimate(cpu: 2, ramMb: 4096, diskMb: 20480)
        XCTAssertEqual(estimate.estimate.avg, 2)
        XCTAssertTrue(records.values[1].url!.absoluteString.contains("ram_mb=4096"))
    }

    func testReleasingMuxDoesNotLeaveTheSocketRetainingItsOwner() {
        weak var reference: TerminalMux?
        let socketSession = URLSession(configuration: .ephemeral)
        defer { socketSession.invalidateAndCancel() }
        autoreleasepool {
            let mux = TerminalMux(webSocketURL: URL(string: "ws://127.0.0.1:1/ws")!, token: "test", session: socketSession)
            reference = mux
            mux.connect()
        }
        XCTAssertNil(reference)
    }
}

private final class HTTPRecords: @unchecked Sendable {
    private let lock = NSLock()
    private var requests: [URLRequest] = []
    private var data: [Data] = []
    var values: [URLRequest] { lock.lock(); defer { lock.unlock() }; return requests }
    var bodies: [Data] { lock.lock(); defer { lock.unlock() }; return data }
    func append(_ request: URLRequest) {
        var body = request.httpBody ?? Data()
        if body.isEmpty, let stream = request.httpBodyStream {
            stream.open(); defer { stream.close() }
            var bytes = [UInt8](repeating: 0, count: 4096)
            while stream.hasBytesAvailable { let n = stream.read(&bytes, maxLength: bytes.count); if n <= 0 { break }; body.append(contentsOf: bytes.prefix(n)) }
        }
        lock.lock(); requests.append(request); data.append(body); lock.unlock()
    }
    func body(_ index: Int) throws -> [String: Any] { try XCTUnwrap(JSONSerialization.jsonObject(with: bodies[index]) as? [String: Any]) }
}
private final class PlatformURLProtocol: URLProtocol, @unchecked Sendable {
    struct Reply {
        var status = 200
        var bytes: Data
        var contentType = "application/json"
        var headers: [String: String] = [:]
        static func json(_ value: String) -> Reply { .init(bytes: Data(value.utf8)) }
    }
    static var handler: ((URLRequest) throws -> Reply)?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            let reply = try XCTUnwrap(Self.handler)(request)
            var headers = reply.headers; headers["Content-Type"] = reply.contentType
            let response = HTTPURLResponse(url: request.url!, statusCode: reply.status, httpVersion: "HTTP/1.1", headerFields: headers)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: reply.bytes)
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
    override func stopLoading() {}
}
