import Foundation

/// Workspace snapshots & archives (`client.workspaces.snapshots(id)` / `handle.snapshots`).
public struct SnapshotsAPI: Sendable {
    let transport: Transport
    let workspaceId: String
    private var base: String { "/workspace/\(workspaceId.pathEscaped)" }
    private struct ArchivesEnvelope: Decodable { let archives: [Archive] }

    /// Capture a live snapshot, optionally choosing what to do afterward.
    public func snapshot(after: String? = nil) async throws {
        struct Body: Encodable { let after: String? }
        let body = try OblienJSON.encode(Body(after: after))
        _ = try await transport.request("POST", base + "/snapshot", body: body, timeout: 600)
    }

    /// Restore the workspace from its latest snapshot.
    public func restore() async throws {
        _ = try await transport.request("POST", base + "/restore", timeout: 600)
    }

    /// Create an archive (point-in-time export) of the workspace.
    public func createArchive(version: String? = nil, format: String? = nil,
                              vmPaths: [String]? = nil, excludeVmPaths: [String]? = nil) async throws {
        struct Body: Encodable { let version: String?; let format: String?; let vmPaths: [String]?; let excludeVmPaths: [String]? }
        let body = try OblienJSON.encode(Body(version: version, format: format, vmPaths: vmPaths, excludeVmPaths: excludeVmPaths))
        _ = try await transport.request("POST", base + "/archives", body: body, timeout: 600)
    }

    /// List all archives for the workspace.
    public func listArchives() async throws -> [Archive] {
        let data = try await transport.request("GET", base + "/archives")
        if let env = try? OblienJSON.decode(ArchivesEnvelope.self, data) { return env.archives }
        return try OblienJSON.decode([Archive]?.self, data) ?? []
    }

    /// Fetch a single archive by version.
    public func getArchive(_ version: String) async throws -> Archive {
        let data = try await transport.request("GET", base + "/archives/\(version.pathEscaped)")
        return try OblienJSON.decode(Archive.self, data)
    }

    /// Delete one archive; optionally remove its backing file.
    public func deleteArchive(_ version: String, deleteFile: Bool? = nil) async throws {
        _ = try await transport.request("DELETE", base + "/archives/\(version.pathEscaped)",
                                        query: ["delete_file": deleteFile.map(String.init)])
    }

    /// Delete all archives; optionally remove their backing files.
    public func deleteAllArchives(deleteFiles: Bool? = nil) async throws {
        _ = try await transport.request("DELETE", base + "/archives",
                                        query: ["delete_files": deleteFiles.map(String.init)])
    }

    public func createArchive(_ params: ArchiveCreateParams) async throws {
        _ = try await transport.request("POST", base + "/archives", body: OblienJSON.encode(params), timeout: 600)
    }
}

// MARK: - Models

public struct Archive: Codable, Sendable {
    public let version: String
    public var createdAt: String?      // created_at
    public var size: Int?
    public var format: String?
    public var sizeBytes: Int?
    public var name: String?
    public var additionalProperties: [String: JSONValue] = [:]
    enum CodingKeys: String, CodingKey { case version, createdAt, size, format, sizeBytes, name }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? c.decode(Int.self, forKey: .version) { version = String(value) }
        else { version = try c.decode(String.self, forKey: .version) }
        createdAt = try c.decodeIfPresent(String.self, forKey: .createdAt)
        size = try c.decodeIfPresent(Int.self, forKey: .size)
        format = try c.decodeIfPresent(String.self, forKey: .format)
        sizeBytes = try c.decodeIfPresent(Int.self, forKey: .sizeBytes)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        let known = Set(["version", "created_at", "createdAt", "size", "format", "size_bytes", "sizeBytes", "name"])
        additionalProperties = try decoder.singleValueContainer().decode([String: JSONValue].self).filter { !known.contains($0.key) }
    }
    public func encode(to encoder: Encoder) throws {
        var fields = JSONFields(additionalProperties)
        try fields.set("version", version)
        try fields.set("created_at", createdAt)
        try fields.set("size", size)
        try fields.set("format", format)
        try fields.set("size_bytes", sizeBytes)
        try fields.set("name", name)
        try fields.encode(to: encoder)
    }
}

public struct ArchiveCreateParams: Codable, Sendable {
    public var version: Int?
    public var format: String?
    public var vmPaths: [String]?
    public var excludeVmPaths: [String]?
    public init(version: Int? = nil, format: String? = nil, vmPaths: [String]? = nil, excludeVmPaths: [String]? = nil) {
        self.version = version; self.format = format; self.vmPaths = vmPaths; self.excludeVmPaths = excludeVmPaths
    }
}

// MARK: - Accessors

extension WorkspaceHandle {
    public var snapshots: SnapshotsAPI { SnapshotsAPI(transport: transport, workspaceId: id) }
}

extension WorkspacesAPI {
    public func snapshots(_ id: String) -> SnapshotsAPI { SnapshotsAPI(transport: transport, workspaceId: id) }
}
