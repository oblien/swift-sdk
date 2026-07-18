import Foundation

/// Workloads — the long-running processes inside a workspace (`client.workspaces.workloads(id)` / `handle.workloads`).
/// Non-streaming subset only: CRUD + lifecycle + status/logs/stats reads. Logs/stats streaming lives elsewhere.
public struct WorkloadsAPI: Sendable {
    let transport: Transport
    let workspaceId: String

    private var base: String { "/workspace/\(workspaceId.pathEscaped)/workloads" }
    private func itemPath(_ wid: String) -> String { base + "/" + wid.pathEscaped }

    private struct WorkloadEnvelope: Decodable { let workload: Workload }
    private struct WorkloadsEnvelope: Decodable { let workloads: [Workload] }
    private struct StatusEnvelope: Decodable { let status: JSONValue }

    // MARK: CRUD

    public func create(_ params: WorkloadCreateParams) async throws -> Workload {
        let body = try OblienJSON.encode(params)
        let data = try await transport.request("POST", base, body: body)
        if let env = try? OblienJSON.decode(WorkloadEnvelope.self, data) { return env.workload }
        return try OblienJSON.decode(Workload.self, data)
    }

    public func list() async throws -> [Workload] {
        let data = try await transport.request("GET", base)
        if let env = try? OblienJSON.decode(WorkloadsEnvelope.self, data) { return env.workloads }
        return (try? OblienJSON.decode([Workload].self, data)) ?? []
    }

    public func get(_ wid: String) async throws -> Workload {
        let data = try await transport.request("GET", itemPath(wid))
        if let env = try? OblienJSON.decode(WorkloadEnvelope.self, data) { return env.workload }
        return try OblienJSON.decode(Workload.self, data)
    }

    public func update(_ wid: String, _ params: WorkloadCreateParams) async throws -> Workload {
        let body = try OblienJSON.encode(params)
        let data = try await transport.request("PUT", itemPath(wid), body: body)
        if let env = try? OblienJSON.decode(WorkloadEnvelope.self, data) { return env.workload }
        return try OblienJSON.decode(Workload.self, data)
    }

    public func patch(_ wid: String, _ params: WorkloadCreateParams) async throws -> Workload {
        let body = try OblienJSON.encode(params)
        let data = try await transport.request("PATCH", itemPath(wid), body: body)
        if let env = try? OblienJSON.decode(WorkloadEnvelope.self, data) { return env.workload }
        return try OblienJSON.decode(Workload.self, data)
    }

    public func delete(_ wid: String) async throws {
        _ = try await transport.request("DELETE", itemPath(wid))
    }

    public func deleteAll() async throws {
        _ = try await transport.request("DELETE", base)
    }

    // MARK: Lifecycle

    public func start(_ wid: String) async throws {
        _ = try await transport.request("POST", itemPath(wid) + "/start")
    }

    public func stop(_ wid: String) async throws {
        _ = try await transport.request("POST", itemPath(wid) + "/stop")
    }

    // MARK: Reads (non-streaming)

    public func status(_ wid: String) async throws -> JSONValue {
        let data = try await transport.request("GET", itemPath(wid) + "/status")
        if let env = try? OblienJSON.decode(StatusEnvelope.self, data) { return env.status }
        return try OblienJSON.decode(JSONValue.self, data)
    }

    public func logs(_ wid: String, tailLines: Int? = nil) async throws -> JSONValue {
        let query: [String: String?] = ["tail_lines": tailLines.map(String.init)]
        let data = try await transport.request("GET", itemPath(wid) + "/logs", query: query)
        return try OblienJSON.decode(JSONValue.self, data)
    }

    public func stats(_ wid: String) async throws -> JSONValue {
        let data = try await transport.request("GET", itemPath(wid) + "/stats")
        return try OblienJSON.decode(JSONValue.self, data)
    }
}

// MARK: - Models

/// A workload record. Shape is loosely documented, so most fields are optional and unknown
/// extras are preserved under `extra`.
public struct Workload: Codable, Sendable {
    public var id: String?
    public var name: String?
    public var status: String?          // running|stopped|exited|failed|pending
    public var command: [String]?
    public var cmd: [String]?
    public var env: [EnvVar]?
    public var restartPolicy: RestartPolicy?
    public var guestPid: Int?
    public var exitCode: Int?
    public var createdAt: String?
    public var startedAt: String?
    public var updatedAt: String?
    /// Any additional, undocumented fields the server returns.
    public var extra: JSONValue?

    public init(id: String? = nil, name: String? = nil, status: String? = nil,
                command: [String]? = nil, cmd: [String]? = nil, env: [EnvVar]? = nil,
                restartPolicy: RestartPolicy? = nil, guestPid: Int? = nil, exitCode: Int? = nil,
                createdAt: String? = nil, startedAt: String? = nil, updatedAt: String? = nil,
                extra: JSONValue? = nil) {
        self.id = id; self.name = name; self.status = status; self.command = command
        self.cmd = cmd; self.env = env; self.restartPolicy = restartPolicy; self.guestPid = guestPid
        self.exitCode = exitCode; self.createdAt = createdAt; self.startedAt = startedAt
        self.updatedAt = updatedAt; self.extra = extra
    }
}

/// Create/update params for a workload. Lenient: anything not captured by the typed fields
/// can be supplied via `extra` (merged into the request body as raw JSON).
public struct WorkloadCreateParams: Codable, Sendable {
    public var name: String?
    public var cmd: [String]?
    public var command: [String]?
    public var env: [EnvVar]?
    public var restartPolicy: RestartPolicy?
    public var maxRestarts: Int?
    public var keepLogs: Bool?
    public var autoStart: Bool?
    public var extra: JSONValue?

    public init(name: String? = nil, cmd: [String]? = nil, command: [String]? = nil,
                env: [EnvVar]? = nil, restartPolicy: RestartPolicy? = nil, maxRestarts: Int? = nil,
                keepLogs: Bool? = nil, autoStart: Bool? = nil, extra: JSONValue? = nil) {
        self.name = name; self.cmd = cmd; self.command = command; self.env = env
        self.restartPolicy = restartPolicy; self.maxRestarts = maxRestarts; self.keepLogs = keepLogs
        self.autoStart = autoStart; self.extra = extra
    }
}

// MARK: - Accessors

extension WorkspaceHandle {
    public var workloads: WorkloadsAPI { WorkloadsAPI(transport: transport, workspaceId: id) }
}

extension WorkspacesAPI {
    public func workloads(_ id: String) -> WorkloadsAPI { WorkloadsAPI(transport: transport, workspaceId: id) }
}
