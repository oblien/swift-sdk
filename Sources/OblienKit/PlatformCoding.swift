import Foundation

/// An explicit JSON null in a patch. `nil` omits the property; `.null` clears it.
public enum JSONField<Value: Codable & Sendable>: Codable, Sendable {
    case null
    case value(Value)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = container.decodeNil() ? .null : .value(try container.decode(Value.self))
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case .value(let value): try container.encode(value)
        }
    }
    public var value: Value? { if case .value(let value) = self { return value }; return nil }
}
extension JSONField: Equatable where Value: Equatable {}

/// Common API responses also carry service-specific fields. Preserve them instead of
/// throwing away operation results that the TypeScript SDK exposes as `ApiResponse`.
public struct APIResponse: Codable, Sendable {
    public let fields: [String: JSONValue]
    public var success: Bool? { fields["success"]?.boolValue }
    public var message: String? { fields["message"]?.stringValue }
    public var data: JSONValue? { fields["data"] }
    public subscript(_ key: String) -> JSONValue? { fields[key] }
    public init(fields: [String: JSONValue]) { self.fields = fields }
    public init(from decoder: Decoder) throws { fields = try [String: JSONValue](from: decoder) }
    public func encode(to encoder: Encoder) throws { try fields.encode(to: encoder) }
}

public struct APIDataResponse<Value: Codable & Sendable>: Codable, Sendable {
    public let success: Bool
    public let data: Value
}

struct APIKey: CodingKey {
    let stringValue: String
    var intValue: Int? { nil }
    init(_ value: String) { stringValue = value }
    init?(stringValue: String) { self.init(stringValue) }
    init?(intValue: Int) { return nil }
}

/// Platform endpoints mix camelCase and snake_case, sometimes in the same object.
/// These models use explicit CodingKeys; never apply a global key conversion to them.
enum APIJSON {
    static func encode<T: Encodable>(_ value: T) throws -> Data { try JSONEncoder().encode(value) }
    static func encode<T: Encodable>(_ value: T, merging fields: [String: JSONValue]) throws -> Data {
        var object = try JSONDecoder().decode([String: JSONValue].self, from: encode(value))
        object.merge(fields) { _, new in new }
        return try encode(object)
    }
    static func decode<T: Decodable>(_ type: T.Type, _ data: Data) throws -> T {
        do { return try JSONDecoder().decode(type, from: data) }
        catch {
            throw OblienError(kind: .decoding, status: nil, code: nil,
                              message: "Unexpected \(type) response.", details: nil)
        }
    }
    static func query<T: Encodable>(_ value: T) throws -> [String: String?] {
        let object = try JSONDecoder().decode([String: JSONValue].self, from: encode(value))
        return try object.mapValues { value in
            switch value {
            case .null: return nil
            case .string(let value): return value
            case .bool(let value): return value ? "true" : "false"
            case .number(let value): return String(decoding: try JSONEncoder().encode(value), as: UTF8.self)
            default:
                throw OblienError(kind: .validation, status: nil, code: nil,
                                  message: "Query values must be strings, numbers or booleans.", details: nil)
            }
        }
    }
}

extension Transport {
    func api<Response: Decodable>(_ method: String, _ path: String,
                                  query: [String: String?] = [:], body: Data? = nil,
                                  bearer: String? = nil, retrySafe: Bool = false) async throws -> Response {
        let data = try await request(method, path, query: query, body: body, bearer: bearer, retrySafe: retrySafe)
        return try APIJSON.decode(Response.self, data)
    }
}
