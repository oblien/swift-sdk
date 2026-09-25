import Foundation

/// JSON coders configured for the Oblien wire format (snake_case ⇄ camelCase).
/// Fresh instances per call keep things `Sendable`-clean and the cost is negligible.
enum OblienJSON {
    static func encoder() -> JSONEncoder {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }

    static func decoder() -> JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }

    static func encode<T: Encodable>(_ value: T) throws -> Data {
        try encoder().encode(value)
    }

    static func decode<T: Decodable>(_ type: T.Type, _ data: Data) throws -> T {
        do {
            return try decoder().decode(type, from: data)
        } catch {
            // Responses can contain access tokens, passwords or environment variables. Report
            // the failing field, never response bytes or DecodingError's value descriptions.
            let path: [CodingKey]
            switch error {
            case DecodingError.keyNotFound(let key, let context): path = context.codingPath + [key]
            case DecodingError.typeMismatch(_, let context), DecodingError.valueNotFound(_, let context),
                 DecodingError.dataCorrupted(let context): path = context.codingPath
            default: path = []
            }
            let location = path.map(\.stringValue).joined(separator: ".")
            throw OblienError(kind: .decoding, status: nil, code: nil,
                              message: "Unexpected \(type) response" + (location.isEmpty ? "." : " at \(location)."), details: nil)
        }
    }
}
