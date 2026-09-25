import Foundation

public struct LogEntry: Codable, Sendable, Equatable {
    public let line: String
    public let timestamp: String?
    public let stream: String?
    public init(line: String, timestamp: String? = nil, stream: String? = nil) {
        self.line = line; self.timestamp = timestamp; self.stream = stream
    }

    /// The retained endpoint uses `[timestamp] stdout: line`; SSE supplies separate fields.
    static func retained(_ line: String) -> LogEntry {
        if line.hasPrefix("["), let end = line.firstIndex(of: "]") {
            let timestamp = String(line[line.index(after: line.startIndex)..<end])
            let suffix = line[line.index(after: end)...]
            let rest = String(suffix.hasPrefix(" ") ? suffix.dropFirst() : suffix)
            for stream in ["stdout", "stderr"] where rest.hasPrefix(stream + ": ") {
                return LogEntry(line: String(rest.dropFirst(stream.count + 2)), timestamp: timestamp, stream: stream)
            }
        }
        return LogEntry(line: line)
    }
}

/// Both retained log responses and SSE frames use the same parser. Clear notifications
/// are retained even when no new lines accompany them.
public struct LogBatch: Codable, Sendable, Equatable {
    public var entries: [LogEntry]
    public var cleared: Bool
    public init(entries: [LogEntry], cleared: Bool = false) { self.entries = entries; self.cleared = cleared }

    static func decode(_ data: Data) throws -> LogBatch {
        func lines(_ text: String) -> [LogEntry] {
            guard !text.isEmpty else { return [] }
            var lines = text.components(separatedBy: "\n")
            if text.hasSuffix("\n") { lines.removeLast() }
            return lines.map(LogEntry.retained)
        }
        guard let value = try? JSONDecoder().decode(JSONValue.self, from: data) else {
            guard let text = String(data: data, encoding: .utf8) else {
                throw OblienError(kind: .decoding, status: nil, code: nil, message: "Unsupported log encoding.", details: nil)
            }
            return LogBatch(entries: lines(text))
        }
        func entries(_ value: JSONValue) -> [LogEntry] {
            switch value {
            case .string(let text): return lines(text)
            case .array(let values): return values.flatMap(entries)
            case .object(let object):
                if let line = (object["line"] ?? object["text"] ?? object["message"])?.stringValue {
                    return [LogEntry(line: line, timestamp: object["timestamp"]?.stringValue, stream: object["stream"]?.stringValue)]
                }
                for key in ["entries", "logs", "data", "output"] {
                    if let nested = object[key] { return entries(nested) }
                }
                return ["stdout", "stderr"].flatMap { object[$0].map(entries) ?? [] }
            default: return []
            }
        }
        return LogBatch(entries: entries(value), cleared: value["cleared"]?.boolValue == true)
    }
}

func logBatchStream(transport: Transport, path: String, query: [String: String?]) -> AsyncThrowingStream<LogBatch, Error> {
    AsyncThrowingStream(bufferingPolicy: .bufferingOldest(512)) { continuation in
        let task = Task {
            do {
                let bytes = try await transport.openStream("GET", path, query: query)
                for try await event in sseEvents(bytes) {
                    try Task.checkCancellation()
                    let batch = try LogBatch.decode(Data(event.data.utf8))
                    guard batch.cleared || !batch.entries.isEmpty else { continue }
                    if case .dropped = continuation.yield(batch) {
                        throw OblienError(kind: .transport, status: nil, code: "log_viewer_slow",
                                          message: "Reconnect to load the latest retained logs.", details: nil)
                    }
                }
                continuation.finish()
            } catch { continuation.finish(throwing: error) }
        }
        continuation.onTermination = { _ in task.cancel() }
    }
}

extension LogsAPI {
    public func entries(source: String = "boot", tail: Int = 500) async throws -> LogBatch {
        try LogBatch.decode(await transport.request("GET", "/workspace/\(workspaceId.pathEscaped)/logs",
            query: ["source": source, "tail_lines": String(tail)]))
    }
    public func events(source: String = "boot", tail: Int = 500) -> AsyncThrowingStream<LogBatch, Error> {
        logBatchStream(transport: transport, path: "/workspace/\(workspaceId.pathEscaped)/logs/stream/\(source.pathEscaped)",
                       query: ["tail_lines": String(tail)])
    }

    /// Opens the subscription before reading retained output, then reconciles their overlap.
    /// The first batch replaces the current view; later batches append or signal a clear.
    public func follow(source: String = "boot", tail: Int = 500) -> AsyncThrowingStream<LogBatch, Error> {
        followLogStream(transport: transport,
            path: "/workspace/\(workspaceId.pathEscaped)/logs/stream/\(source.pathEscaped)",
            query: ["tail_lines": String(tail)], history: { try await entries(source: source, tail: tail) })
    }
}

extension WorkloadsAPI {
    public func followLogs(_ id: String, tail: Int = 500) -> AsyncThrowingStream<LogBatch, Error> {
        followLogStream(transport: transport,
            path: "/workspace/\(workspaceId.pathEscaped)/workloads/\(id.pathEscaped)/logs/stream",
            query: [:], history: { try await logEntries(id, tail: tail) })
    }
}

private func followLogStream(transport: Transport, path: String, query: [String: String?],
                             history: @escaping @Sendable () async throws -> LogBatch) -> AsyncThrowingStream<LogBatch, Error> {
    AsyncThrowingStream(bufferingPolicy: .bufferingOldest(512)) { continuation in
        let task = Task {
            do {
                // Wait for response headers before starting the snapshot. Live bytes are
                // buffered from this point, so lines written during the read cannot vanish.
                let bytes = try await transport.openStream("GET", path, query: query)
                let buffer = LogFollowBuffer(continuation: continuation)
                try await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask { try await buffer.seed(history()) }
                    group.addTask {
                        for try await event in sseEvents(bytes) {
                            try Task.checkCancellation()
                            try await buffer.receive(LogBatch.decode(Data(event.data.utf8)))
                        }
                    }
                    while try await group.next() != nil { }
                }
                continuation.finish()
            } catch { continuation.finish(throwing: error) }
        }
        continuation.onTermination = { _ in task.cancel() }
    }
}

actor LogFollowBuffer {
    private var pending = true
    private var buffered: [LogEntry] = []
    private var bytes = 0
    private var cleared = false
    private var boundary: LogHistoryBoundary?
    private let continuation: AsyncThrowingStream<LogBatch, Error>.Continuation

    init(continuation: AsyncThrowingStream<LogBatch, Error>.Continuation) { self.continuation = continuation }
    func receive(_ batch: LogBatch) throws {
        guard pending else {
            if batch.cleared { boundary = nil }
            var batch = batch
            if boundary != nil { batch.entries = boundary!.filter(batch.entries) }
            try emit(batch)
            return
        }
        if batch.cleared { buffered = []; bytes = 0; cleared = true }
        buffered += batch.entries
        bytes += batch.entries.reduce(0) { $0 + $1.line.utf8.count + 128 }
        guard buffered.count <= 2000, bytes <= 1_048_576 else { throw slowConsumer() }
    }
    func seed(_ history: LogBatch) throws {
        if !cleared { boundary = LogHistoryBoundary(history.entries) }
        let live = boundary?.filter(buffered, allowUntimed: true) ?? buffered
        let entries = (cleared ? [] : history.entries) + live
        pending = false; buffered = []; bytes = 0
        try emit(LogBatch(entries: entries, cleared: true))
    }
    private func emit(_ batch: LogBatch) throws {
        guard batch.cleared || !batch.entries.isEmpty else { return }
        switch continuation.yield(batch) {
        case .dropped: throw slowConsumer()
        case .terminated: throw CancellationError()
        case .enqueued: break
        @unknown default: break
        }
    }
    private func slowConsumer() -> Error {
        OblienError(kind: .transport, status: nil, code: "log_viewer_slow",
                    message: "Reconnect to load the latest retained logs.", details: nil)
    }
    /// Only deduplicate the snapshot/subscription boundary. Repeated live lines remain intact.
    static func join(history: [LogEntry], live: [LogEntry]) -> [LogEntry] {
        var boundary = LogHistoryBoundary(history)
        return history + boundary.filter(live, allowUntimed: true)
    }
}

/// Retained timestamps have second precision. Match the initial ordered sequence only;
/// after the first new event no subsequent live line is deduplicated. Keeping the cursor
/// after seeding also handles bytes already received but still awaiting parser delivery.
private struct LogHistoryBoundary {
    private let keys: [String]
    private var cursor = 0
    private var finished = false
    init(_ history: [LogEntry]) { keys = Self.keys(history) }

    mutating func filter(_ live: [LogEntry], allowUntimed: Bool = false) -> [LogEntry] {
        guard !finished, !live.isEmpty else { return live }
        let incoming = Self.keys(live)
        for (offset, key) in incoming.enumerated() {
            if !allowUntimed, live[offset].timestamp == nil {
                finished = true
                return Array(live.dropFirst(offset))
            }
            guard let index = keys.indices.dropFirst(cursor).first(where: { keys[$0] == key }) else {
                finished = true
                return Array(live.dropFirst(offset))
            }
            cursor = index + 1
            if cursor == keys.count {
                finished = true
                return Array(live.dropFirst(offset + 1))
            }
        }
        return []
    }
    private static func keys(_ values: [LogEntry]) -> [String] {
        let fractional = ISO8601DateFormatter(); fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let plain = ISO8601DateFormatter()
        return values.map { entry in
            let date = entry.timestamp.flatMap { fractional.date(from: $0) ?? plain.date(from: $0) }
            let time = date.map { String(Int64(floor($0.timeIntervalSince1970))) } ?? entry.timestamp ?? ""
            return time + "\u{0}" + (entry.stream ?? "") + "\u{0}" + entry.line
        }
    }
}
