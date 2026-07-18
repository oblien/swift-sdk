import Foundation

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
    let transport: Transport
    public let config: OblienConfiguration

    public init(_ config: OblienConfiguration) {
        self.config = config
        self.transport = Transport(config: config)
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

    /// A scoped handle for one workspace (mirrors `client.workspace(id)`).
    public func workspace(_ id: String) -> WorkspaceHandle {
        WorkspaceHandle(id: id, transport: transport, config: config)
    }
}
