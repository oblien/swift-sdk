import Foundation

/// A typed error from the Oblien API or transport. Mirrors the TS SDK's `OblienError`
/// (`.code` / `.status` / `.message`) with a Swift `Kind` for easy pattern matching.
public struct OblienError: Error, Sendable {
    public enum Kind: Sendable, Equatable {
        case authentication   // 401 / 403
        case notFound         // 404
        case rateLimited      // 429
        case validation       // 400 / 422
        case paymentRequired  // 402 (e.g. SANDBOX_LIMIT_REACHED)
        case conflict         // 409
        case server           // >= 500
        case transport        // URLSession failure
        case decoding         // bad/unexpected payload
        case badURL
    }

    public let kind: Kind
    /// HTTP status code, when the failure came from a response.
    public let status: Int?
    /// Machine-readable code from the error body, e.g. `"SANDBOX_LIMIT_REACHED"`.
    public let code: String?
    /// Human-readable message.
    public let message: String?
    /// Optional structured details from the error body.
    public let details: JSONValue?

    public init(kind: Kind, status: Int?, code: String?, message: String?, details: JSONValue?) {
        self.kind = kind
        self.status = status
        self.code = code
        self.message = message
        self.details = details
    }

    static func kind(forStatus status: Int, code: String?) -> Kind {
        switch status {
        case 401: return .authentication
        case 402: return .paymentRequired
        case 403: return .authentication
        case 404: return .notFound
        case 409: return .conflict
        case 400, 422: return .validation
        case 429: return .rateLimited
        case 500...: return .server
        default: return .server
        }
    }

    var isRetryable: Bool {
        kind == .rateLimited || (status ?? 0) >= 500
    }
}

extension OblienError: LocalizedError {
    public var errorDescription: String? {
        if let message, !message.isEmpty { return message }
        if let code { return code }
        if let status { return "Oblien request failed (\(status))" }
        return "Oblien request failed (\(kind))"
    }
}
