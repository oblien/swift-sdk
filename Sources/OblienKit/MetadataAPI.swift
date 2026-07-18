import Foundation

/// Arbitrary per-workspace metadata bag (`client.workspaces.metadata(id)` / `handle.metadata`).
/// The value is free-form, so it is modeled as `JSONValue`.
public struct MetadataAPI: Sendable {
    let transport: Transport
    let workspaceId: String

    private var path: String { "/workspace/\(workspaceId.pathEscaped)/metadata" }

    /// `GET /workspace/:id/metadata` — fetch the current metadata bag.
    public func get() async throws -> JSONValue {
        let data = try await transport.request("GET", path)
        return try OblienJSON.decode(JSONValue.self, data)
    }

    /// `PUT /workspace/:id/metadata` — replace the metadata bag entirely.
    public func update(_ value: JSONValue) async throws -> JSONValue {
        let body = try OblienJSON.encode(value)
        let data = try await transport.request("PUT", path, body: body)
        return try OblienJSON.decode(JSONValue.self, data)
    }

    /// `PATCH /workspace/:id/metadata` — shallow-merge into the metadata bag.
    public func patch(_ value: JSONValue) async throws -> JSONValue {
        let body = try OblienJSON.encode(value)
        let data = try await transport.request("PATCH", path, body: body)
        return try OblienJSON.decode(JSONValue.self, data)
    }
}

extension WorkspaceHandle {
    public var metadata: MetadataAPI { MetadataAPI(transport: transport, workspaceId: id) }
}

extension WorkspacesAPI {
    public func metadata(_ id: String) -> MetadataAPI { MetadataAPI(transport: transport, workspaceId: id) }
}
