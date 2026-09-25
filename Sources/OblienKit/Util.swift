import Foundation

extension String {
    /// Percent-encode for use as a single URL path component.
    var pathEscaped: String {
        addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn:
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")) ?? self
    }
}

/// `{ "force": Bool }` lifecycle body.
struct ForceBody: Encodable { let force: Bool }
