import Foundation

/// Transparent reverse-proxy to a loopback port inside the workspace (`127.0.0.1:<port>`), reached
/// via `rt.proxy(port)`. Returns the upstream response **verbatim** — status + body, non-2xx
/// included (the upstream's status is the real signal, so it is NOT mapped to an error). Mirrors
/// the TS SDK's `rt.proxy(port).fetch(...)`. Streaming can be added later via `openStream`.
public struct ProxyAPI: Sendable {
    let runtime: RuntimeClient
    let port: Int

    /// Forward `method path` to the loopback service. `path` should begin with "/". `body`, when
    /// present, is sent with `contentType` (default JSON).
    public func request(method: String, path: String, body: Data? = nil,
                        contentType: String? = "application/json") async throws -> (status: Int, body: Data) {
        let result = try await runtime.proxyRequest(port: port, method: method, path: path,
                                                    body: body, contentType: body == nil ? nil : contentType)
        return (status: result.status, body: result.data)
    }

    /// Stream an SSE response from the loopback service — one `Data` per `data:` block (the raw
    /// JSON payload). For long-lived event streams (e.g. the daemon's `/runs/{id}/stream`). JWT +
    /// 401-refresh are inherited from `proxyStream`.
    public func stream(method: String, path: String, body: Data? = nil) -> AsyncThrowingStream<Data, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let bytes = try await runtime.proxyStream(port: port, method: method, path: path, body: body)
                    for try await sse in sseEvents(bytes) where !sse.data.isEmpty {
                        continuation.yield(Data(sse.data.utf8))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

/// Runtime files API (`rt.files.*`).
public struct FilesAPI: Sendable {
    let runtime: RuntimeClient

    public func list(_ params: FileListParams) async throws -> FileListResult {
        let data = try await runtime.perform("GET", "/files", query: params.query)
        return try OblienJSON.decode(FileListResult.self, data)
    }
    public func list(path: String) async throws -> FileListResult { try await list(FileListParams(path: path)) }

    public func read(path: String, startLine: Int? = nil, endLine: Int? = nil, withLineNumbers: Bool = false) async throws -> FileRead {
        let query: [String: String?] = ["path": path, "start_line": startLine.map(String.init),
                                        "end_line": endLine.map(String.init),
                                        "with_line_numbers": withLineNumbers ? "true" : nil]
        let data = try await runtime.perform("GET", "/files/read", query: query)
        return try OblienJSON.decode(FileRead.self, data)
    }

    public func write(fullPath: String, content: String, createDirs: Bool = false,
                      append: Bool = false, mode: String? = nil) async throws -> FileWriteResult {
        struct Body: Encodable { let path: String; let content: String; let createDirs: Bool; let append: Bool; let mode: String? }
        let body = try OblienJSON.encode(Body(path: fullPath, content: content, createDirs: createDirs, append: append, mode: mode))
        let data = try await runtime.perform("POST", "/files/write", body: body)
        return try OblienJSON.decode(FileWriteResult.self, data)
    }

    public func mkdir(path: String, mode: String? = nil) async throws {
        struct Body: Encodable { let path: String; let mode: String? }
        let body = try OblienJSON.encode(Body(path: path, mode: mode))
        _ = try await runtime.perform("POST", "/files/mkdir", body: body)
    }

    public func stat(path: String) async throws -> FileStat {
        let data = try await runtime.perform("GET", "/files/stat", query: ["path": path])
        return try OblienJSON.decode(FileStat.self, data)
    }

    public func delete(path: String) async throws {
        _ = try await runtime.perform("DELETE", "/files/delete", query: ["path": path])
    }
}

/// Runtime exec API (`rt.exec.*`).
public struct ExecAPI: Sendable {
    let runtime: RuntimeClient
    private struct TasksEnvelope: Decodable { let tasks: [ExecTask] }

    public func run(_ cmd: [String], timeoutSeconds: Int? = nil, execMode: ExecMode? = nil, ttlSeconds: Int? = nil) async throws -> ExecTask {
        struct Body: Encodable { let cmd: [String]; let timeoutSeconds: Int?; let execMode: ExecMode?; let ttlSeconds: Int? }
        let body = try OblienJSON.encode(Body(cmd: cmd, timeoutSeconds: timeoutSeconds, execMode: execMode, ttlSeconds: ttlSeconds))
        let data = try await runtime.perform("POST", "/exec", body: body)
        return try OblienJSON.decode(ExecTask.self, data)
    }
    public func list() async throws -> [ExecTask] {
        let data = try await runtime.perform("GET", "/exec")
        return (try? OblienJSON.decode(TasksEnvelope.self, data).tasks) ?? []
    }
    public func get(_ id: String) async throws -> ExecTask {
        let data = try await runtime.perform("GET", "/exec/\(id.pathEscaped)")
        return try OblienJSON.decode(ExecTask.self, data)
    }
    public func kill(_ id: String) async throws {
        _ = try await runtime.perform("DELETE", "/exec/\(id.pathEscaped)")
    }
}

/// Runtime terminal API (`rt.terminal.*`). For live I/O use `RuntimeClient.openTerminal`.
public struct TerminalAPI: Sendable {
    let runtime: RuntimeClient

    public func create(cmd: [String]? = nil, cols: Int? = nil, rows: Int? = nil) async throws -> TerminalCreateResult {
        struct Body: Encodable { let cmd: [String]?; let cols: Int?; let rows: Int? }
        let body = try OblienJSON.encode(Body(cmd: cmd, cols: cols, rows: rows))
        let data = try await runtime.perform("POST", "/terminals", body: body)
        return try OblienJSON.decode(TerminalCreateResult.self, data)
    }
    public func close(_ id: Int) async throws {
        _ = try await runtime.perform("DELETE", "/terminals/\(id)")
    }
}

/// Runtime code search (`rt.search.*`).
public struct SearchAPI: Sendable {
    let runtime: RuntimeClient
    private struct FilesEnvelope: Decodable { let files: [String] }

    public func files(_ query: String, path: String? = nil,
                      ignorePatterns: String? = nil, includeHidden: Bool? = nil) async throws -> [String] {
        let data = try await runtime.perform("GET", "/files/search/files",
                                             query: ["q": query, "path": path,
                                                     "ignore_patterns": ignorePatterns,
                                                     "include_hidden": includeHidden.map(String.init)])
        return (try? OblienJSON.decode(FilesEnvelope.self, data).files) ?? []
    }
    public func content(_ query: String, path: String? = nil) async throws -> JSONValue {
        let data = try await runtime.perform("GET", "/files/search", query: ["q": query, "path": path])
        return try OblienJSON.decode(JSONValue.self, data)
    }
}

/// Runtime filesystem watchers (`rt.watcher.*`). Events stream over `RuntimeClient.websocketURL()`.
public struct WatcherAPI: Sendable {
    let runtime: RuntimeClient

    public func create(path: String, excludes: [String]? = nil) async throws -> JSONValue {
        struct Body: Encodable { let path: String; let excludes: [String]? }
        let body = try OblienJSON.encode(Body(path: path, excludes: excludes))
        return try OblienJSON.decode(JSONValue.self, try await runtime.perform("POST", "/watchers", body: body))
    }
    public func list() async throws -> JSONValue {
        try OblienJSON.decode(JSONValue.self, try await runtime.perform("GET", "/watchers"))
    }
    public func delete(_ id: String) async throws {
        _ = try await runtime.perform("DELETE", "/watchers/\(id.pathEscaped)")
    }
}
