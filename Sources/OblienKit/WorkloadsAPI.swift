import Foundation

/// Workloads — the long-running processes inside a workspace (`client.workspaces.workloads(id)` / `handle.workloads`).
/// Typed configuration, lifecycle, bounded logs and live log events.
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

    public func list(states: String? = nil, name: String? = nil) async throws -> [Workload] {
        let data = try await transport.request("GET", base, query: ["states": states, "name": name])
        if let env = try? OblienJSON.decode(WorkloadsEnvelope.self, data) { return env.workloads }
        return try OblienJSON.decode([Workload].self, data)
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
        let query: [String: String?] = ["tail": tailLines.map(String.init)]
        let data = try await transport.request("GET", itemPath(wid) + "/logs", query: query)
        return try OblienJSON.decode(JSONValue.self, data)
    }

    public func stats(_ wid: String) async throws -> JSONValue {
        let data = try await transport.request("GET", itemPath(wid) + "/stats")
        return try OblienJSON.decode(JSONValue.self, data)
    }

    public func logConfig(_ wid: String) async throws -> WorkloadLogConfig {
        try OblienJSON.decode(WorkloadLogConfig.self, await transport.request("GET", itemPath(wid) + "/logs/config"))
    }
    public func clearLogs(_ wid: String) async throws {
        _ = try await transport.request("DELETE", itemPath(wid) + "/logs")
    }
    public func setLogRetention(_ wid: String, maxLogSizeMb: Int, logRetentionHours: Int) async throws {
        struct Body: Encodable { let maxLogSizeMb: Int; let logRetentionHours: Int }
        _ = try await transport.request("PATCH", itemPath(wid),
            body: OblienJSON.encode(Body(maxLogSizeMb: maxLogSizeMb, logRetentionHours: logRetentionHours)))
    }
    public func logEntries(_ wid: String, tail: Int = 500) async throws -> LogBatch {
        try LogBatch.decode(await transport.request("GET", itemPath(wid) + "/logs", query: ["tail": String(tail)]))
    }
    /// Future output. Load `logEntries` separately for history: the runtime does not
    /// replay retained lines on this stream. On `cleared`, discard previously shown entries.
    public func logsStream(_ wid: String, tail: Int = 500) -> AsyncThrowingStream<LogBatch, Error> {
        logBatchStream(transport: transport, path: itemPath(wid) + "/logs/stream", query: ["tail": String(tail)])
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
    public var state: String?
    public var target: String?
    public var pid: Int?
    public var enabled: Bool?
    public var workingDir: String?
    public var maxRestarts: Int?
    public var restartCount: Int?
    public var origin: String?
    public var maxLogSizeMb: Int?
    public var logRetentionHours: Int?

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

    enum CodingKeys: String, CodingKey {
        case id, name, status, command, cmd, env, restartPolicy, guestPid, exitCode, createdAt,
             startedAt, updatedAt, extra, state, target, pid, enabled, workingDir, maxRestarts,
             restartCount, origin, maxLogSizeMb, logRetentionHours
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? c.decode(String.self, forKey: .id) { id = value }
        else if let value = try? c.decode(Int.self, forKey: .id) { id = String(value) }
        else { id = nil }
        name = try c.decodeIfPresent(String.self, forKey: .name)
        status = try c.decodeIfPresent(String.self, forKey: .status)
        command = try c.decodeIfPresent([String].self, forKey: .command)
        cmd = try c.decodeIfPresent([String].self, forKey: .cmd)
        env = try decodeEnvironment(c, key: .env)
        restartPolicy = try c.decodeIfPresent(String.self, forKey: .restartPolicy).flatMap(RestartPolicy.init(rawValue:))
        guestPid = try c.decodeIfPresent(Int.self, forKey: .guestPid)
        exitCode = try c.decodeIfPresent(Int.self, forKey: .exitCode)
        createdAt = try c.decodeIfPresent(String.self, forKey: .createdAt)
        startedAt = try c.decodeIfPresent(String.self, forKey: .startedAt)
        updatedAt = try c.decodeIfPresent(String.self, forKey: .updatedAt)
        extra = try c.decodeIfPresent(JSONValue.self, forKey: .extra)
        state = try c.decodeIfPresent(String.self, forKey: .state)
        target = try c.decodeIfPresent(String.self, forKey: .target)
        pid = try c.decodeIfPresent(Int.self, forKey: .pid)
        enabled = try c.decodeIfPresent(Bool.self, forKey: .enabled)
        workingDir = try c.decodeIfPresent(String.self, forKey: .workingDir)
        maxRestarts = try c.decodeIfPresent(Int.self, forKey: .maxRestarts)
        restartCount = try c.decodeIfPresent(Int.self, forKey: .restartCount)
        origin = try c.decodeIfPresent(String.self, forKey: .origin)
        maxLogSizeMb = try c.decodeIfPresent(Int.self, forKey: .maxLogSizeMb)
        logRetentionHours = try c.decodeIfPresent(Int.self, forKey: .logRetentionHours)
            let raw = try [String: JSONValue](from: decoder)
        let known: Set<String> = ["id", "name", "status", "command", "cmd", "env", "restart_policy", "guest_pid", "exit_code", "created_at", "started_at", "updated_at", "extra", "state", "target", "pid", "enabled", "working_dir", "max_restarts", "restart_count", "origin", "max_log_size_mb", "log_retention_hours"]
        var unknown = raw.filter { !known.contains($0.key) }
        if case .object(let legacy) = extra { unknown.merge(legacy) { existing, _ in existing } }
        extra = unknown.isEmpty ? nil : .object(unknown)
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
    public var workingDir: String?
    public var target: String?
    public var maxLogSizeMb: Int?
    public var logRetentionHours: Int?
    public var labels: [String: String]?
    public var user: String?
    public var restartDelay: Int?
    public var restartBackoff: Bool?
    public var logPath: String?
    public var vmOnExit: String?
    public var annotations: [String: String]?
    public var enabled: Bool?
    public var id: String?

    public init(name: String? = nil, cmd: [String]? = nil, command: [String]? = nil,
                env: [EnvVar]? = nil, restartPolicy: RestartPolicy? = nil, maxRestarts: Int? = nil,
                keepLogs: Bool? = nil, autoStart: Bool? = nil, extra: JSONValue? = nil,
                workingDir: String? = nil, target: String? = nil, maxLogSizeMb: Int? = nil,
                logRetentionHours: Int? = nil, labels: [String: String]? = nil,
                user: String? = nil, restartDelay: Int? = nil, restartBackoff: Bool? = nil,
                logPath: String? = nil, vmOnExit: String? = nil, annotations: [String: String]? = nil,
                enabled: Bool? = nil, id: String? = nil) {
        self.name = name; self.cmd = cmd; self.command = command; self.env = env
        self.restartPolicy = restartPolicy; self.maxRestarts = maxRestarts; self.keepLogs = keepLogs
        self.autoStart = autoStart; self.extra = extra
        self.workingDir = workingDir; self.target = target; self.maxLogSizeMb = maxLogSizeMb
        self.logRetentionHours = logRetentionHours; self.labels = labels
        self.user = user; self.restartDelay = restartDelay; self.restartBackoff = restartBackoff
        self.logPath = logPath; self.vmOnExit = vmOnExit; self.annotations = annotations
        self.enabled = enabled; self.id = id
    }

    public func encode(to encoder: Encoder) throws {
        var body: [String: JSONValue] = [:]
        if case .object(let value) = extra { body = value }
        func string(_ key: String, _ value: String?) { if let value { body[key] = .string(value) } }
        func integer(_ key: String, _ value: Int?) { if let value { body[key] = .number(Double(value)) } }
        func strings(_ key: String, _ value: [String]?) { if let value { body[key] = .array(value.map(JSONValue.string)) } }
        string("name", name); strings("cmd", cmd); strings("command", command)
        strings("env", env?.map { "\($0.key)=\($0.value)" })
        string("restart_policy", restartPolicy?.rawValue); integer("max_restarts", maxRestarts)
        if let keepLogs { body["keep_logs"] = .bool(keepLogs) }
        if let autoStart { body["auto_start"] = .bool(autoStart) }
        string("working_dir", workingDir); string("target", target)
        integer("max_log_size_mb", maxLogSizeMb); integer("log_retention_hours", logRetentionHours)
        if let labels { body["labels"] = .object(labels.mapValues(JSONValue.string)) }
        string("user", user); integer("restart_delay", restartDelay); string("log_path", logPath)
        string("vm_on_exit", vmOnExit); string("id", id)
        if let restartBackoff { body["restart_backoff"] = .bool(restartBackoff) }
        if let enabled { body["enabled"] = .bool(enabled) }
        if let annotations { body["annotations"] = .object(annotations.mapValues(JSONValue.string)) }
        try body.encode(to: encoder)
    }

    enum CodingKeys: String, CodingKey {
        case name, cmd, command, env, restartPolicy, maxRestarts, keepLogs, autoStart, extra,
             workingDir, target, maxLogSizeMb, logRetentionHours, labels, user, restartDelay,
             restartBackoff, logPath, vmOnExit, annotations, enabled, id
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        cmd = try c.decodeIfPresent([String].self, forKey: .cmd)
        command = try c.decodeIfPresent([String].self, forKey: .command)
        env = try decodeEnvironment(c, key: .env)
        restartPolicy = try c.decodeIfPresent(String.self, forKey: .restartPolicy).flatMap(RestartPolicy.init(rawValue:))
        maxRestarts = try c.decodeIfPresent(Int.self, forKey: .maxRestarts)
        keepLogs = try c.decodeIfPresent(Bool.self, forKey: .keepLogs)
        autoStart = try c.decodeIfPresent(Bool.self, forKey: .autoStart)
        extra = try c.decodeIfPresent(JSONValue.self, forKey: .extra)
        workingDir = try c.decodeIfPresent(String.self, forKey: .workingDir)
        target = try c.decodeIfPresent(String.self, forKey: .target)
        maxLogSizeMb = try c.decodeIfPresent(Int.self, forKey: .maxLogSizeMb)
        logRetentionHours = try c.decodeIfPresent(Int.self, forKey: .logRetentionHours)
        labels = try c.decodeIfPresent([String: String].self, forKey: .labels)
        user = try c.decodeIfPresent(String.self, forKey: .user)
        restartDelay = try c.decodeIfPresent(Int.self, forKey: .restartDelay)
        restartBackoff = try c.decodeIfPresent(Bool.self, forKey: .restartBackoff)
        logPath = try c.decodeIfPresent(String.self, forKey: .logPath)
        vmOnExit = try c.decodeIfPresent(String.self, forKey: .vmOnExit)
        annotations = try c.decodeIfPresent([String: String].self, forKey: .annotations)
        enabled = try c.decodeIfPresent(Bool.self, forKey: .enabled)
        id = try c.decodeIfPresent(String.self, forKey: .id)
            let raw = try [String: JSONValue](from: decoder)
        let known: Set<String> = ["name", "cmd", "command", "env", "restart_policy", "max_restarts", "keep_logs", "auto_start", "extra", "working_dir", "target", "max_log_size_mb", "log_retention_hours", "labels", "user", "restart_delay", "restart_backoff", "log_path", "vm_on_exit", "annotations", "enabled", "id"]
        var unknown = raw.filter { !known.contains($0.key) }
        if case .object(let legacy) = extra { unknown.merge(legacy) { existing, _ in existing } }
        extra = unknown.isEmpty ? nil : .object(unknown)
    }
}

private func decodeEnvironment<Key: CodingKey>(_ container: KeyedDecodingContainer<Key>, key: Key) throws -> [EnvVar]? {
    try environmentValues(container.decodeIfPresent(JSONValue.self, forKey: key))
}

public struct WorkloadLogConfig: Codable, Sendable {
    public var maxLogSizeMb: Int?
    public var logRetentionHours: Int?
    public var storedBytes: Int?
    public var droppedLines: Int?
}

// MARK: - Accessors

extension WorkspaceHandle {
    public var workloads: WorkloadsAPI { WorkloadsAPI(transport: transport, workspaceId: id) }
}

extension WorkspacesAPI {
    public func workloads(_ id: String) -> WorkloadsAPI { WorkloadsAPI(transport: transport, workspaceId: id) }
}
