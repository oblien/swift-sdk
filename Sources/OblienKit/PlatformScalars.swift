import Foundation

/// SQL-backed endpoints can return booleans as 0/1 and aggregates as decimal strings.
/// Normalize those representations at the wire boundary without accepting arbitrary values.
@propertyWrapper public struct APIBoolean: Codable, Sendable {
    public var wrappedValue: Bool
    public init(wrappedValue: Bool) { self.wrappedValue = wrappedValue }
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let value = try? c.decode(Bool.self) { wrappedValue = value }
        else if let value = try? c.decode(Int.self), value == 0 || value == 1 { wrappedValue = value == 1 }
        else if let value = try? c.decode(String.self), ["0", "1", "false", "true"].contains(value) { wrappedValue = value == "1" || value == "true" }
        else { throw DecodingError.dataCorruptedError(in: c, debugDescription: "Expected a boolean or 0/1") }
    }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(wrappedValue) }
}

@propertyWrapper public struct APIOptionalBoolean: Codable, Sendable {
    public var wrappedValue: Bool?
    public init(wrappedValue: Bool? = nil) { self.wrappedValue = wrappedValue }
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        wrappedValue = c.decodeNil() ? nil : try APIBoolean(from: decoder).wrappedValue
    }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(wrappedValue) }
}

@propertyWrapper public struct APINumber<Value: Codable & Sendable & LosslessStringConvertible>: Codable, Sendable {
    public var wrappedValue: Value
    public init(wrappedValue: Value) { self.wrappedValue = wrappedValue }
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let value = try? c.decode(Value.self) { wrappedValue = value }
        else if let text = try? c.decode(String.self), let value = Value(text), Double(text)?.isFinite == true { wrappedValue = value }
        else { throw DecodingError.dataCorruptedError(in: c, debugDescription: "Expected a JSON number or numeric string") }
    }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(wrappedValue) }
}

@propertyWrapper public struct APIOptionalNumber<Value: Codable & Sendable & LosslessStringConvertible>: Codable, Sendable {
    public var wrappedValue: Value?
    public init(wrappedValue: Value? = nil) { self.wrappedValue = wrappedValue }
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        wrappedValue = c.decodeNil() ? nil : try APINumber<Value>(from: decoder).wrappedValue
    }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(wrappedValue) }
}

@propertyWrapper public struct APIJSONString<Value: Codable & Sendable>: Codable, Sendable {
    public var wrappedValue: Value
    public init(wrappedValue: Value) { self.wrappedValue = wrappedValue }
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let text = try? c.decode(String.self) { wrappedValue = try APIJSON.decode(Value.self, Data(text.utf8)) }
        else { wrappedValue = try c.decode(Value.self) }
    }
    public func encode(to encoder: Encoder) throws { try wrappedValue.encode(to: encoder) }
}

extension KeyedDecodingContainer {
    public func decode(_ type: APIOptionalBoolean.Type, forKey key: Key) throws -> APIOptionalBoolean {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
    public func decode<Value>(_ type: APIOptionalNumber<Value>.Type, forKey key: Key) throws -> APIOptionalNumber<Value> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

extension KeyedEncodingContainer {
    public mutating func encode(_ value: APIOptionalBoolean, forKey key: Key) throws {
        try encodeIfPresent(value.wrappedValue, forKey: key)
    }
    public mutating func encode<Value>(_ value: APIOptionalNumber<Value>, forKey key: Key) throws {
        try encodeIfPresent(value.wrappedValue, forKey: key)
    }
}
