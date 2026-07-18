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
        _ = try await transport.request("POST", base + "/snapshot", body: body)
    }

    /// Restore the workspace from its latest snapshot.
    public func restore() async throws {
        _ = try await transport.request("POST", base + "/restore")
    }

    /// Create an archive (point-in-time export) of the workspace.
    public func createArchive(version: String? = nil, format: String? = nil) async throws {
        struct Body: Encodable { let version: String?; let format: String? }
        let body = try OblienJSON.encode(Body(version: version, format: format))
        _ = try await transport.request("POST", base + "/archives", body: body)
    }

    /// List all archives for the workspace.
    public func listArchives() async throws -> [Archive] {
        let data = try await transport.request("GET", base + "/archives")
        if let env = try? OblienJSON.decode(ArchivesEnvelope.self, data) { return env.archives }
        return (try? OblienJSON.decode([Archive].self, data)) ?? []
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
}

// MARK: - Models

public struct Archive: Codable, Sendable {
    public let version: String
    public var createdAt: String?      // created_at
    public var size: Int?
    public var format: String?
}

// MARK: - Accessors

extension WorkspaceHandle {
    public var snapshots: SnapshotsAPI { SnapshotsAPI(transport: transport, workspaceId: id) }
}

extension WorkspacesAPI {
    public func snapshots(_ id: String) -> SnapshotsAPI { SnapshotsAPI(transport: transport, workspaceId: id) }
}
