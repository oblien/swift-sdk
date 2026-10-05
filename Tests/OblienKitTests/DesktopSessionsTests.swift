import XCTest
@testable import OblienKit
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class DesktopSessionsTests: XCTestCase {
    private let id = "ds_0123456789abcdef"
    private let sessionJSON = #"{"id":"ds_0123456789abcdef","name":"Project","state":"running","managed":true,"available":true,"resolution":{"width":1280,"height":800}}"#
    override func tearDown() { SessionURLProtocol.handler = nil; super.tearDown() }
    private func client(retries: Int = 0) -> OblienClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [SessionURLProtocol.self]
        return OblienClient(.init(auth: .scopedToken("account-test"), baseURL: URL(string: "https://api.test")!,
            runtimeURL: URL(string: "https://workspace.oblien.com")!, maxRetries: retries), session: URLSession(configuration: config))
    }

    func testSavedSessionLifecycleAndSessionBoundSSHGrant() async throws {
        let store = SessionRequests()
        let sessionJSON = sessionJSON
        SessionURLProtocol.handler = { request in
            store.append(request)
            if request.url!.path.hasSuffix("/ssh") {
                return .init(body: #"{"session_id":"ds_0123456789abcdef","expires_at":"2026-10-04T23:00:00Z","ssh":{"host":"ssh.oblien.com","port":22,"username":"desktop","password":"test-only","host_key_fingerprint":"SHA256:test"},"vnc":{"host":"127.0.0.1","port":5900,"authentication":"none"}}"#)
            }
            if request.httpMethod == "GET", request.url!.path.hasSuffix("/sessions") {
                return .init(body: #"{"success":true,"sessions":[],"capabilities":{"mode":"virtual","max_sessions":10,"can_create":true,"resolution":{"min":{"width":640,"height":480},"max":{"width":3840,"height":2160},"default":{"width":1280,"height":800}}}}"#)
            }
            return .init(body: "{\"success\":true,\"session\":" + sessionJSON + "}")
        }
        let desktop = client().workspace("workspace1").desktop
        let catalog = try await desktop.sessions.list()
        XCTAssertEqual(catalog.capabilities.resolution?.default.width, 1280)
        _ = try await desktop.createSession(.init(name: "Project", resolution: .init(width: 1280, height: 800), idempotencyKey: "project-key"))
        _ = try await desktop.getSession(id)
        _ = try await desktop.updateSession(id, .init(resolution: .init(width: 1440, height: 900)))
        _ = try await desktop.startSession(id)
        _ = try await desktop.stopSession(id)
        let grant = try await desktop.sshConnection(sessionId: id)
        XCTAssertEqual(grant.sessionId, id)
        _ = try await desktop.deleteSession(id)
        XCTAssertEqual(store.values.map { $0.httpMethod! }, ["GET", "POST", "GET", "PATCH", "POST", "POST", "POST", "DELETE"])
        XCTAssertEqual(store.values[4].url!.path, "/workspace/workspace1/desktop/sessions/\(id)/start")
        XCTAssertEqual(try store.body(1)["idempotency_key"] as? String, "project-key")
        XCTAssertEqual(try store.body(6)["session_id"] as? String, id)
        XCTAssertEqual(store.values.filter { $0.httpMethod == "POST" && $0.url!.path.hasSuffix("/sessions") }.count, 1)
    }

    func testAccountSelectionIsIsolatedAndNeverSentToRuntime() async throws {
        let requests = SessionRequests()
        SessionURLProtocol.handler = { request in
            requests.append(request)
            switch request.url!.path {
            case "/workspace/workspace1/runtime-api-access/token": return .init(body: #"{"token":"runtime-test"}"#)
            case "/workspace/workspace1/runtime-api-access": return .init(body: #"{"enabled":true}"#)
            case "/desktop/status": return .init(body: #"{"supported":true,"enabled":true,"available":true,"credentials":false}"#)
            default: return .init(body: #"{"workspaces":[]}"#)
            }
        }
        let owner = client()
        let shared = try owner.withAccount("123")
        _ = try await shared.workspaces.list()
        _ = try await owner.workspaces.list()
        let runtime = try await shared.workspace("workspace1").runtime()
        _ = try await runtime.desktop.status()
        XCTAssertEqual(requests.values[0].value(forHTTPHeaderField: "X-Oblien-Account"), "123")
        XCTAssertNil(requests.values[1].value(forHTTPHeaderField: "X-Oblien-Account"))
        let last = try XCTUnwrap(requests.values.last)
        XCTAssertNil(last.value(forHTTPHeaderField: "X-Oblien-Account"))
        XCTAssertEqual(last.value(forHTTPHeaderField: "Authorization"), "Bearer runtime-test")
        XCTAssertThrowsError(try owner.withAccount("../123"))
    }

    func testRuntimeSessionsStayAtRootAndUseHeaderAuthForNativeVideo() async throws {
        let requests = SessionRequests()
        let sessionJSON = sessionJSON
        SessionURLProtocol.handler = { request in
            requests.append(request)
            return .init(body: "{\"success\":true,\"session\":" + sessionJSON + "}")
        }
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [SessionURLProtocol.self]
        let runtime = try RuntimeClient(token: "a+b/c=", session: URLSession(configuration: config)).forTarget("linux")
        _ = try await runtime.desktop.sessions.get(id)
        XCTAssertEqual(requests.values[0].url!.path, "/desktop/sessions/\(id)")
        let socket = try await runtime.desktop.webSocketRequest(sessionId: id)
        XCTAssertEqual(socket.url!.path, "/desktop/sessions/\(id)/ws")
        XCTAssertNil(socket.url!.query)
        XCTAssertEqual(socket.value(forHTTPHeaderField: "Authorization"), "Bearer a+b/c=")
        XCTAssertEqual(socket.value(forHTTPHeaderField: "Sec-WebSocket-Protocol"), "binary")
        let viewer = try await runtime.desktop.url(sessionId: id)
        XCTAssertNil(viewer.query)
        var fragment = URLComponents(); fragment.percentEncodedQuery = viewer.fragment
        XCTAssertEqual(fragment.queryItems?.first { $0.name == "token" }?.value, "a+b/c=")
        XCTAssertEqual(fragment.queryItems?.first { $0.name == "session" }?.value, id)
        do { _ = try await runtime.desktop.getSession("../../token"); XCTFail("Invalid ID accepted") } catch {}
        XCTAssertEqual(requests.values.count, 1)
    }

    func testConsoleCreationOmitsResolutionAndDeletionCanBeAsynchronous() async throws {
        let requests = SessionRequests()
        SessionURLProtocol.handler = { request in
            requests.append(request)
            return .init(body: #"{"success":true,"session":{"id":"console","name":"Mac","state":"deleting","available":false,"managed":false,"can_resize":false}}"#)
        }
        let desktop = client().workspace("workspace1").desktop
        _ = try await desktop.createSession(.init(name: "Mac", idempotencyKey: "console-key"))
        let result = try await desktop.deleteSession("console")
        XCTAssertEqual(result.session?.state, "deleting")
        XCTAssertEqual(result.session?.canResize, false)
        XCTAssertNil(try requests.body(0)["resolution"])
    }

    func testTerminalHistoryRequiresRealAcknowledgment() async throws {
        let requests = SessionRequests()
        SessionURLProtocol.handler = { request in
            requests.append(request)
            if request.httpMethod == "DELETE" { return .init(body: #"{"success":true,"terminal_id":"7","scrollback_size":65536}"#) }
            return .init(body: #"{"success":true,"terminal_id":"wrong","scrollback_size":65536}"#)
        }
        let config = URLSessionConfiguration.ephemeral; config.protocolClasses = [SessionURLProtocol.self]
        let runtime = RuntimeClient(token: "runtime", session: URLSession(configuration: config))
        _ = try await runtime.terminal.clearScrollback(7)
        do { _ = try await runtime.terminal.configureScrollback(7, bytes: 0); XCTFail("Wrong terminal accepted") }
        catch let error as OblienError { XCTAssertEqual(error.code, "runtime_upgrade_required") }
        XCTAssertEqual(try requests.body(1)["scrollback_size"] as? Int, 0)
    }

    func testNewDiskAndWorkspaceFieldsRoundTrip() throws {
        let operation = try OblienJSON.decode(DiskOperation.self, Data(#"{"id":"op","state":"failed","kind":"resize","disk_id":"disk","error":{"code":"capacity","message":"No space"},"result":{"was_running":true,"relaunched":false,"warning":"kept files"}}"#.utf8))
        XCTAssertEqual(operation.error, "No space")
        XCTAssertEqual(operation.errorCode, "capacity")
        XCTAssertEqual(operation.result?.warning, "kept files")
        XCTAssertEqual(try OblienJSON.decode(DiskOperation.self, OblienJSON.encode(operation)).errorCode, "capacity")
        let workspace = try OblienJSON.decode(Workspace.self, Data(#"{"id":"w","owner":{"id":"1","name":"Owner"},"sharing":{"owner_id":"1","actor_id":"2","role":"developer","permissions":["desktop"]},"base_os":{"family":"linux","distribution":"ubuntu","version":"24.04"},"preset":{"id":"desktop","revision":"2","label":"Desktop","base_image":"ubuntu","software":[{"id":"gui","label":"GUI","read_only":true,"size_mb":100}]},"config":{"macos":{"warm_boot":"off"}}}"#.utf8))
        XCTAssertEqual(workspace.sharing?.role, "developer")
        XCTAssertEqual(workspace.preset?.software.first?.readOnly, true)
        XCTAssertEqual(workspace.baseOs?.distribution, "ubuntu")
        XCTAssertEqual(try OblienJSON.decode(Workspace.self, OblienJSON.encode(workspace)).config?.macos?.warmBoot, "off")
    }

    func testAccessMemberPatchSupportsExplicitExpiryRemoval() async throws {
        let requests = SessionRequests()
        SessionURLProtocol.handler = { request in requests.append(request); return .init(body: #"{"success":true}"#) }
        _ = try await client().access.updateMember("member/1", role: "developer", version: "3", expiresAt: .null)
        XCTAssertTrue(requests.values[0].url!.absoluteString.contains("member%2F1"))
        let body = try requests.body(0)
        XCTAssertTrue(body["expires_at"] is NSNull)
        XCTAssertEqual(body["version"] as? String, "3")
    }

    func testSavedDesktopRetriesKeepTheSameKeyAndBody() async throws {
        let requests = SessionRequests()
        let sessionJSON = sessionJSON
        SessionURLProtocol.handler = { request in
            requests.append(request)
            if requests.values.count == 1 { return .init(status: 503, body: #"{"message":"Try again"}"#) }
            return .init(body: "{\"success\":true,\"session\":" + sessionJSON + "}")
        }
        let desktop = client(retries: 1).workspace("workspace1").desktop
        _ = try await desktop.createSession(.init(name: "Project", resolution: .init(width: 1280, height: 800), idempotencyKey: "same-create"))
        XCTAssertEqual(requests.values.count, 2)
        XCTAssertEqual(try requests.body(0) as NSDictionary, try requests.body(1) as NSDictionary)

        SessionURLProtocol.handler = { request in
            requests.append(request)
            return .init(status: 503, body: #"{"message":"Try again"}"#)
        }
        do { _ = try await desktop.createSession(.init(name: "Without a key")); XCTFail("Expected failure") } catch {}
        XCTAssertEqual(requests.values.count, 3, "Unkeyed creation must not replay")
    }

    func testCapacityBillingPreservesWireKeysAndFractionalCPU() async throws {
        let requests = SessionRequests()
        let quote = #"{"id":"q1","namespace":"team","status":"pending","action":"start","expiresAt":"2026-10-05T00:00:00Z","effectiveAt":"2026-10-04T00:00:00Z","periodEnd":null,"billingMode":"monthly","paymentSource":"wallet","currency":"usd","current":null,"capacity":{"vcpus":0.125,"memoryMb":512,"diskGb":10,"workspaces":1},"tariffId":"t1","monthlyAmount":125,"paygCapAmount":150,"unusedTimeCredit":0,"remainingTimeCharge":125,"amountDueNow":125,"walletCreditsRequired":12500,"retainedStorageAmountDue":0,"nextPaymentAmount":125,"autoRenew":false,"networkIncluded":false,"networkBytes":null,"preservesUsage":true,"preservesPurchasedCredits":true}"#
        SessionURLProtocol.handler = { request in
            requests.append(request)
            if request.url!.path.hasSuffix("/preview") {
                return .init(body: "{\"success\":true,\"namespace\":\"team\",\"quote\":" + quote + "}")
            }
            if request.url!.path.hasSuffix("/checkout") {
                return .init(body: #"{"success":true,"namespace":"team","checkoutId":"checkout1","url":"https://pay.test"}"#)
            }
            return .init(body: #"{"success":true,"namespace":"team","capacity":null,"pendingCheckout":null}"#)
        }
        let billing = client().billing
        let preview = try await billing.previewCapacity("team", .init(capacity: .init(vcpus: 0.125, memoryMb: 512, diskGb: 10, workspaces: 1), billingMode: .monthly, autoRenew: false, idempotencyKey: "preview-1"))
        XCTAssertEqual(preview.quote.capacity?.vcpus, 0.125)
        _ = try await billing.capacity("team")
        _ = try await billing.confirmCapacity("team", .init(quoteId: "q1", idempotencyKey: "confirm-1"))
        _ = try await billing.capacityCheckout("team", .init(successUrl: "https://return.test", allowPromotionCodes: false, quoteId: "q1", idempotencyKey: "checkout-1"))
        _ = try await billing.cancelCapacityChange("team", .init(quoteId: "q1", idempotencyKey: "cancel-1"))
        _ = try await billing.setCapacityAutoRenew("team", autoRenew: false, idempotencyKey: "renew-1")
        _ = try await billing.previewNetworkTopup("team", unitAmount: 2.5, idempotencyKey: "network-1")
        XCTAssertEqual(requests.values.map { $0.url!.path }, ["/billing/capacity/preview", "/billing/capacity", "/billing/capacity/confirm", "/billing/capacity/checkout", "/billing/capacity/change/cancel", "/billing/capacity/renewal", "/billing/capacity/network/preview"])
        let body = try requests.body(0)
        XCTAssertEqual(body["namespace"] as? String, "team")
        XCTAssertEqual((body["capacity"] as? [String: Any])?["vcpus"] as? Double, 0.125)
        XCTAssertEqual(body["billingMode"] as? String, "monthly")
        XCTAssertEqual(body["autoRenew"] as? Bool, false)
        XCTAssertNil(body["idempotency_key"])
        XCTAssertEqual(try requests.body(2)["quoteId"] as? String, "q1")
        XCTAssertEqual(try requests.body(3)["allowPromotionCodes"] as? Bool, false)
        XCTAssertEqual(try requests.body(5)["idempotencyKey"] as? String, "renew-1")
        XCTAssertEqual(try requests.body(6)["unitAmount"] as? Double, 2.5)
    }

    func testAccountHeaderIsRemovedOnCrossOriginRedirects() throws {
        let session = URLSession(configuration: .ephemeral)
        defer { session.invalidateAndCancel() }
        let origin = URL(string: "https://api.test/workspaces")!
        let response = HTTPURLResponse(url: origin, statusCode: 302, httpVersion: nil, headerFields: nil)!
        let delegate = HTTPRedirectDelegate(policy: .follow)
        var request = URLRequest(url: URL(string: "https://elsewhere.test/workspaces")!)
        request.setValue("123", forHTTPHeaderField: "X-Oblien-Account")
        request.setValue("Bearer test", forHTTPHeaderField: "Authorization")
        delegate.urlSession(session, task: session.dataTask(with: origin), willPerformHTTPRedirection: response, newRequest: request) {
            XCTAssertNil($0?.value(forHTTPHeaderField: "X-Oblien-Account"))
            XCTAssertNil($0?.value(forHTTPHeaderField: "Authorization"))
        }
        request.url = URL(string: "https://api.test/new-path")!
        delegate.urlSession(session, task: session.dataTask(with: origin), willPerformHTTPRedirection: response, newRequest: request) {
            XCTAssertEqual($0?.value(forHTTPHeaderField: "X-Oblien-Account"), "123")
        }
    }
}

private final class SessionRequests: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [URLRequest] = []
    var values: [URLRequest] { lock.lock(); defer { lock.unlock() }; return storage }
    func append(_ request: URLRequest) { lock.lock(); storage.append(request); lock.unlock() }
    func body(_ index: Int) throws -> [String: Any] {
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
private final class SessionURLProtocol: URLProtocol, @unchecked Sendable {
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
