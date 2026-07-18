import Foundation

/// Workspace push **send tokens** (`/notifications/tokens*`, management API, session-authed). The
/// plaintext token is returned once on create and handed to the workspace daemon, which uses it to
/// `POST /notifications/send`. (FCM *device* registration is the app's concern — Firebase-specific,
/// not part of this SDK.)
public struct NotificationsAPI: Sendable {
    let transport: Transport

    private struct TokenEnvelope: Decodable { let token: WorkspaceSendToken }
    private struct TokenListEnvelope: Decodable { let tokens: [WorkspaceSendToken] }

    /// Create OR refresh a send token. Pass a stable `tag` (unique per user) for the recommended
    /// idempotent flow: re-minting with the same tag **refreshes the single token in place** (same id,
    /// a NEW secret, `refreshed == true`) instead of accumulating duplicates. Omit `workspaceId` for a
    /// generic user-scoped token; pass it for a workspace-bound one. `expiresInDays` omitted ⇒ never
    /// expires (right for long-running agents). The plaintext `token` is returned **once**.
    @discardableResult
    public func createSendToken(workspaceId: String? = nil, tag: String? = nil, name: String? = nil,
                                metadata: [String: String]? = nil,
                                expiresInDays: Int? = nil) async throws -> WorkspaceSendToken {
        struct Body: Encodable {
            let workspaceId: String?
            let tag: String?
            let name: String?
            let metadata: [String: String]?
            let expiresInDays: Int?
        }
        let body = try OblienJSON.encode(Body(workspaceId: workspaceId, tag: tag, name: name,
                                              metadata: metadata, expiresInDays: expiresInDays))
        let data = try await transport.request("POST", "/notifications/tokens", body: body)
        return try OblienJSON.decode(TokenEnvelope.self, data).token
    }

    /// Existing send tokens for a workspace (no plaintext — prefix/status only).
    public func listSendTokens(workspaceId: String) async throws -> [WorkspaceSendToken] {
        let data = try await transport.request("GET", "/notifications/tokens",
                                               query: ["workspace_id": workspaceId])
        return try OblienJSON.decode(TokenListEnvelope.self, data).tokens
    }

    public func revokeSendToken(id: Int) async throws {
        _ = try await transport.request("POST", "/notifications/tokens/\(id)/revoke")
    }

    public func deleteSendToken(id: Int) async throws {
        _ = try await transport.request("DELETE", "/notifications/tokens/\(id)")
    }
}

/// A workspace send token. `token` (plaintext) is present only in the create response.
public struct WorkspaceSendToken: Codable, Sendable, Identifiable, Hashable {
    public let id: Int
    public var workspaceId: String?
    public var tag: String?
    public var name: String?
    public var tokenPrefix: String?
    public var status: String?
    public var refreshed: Bool?   // true when a same-tag mint rotated the existing token in place
    public var token: String?
}
