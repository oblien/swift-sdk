import Foundation

extension String {
    /// Percent-encode for use as a single URL path component.
    var pathEscaped: String {
        addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? self
    }
}

/// `{ "force": Bool }` lifecycle body.
struct ForceBody: Encodable { let force: Bool }
