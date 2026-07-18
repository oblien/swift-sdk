import Foundation

/// Per-workspace data-plane client (`workspace.oblien.com`). Lazily enables + caches the
/// gateway JWT (~55m) and refreshes it on a 401. Mirrors `const rt = await ws.runtime()`.
public actor RuntimeClient {
    private let transport: Transport
    let workspaceId: String
    private let runtimeURL: URL
    private let ttl: TimeInterval

    private var gatewayToken: String?
    private var expiresAt: Date = .distantPast

    init(transport: Transport, workspaceId: String, runtimeURL: URL, ttl: TimeInterval) {
        self.transport = transport
        self.workspaceId = workspaceId
        self.runtimeURL = runtimeURL
        self.ttl = ttl
    }

    public func invalidate() { gatewayToken = nil; expiresAt = .distantPast }

    /// The current gateway JWT (enabling/refreshing as needed) — e.g. to build a terminal endpoint.
    public func token() async throws -> String { try await currentToken() }

    /// Current gateway JWT, enabling/refreshing as needed.
    func currentToken(force: Bool = false) async throws -> String {
        if !force, let token = gatewayToken, Date() < expiresAt { return token }
        let access = RuntimeAccessAPI(transport: transport, workspaceId: workspaceId)
        let result = try await access.enable()
        gatewayToken = result.token
        expiresAt = Date().addingTimeInterval(ttl)
        return result.token
    }

    /// Authenticated runtime request, refreshing the gateway token once on 401.
    func perform(_ method: String, _ path: String, query: [String: String?] = [:], body: Data? = nil, contentType: String? = nil) async throws -> Data {
        let token = try await currentToken()
        do {
            return try await transport.request(method, path, query: query, body: body, host: .runtime, bearer: token, contentType: contentType)
        } catch let error as OblienError where error.kind == .authentication {
            let fresh = try await currentToken(force: true)
            return try await transport.request(method, path, query: query, body: body, host: .runtime, bearer: fresh, contentType: contentType)
        }
    }

    /// Authenticated runtime byte-stream (SSE / NDJSON), refreshing the gateway token once on 401.
    func performStream(_ method: String, _ path: String, query: [String: String?] = [:], body: Data? = nil) async throws -> AsyncThrowingStream<Data, Error> {
        let token = try await currentToken()
        do {
            return try await transport.openStream(method, path, query: query, body: body, host: .runtime, bearer: token)
        } catch let error as OblienError where error.kind == .authentication {
            let fresh = try await currentToken(force: true)
            return try await transport.openStream(method, path, query: query, body: body, host: .runtime, bearer: fresh)
        }
    }

    /// Raw call through the workspace reverse-proxy to a loopback port (`127.0.0.1:<port>`). Returns
    /// the upstream status + body verbatim (non-2xx passes through — the upstream's status is the
    /// real signal). Refreshes the gateway JWT once on a 401 (that's the gateway rejecting the
    /// token, not the upstream). Used by `proxy(_:)`.
    func proxyRequest(port: Int, method: String, path: String,
                      body: Data? = nil, contentType: String? = nil) async throws -> (status: Int, data: Data) {
        // Path form: /proxy/<port>/<upstream path>. `path` already begins with "/".
        let proxyPath = "/proxy/\(port)\(path)"
        let token = try await currentToken()
        let result = try await transport.rawRequest(method, proxyPath, body: body, host: .runtime, bearer: token, contentType: contentType)
        if result.status == 401 {
            let fresh = try await currentToken(force: true)
            return try await transport.rawRequest(method, proxyPath, body: body, host: .runtime, bearer: fresh, contentType: contentType)
        }
        return result
    }

    /// Byte-stream (SSE) through the workspace reverse-proxy to a loopback port. Same JWT + 401
    /// refresh as `proxyRequest`, but returns a live `AsyncBytes` for long-lived streams. Used by
    /// `proxy(_:).stream(...)`.
    func proxyStream(port: Int, method: String, path: String, body: Data? = nil) async throws -> AsyncThrowingStream<Data, Error> {
        let proxyPath = "/proxy/\(port)\(path)"
        let token = try await currentToken()
        do {
            return try await transport.openStream(method, proxyPath, body: body, host: .runtime, bearer: token)
        } catch let error as OblienError where error.kind == .authentication {
            let fresh = try await currentToken(force: true)
            return try await transport.openStream(method, proxyPath, body: body, host: .runtime, bearer: fresh)
        }
    }

    public nonisolated var files: FilesAPI { FilesAPI(runtime: self) }
    public nonisolated var exec: ExecAPI { ExecAPI(runtime: self) }
    public nonisolated var terminal: TerminalAPI { TerminalAPI(runtime: self) }
    public nonisolated var search: SearchAPI { SearchAPI(runtime: self) }
    public nonisolated var watcher: WatcherAPI { WatcherAPI(runtime: self) }
    /// Transparent reverse-proxy to a loopback port inside the workspace. Mirrors the TS SDK's
    /// `rt.proxy(port)`.
    public nonisolated func proxy(_ port: Int) -> ProxyAPI { ProxyAPI(runtime: self, port: port) }

    /// `wss://workspace.oblien.com/ws` — the multiplexed terminal/watcher socket.
    public nonisolated func websocketURL() -> URL {
        var s = runtimeURL.absoluteString
        if s.hasPrefix("https://") { s = "wss://" + s.dropFirst("https://".count) }
        else if s.hasPrefix("http://") { s = "ws://" + s.dropFirst("http://".count) }
        return URL(string: s + "/ws") ?? runtimeURL
    }

    /// Create a PTY and open a connected terminal over the binary WebSocket.
    public func openTerminal(cmd: [String]? = nil, cols: Int = 80, rows: Int = 24) async throws -> TerminalConnection {
        let created = try await terminal.create(cmd: cmd, cols: cols, rows: rows)
        let token = try await currentToken()
        let connection = TerminalConnection(webSocketURL: websocketURL(), token: token, terminalId: created.id)
        connection.connect()
        return connection
    }

    /// Open the runtime's single multiplexed terminal socket. Share one `TerminalMux` across every
    /// terminal/tab and route by id — opening a socket per terminal makes the runtime drop the
    /// previous one. Combine with `terminal.create`/`list`/`close`/`scrollback`.
    public func terminalMux() async throws -> TerminalMux {
        let token = try await currentToken()
        let mux = TerminalMux(webSocketURL: websocketURL(), token: token)
        mux.connect()
        return mux
    }
}
