import Foundation

/// Granular lifecycle control for one workspace (`client.workspaces.lifecycle(id)` / `handle.lifecycle`):
/// inspect state, switch between permanent/temporary modes, adjust TTL, or destroy.
public struct LifecycleAPI: Sendable {
    let transport: Transport
    let workspaceId: String
    private var base: String { "/workspace/\(workspaceId.pathEscaped)/lifecycle" }

    public func get() async throws -> Lifecycle {
        let data = try await transport.request("GET", base)
        return try OblienJSON.decode(Lifecycle.self, data)
    }

    public func makePermanent(restartPolicy: RestartPolicy? = nil) async throws {
        struct Body: Encodable { let restartPolicy: RestartPolicy? }
        let body = try OblienJSON.encode(Body(restartPolicy: restartPolicy))
        _ = try await transport.request("POST", base + "/permanent", body: body)
    }

    public func makeTemporary(ttl: String, ttlAction: TTLAction? = nil, removeOnExit: Bool? = nil) async throws {
        struct Body: Encodable { let ttl: String; let ttlAction: TTLAction?; let removeOnExit: Bool? }
        let body = try OblienJSON.encode(Body(ttl: ttl, ttlAction: ttlAction, removeOnExit: removeOnExit))
        _ = try await transport.request("POST", base + "/temporary", body: body)
    }

    public func updateTTL(ttl: String? = nil, ttlAction: TTLAction? = nil) async throws {
        struct Body: Encodable { let ttl: String?; let ttlAction: TTLAction? }
        let body = try OblienJSON.encode(Body(ttl: ttl, ttlAction: ttlAction))
        _ = try await transport.request("PUT", base + "/ttl", body: body)
    }

    public func destroy() async throws {
        _ = try await transport.request("DELETE", base)
    }
}

// MARK: - Model (lenient — all fields optional for forward-compat)

public struct Lifecycle: Codable, Sendable {
    public var mode: WorkspaceMode?
    public var status: String?
    public var restartPolicy: RestartPolicy?
    public var maxRestarts: Int?
    public var restartInfo: JSONValue?
    public var ttl: String?
    public var ttlAction: TTLAction?
    public var removeOnExit: Bool?
    public var uptime: Int?
}

// MARK: - Accessors

extension WorkspaceHandle {
    public var lifecycle: LifecycleAPI { LifecycleAPI(transport: transport, workspaceId: id) }
}

extension WorkspacesAPI {
    public func lifecycle(_ id: String) -> LifecycleAPI { LifecycleAPI(transport: transport, workspaceId: id) }
}
