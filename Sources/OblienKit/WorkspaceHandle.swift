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
    public func reinstall() async throws { try await ws.reinstall(id) }
    public func retryProvisioning() async throws -> Workspace { try await ws.retryProvisioning(id) }
    public func waitUntilReady(timeout: TimeInterval = 600) async throws -> Workspace { try await ws.waitUntilReady(id, timeout: timeout) }
    public func pause() async throws { try await ws.pause(id) }
    public func resume() async throws { try await ws.resume(id) }
    /// Choose the correct transition without discarding saved execution.
    public func wake() async throws {
        let workspace = try await get()
        switch workspace.info?.status {
        case "running": return
        case "paused": try await resume()
        case "suspended", "hibernated": try await snapshots.restore()
        default: try await start()
        }
    }
    public func ping(ttlSeconds: Int? = nil) async throws { try await ws.ping(id, ttlSeconds: ttlSeconds) }

    public var resources: ResourcesAPI { ws.resources(id) }
    public var network: NetworkAPI { ws.network(id) }
    public var publicAccess: PublicAccessAPI { ws.publicAccess(id) }
    public var runtimeAccess: RuntimeAccessAPI { ws.runtimeAccess(id) }
    public var metrics: MetricsAPI { ws.metrics(id) }

    /// A runtime client for the data plane (files/exec/terminal). Keep the returned value
    /// and reuse it — it caches the gateway JWT.
    public func runtime(force: Bool = false, enableIfNeeded: Bool = true, target: String? = nil) async throws -> RuntimeClient {
        let runtime = await transport.runtime(id, force: force, enableIfNeeded: enableIfNeeded)
        return try target.map { try runtime.forTarget($0) } ?? runtime
    }
    public func invalidateRuntime() async { await transport.invalidateRuntime(id) }
    public func getDetails() async throws -> WorkspaceDetails { try await ws.getDetails(id) }
}

extension WorkspacesAPI {
    public func runtime(_ id: String, force: Bool = false, target: String? = nil, enableIfNeeded: Bool = true) async throws -> RuntimeClient {
        let runtime = await transport.runtime(id, force: force, enableIfNeeded: enableIfNeeded)
        return try target.map { try runtime.forTarget($0) } ?? runtime
    }
    public func setTokenTTL(_ seconds: TimeInterval) async throws { try await transport.setTokenTTL(seconds) }
    public func invalidateRuntime(_ id: String) async { await transport.invalidateRuntime(id) }
    public func invalidateAllRuntimes() async { await transport.invalidateRuntime() }
}
