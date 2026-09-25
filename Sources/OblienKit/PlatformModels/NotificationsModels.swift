// Models audited against oblien 2.4.0. Regenerate with scripts/generate-platform-models.cjs.
import Foundation

/// Open string enum; preserves new server values.
public struct PushPlatform: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(from decoder: Decoder) throws { rawValue = try decoder.singleValueContainer().decode(String.self) }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public static let `ios` = Self(rawValue: "ios")
    public static let `android` = Self(rawValue: "android")
    public static let `web` = Self(rawValue: "web")
}

/// Open string enum; preserves new server values.
public struct PushDeviceStatus: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(from decoder: Decoder) throws { rawValue = try decoder.singleValueContainer().decode(String.self) }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public static let `active` = Self(rawValue: "active")
    public static let `revoked` = Self(rawValue: "revoked")
}

/// Open string enum; preserves new server values.
public struct PushTokenStatus: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(from decoder: Decoder) throws { rawValue = try decoder.singleValueContainer().decode(String.self) }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public static let `active` = Self(rawValue: "active")
    public static let `revoked` = Self(rawValue: "revoked")
}

public struct PushDevice: Codable, Sendable {
    @APINumber public var `id`: Int
    public var `deviceId`: String
    public var `platform`: PushPlatform
    public var `deviceInfo`: [String: JSONValue]?
    public var `status`: PushDeviceStatus
    public var `lastSeenAt`: String?
    public var `createdAt`: String?
    public var `tokenValidation`: String?

    public init(`id`: Int,
                `deviceId`: String,
                `platform`: PushPlatform,
                `deviceInfo`: [String: JSONValue]? = nil,
                `status`: PushDeviceStatus,
                `lastSeenAt`: String? = nil,
                `createdAt`: String? = nil,
                `tokenValidation`: String? = nil) {
        self.`id` = `id`
        self.`deviceId` = `deviceId`
        self.`platform` = `platform`
        self.`deviceInfo` = `deviceInfo`
        self.`status` = `status`
        self.`lastSeenAt` = `lastSeenAt`
        self.`createdAt` = `createdAt`
        self.`tokenValidation` = `tokenValidation`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `deviceId` = "device_id"
        case `platform` = "platform"
        case `deviceInfo` = "device_info"
        case `status` = "status"
        case `lastSeenAt` = "last_seen_at"
        case `createdAt` = "created_at"
        case `tokenValidation` = "token_validation"
    }
}

public struct RegisterDeviceParams: Codable, Sendable {
    public var `deviceId`: String
    public var `fcmToken`: String
    public var `platform`: PushPlatform?
    public var `deviceInfo`: [String: JSONValue]?

    public init(`deviceId`: String,
                `fcmToken`: String,
                `platform`: PushPlatform? = nil,
                `deviceInfo`: [String: JSONValue]? = nil) {
        self.`deviceId` = `deviceId`
        self.`fcmToken` = `fcmToken`
        self.`platform` = `platform`
        self.`deviceInfo` = `deviceInfo`
    }

    enum CodingKeys: String, CodingKey {
        case `deviceId` = "device_id"
        case `fcmToken` = "fcm_token"
        case `platform` = "platform"
        case `deviceInfo` = "device_info"
    }
}

public struct PushDeviceListResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `devices`: [PushDevice]

    public init(`success`: Bool,
                `devices`: [PushDevice]) {
        self.`success` = `success`
        self.`devices` = `devices`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `devices` = "devices"
    }
}

public struct WorkspacePushToken: Codable, Sendable {
    @APINumber public var `id`: Int
    public var `workspaceId`: String?
    public var `name`: String?
    public var `metadata`: [String: JSONValue]?
    public var `tokenPrefix`: String
    public var `status`: PushTokenStatus
    public var `lastUsedAt`: String?
    public var `createdAt`: String?
    public var `revokedAt`: String?
    public var `tag`: String?
    public var `refreshed`: Bool?

    public init(`id`: Int,
                `workspaceId`: String? = nil,
                `name`: String? = nil,
                `metadata`: [String: JSONValue]? = nil,
                `tokenPrefix`: String,
                `status`: PushTokenStatus,
                `lastUsedAt`: String? = nil,
                `createdAt`: String? = nil,
                `revokedAt`: String? = nil,
                `tag`: String? = nil,
                `refreshed`: Bool? = nil) {
        self.`id` = `id`
        self.`workspaceId` = `workspaceId`
        self.`name` = `name`
        self.`metadata` = `metadata`
        self.`tokenPrefix` = `tokenPrefix`
        self.`status` = `status`
        self.`lastUsedAt` = `lastUsedAt`
        self.`createdAt` = `createdAt`
        self.`revokedAt` = `revokedAt`
        self.`tag` = `tag`
        self.`refreshed` = `refreshed`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `workspaceId` = "workspace_id"
        case `name` = "name"
        case `metadata` = "metadata"
        case `tokenPrefix` = "token_prefix"
        case `status` = "status"
        case `lastUsedAt` = "last_used_at"
        case `createdAt` = "created_at"
        case `revokedAt` = "revoked_at"
        case `tag` = "tag"
        case `refreshed` = "refreshed"
    }
}

public struct CreatedWorkspacePushToken: Codable, Sendable {
    public var `token`: String
    @APINumber public var `id`: Int
    public var `workspaceId`: String?
    public var `name`: String?
    public var `metadata`: [String: JSONValue]?
    public var `tokenPrefix`: String
    public var `status`: PushTokenStatus
    public var `lastUsedAt`: String?
    public var `createdAt`: String?
    public var `revokedAt`: String?
    public var `tag`: String?
    public var `refreshed`: Bool?

    public init(`token`: String,
                `id`: Int,
                `workspaceId`: String? = nil,
                `name`: String? = nil,
                `metadata`: [String: JSONValue]? = nil,
                `tokenPrefix`: String,
                `status`: PushTokenStatus,
                `lastUsedAt`: String? = nil,
                `createdAt`: String? = nil,
                `revokedAt`: String? = nil,
                `tag`: String? = nil,
                `refreshed`: Bool? = nil) {
        self.`token` = `token`
        self.`id` = `id`
        self.`workspaceId` = `workspaceId`
        self.`name` = `name`
        self.`metadata` = `metadata`
        self.`tokenPrefix` = `tokenPrefix`
        self.`status` = `status`
        self.`lastUsedAt` = `lastUsedAt`
        self.`createdAt` = `createdAt`
        self.`revokedAt` = `revokedAt`
        self.`tag` = `tag`
        self.`refreshed` = `refreshed`
    }

    enum CodingKeys: String, CodingKey {
        case `token` = "token"
        case `id` = "id"
        case `workspaceId` = "workspace_id"
        case `name` = "name"
        case `metadata` = "metadata"
        case `tokenPrefix` = "token_prefix"
        case `status` = "status"
        case `lastUsedAt` = "last_used_at"
        case `createdAt` = "created_at"
        case `revokedAt` = "revoked_at"
        case `tag` = "tag"
        case `refreshed` = "refreshed"
    }
}

public struct CreatePushTokenParams: Codable, Sendable {
    public var `workspaceId`: String?
    public var `name`: String?
    public var `metadata`: [String: JSONValue]?
    public var `tag`: String?
    public var `expiresInDays`: Int?

    public init(`workspaceId`: String? = nil,
                `name`: String? = nil,
                `metadata`: [String: JSONValue]? = nil,
                `tag`: String? = nil,
                `expiresInDays`: Int? = nil) {
        self.`workspaceId` = `workspaceId`
        self.`name` = `name`
        self.`metadata` = `metadata`
        self.`tag` = `tag`
        self.`expiresInDays` = `expiresInDays`
    }

    enum CodingKeys: String, CodingKey {
        case `workspaceId` = "workspace_id"
        case `name` = "name"
        case `metadata` = "metadata"
        case `tag` = "tag"
        case `expiresInDays` = "expires_in_days"
    }
}

public struct PushTokenListResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `tokens`: [WorkspacePushToken]

    public init(`success`: Bool,
                `tokens`: [WorkspacePushToken]) {
        self.`success` = `success`
        self.`tokens` = `tokens`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `tokens` = "tokens"
    }
}

public struct SendNotificationParams: Codable, Sendable {
    public var `title`: String?
    public var `body`: String?
    public var `data`: [String: JSONValue]?

    public init(`title`: String? = nil,
                `body`: String? = nil,
                `data`: [String: JSONValue]? = nil) {
        self.`title` = `title`
        self.`body` = `body`
        self.`data` = `data`
    }

    enum CodingKeys: String, CodingKey {
        case `title` = "title"
        case `body` = "body"
        case `data` = "data"
    }
}

public struct PushDeliveryError: Codable, Sendable {
    public var `code`: String
    public var `message`: String
    @APINumber public var `count`: Int

    public init(`code`: String,
                `message`: String,
                `count`: Int) {
        self.`code` = `code`
        self.`message` = `message`
        self.`count` = `count`
    }

    enum CodingKeys: String, CodingKey {
        case `code` = "code"
        case `message` = "message"
        case `count` = "count"
    }
}

public struct SendNotificationResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    @APINumber public var `delivered`: Double
    @APINumber public var `failed`: Double
    @APINumber public var `devices`: Double
    public var `errors`: [PushDeliveryError]?
    @APIOptionalBoolean public var `skipped`: Bool?
    public var `reason`: String?
    public var `detail`: String?

    public init(`success`: Bool,
                `delivered`: Double,
                `failed`: Double,
                `devices`: Double,
                `errors`: [PushDeliveryError]? = nil,
                `skipped`: Bool? = nil,
                `reason`: String? = nil,
                `detail`: String? = nil) {
        self.`success` = `success`
        self.`delivered` = `delivered`
        self.`failed` = `failed`
        self.`devices` = `devices`
        self.`errors` = `errors`
        self.`skipped` = `skipped`
        self.`reason` = `reason`
        self.`detail` = `detail`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `delivered` = "delivered"
        case `failed` = "failed"
        case `devices` = "devices"
        case `errors` = "errors"
        case `skipped` = "skipped"
        case `reason` = "reason"
        case `detail` = "detail"
    }
}
