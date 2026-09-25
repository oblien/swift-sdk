import Foundation

public struct WorkspaceCreditEstimate: Codable, Sendable {
    public var estimate: Range
    public var period: String
    public struct Range: Codable, Sendable {
        public var min: Double
        public var avg: Double
        public var max: Double
    }
}

public struct WorkspaceWaitOptions: Sendable {
    public var timeout: TimeInterval
    public var pollInterval: TimeInterval
    public var onProgress: (@Sendable (Workspace) async -> Void)?
    public init(timeout: TimeInterval = 600, pollInterval: TimeInterval = 2,
                onProgress: (@Sendable (Workspace) async -> Void)? = nil) {
        self.timeout = timeout; self.pollInterval = pollInterval; self.onProgress = onProgress
    }
    func validate() throws {
        guard timeout.isFinite, timeout > 0, pollInterval.isFinite, pollInterval > 0, pollInterval <= 3600 else {
            throw OblienError(kind: .validation, status: nil, code: nil, message: "Use positive, finite readiness timing values.", details: nil)
        }
    }
}

extension WorkspaceHandle {
    public func retryCreation() async throws -> Workspace { try await retryProvisioning() }
    public func waitUntilReady(options: WorkspaceWaitOptions) async throws -> Workspace {
        try await WorkspacesAPI(transport: transport).waitUntilReady(id, options: options)
    }
}

/// Durations accept seconds or values such as `"15m"`, matching the management API.
public struct IdlePolicy: Codable, Sendable {
    public var suspendAfter: JSONValue
    public var stopAfter: JSONValue?
    public init(suspendAfter: JSONValue, stopAfter: JSONValue? = nil) {
        self.suspendAfter = suspendAfter; self.stopAfter = stopAfter
    }
}

public struct MacOSBootConfig: Codable, Sendable {
    public var agent: String?
    public var network: String?
    public var storage: String?
    public var diskCache: String?
    public var bootArgs: String?
    public var ports: [Port]?
    public init(agent: String? = nil, network: String? = nil, storage: String? = nil,
                diskCache: String? = nil, bootArgs: String? = nil, ports: [Port]? = nil) {
        self.agent = agent; self.network = network; self.storage = storage
        self.diskCache = diskCache; self.bootArgs = bootArgs; self.ports = ports
    }
    public struct Port: Codable, Sendable {
        public var host: Int
        public var guest: Int
        public var `protocol`: String?
        public init(host: Int, guest: Int, protocol: String? = nil) {
            self.host = host; self.guest = guest; self.protocol = `protocol`
        }
    }
}

/// Flattened JSON keeps unknown option names untouched. Typed fields have precedence.
struct JSONFields {
    var values: [String: JSONValue]
    init(_ values: [String: JSONValue] = [:]) { self.values = values }
    init(from decoder: Decoder) throws {
        // Decode through the container so JSONDecoder uses its dictionary path, which
        // preserves literal keys even when the surrounding model uses snake-case conversion.
        values = try decoder.singleValueContainer().decode([String: JSONValue].self)
    }
    mutating func set<Value: Encodable>(_ key: String, _ value: Value?) throws {
        if let value { values[key] = try JSONDecoder().decode(JSONValue.self, from: OblienJSON.encode(value)) }
    }
    mutating func take<Value: Decodable>(_ key: String, as: Value.Type = Value.self) throws -> Value? {
        let parts = key.split(separator: "_")
        let camelKey = (parts.first.map(String.init) ?? key) + parts.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined()
        let raw = values.removeValue(forKey: key) ?? values.removeValue(forKey: camelKey)
        guard let raw, raw != .null else { return nil }
        return try OblienJSON.decode(Value.self, JSONEncoder().encode(raw))
    }
    mutating func required<Value: Decodable>(_ key: String, as: Value.Type) throws -> Value {
        guard let value: Value = try take(key) else {
            throw OblienError(kind: .decoding, status: nil, code: nil, message: "Missing required response field: \(key).", details: nil)
        }
        return value
    }
    func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(values) }
}

func environmentValues(_ raw: JSONValue?) throws -> [EnvVar]? {
    guard let raw, raw != .null else { return nil }
    guard case .array(let values) = raw else {
        throw OblienError(kind: .decoding, status: nil, code: nil, message: "Invalid environment array.", details: nil)
    }
    return try values.map { value in
        if let entry = value.stringValue {
            let parts = entry.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            return EnvVar(key: parts.first.map(String.init) ?? "", value: parts.count > 1 ? String(parts[1]) : "")
        }
        return try APIJSON.decode(EnvVar.self, APIJSON.encode(value))
    }
}
