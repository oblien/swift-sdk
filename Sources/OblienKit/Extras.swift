import Foundation

/// Cross-cutting "extras": details/estimate/archived workspace reads, outbound-IP + zones,
/// raw VM info/config, runtime-access reconnect + 30-day workspace token, and a handful of
/// runtime sub-API methods (terminal list/scrollback, exec input/deleteAll, search init,
/// watcher get). All implemented as extensions on the existing resource APIs.

// MARK: - Models

/// Lenient view of `GET /workspace/:id/details` — most fields are loosely shaped, so they
/// stay as `JSONValue`.
public struct WorkspaceDetails: Codable, Sendable {
    public var workspace: Workspace?
    public var token: JSONValue?
    public var stats: JSONValue?
    public var ssh: JSONValue?
    public var apiAccess: JSONValue?    // api_access
    public var lifecycle: JSONValue?
    public var config: JSONValue?
}

/// One PTY session from `GET /terminals`. `id` may arrive as a number or a string, so it is
/// decoded leniently (mirrors `TerminalCreateResult`).
public struct TerminalSession: Codable, Sendable {
    public let id: Int
    public var command: [String]?
    public var cols: Int?
    public var rows: Int?
    public var alive: Bool?
    public var exitCode: Int?
    public var createdAt: String?

    enum CodingKeys: String, CodingKey { case id, command, cols, rows, alive, exitCode, createdAt }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let i = try? c.decode(Int.self, forKey: .id) { id = i }
        else if let s = try? c.decode(String.self, forKey: .id), let i = Int(s) { id = i }
        else { id = 1 }
        command = try? c.decodeIfPresent([String].self, forKey: .command)
        cols = try? c.decodeIfPresent(Int.self, forKey: .cols)
        rows = try? c.decodeIfPresent(Int.self, forKey: .rows)
        alive = try? c.decodeIfPresent(Bool.self, forKey: .alive)
        exitCode = try? c.decodeIfPresent(Int.self, forKey: .exitCode)
        createdAt = try? c.decodeIfPresent(String.self, forKey: .createdAt)
    }
}

// MARK: - WorkspacesAPI: details / estimate / archived / zones

extension WorkspacesAPI {
    public func getDetails(_ id: String) async throws -> WorkspaceDetails {
        let data = try await transport.request("GET", "/workspace/\(id.pathEscaped)/details")
        return try OblienJSON.decode(WorkspaceDetails.self, data)
    }

    public func getEstimate() async throws -> JSONValue {
        let data = try await transport.request("GET", "/workspace/estimate")
        return try OblienJSON.decode(JSONValue.self, data)
    }

    public func archived() async throws -> [Workspace] {
        let data = try await transport.request("GET", "/workspace/archived")
        struct Envelope: Decodable { let workspaces: [Workspace] }
        if let env = try? OblienJSON.decode(Envelope.self, data) { return env.workspaces }
        return (try? OblienJSON.decode([Workspace].self, data)) ?? []
    }

    public func zones() async throws -> JSONValue {
        let data = try await transport.request("GET", "/zone/mine")
        return try OblienJSON.decode(JSONValue.self, data)
    }
}

// MARK: - NetworkAPI: outbound IP

extension NetworkAPI {
    public func applyOutboundIp(_ ip: String) async throws -> JSONValue {
        struct Body: Encodable { let ip: String }
        let body = try OblienJSON.encode(Body(ip: ip))
        let data = try await transport.request("POST", "/workspace/\(workspaceId.pathEscaped)/network/ip", body: body)
        return try OblienJSON.decode(JSONValue.self, data)
    }
}

// MARK: - MetricsAPI: raw VM info / config

extension MetricsAPI {
    public func info() async throws -> JSONValue {
        let data = try await transport.request("GET", "/workspace/\(workspaceId.pathEscaped)/info")
        return try OblienJSON.decode(JSONValue.self, data)
    }
    public func config() async throws -> JSONValue {
        let data = try await transport.request("GET", "/workspace/\(workspaceId.pathEscaped)/config")
        return try OblienJSON.decode(JSONValue.self, data)
    }
}

// MARK: - RuntimeAccessAPI: reconnect / 30-day workspace token

extension RuntimeAccessAPI {
    public func reconnect() async throws {
        _ = try await transport.request("POST", "/workspace/\(workspaceId.pathEscaped)/runtime-api-access/reconnect")
    }
    /// Mint a 30-day workspace gateway token.
    public func workspaceToken() async throws -> RuntimeAccessToken {
        let data = try await transport.request("POST", "/workspace/\(workspaceId.pathEscaped)/runtime-api-access/workspace")
        return try OblienJSON.decode(RuntimeAccessToken.self, data)
    }
}

// MARK: - Runtime: TerminalAPI list / scrollback

extension TerminalAPI {
    public func list() async throws -> [TerminalSession] {
        let data = try await runtime.perform("GET", "/terminals")
        struct Envelope: Decodable { let terminals: [TerminalSession] }
        if let env = try? OblienJSON.decode(Envelope.self, data) { return env.terminals }
        return (try? OblienJSON.decode([TerminalSession].self, data)) ?? []
    }
    /// Raw scrollback bytes (the wire field is base64-encoded).
    public func scrollback(_ id: Int) async throws -> Data {
        let data = try await runtime.perform("GET", "/terminals/\(id)/scrollback")
        struct Envelope: Decodable { let scrollback: String? }
        let b64 = (try? OblienJSON.decode(Envelope.self, data))?.scrollback
        return b64.flatMap { Data(base64Encoded: $0) } ?? Data()
    }
}

// MARK: - Runtime: ExecAPI input / deleteAll

extension ExecAPI {
    /// Write raw stdin bytes to a running task. The wire endpoint expects
    /// `application/octet-stream`; the transport sends `application/json`, which the server
    /// tolerates for the raw-body case.
    public func input(_ id: String, _ bytes: Data) async throws {
        _ = try await runtime.perform("POST", "/exec/\(id.pathEscaped)/input", body: bytes)
    }
    public func deleteAll() async throws {
        _ = try await runtime.perform("DELETE", "/exec")
    }
}

// MARK: - Runtime: SearchAPI init

extension SearchAPI {
    public func initStatus() async throws -> JSONValue {
        try OblienJSON.decode(JSONValue.self, try await runtime.perform("GET", "/files/search/init"))
    }
    public func initialize() async throws -> JSONValue {
        try OblienJSON.decode(JSONValue.self, try await runtime.perform("POST", "/files/search/init"))
    }
}

// MARK: - Runtime: WatcherAPI get

extension WatcherAPI {
    public func get(_ id: String) async throws -> JSONValue {
        try OblienJSON.decode(JSONValue.self, try await runtime.perform("GET", "/watchers/\(id.pathEscaped)"))
    }
}
