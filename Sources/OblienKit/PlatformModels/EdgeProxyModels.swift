// Models audited against oblien 2.8.0. Regenerate with scripts/generate-platform-models.cjs.
import Foundation

public struct EdgeProxyData: Codable, Sendable {
    @APINumber public var `id`: Int
    public var `name`: String
    public var `slug`: String
    public var `domain`: String
    public var `url`: String
    public var `target`: String
    /// Accepted values: 'active' | 'disabled'.
    public var `status`: String
    public var `namespace`: String?
    public var `config`: [String: JSONValue]?
    public var `createdAt`: String
    public var `updatedAt`: String

    public init(`id`: Int,
                `name`: String,
                `slug`: String,
                `domain`: String,
                `url`: String,
                `target`: String,
                `status`: String,
                `namespace`: String? = nil,
                `config`: [String: JSONValue]? = nil,
                `createdAt`: String,
                `updatedAt`: String) {
        self.`id` = `id`
        self.`name` = `name`
        self.`slug` = `slug`
        self.`domain` = `domain`
        self.`url` = `url`
        self.`target` = `target`
        self.`status` = `status`
        self.`namespace` = `namespace`
        self.`config` = `config`
        self.`createdAt` = `createdAt`
        self.`updatedAt` = `updatedAt`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `name` = "name"
        case `slug` = "slug"
        case `domain` = "domain"
        case `url` = "url"
        case `target` = "target"
        case `status` = "status"
        case `namespace` = "namespace"
        case `config` = "config"
        case `createdAt` = "created_at"
        case `updatedAt` = "updated_at"
    }
}

public struct EdgeProxyCreateParams: Codable, Sendable {
    public var `name`: String
    public var `slug`: String
    public var `domain`: String?
    public var `target`: String
    public var `config`: [String: JSONValue]?
    public var `namespace`: String?

    public init(`name`: String,
                `slug`: String,
                `domain`: String? = nil,
                `target`: String,
                `config`: [String: JSONValue]? = nil,
                `namespace`: String? = nil) {
        self.`name` = `name`
        self.`slug` = `slug`
        self.`domain` = `domain`
        self.`target` = `target`
        self.`config` = `config`
        self.`namespace` = `namespace`
    }

    enum CodingKeys: String, CodingKey {
        case `name` = "name"
        case `slug` = "slug"
        case `domain` = "domain"
        case `target` = "target"
        case `config` = "config"
        case `namespace` = "namespace"
    }
}

public struct EdgeProxyUpdateParams: Codable, Sendable {
    public var `name`: String?
    public var `slug`: String?
    public var `target`: String?
    public var `config`: [String: JSONValue]?

    public init(`name`: String? = nil,
                `slug`: String? = nil,
                `target`: String? = nil,
                `config`: [String: JSONValue]? = nil) {
        self.`name` = `name`
        self.`slug` = `slug`
        self.`target` = `target`
        self.`config` = `config`
    }

    enum CodingKeys: String, CodingKey {
        case `name` = "name"
        case `slug` = "slug"
        case `target` = "target"
        case `config` = "config"
    }
}

public struct EdgeProxyListResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `proxies`: [EdgeProxyData]

    public init(`success`: Bool,
                `proxies`: [EdgeProxyData]) {
        self.`success` = `success`
        self.`proxies` = `proxies`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `proxies` = "proxies"
    }
}

/// Open string enum; preserves new server values.
public struct EdgeProxyVerificationStatus: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(from decoder: Decoder) throws { rawValue = try decoder.singleValueContainer().decode(String.self) }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public static let `pending` = Self(rawValue: "pending")
    public static let `verified` = Self(rawValue: "verified")
    public static let `failed` = Self(rawValue: "failed")
    public static let `expired` = Self(rawValue: "expired")
}

public struct EdgeProxyVerification: Codable, Sendable {
    @APINumber public var `id`: Int
    public var `target`: String
    public var `status`: EdgeProxyVerificationStatus
    public var `validatedIp`: String?
    @APIOptionalNumber public var `attempts`: Int?
    public var `createdAt`: String?
    public var `verifiedAt`: String?
    public var `expiresAt`: String?
    public var `lastCheckedAt`: String?

    public init(`id`: Int,
                `target`: String,
                `status`: EdgeProxyVerificationStatus,
                `validatedIp`: String? = nil,
                `attempts`: Int? = nil,
                `createdAt`: String? = nil,
                `verifiedAt`: String? = nil,
                `expiresAt`: String? = nil,
                `lastCheckedAt`: String? = nil) {
        self.`id` = `id`
        self.`target` = `target`
        self.`status` = `status`
        self.`validatedIp` = `validatedIp`
        self.`attempts` = `attempts`
        self.`createdAt` = `createdAt`
        self.`verifiedAt` = `verifiedAt`
        self.`expiresAt` = `expiresAt`
        self.`lastCheckedAt` = `lastCheckedAt`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `target` = "target"
        case `status` = "status"
        case `validatedIp` = "validated_ip"
        case `attempts` = "attempts"
        case `createdAt` = "created_at"
        case `verifiedAt` = "verified_at"
        case `expiresAt` = "expires_at"
        case `lastCheckedAt` = "last_checked_at"
    }
}

public struct EdgeProxyVerificationChallenge: Codable, Sendable {
    @APINumber public var `id`: Int
    public var `target`: String
    public var `status`: String
    public var `method`: String
    public var `path`: String
    public var `token`: String
    public var `instructions`: String

    public init(`id`: Int,
                `target`: String,
                `status`: String = "pending",
                `method`: String = "http",
                `path`: String,
                `token`: String,
                `instructions`: String) {
        self.`id` = `id`
        self.`target` = `target`
        self.`status` = `status`
        self.`method` = `method`
        self.`path` = `path`
        self.`token` = `token`
        self.`instructions` = `instructions`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `target` = "target"
        case `status` = "status"
        case `method` = "method"
        case `path` = "path"
        case `token` = "token"
        case `instructions` = "instructions"
    }
}

public struct EdgeProxyVerificationCheckResult: Codable, Sendable {
    @APINumber public var `id`: Int
    public var `target`: String
    public var `status`: EdgeProxyVerificationStatus
    public var `validatedIp`: String?
    public var `expiresAt`: String?
    public var `error`: String?

    public init(`id`: Int,
                `target`: String,
                `status`: EdgeProxyVerificationStatus,
                `validatedIp`: String? = nil,
                `expiresAt`: String? = nil,
                `error`: String? = nil) {
        self.`id` = `id`
        self.`target` = `target`
        self.`status` = `status`
        self.`validatedIp` = `validatedIp`
        self.`expiresAt` = `expiresAt`
        self.`error` = `error`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `target` = "target"
        case `status` = "status"
        case `validatedIp` = "validated_ip"
        case `expiresAt` = "expires_at"
        case `error` = "error"
    }
}

public struct EdgeProxyVerificationListResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `verifications`: [EdgeProxyVerification]

    public init(`success`: Bool,
                `verifications`: [EdgeProxyVerification]) {
        self.`success` = `success`
        self.`verifications` = `verifications`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `verifications` = "verifications"
    }
}
