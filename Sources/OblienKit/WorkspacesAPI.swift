import Foundation

/// Workspace collection + lifecycle operations (`client.workspaces.*`).
public struct WorkspacesAPI: Sendable {
    let transport: Transport

    private struct WorkspaceEnvelope: Decodable { let workspace: Workspace }

    // MARK: CRUD

    public func create(_ params: WorkspaceCreateParams) async throws -> Workspace {
        let body = try OblienJSON.encode(params)
        let data = try await transport.request("POST", "/workspace", body: body)
        return try OblienJSON.decode(WorkspaceEnvelope.self, data).workspace
    }

    public func list(_ params: WorkspaceListParams = .init()) async throws -> WorkspaceList {
        let data = try await transport.request("GET", "/workspace", query: params.query)
        return try OblienJSON.decode(WorkspaceList.self, data)
    }

    public func get(_ id: String) async throws -> Workspace {
        let data = try await transport.request("GET", "/workspace/\(id.pathEscaped)")
        return try OblienJSON.decode(WorkspaceEnvelope.self, data).workspace
    }

    public func update(_ id: String, _ params: WorkspaceUpdateParams) async throws -> Workspace {
        let body = try OblienJSON.encode(params)
        let data = try await transport.request("PUT", "/workspace/\(id.pathEscaped)", body: body)
        return try OblienJSON.decode(WorkspaceEnvelope.self, data).workspace
    }

    public func delete(_ id: String) async throws {
        _ = try await transport.request("DELETE", "/workspace/\(id.pathEscaped)")
    }

    public func getQuota() async throws -> Quota {
        let data = try await transport.request("GET", "/workspace/quota")
        return try OblienJSON.decode(Quota.self, data)
    }

    public func images(search: String? = nil, category: String? = nil) async throws -> ImageList {
        let data = try await transport.request("GET", "/workspace/images",
                                               query: ["search": search, "category": category])
        return try OblienJSON.decode(ImageList.self, data)
    }

    // MARK: Lifecycle

    public func start(_ id: String, force: Bool = false) async throws {
        let body = try OblienJSON.encode(ForceBody(force: force))
        _ = try await transport.request("POST", "/workspace/\(id.pathEscaped)/start", body: body)
    }
    public func stop(_ id: String) async throws {
        _ = try await transport.request("POST", "/workspace/\(id.pathEscaped)/stop")
    }
    public func restart(_ id: String) async throws {
        _ = try await transport.request("POST", "/workspace/\(id.pathEscaped)/restart")
    }
    public func pause(_ id: String) async throws {
        _ = try await transport.request("POST", "/workspace/\(id.pathEscaped)/pause")
    }
    public func resume(_ id: String) async throws {
        _ = try await transport.request("POST", "/workspace/\(id.pathEscaped)/resume")
    }
    public func ping(_ id: String, ttlSeconds: Int? = nil) async throws {
        struct Body: Encodable { let ttlSeconds: Int? }
        let body = try OblienJSON.encode(Body(ttlSeconds: ttlSeconds))
        _ = try await transport.request("POST", "/workspace/\(id.pathEscaped)/ping", body: body)
    }

    // MARK: Sub-resources (bound to an id)

    public func resources(_ id: String) -> ResourcesAPI { ResourcesAPI(transport: transport, workspaceId: id) }
    public func network(_ id: String) -> NetworkAPI { NetworkAPI(transport: transport, workspaceId: id) }
    public func publicAccess(_ id: String) -> PublicAccessAPI { PublicAccessAPI(transport: transport, workspaceId: id) }
    public func runtimeAccess(_ id: String) -> RuntimeAccessAPI { RuntimeAccessAPI(transport: transport, workspaceId: id) }
    public func metrics(_ id: String) -> MetricsAPI { MetricsAPI(transport: transport, workspaceId: id) }
}
