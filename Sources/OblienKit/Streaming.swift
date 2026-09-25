import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - SSE / NDJSON helpers

struct SSEEvent: Sendable {
    let event: String?
    let data: String
}

/// Split a live stream of response-body `Data` chunks into lines (`\n`-delimited, `\r` trimmed),
/// yielding each COMPLETE line as it arrives. Shared by the SSE and NDJSON parsers so both consume
/// the delegate-backed byte stream incrementally (no waiting for the response to finish).
func byteLines(_ chunks: AsyncThrowingStream<Data, Error>) -> AsyncThrowingStream<String, Error> {
    AsyncThrowingStream { continuation in
        let task = Task {
            do {
                var buffer = Data()
                for try await chunk in chunks {
                    try Task.checkCancellation()
                    buffer.append(chunk)
                    while let nl = buffer.firstIndex(of: 0x0A) { // 0x0A == '\n'
                        guard buffer.distance(from: buffer.startIndex, to: nl) <= 2 * 1024 * 1024 else {
                            throw OblienError(kind: .decoding, status: nil, code: "stream_line_too_large", message: "The stream returned an oversized line.", details: nil)
                        }
                        var line = String(decoding: buffer[buffer.startIndex..<nl], as: UTF8.self)
                        if line.hasSuffix("\r") { line.removeLast() }
                        continuation.yield(line)
                        buffer.removeSubrange(buffer.startIndex...nl)
                    }
                    guard buffer.count <= 2 * 1024 * 1024 else {
                        throw OblienError(kind: .decoding, status: nil, code: "stream_line_too_large",
                                          message: "The stream returned an oversized line.", details: nil)
                    }
                }
                if !buffer.isEmpty { // trailing partial line with no final newline
                    continuation.yield(String(decoding: buffer, as: UTF8.self))
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
        continuation.onTermination = { _ in task.cancel() }
    }
}

/// Parse a byte stream as Server-Sent Events, emitting one `SSEEvent` per `data:` block.
func sseEvents(_ chunks: AsyncThrowingStream<Data, Error>) -> AsyncThrowingStream<SSEEvent, Error> {
    AsyncThrowingStream { continuation in
        let task = Task {
            do {
                var event: String?
                var dataLines: [String] = []
                var eventSize = 0
                func flush() {
                    if !dataLines.isEmpty {
                        continuation.yield(SSEEvent(event: event, data: dataLines.joined(separator: "\n")))
                    }
                    event = nil
                    dataLines = []
                    eventSize = 0
                }
                for try await line in byteLines(chunks) {
                    if line.isEmpty { flush(); continue }
                    if line.hasPrefix(":") { continue } // comment / heartbeat
                    if line.hasPrefix("event:") {
                        event = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                    } else if line.hasPrefix("data:") {
                        var value = String(line.dropFirst(5))
                        if value.hasPrefix(" ") { value.removeFirst() }
                        eventSize += value.utf8.count
                        guard eventSize <= 2 * 1024 * 1024 else {
                            throw OblienError(kind: .decoding, status: nil, code: "stream_event_too_large",
                                              message: "The stream returned an oversized event.", details: nil)
                        }
                        dataLines.append(value)
                    }
                }
                flush()
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
        continuation.onTermination = { _ in task.cancel() }
    }
}

// MARK: - Exec streaming

public struct ExecStreamEvent: Sendable {
    public enum Kind: Sendable, Equatable { case stdout, stderr, output, exit, taskId, other(String) }
    public let kind: Kind
    /// Original SSE data, preserved for unknown event types.
    public let raw: String
    public let payload: JSONValue?
    public var taskId: String? { payload?["task_id"]?.stringValue }
    public var exitCode: Int? { payload?["exit_code"]?.intValue }
    public var pid: Int? { payload?["pid"]?.intValue }
    public var status: String? { payload?["status"]?.stringValue }
    public var stdout: String? { payload?["stdout"]?.stringValue }
    public var stderr: String? { payload?["stderr"]?.stringValue }

    public var data: Data? {
        guard kind == .stdout || kind == .stderr else { return nil }
        let value = payload?["data"]?.stringValue ?? raw
        if ["utf8", "text"].contains(payload?["encoding"]?.stringValue ?? "") { return Data(value.utf8) }
        // The live runtime sends {"data":"<base64>"}. Decode that field, not the
        // entire JSON envelope. Plain-text events from older gateways still work.
        return Data(base64Encoded: value) ?? Data(value.utf8)
    }
    public var text: String? { data.flatMap { String(data: $0, encoding: .utf8) } }

    init(_ sse: SSEEvent) {
        payload = try? JSONDecoder().decode(JSONValue.self, from: Data(sse.data.utf8))
        switch sse.event ?? payload?["event"]?.stringValue {
        case "stdout": kind = .stdout
        case "stderr": kind = .stderr
        case "output": kind = .output
        case "exit": kind = .exit
        case "task_id": kind = .taskId
        case .some(let other): kind = .other(other)
        case .none: kind = .other("message")
        }
        raw = sse.data
    }
}

extension ExecAPI {
    /// Run a command and stream task-id, output and exit events.
    public func stream(_ cmd: [String], timeoutSeconds: Int? = nil, execMode: ExecMode? = nil,
                       ttlSeconds: Int? = nil, keepLogs: Bool? = nil) -> AsyncThrowingStream<ExecStreamEvent, Error> {
        execEvents(method: "POST", command: ExecRequest(cmd: cmd, timeoutSeconds: timeoutSeconds, execMode: execMode,
                                                       ttlSeconds: ttlSeconds, keepLogs: keepLogs))
    }

    /// Reattach to an existing execution without starting a second process.
    public func subscribe(_ taskId: String) -> AsyncThrowingStream<ExecStreamEvent, Error> {
        execEvents(method: "GET", taskId: taskId)
    }

    private func execEvents(method: String, command: ExecRequest? = nil, taskId: String? = nil) -> AsyncThrowingStream<ExecStreamEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let body = try command.map { try OblienJSON.encode($0) }
                    let bytes = try await runtime.performStream(method, "/exec/stream", query: ["task_id": taskId], body: body)
                    for try await sse in sseEvents(bytes) where sse.data != "[DONE]" {
                        let event = ExecStreamEvent(sse)
                        continuation.yield(event)
                        if event.kind == .exit { break }
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

// MARK: - Files streaming + transfer

public struct FileStreamFrame: Codable, Sendable {
    public let event: String?
    public let path: String?
    public let count: Int?
    public let name: String?
    public let type: String?
    public let size: Int?
    public let modified: String?
    public let fileExtension: String?
    public let content: String?
    public let hash: String?
    public let children: [FileEntry]?
    enum CodingKeys: String, CodingKey {
        case event, path, count, name, type, size, modified, content, hash, children
        case fileExtension = "extension"
    }
    public var entry: FileEntry? {
        guard event == nil, let name, let path, let type else { return nil }
        return FileEntry(name: name, path: path, type: type, size: size, modified: modified,
                         fileExtension: fileExtension, content: content, hash: hash, children: children)
    }
}

extension FilesAPI {
    /// Stream a directory listing as NDJSON frames (terminated by `event == "done"`).
    public func streamList(_ params: FileListParams = .init()) -> AsyncThrowingStream<FileStreamFrame, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let bytes = try await runtime.performStream("GET", "/files/stream", query: params.query)
                    for try await line in byteLines(bytes) {
                        if line.isEmpty { continue }
                        let frame = try OblienJSON.decode(FileStreamFrame.self, Data(line.utf8))
                        continuation.yield(frame)
                        if frame.event == "done" { break }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// File entries retain all listing metadata and optional file contents.
    public func stream(_ params: FileListParams = .init()) -> AsyncThrowingStream<FileEntry, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await frame in streamList(params) {
                        if let entry = frame.entry { continuation.yield(entry) }
                    }
                    continuation.finish()
                } catch { continuation.finish(throwing: error) }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// Download paths as a tar.gz archive.
    public func download(paths: [String], excludePatterns: [String]? = nil) async throws -> Data {
        let response = try await runtime.transfer.download(paths: paths, excludePatterns: excludePatterns)
        var data = Data()
        for try await chunk in response.chunks { data.append(chunk) }
        return data
    }

    /// Upload a tar.gz archive, extracting it under `dest`.
    public func upload(dest: String, tarGz: Data) async throws {
        _ = try await runtime.transfer.upload(dest: dest, tarGz: tarGz)
    }
}

// MARK: - Logs streaming

extension LogsAPI {
    /// Stream the boot log (SSE, one line per event).
    public func streamBoot(tailLines: Int? = nil) -> AsyncThrowingStream<String, Error> {
        logLineStream("/workspace/\(workspaceId.pathEscaped)/logs/stream/boot", tailLines)
    }
    /// Stream the command log (SSE, one line per event).
    public func streamCmd(tailLines: Int? = nil) -> AsyncThrowingStream<String, Error> {
        logLineStream("/workspace/\(workspaceId.pathEscaped)/logs/stream/cmd", tailLines)
    }

    private func logLineStream(_ path: String, _ tailLines: Int?) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    struct Line: Decodable { let line: String? }
                    let bytes = try await transport.openStream("GET", path, query: ["tail_lines": tailLines.map(String.init)])
                    for try await sse in sseEvents(bytes) {
                        if let data = sse.data.data(using: .utf8),
                           let parsed = try? OblienJSON.decode(Line.self, data), let line = parsed.line {
                            continuation.yield(line)
                        } else if !sse.data.isEmpty {
                            continuation.yield(sse.data)
                        }
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

// MARK: - Metrics streaming

extension MetricsAPI {
    /// Live stats over SSE (15s heartbeat).
    public func statsStream() -> AsyncThrowingStream<Stats, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    struct Envelope: Decodable { let stats: Stats }
                    let bytes = try await transport.openStream("GET", "/workspace/\(workspaceId.pathEscaped)/stats/stream")
                    for try await sse in sseEvents(bytes) {
                        guard let data = sse.data.data(using: .utf8) else { continue }
                        if let env = try? OblienJSON.decode(Envelope.self, data) {
                            continuation.yield(env.stats)
                        } else if let stats = try? OblienJSON.decode(Stats.self, data) {
                            continuation.yield(stats)
                        }
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
