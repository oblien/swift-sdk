import Foundation

/// A scoped handle for one workspace (mirrors `client.workspace(id)`): lifecycle, bound
/// sub-resources, and a lazily-authenticated `RuntimeClient`.
public struct WorkspaceHandle: Sendable {
    public let id: String
    let transport: Transport
    let config: OblienConfiguration

    private var ws: WorkspacesAPI { WorkspacesAPI(transport: transport) }

    public func get() async throws -> Workspace { try await ws.get(id) }
    public func update(_ params: WorkspaceUpdateParams) async throws -> Workspace { try await ws.update(id, params) }
    public func delete() async throws { try await ws.delete(id) }

    public func start(force: Bool = false) async throws { try await ws.start(id, force: force) }
    public func stop() async throws { try await ws.stop(id) }
    public func restart() async throws { try await ws.restart(id) }
    public func pause() async throws { try await ws.pause(id) }
    public func resume() async throws { try await ws.resume(id) }
    public func ping(ttlSeconds: Int? = nil) async throws { try await ws.ping(id, ttlSeconds: ttlSeconds) }

    public var resources: ResourcesAPI { ws.resources(id) }
    public var network: NetworkAPI { ws.network(id) }
    public var publicAccess: PublicAccessAPI { ws.publicAccess(id) }
    public var runtimeAccess: RuntimeAccessAPI { ws.runtimeAccess(id) }
    public var metrics: MetricsAPI { ws.metrics(id) }

    /// A runtime client for the data plane (files/exec/terminal). Keep the returned value
    /// and reuse it — it caches the gateway JWT.
    public func runtime(force: Bool = false) async throws -> RuntimeClient {
        let rt = RuntimeClient(transport: transport, workspaceId: id,
                               runtimeURL: config.runtimeURL, ttl: config.runtimeTokenTTL)
        if force { await rt.invalidate() }
        return rt
    }
}
