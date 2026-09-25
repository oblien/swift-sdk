import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Per-workspace data-plane client (`workspace.oblien.com`). Lazily enables + caches the
/// gateway JWT (~55m) and refreshes it on a 401. Mirrors `const rt = await ws.runtime()`.
public actor RuntimeClient {
    private let transport: Transport
    let workspaceId: String
    private let runtimeURL: URL
    private var ttl: TimeInterval
    private let enableIfNeeded: Bool
    private let credentialSource: RuntimeClient?
    private let fixedToken: String?
    public nonisolated let target: String?
    private nonisolated var prefix: String { target.map { "/runtimes/\($0.pathEscaped)" } ?? "" }

    private var gatewayToken: String?
    private var expiresAt: Date = .distantPast
    private var tokenTask: Task<String, Error>?
    private var tokenGeneration = UUID()

    init(transport: Transport, workspaceId: String, runtimeURL: URL, ttl: TimeInterval, enableIfNeeded: Bool = true,
         target: String? = nil, credentialSource: RuntimeClient? = nil, fixedToken: String? = nil) {
        self.transport = transport
        self.workspaceId = workspaceId
        self.runtimeURL = runtimeURL
        self.ttl = ttl
        self.enableIfNeeded = enableIfNeeded
        self.target = target
        self.credentialSource = credentialSource
        self.fixedToken = fixedToken
    }

    /// Standalone data-plane client for an already-issued gateway token.
    public init(token: String, baseURL: URL = URL(string: "https://workspace.oblien.com")!, session: URLSession = .shared) {
        let config = OblienConfiguration(auth: .scopedToken(token), runtimeURL: baseURL)
        self.transport = Transport(config: config, session: session)
        self.workspaceId = ""
        self.runtimeURL = baseURL
        self.ttl = config.runtimeTokenTTL
        self.enableIfNeeded = false
        self.target = nil
        self.credentialSource = nil
        self.fixedToken = token
    }

    public func invalidate() async {
        if let credentialSource { await credentialSource.invalidate(); return }
        gatewayToken = nil; expiresAt = .distantPast
        tokenGeneration = UUID(); tokenTask?.cancel(); tokenTask = nil
    }

    func setTokenTTL(_ seconds: TimeInterval) { ttl = seconds; expiresAt = .distantPast }

    public nonisolated func forTarget(_ target: String) throws -> RuntimeClient {
        guard target.range(of: "^[a-z][a-z0-9_-]{0,63}$", options: .regularExpression) != nil else {
            throw OblienError(kind: .validation, status: nil, code: nil, message: "Invalid runtime target.", details: nil)
        }
        return RuntimeClient(transport: transport, workspaceId: workspaceId, runtimeURL: runtimeURL,
            ttl: 0, enableIfNeeded: enableIfNeeded, target: target == "default" ? nil : target,
            credentialSource: credentialSource ?? self)
    }

    public func info() async throws -> RuntimeInfo { try APIJSON.decode(RuntimeInfo.self, await perform("GET", "/runtime")) }
    public func targets() async throws -> RuntimeDiscovery {
        try APIJSON.decode(RuntimeDiscovery.self, await perform("GET", "/runtimes", root: true))
    }
    public func health() async throws -> Bool {
        do { return try APIJSON.decode(JSONValue.self, await perform("GET", "/health"))["status"]?.stringValue == "ok" }
        catch { try Task.checkCancellation(); return false }
    }

    /// The current gateway JWT (enabling/refreshing as needed) — e.g. to build a terminal endpoint.
    public func token() async throws -> String { try await currentToken() }

    /// Current gateway JWT, enabling/refreshing as needed.
    func currentToken(force: Bool = false) async throws -> String {
        try Task.checkCancellation()
        if let credentialSource { return try await credentialSource.currentToken(force: force) }
        if let fixedToken { return fixedToken }
        if !force, let token = gatewayToken, Date() < expiresAt { return token }
        if let tokenTask { return try await tokenTask.value }
        let generation = tokenGeneration
        let access = RuntimeAccessAPI(transport: transport, workspaceId: workspaceId)
        let task = Task { [enableIfNeeded] in
            if enableIfNeeded {
                if try await access.status().enabled == true { return try await access.getToken().token }
                return try await access.enable().token
            }
            return try await access.getToken().token
        }
        tokenTask = task
        defer { if generation == tokenGeneration { tokenTask = nil } }
        let token = try await task.value
        guard generation == tokenGeneration else { throw CancellationError() }
        gatewayToken = token
        expiresAt = Date().addingTimeInterval(ttl)
        return token
    }

    private func refreshRejectedToken(_ token: String) async throws -> String {
        if let credentialSource { return try await credentialSource.refreshRejectedToken(token) }
        return try await currentToken(force: gatewayToken == token)
    }

    /// Authenticated runtime request, refreshing the gateway token once on 401.
    func perform(_ method: String, _ path: String, query: [String: String?] = [:], body: Data? = nil, contentType: String? = nil, root: Bool = false) async throws -> Data {
        let path = (root ? "" : prefix) + path
        let token = try await currentToken()
        do {
            return try await transport.request(method, path, query: query, body: body, host: .runtime, bearer: token, contentType: contentType)
        } catch let error as OblienError where error.status == 401 {
            let fresh = try await refreshRejectedToken(token)
            return try await transport.request(method, path, query: query, body: body, host: .runtime, bearer: fresh, contentType: contentType)
        }
    }

    /// Authenticated runtime byte-stream (SSE / NDJSON), refreshing the gateway token once on 401.
    func performStream(_ method: String, _ path: String, query: [String: String?] = [:], body: Data? = nil) async throws -> AsyncThrowingStream<Data, Error> {
        let path = prefix + path
        let token = try await currentToken()
        do {
            return try await transport.openStream(method, path, query: query, body: body, host: .runtime, bearer: token)
        } catch let error as OblienError where error.status == 401 {
            let fresh = try await refreshRejectedToken(token)
            return try await transport.openStream(method, path, query: query, body: body, host: .runtime, bearer: fresh)
        }
    }

    /// Upstream HTTP status and headers are preserved. In particular, an upstream 401
    /// must not cause a POST to be repeated or rotate the workspace credential.
    func proxyRequest(port: Int, host: String?, method: String, path: String,
                      body: Data? = nil, contentType: String? = nil,
                      headers: [String: String] = [:], redirect: HTTPRedirectPolicy = .follow) async throws -> ProxyResponse {
        let target = try proxyTarget(port: port, host: host)
        let proxyPath = prefix + "/proxy" + (path.hasPrefix("/") ? path : "/" + path)
        let token = try await currentToken()
        var headers = headers
        headers["X-Oblien-Proxy-Target"] = target
        let result = try await transport.rawRequest(method, proxyPath, body: body, host: .runtime, bearer: token,
                                                    contentType: contentType, headers: headers, redirect: redirect)
        return ProxyResponse(status: result.status, body: result.data, headers: result.headers)
    }

    func proxyFetchStream(port: Int, host: String?, method: String, path: String,
                          body: Data?, contentType: String?, headers: [String: String],
                          redirect: HTTPRedirectPolicy) async throws -> HTTPBodyStream {
        let target = try proxyTarget(port: port, host: host)
        let proxyPath = prefix + "/proxy" + (path.hasPrefix("/") ? path : "/" + path)
        var headers = headers
        headers["X-Oblien-Proxy-Target"] = target
        if let contentType { headers["Content-Type"] = contentType }
        return try await transport.openStreamResponse(method, proxyPath, body: body, host: .runtime,
            bearer: currentToken(), headers: headers, accept: "*/*", mapErrors: false, redirect: redirect)
    }

    /// Byte-stream (SSE) through the workspace reverse-proxy. Upstream errors are never replayed.
    func proxyStream(port: Int, host: String?, method: String, path: String, body: Data? = nil) async throws -> AsyncThrowingStream<Data, Error> {
        let target = try proxyTarget(port: port, host: host)
        let proxyPath = prefix + "/proxy" + (path.hasPrefix("/") ? path : "/" + path)
        let token = try await currentToken()
        return try await transport.openStream(method, proxyPath, body: body, host: .runtime, bearer: token,
                                              headers: ["X-Oblien-Proxy-Target": target])
    }

    public nonisolated var files: FilesAPI { FilesAPI(runtime: self) }
    public nonisolated var exec: ExecAPI { ExecAPI(runtime: self) }
    public nonisolated var terminal: TerminalAPI { TerminalAPI(runtime: self) }
    public nonisolated var search: SearchAPI { SearchAPI(runtime: self) }
    public nonisolated var watcher: WatcherAPI { WatcherAPI(runtime: self) }
    public nonisolated var transfer: TransferAPI { TransferAPI(runtime: self) }

    func download(body: Data) async throws -> HTTPBodyStream {
        let token = try await currentToken()
        let path = prefix + "/files/transfer/download"
        do { return try await transport.openStreamResponse("POST", path, body: body, host: .runtime, bearer: token, accept: "application/gzip") }
        catch let error as OblienError where error.status == 401 {
            return try await transport.openStreamResponse("POST", path, body: body, host: .runtime,
                bearer: refreshRejectedToken(token), accept: "application/gzip")
        }
    }

    func upload(dest: String, source: UploadSource, onProgress: (@Sendable (TransferProgress) -> Void)?) async throws -> Data {
        let token = try await currentToken()
        let path = prefix + "/files/transfer/upload"
        do { return try await transport.upload(path, query: ["dest": dest], bearer: token, source: source, onProgress: onProgress) }
        catch let error as OblienError where error.status == 401 {
            return try await transport.upload(path, query: ["dest": dest], bearer: refreshRejectedToken(token), source: source, onProgress: onProgress)
        }
    }
    /// Transparent reverse-proxy to a loopback port inside the workspace. Mirrors the TS SDK's
    /// `rt.proxy(port)`.
    public nonisolated func proxy(_ port: Int, host: String? = nil) -> ProxyAPI { ProxyAPI(runtime: self, port: port, host: host) }

    /// `wss://workspace.oblien.com/ws` — the multiplexed terminal/watcher socket.
    public nonisolated func websocketURL() -> URL {
        var s = runtimeURL.absoluteString
        if s.hasPrefix("https://") { s = "wss://" + s.dropFirst("https://".count) }
        else if s.hasPrefix("http://") { s = "ws://" + s.dropFirst("http://".count) }
        return URL(string: s.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + prefix + "/ws") ?? runtimeURL
    }

    func endpoint(_ path: String, root: Bool = false) throws -> URL {
        let base = runtimeURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: base + (root ? "" : prefix) + path) else {
            throw OblienError(kind: .badURL, status: nil, code: nil, message: "Invalid runtime endpoint.", details: nil)
        }
        return url
    }

    private func proxyTarget(port: Int, host: String?) throws -> String {
        guard (1...65535).contains(port), host?.contains(where: { $0.isWhitespace || $0 == "/" || $0 == "?" || $0 == "#" }) != true else {
            throw OblienError(kind: .validation, status: nil, code: nil, message: "Use a valid proxy host and port (1–65535).", details: nil)
        }
        return host.map { "\($0):\(port)" } ?? String(port)
    }

    func proxyWebSocketRequest(port: Int, host: String?, path: String, protocols: [String]) async throws -> URLRequest {
        let target = try proxyTarget(port: port, host: host)
        let url = try endpoint("/proxy" + (path.hasPrefix("/") ? path : "/" + path))
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.scheme = components.scheme == "https" ? "wss" : "ws"
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(try await currentToken())", forHTTPHeaderField: "Authorization")
        request.setValue(target, forHTTPHeaderField: "X-Oblien-Proxy-Target")
        if !protocols.isEmpty { request.setValue(protocols.joined(separator: ", "), forHTTPHeaderField: "Sec-WebSocket-Protocol") }
        return request
    }

    /// Create a PTY and open a connected terminal over the binary WebSocket.
    public func openTerminal(cmd: [String]? = nil, cols: Int = 80, rows: Int = 24) async throws -> TerminalConnection {
        let created = try await terminal.create(cmd: cmd, cols: cols, rows: rows)
        let token = try await currentToken()
        let connection = TerminalConnection(webSocketURL: websocketURL(), token: token, terminalId: created.id, session: transport.session)
        connection.connect()
        return connection
    }

    /// Open the runtime's single multiplexed terminal socket. Share one `TerminalMux` across every
    /// terminal/tab and route by id — opening a socket per terminal makes the runtime drop the
    /// previous one. Combine with `terminal.create`/`list`/`close`/`scrollback`.
    public func terminalMux() async throws -> TerminalMux {
        let token = try await currentToken()
        let mux = TerminalMux(webSocketURL: websocketURL(), token: token, session: transport.session)
        mux.connect()
        return mux
    }

    /// Terminal and watcher events share this native socket. Install callbacks before
    /// calling `connect()`, then keep one socket per runtime. Matches `runtime.ws()`.
    public func ws(options: WSOptions = .init()) async throws -> TerminalMux {
        TerminalMux(webSocketURL: websocketURL(), token: try await currentToken(), session: transport.session, options: options)
    }
}
