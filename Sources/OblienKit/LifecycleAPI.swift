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

    public func makeTemporary(ttl: String? = nil, ttlAction: TTLAction? = nil, removeOnExit: Bool? = nil) async throws {
        struct Body: Encodable { let ttl: String?; let ttlAction: TTLAction?; let removeOnExit: Bool? }
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
    public func setIdle(suspendAfter: Int, stopAfter: Int = 0) async throws {
        struct Body: Encodable { let suspendAfter: Int; let stopAfter: Int }
        _ = try await transport.request("PUT", base + "/idle", body: OblienJSON.encode(Body(suspendAfter: suspendAfter, stopAfter: stopAfter)))
    }
    public func setIdle(_ policy: IdlePolicy?) async throws {
        _ = try await transport.request("PUT", base + "/idle", body: OblienJSON.encode(policy ?? .init(suspendAfter: .number(0))))
    }
    public func makeTemporary(ttlSeconds: Int, ttlAction: TTLAction? = nil, removeOnExit: Bool? = nil) async throws {
        struct Body: Encodable { let ttl: Int; let ttlAction: TTLAction?; let removeOnExit: Bool? }
        _ = try await transport.request("POST", base + "/temporary", body: OblienJSON.encode(Body(ttl: ttlSeconds, ttlAction: ttlAction, removeOnExit: removeOnExit)))
    }
    public func updateTTL(ttlSeconds: Int, ttlAction: TTLAction? = nil) async throws {
        struct Body: Encodable { let ttl: Int; let ttlAction: TTLAction? }
        _ = try await transport.request("PUT", base + "/ttl", body: OblienJSON.encode(Body(ttl: ttlSeconds, ttlAction: ttlAction)))
    }
    public func ping(ttlSeconds: Int? = nil) async throws { try await WorkspacesAPI(transport: transport).ping(workspaceId, ttlSeconds: ttlSeconds) }
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
    public var pauseSupported: Bool?
    public var snapshotSupported: Bool?
    public var snapshotUnavailableReason: String?
    public var ttlExpiresAt: String?
    public var idle: Idle?
    public var expiresAt: String?
    public var createdAt: String?
    public var additionalProperties: [String: JSONValue] = [:]
    public struct Idle: Codable, Sendable {
        public var suspendAfter: Int?
        public var stopAfter: Int?
        public var suspendAfterSeconds: Int?
        public var stopAfterSeconds: Int?
    }

    public init(from decoder: Decoder) throws {
        var fields = try JSONFields(from: decoder)
        mode = try fields.take("mode", as: WorkspaceMode.self)
        status = try fields.take("status", as: String.self)
        restartPolicy = try fields.take("restart_policy", as: RestartPolicy.self)
        maxRestarts = try fields.take("max_restarts", as: Int.self)
        restartInfo = try fields.take("restart_info", as: JSONValue.self)
        let ttlValue = fields.values.removeValue(forKey: "ttl")
        ttl = ttlValue?.stringValue ?? ttlValue?.intValue.map(String.init)
        ttlAction = try fields.take("ttl_action", as: TTLAction.self)
        removeOnExit = try fields.take("remove_on_exit", as: Bool.self)
        uptime = try fields.take("uptime", as: Int.self)
        pauseSupported = try fields.take("pause_supported", as: Bool.self)
        snapshotSupported = try fields.take("snapshot_supported", as: Bool.self)
        snapshotUnavailableReason = try fields.take("snapshot_unavailable_reason", as: String.self)
        ttlExpiresAt = try fields.take("ttl_expires_at", as: String.self)
        idle = try fields.take("idle", as: Idle.self)
        expiresAt = try fields.take("expires_at", as: String.self)
        createdAt = try fields.take("created_at", as: String.self)
        additionalProperties = fields.values
    }

    public func encode(to encoder: Encoder) throws {
        var fields = JSONFields(additionalProperties)
        try fields.set("mode", mode)
        try fields.set("status", status)
        try fields.set("restart_policy", restartPolicy)
        try fields.set("max_restarts", maxRestarts)
        try fields.set("restart_info", restartInfo)
        try fields.set("ttl", ttl)
        try fields.set("ttl_action", ttlAction)
        try fields.set("remove_on_exit", removeOnExit)
        try fields.set("uptime", uptime)
        try fields.set("pause_supported", pauseSupported)
        try fields.set("snapshot_supported", snapshotSupported)
        try fields.set("snapshot_unavailable_reason", snapshotUnavailableReason)
        try fields.set("ttl_expires_at", ttlExpiresAt)
        try fields.set("idle", idle)
        try fields.set("expires_at", expiresAt)
        try fields.set("created_at", createdAt)
        try fields.encode(to: encoder)
    }
}

// MARK: - Accessors

extension WorkspaceHandle {
    public var lifecycle: LifecycleAPI { LifecycleAPI(transport: transport, workspaceId: id) }
}

extension WorkspacesAPI {
    public func lifecycle(_ id: String) -> LifecycleAPI { LifecycleAPI(transport: transport, workspaceId: id) }
}
