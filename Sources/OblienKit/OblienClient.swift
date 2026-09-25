import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Entry point to the Oblien API. Mirrors the TS `Oblien` client:
/// `client.workspaces.*`, `client.workspace(id)`, `client.tokens.create(...)`.
///
/// ```swift
/// let client = OblienClient(clientId: "...", clientSecret: "...")
/// let ws = try await client.workspaces.create(.init(image: "node-20"))
/// let handle = client.workspace(ws.id)
/// try await handle.start()
/// let rt = try await handle.runtime()
/// let result = try await rt.exec.run(["node", "-v"])
/// ```
public struct OblienClient: Sendable {
    var transport: Transport
    public private(set) var config: OblienConfiguration
    private let originalAuth: OblienAuth
    private let session: URLSession

    public init(_ config: OblienConfiguration, session: URLSession = .shared) {
        self.config = config
        self.session = session
        self.transport = Transport(config: config, session: session)
        self.originalAuth = config.auth
    }

    /// API-key (account/admin) client.
    public init(clientId: String, clientSecret: String,
                baseURL: URL = URL(string: "https://api.oblien.com")!) {
        self.init(.init(auth: .apiKey(clientId: clientId, clientSecret: clientSecret), baseURL: baseURL))
    }

    /// Scoped-token client.
    public init(token: String, baseURL: URL = URL(string: "https://api.oblien.com")!) {
        self.init(.init(auth: .scopedToken(token), baseURL: baseURL))
    }

    public var workspaces: WorkspacesAPI { WorkspacesAPI(transport: transport) }
    public var tokens: TokensAPI { TokensAPI(transport: transport) }
    public var notifications: NotificationsAPI { NotificationsAPI(transport: transport) }

    /// Returns a separate client with new credentials and no shared runtime-token cache.
    /// Previously created handles retain their original identity (Swift value semantics).
    public func withToken(_ token: String) -> OblienClient {
        var client = self
        client.setToken(token)
        return client
    }
    public mutating func setToken(_ token: String) {
        config.auth = .scopedToken(token)
        transport = Transport(config: config, session: session)
    }
    public mutating func restoreAuth() {
        config.auth = originalAuth
        transport = Transport(config: config, session: session)
    }

    /// A scoped handle for one workspace (mirrors `client.workspace(id)`).
    public func workspace(_ id: String) -> WorkspaceHandle {
        WorkspaceHandle(id: id, transport: transport, config: config)
    }
}
