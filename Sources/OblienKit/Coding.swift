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
            // Include a snippet of the ACTUAL response so a decode failure is diagnosable (HTML
            // error page, empty body, wrong shape, …) instead of an opaque "not valid json".
            let raw = String(decoding: data.prefix(300), as: UTF8.self)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let snippet = raw.isEmpty ? "<empty \(data.count)b>" : raw
            throw OblienError(kind: .decoding, status: nil, code: nil,
                              message: "Failed to decode \(type): \(error) — body: \(snippet)", details: nil)
        }
    }
}
