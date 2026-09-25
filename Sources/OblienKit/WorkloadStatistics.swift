import Foundation

/// Native process measurements. The gateway may wrap one record or an array in a
/// `stats` event; older runtimes use the TypeScript declaration's usage field names.
public struct WorkloadProcessStats: Sendable, Equatable, Identifiable {
    public let id: String
    public let state: String?
    public let cpuPercent: Double?
    public let memoryBytes: Double?
    public let uptimeSeconds: Double?
    public let pid: Int?
    public let ports: [Int]?
    public let additionalProperties: [String: JSONValue]

    init(_ value: JSONValue, fallbackID: String?) throws {
        guard case .object(let fields) = value,
              let id = value["id"]?.stringValue ?? value["workload_id"]?.stringValue
                ?? value["id"]?.intValue.map(String.init) ?? value["workload_id"]?.intValue.map(String.init) ?? fallbackID,
              !id.isEmpty else {
            throw OblienError(kind: .decoding, status: nil, code: nil,
                              message: "A workload statistics record has no process ID.", details: nil)
        }
        self.id = id
        state = value["state"]?.stringValue ?? value["status"]?.stringValue
        func number(_ name: String) -> Double? {
            let result: Double?
            switch value[name] {
            case .number(let value): result = value
            case .string(let value): result = Double(value)
            default: result = nil
            }
            return result.flatMap { $0.isFinite && $0 >= 0 ? $0 : nil }
        }
        cpuPercent = number("cpu_percent") ?? number("cpu_usage")
        memoryBytes = number("rss_bytes") ?? number("memory_usage") ?? number("memory_mb").map { $0 * 1_048_576 }
        uptimeSeconds = number("uptime_seconds")
        pid = value["pid"]?.intValue
        if case .array(let values) = value["ports"] { ports = values.compactMap(\.intValue) }
        else { ports = nil }
        let known: Set<String> = ["id", "workload_id", "state", "status", "cpu_percent", "cpu_usage", "rss_bytes",
                                  "memory_usage", "memory_mb", "uptime_seconds", "pid", "ports"]
        additionalProperties = fields.filter { !known.contains($0.key) }
    }

    static func batch(_ value: JSONValue, fallbackID: String? = nil) throws -> [Self]? {
        let event = value["event"]?.stringValue ?? value["type"]?.stringValue
        if event == "error" || value["success"]?.boolValue == false {
            throw OblienError(kind: .transport, status: nil, code: nil,
                              message: value["message"]?.stringValue ?? "The workload statistics stream failed.", details: nil)
        }
        if let event, event != "stats" { return nil }
        let payload = value["data"] ?? value["stats"] ?? value
        if case .array(let records) = payload { return try records.map { try Self($0, fallbackID: fallbackID) } }
        if case .object(let fields) = payload, event == "stats" {
            // The current gateway spreads its runtime array into an object before
            // adding `type`: {"0": {...}, "1": {...}, "type": "stats"}.
            let indexed = fields.compactMap { key, value -> (Int, JSONValue)? in
                guard let index = Int(key), index >= 0 else { return nil }
                return (index, value)
            }.sorted { $0.0 < $1.0 }
            if !indexed.isEmpty { return try indexed.map { try Self($0.1, fallbackID: fallbackID) } }
            if fields.keys.allSatisfy({ $0 == "type" || $0 == "event" }) { return [] }
        }
        return [try Self(payload, fallbackID: fallbackID)]
    }
}

extension WorkloadsAPI {
    /// Decodes both the current gateway's event envelope and older direct records.
    /// Omit the ID for a single subscription covering every process in the workspace.
    public func processStatsStream(_ id: String? = nil) -> AsyncThrowingStream<[WorkloadProcessStats], Error> {
        let source = id.map(statsStream) ?? allStatsStream()
        return AsyncThrowingStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let task = Task {
                do {
                    for try await event in source {
                        try Task.checkCancellation()
                        if let records = try WorkloadProcessStats.batch(event, fallbackID: id) { continuation.yield(records) }
                    }
                    continuation.finish()
                } catch { continuation.finish(throwing: error) }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
