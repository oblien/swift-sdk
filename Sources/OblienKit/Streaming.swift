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
                    buffer.append(chunk)
                    while let nl = buffer.firstIndex(of: 0x0A) { // 0x0A == '\n'
                        var line = String(decoding: buffer[buffer.startIndex..<nl], as: UTF8.self)
                        if line.hasSuffix("\r") { line.removeLast() }
                        continuation.yield(line)
                        buffer.removeSubrange(buffer.startIndex...nl)
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
                func flush() {
                    if !dataLines.isEmpty {
                        continuation.yield(SSEEvent(event: event, data: dataLines.joined(separator: "\n")))
                    }
                    event = nil
                    dataLines = []
                }
                for try await line in byteLines(chunks) {
                    if line.isEmpty { flush(); continue }
                    if line.hasPrefix(":") { continue } // comment / heartbeat
                    if line.hasPrefix("event:") {
                        event = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                    } else if line.hasPrefix("data:") {
                        dataLines.append(String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces))
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
    public enum Kind: Sendable, Equatable { case stdout, stderr, exit, taskId, other(String) }
    public let kind: Kind
    /// The raw SSE payload (base64 for stdout/stderr per the runtime protocol).
    public let raw: String

    public var data: Data? {
        (kind == .stdout || kind == .stderr) ? Data(base64Encoded: raw) : nil
    }
    public var text: String? { data.flatMap { String(data: $0, encoding: .utf8) } }

    init(_ sse: SSEEvent) {
        switch sse.event {
        case "stdout": kind = .stdout
        case "stderr": kind = .stderr
        case "exit": kind = .exit
        case "task_id": kind = .taskId
        case .some(let other): kind = .other(other)
        case .none: kind = .other("message")
        }
        raw = sse.data
    }
}

extension ExecAPI {
    /// Run a command and stream stdout/stderr/exit events (base64-decoded via `event.text`).
    public func stream(_ cmd: [String]) -> AsyncThrowingStream<ExecStreamEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    struct Body: Encodable { let cmd: [String]; let stream: Bool }
                    let body = try OblienJSON.encode(Body(cmd: cmd, stream: true))
                    let bytes = try await runtime.performStream("POST", "/exec", body: body)
                    for try await sse in sseEvents(bytes) {
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
}

extension FilesAPI {
    /// Stream a directory listing as NDJSON frames (terminated by `event == "done"`).
    public func streamList(_ params: FileListParams) -> AsyncThrowingStream<FileStreamFrame, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let bytes = try await runtime.performStream("GET", "/files/stream", query: params.query)
                    for try await line in byteLines(bytes) {
                        if line.isEmpty { continue }
                        guard let data = line.data(using: .utf8),
                              let frame = try? OblienJSON.decode(FileStreamFrame.self, data) else { continue }
                        if frame.event == "done" { break }
                        continuation.yield(frame)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// Download paths as a tar.gz archive.
    public func download(paths: [String], excludePatterns: [String]? = nil) async throws -> Data {
        struct Body: Encodable { let paths: [String]; let excludePatterns: [String]? }
        let body = try OblienJSON.encode(Body(paths: paths, excludePatterns: excludePatterns))
        return try await runtime.perform("POST", "/files/transfer/download", body: body)
    }

    /// Upload a tar.gz archive, extracting it under `dest`.
    public func upload(dest: String, tarGz: Data) async throws {
        _ = try await runtime.perform("POST", "/files/transfer/upload", query: ["dest": dest],
                                      body: tarGz, contentType: "application/gzip")
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
