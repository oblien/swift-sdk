import Foundation

/// `client.workspaces.resources(id)` / `handle.resources`.
public struct ResourcesAPI: Sendable {
    let transport: Transport
    let workspaceId: String
    private struct Envelope: Decodable { let resources: Resources }

    public func get() async throws -> Resources {
        let data = try await transport.request("GET", "/workspace/\(workspaceId.pathEscaped)/resources")
        return try OblienJSON.decode(Envelope.self, data).resources
    }
    public func update(_ patch: ResourcePatch) async throws -> ResourceUpdateResult {
        let body = try OblienJSON.encode(patch)
        let data = try await transport.request("PUT", "/workspace/\(workspaceId.pathEscaped)/resources", body: body)
        return try OblienJSON.decode(ResourceUpdateResult.self, data)
    }
    public func patch(_ patch: ResourcePatch) async throws -> ResourceUpdateResult {
        let body = try OblienJSON.encode(patch)
        let data = try await transport.request("PATCH", "/workspace/\(workspaceId.pathEscaped)/resources", body: body)
        return try OblienJSON.decode(ResourceUpdateResult.self, data)
    }
}

public struct NetworkAPI: Sendable {
    let transport: Transport
    let workspaceId: String
    public func get() async throws -> Network {
        let data = try await transport.request("GET", "/workspace/\(workspaceId.pathEscaped)/network")
        return try OblienJSON.decode(Network.self, data)
    }
    public func update(_ params: NetworkUpdateParams) async throws -> Network {
        let body = try OblienJSON.encode(params)
        let data = try await transport.request("PATCH", "/workspace/\(workspaceId.pathEscaped)/network", body: body)
        return try OblienJSON.decode(Network.self, data)
    }
}

public struct PublicAccessAPI: Sendable {
    let transport: Transport
    let workspaceId: String
    private struct PortsEnvelope: Decodable { let ports: [ExposedPort] }
    private struct PortEnvelope: Decodable { let port: ExposedPort }

    public func list() async throws -> [ExposedPort] {
        let data = try await transport.request("GET", "/workspace/\(workspaceId.pathEscaped)/public-access")
        if let env = try? OblienJSON.decode(PortsEnvelope.self, data) { return env.ports }
        return (try? OblienJSON.decode([ExposedPort].self, data)) ?? []
    }
    public func expose(port: Int, label: String? = nil, slug: String? = nil) async throws -> ExposedPort {
        struct Body: Encodable { let port: Int; let label: String?; let slug: String? }
        let body = try OblienJSON.encode(Body(port: port, label: label, slug: slug))
        let data = try await transport.request("POST", "/workspace/\(workspaceId.pathEscaped)/public-access", body: body)
        return try OblienJSON.decode(PortEnvelope.self, data).port
    }
    public func updateSlug(port: Int, slug: String) async throws {
        struct Body: Encodable { let slug: String }
        let body = try OblienJSON.encode(Body(slug: slug))
        _ = try await transport.request("PATCH", "/workspace/\(workspaceId.pathEscaped)/public-access/\(port)", body: body)
    }
    public func revoke(port: Int) async throws {
        _ = try await transport.request("DELETE", "/workspace/\(workspaceId.pathEscaped)/public-access/\(port)")
    }
}

public struct RuntimeAccessAPI: Sendable {
    let transport: Transport
    let workspaceId: String
    private var base: String { "/workspace/\(workspaceId.pathEscaped)/runtime-api-access" }

    public func status() async throws -> RuntimeAccessStatus {
        try OblienJSON.decode(RuntimeAccessStatus.self, try await transport.request("GET", base))
    }
    public func enable() async throws -> RuntimeAccessToken {
        try OblienJSON.decode(RuntimeAccessToken.self, try await transport.request("POST", base + "/enable"))
    }
    public func disable() async throws {
        _ = try await transport.request("POST", base + "/disable")
    }
    public func getToken() async throws -> RuntimeAccessToken {
        try OblienJSON.decode(RuntimeAccessToken.self, try await transport.request("GET", base + "/token"))
    }
    public func rotateToken() async throws -> RuntimeAccessToken {
        try OblienJSON.decode(RuntimeAccessToken.self, try await transport.request("POST", base + "/token"))
    }
    public func rawToken() async throws -> RawToken {
        try OblienJSON.decode(RawToken.self, try await transport.request("GET", base + "/token/raw"))
    }
}

public struct MetricsAPI: Sendable {
    let transport: Transport
    let workspaceId: String
    private struct Envelope: Decodable { let stats: Stats }
    public func stats() async throws -> Stats {
        let data = try await transport.request("GET", "/workspace/\(workspaceId.pathEscaped)/stats")
        return try OblienJSON.decode(Envelope.self, data).stats
    }
}

/// `client.tokens.create(...)` — short-lived scoped tokens (admin API key only).
public struct TokensAPI: Sendable {
    let transport: Transport
    public func create(scope: TokenScope, namespace: String? = nil, workspaceId: String? = nil,
                       ttl: Int = 900, label: String? = nil) async throws -> ScopedToken {
        // `workspaceId` is camelCase on the wire, so build the body explicitly (no snake_case conversion).
        var obj: [String: Any] = ["scope": scope.rawValue, "ttl": ttl]
        if let namespace { obj["namespace"] = namespace }
        if let workspaceId { obj["workspaceId"] = workspaceId }
        if let label { obj["label"] = label }
        let body = try JSONSerialization.data(withJSONObject: obj)
        let data = try await transport.request("POST", "/tokens", body: body)
        return try OblienJSON.decode(ScopedToken.self, data)
    }
}
