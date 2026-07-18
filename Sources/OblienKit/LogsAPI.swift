import Foundation

/// Workspace boot/command logs (`client.workspaces.logs(id)` / `handle.logs`). Non-streaming
/// endpoints only — the SSE boot/cmd streams are handled separately.
public struct LogsAPI: Sendable {
    let transport: Transport
    let workspaceId: String
    private var base: String { "/workspace/\(workspaceId.pathEscaped)/logs" }

    /// Recent log output. Shape is undocumented, so this returns a loose `JSONValue`.
    /// `source` selects the log stream (e.g. boot/cmd); `tailLines` caps the line count.
    public func get(source: String? = nil, tailLines: Int? = nil) async throws -> JSONValue {
        let query: [String: String?] = ["source": source, "tail_lines": tailLines.map(String.init)]
        let data = try await transport.request("GET", base, query: query)
        return try OblienJSON.decode(JSONValue.self, data)
    }

    /// Clear the stored logs for this workspace.
    public func clear() async throws {
        _ = try await transport.request("DELETE", base)
    }

    /// List available log files. Shape is undocumented, so this returns a loose `JSONValue`.
    public func listFiles() async throws -> JSONValue {
        let data = try await transport.request("GET", base + "/list")
        return try OblienJSON.decode(JSONValue.self, data)
    }

    /// Raw body of a single log file, returned as a UTF-8 string (not JSON).
    public func getFile(_ name: String) async throws -> String {
        let data = try await transport.request("GET", base + "/file/\(name.pathEscaped)")
        return String(data: data, encoding: .utf8) ?? ""
    }
}

extension WorkspaceHandle {
    public var logs: LogsAPI { LogsAPI(transport: transport, workspaceId: id) }
}

extension WorkspacesAPI {
    public func logs(_ id: String) -> LogsAPI { LogsAPI(transport: transport, workspaceId: id) }
}
