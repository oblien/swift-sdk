import Foundation

/// Push send tokens and delivery. Device registration methods are for the signed-in
/// mobile app only; workspace credentials must never manage the user's device registry.
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
    public func listSendTokens(workspaceId: String? = nil) async throws -> [WorkspaceSendToken] {
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

extension NotificationsAPI {
    private struct DeviceEnvelope: Decodable { let device: PushDevice }
    private struct CreatedTokenEnvelope: Decodable { let token: CreatedWorkspacePushToken }

    /// App-internal: requires the owner's user session, not a delegated workspace token.
    public func registerDevice(_ params: RegisterDeviceParams) async throws -> PushDevice {
        let response: DeviceEnvelope = try await transport.api("POST", "/notifications/devices", body: APIJSON.encode(params))
        return response.device
    }
    public func deviceStatus(deviceId: String) async throws -> PushDeviceRegistrationStatus {
        try await transport.api("GET", "/notifications/devices/status", query: ["device_id": deviceId])
    }
    public func listDevices() async throws -> PushDeviceListResponse { try await transport.api("GET", "/notifications/devices") }
    @discardableResult public func removeDevice(_ id: Int) async throws -> APIResponse {
        try await transport.api("DELETE", "/notifications/devices/\(id)")
    }
    public func createToken(_ params: CreatePushTokenParams) async throws -> CreatedWorkspacePushToken {
        let response: CreatedTokenEnvelope = try await transport.api("POST", "/notifications/tokens", body: APIJSON.encode(params))
        return response.token
    }
    public func listTokens(workspaceId: String? = nil) async throws -> PushTokenListResponse {
        try await transport.api("GET", "/notifications/tokens", query: ["workspace_id": workspaceId])
    }
    public func revokeToken(_ id: Int) async throws { try await revokeSendToken(id: id) }
    public func deleteToken(_ id: Int) async throws { try await deleteSendToken(id: id) }
    /// Authenticates with the virtual send token alone, never the account's session.
    public func send(token: String, _ params: SendNotificationParams) async throws -> SendNotificationResponse {
        try await transport.api("POST", "/notifications/send", body: APIJSON.encode(params), bearer: token)
    }
}

public struct PushDeviceRegistrationStatus: Codable, Sendable {
    public let success: Bool
    public let registered: Bool
    public let id: Int?
    public let deviceId: String?
    public let platform: PushPlatform?
    public let deviceInfo: [String: JSONValue]?
    public let status: PushDeviceStatus?
    public let lastSeenAt: String?
    public let createdAt: String?
    enum CodingKeys: String, CodingKey {
        case success, registered, id, platform, status
        case deviceId = "device_id", deviceInfo = "device_info", lastSeenAt = "last_seen_at", createdAt = "created_at"
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
