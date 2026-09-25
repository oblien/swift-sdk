// Models audited against oblien 2.4.0. Regenerate with scripts/generate-platform-models.cjs.
import Foundation

public struct EdgeTunnelSSLState: Codable, Sendable {
    /// Accepted values: 'active' | 'pending'.
    public var `status`: String
    public var `expiresAt`: String?
    public var `error`: String?

    public init(`status`: String,
                `expiresAt`: String? = nil,
                `error`: String? = nil) {
        self.`status` = `status`
        self.`expiresAt` = `expiresAt`
        self.`error` = `error`
    }

    enum CodingKeys: String, CodingKey {
        case `status` = "status"
        case `expiresAt` = "expiresAt"
        case `error` = "error"
    }
}

public struct EdgeTunnelData: Codable, Sendable {
    @APINumber public var `id`: Int
    public var `name`: String
    public var `slug`: String
    public var `domain`: String
    public var `hostname`: String?
    @APIOptionalBoolean public var `isCustom`: Bool?
    public var `tunnelId`: String
    @APINumber public var `port`: Int
    public var `url`: String
    public var `ssl`: EdgeTunnelSSLState?
    /// Accepted values: 'active' | 'disabled'.
    public var `status`: String
    public var `createdAt`: String
    public var `updatedAt`: String

    public init(`id`: Int,
                `name`: String,
                `slug`: String,
                `domain`: String,
                `hostname`: String? = nil,
                `isCustom`: Bool? = nil,
                `tunnelId`: String,
                `port`: Int,
                `url`: String,
                `ssl`: EdgeTunnelSSLState? = nil,
                `status`: String,
                `createdAt`: String,
                `updatedAt`: String) {
        self.`id` = `id`
        self.`name` = `name`
        self.`slug` = `slug`
        self.`domain` = `domain`
        self.`hostname` = `hostname`
        self.`isCustom` = `isCustom`
        self.`tunnelId` = `tunnelId`
        self.`port` = `port`
        self.`url` = `url`
        self.`ssl` = `ssl`
        self.`status` = `status`
        self.`createdAt` = `createdAt`
        self.`updatedAt` = `updatedAt`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `name` = "name"
        case `slug` = "slug"
        case `domain` = "domain"
        case `hostname` = "hostname"
        case `isCustom` = "is_custom"
        case `tunnelId` = "tunnel_id"
        case `port` = "port"
        case `url` = "url"
        case `ssl` = "ssl"
        case `status` = "status"
        case `createdAt` = "created_at"
        case `updatedAt` = "updated_at"
    }
}

public struct EdgeTunnelCreateParams: Codable, Sendable {
    public var `name`: String
    public var `slug`: String?
    public var `domain`: String?
    @APINumber public var `port`: Int
    public var `namespace`: String?

    public init(`name`: String,
                `slug`: String? = nil,
                `domain`: String? = nil,
                `port`: Int,
                `namespace`: String? = nil) {
        self.`name` = `name`
        self.`slug` = `slug`
        self.`domain` = `domain`
        self.`port` = `port`
        self.`namespace` = `namespace`
    }

    enum CodingKeys: String, CodingKey {
        case `name` = "name"
        case `slug` = "slug"
        case `domain` = "domain"
        case `port` = "port"
        case `namespace` = "namespace"
    }
}

public struct EdgeTunnelCheckDomainParams: Codable, Sendable {
    public var `domain`: String
    @APIOptionalNumber public var `port`: Int?

    public init(`domain`: String,
                `port`: Int? = nil) {
        self.`domain` = `domain`
        self.`port` = `port`
    }

    enum CodingKeys: String, CodingKey {
        case `domain` = "domain"
        case `port` = "port"
    }
}

public struct EdgeTunnelCheckDomainResponseRequiredRecordsCname: Codable, Sendable {
    public var `host`: String
    public var `target`: String

    public init(`host`: String,
                `target`: String) {
        self.`host` = `host`
        self.`target` = `target`
    }

    enum CodingKeys: String, CodingKey {
        case `host` = "host"
        case `target` = "target"
    }
}

public struct EdgeTunnelCheckDomainResponseRequiredRecordsTxt: Codable, Sendable {
    public var `host`: String
    public var `value`: String
    public var `note`: String?

    public init(`host`: String,
                `value`: String,
                `note`: String? = nil) {
        self.`host` = `host`
        self.`value` = `value`
        self.`note` = `note`
    }

    enum CodingKeys: String, CodingKey {
        case `host` = "host"
        case `value` = "value"
        case `note` = "note"
    }
}

public struct EdgeTunnelCheckDomainResponseRequiredRecords: Codable, Sendable {
    public var `cname`: EdgeTunnelCheckDomainResponseRequiredRecordsCname
    public var `txt`: EdgeTunnelCheckDomainResponseRequiredRecordsTxt?

    public init(`cname`: EdgeTunnelCheckDomainResponseRequiredRecordsCname,
                `txt`: EdgeTunnelCheckDomainResponseRequiredRecordsTxt? = nil) {
        self.`cname` = `cname`
        self.`txt` = `txt`
    }

    enum CodingKeys: String, CodingKey {
        case `cname` = "cname"
        case `txt` = "txt"
    }
}

public struct EdgeTunnelCheckDomainResponseExistingTunnel: Codable, Sendable {
    @APINumber public var `id`: Int
    public var `name`: String
    public var `slug`: String
    public var `domain`: String
    public var `hostname`: String?
    @APIOptionalBoolean public var `isCustom`: Bool?
    public var `tunnelId`: String
    @APINumber public var `port`: Int
    public var `url`: String
    public var `ssl`: EdgeTunnelSSLState?
    /// Accepted values: 'active' | 'disabled'.
    public var `status`: String
    public var `createdAt`: String
    public var `updatedAt`: String
    @APIOptionalBoolean public var `samePort`: Bool?

    public init(`id`: Int,
                `name`: String,
                `slug`: String,
                `domain`: String,
                `hostname`: String? = nil,
                `isCustom`: Bool? = nil,
                `tunnelId`: String,
                `port`: Int,
                `url`: String,
                `ssl`: EdgeTunnelSSLState? = nil,
                `status`: String,
                `createdAt`: String,
                `updatedAt`: String,
                `samePort`: Bool? = nil) {
        self.`id` = `id`
        self.`name` = `name`
        self.`slug` = `slug`
        self.`domain` = `domain`
        self.`hostname` = `hostname`
        self.`isCustom` = `isCustom`
        self.`tunnelId` = `tunnelId`
        self.`port` = `port`
        self.`url` = `url`
        self.`ssl` = `ssl`
        self.`status` = `status`
        self.`createdAt` = `createdAt`
        self.`updatedAt` = `updatedAt`
        self.`samePort` = `samePort`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `name` = "name"
        case `slug` = "slug"
        case `domain` = "domain"
        case `hostname` = "hostname"
        case `isCustom` = "is_custom"
        case `tunnelId` = "tunnel_id"
        case `port` = "port"
        case `url` = "url"
        case `ssl` = "ssl"
        case `status` = "status"
        case `createdAt` = "created_at"
        case `updatedAt` = "updated_at"
        case `samePort` = "same_port"
    }
}

public struct EdgeTunnelCheckDomainResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    /// Accepted values: 'managed_subdomain' | 'custom_domain'.
    public var `mode`: String
    public var `domain`: String
    @APIBoolean public var `available`: Bool
    @APIBoolean public var `needsVerification`: Bool
    @APIBoolean public var `verified`: Bool
    @APIOptionalBoolean public var `cname`: Bool?
    @APIOptionalBoolean public var `ownership`: Bool?
    public var `records`: [String: [String]]
    public var `errors`: [String]
    public var `requiredRecords`: EdgeTunnelCheckDomainResponseRequiredRecords?
    public var `edgeIps`: [String]
    public var `verificationId`: String?
    @APIOptionalBoolean public var `reusable`: Bool?
    public var `existingTunnel`: EdgeTunnelCheckDomainResponseExistingTunnel?
    public var `message`: String?

    public init(`success`: Bool,
                `mode`: String,
                `domain`: String,
                `available`: Bool,
                `needsVerification`: Bool,
                `verified`: Bool,
                `cname`: Bool? = nil,
                `ownership`: Bool? = nil,
                `records`: [String: [String]],
                `errors`: [String],
                `requiredRecords`: EdgeTunnelCheckDomainResponseRequiredRecords? = nil,
                `edgeIps`: [String],
                `verificationId`: String? = nil,
                `reusable`: Bool? = nil,
                `existingTunnel`: EdgeTunnelCheckDomainResponseExistingTunnel? = nil,
                `message`: String? = nil) {
        self.`success` = `success`
        self.`mode` = `mode`
        self.`domain` = `domain`
        self.`available` = `available`
        self.`needsVerification` = `needsVerification`
        self.`verified` = `verified`
        self.`cname` = `cname`
        self.`ownership` = `ownership`
        self.`records` = `records`
        self.`errors` = `errors`
        self.`requiredRecords` = `requiredRecords`
        self.`edgeIps` = `edgeIps`
        self.`verificationId` = `verificationId`
        self.`reusable` = `reusable`
        self.`existingTunnel` = `existingTunnel`
        self.`message` = `message`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `mode` = "mode"
        case `domain` = "domain"
        case `available` = "available"
        case `needsVerification` = "needs_verification"
        case `verified` = "verified"
        case `cname` = "cname"
        case `ownership` = "ownership"
        case `records` = "records"
        case `errors` = "errors"
        case `requiredRecords` = "required_records"
        case `edgeIps` = "edge_ips"
        case `verificationId` = "verification_id"
        case `reusable` = "reusable"
        case `existingTunnel` = "existing_tunnel"
        case `message` = "message"
    }
}

public struct EdgeTunnelUpdateParams: Codable, Sendable {
    public var `name`: String?
    public var `slug`: String?
    @APIOptionalNumber public var `port`: Int?

    public init(`name`: String? = nil,
                `slug`: String? = nil,
                `port`: Int? = nil) {
        self.`name` = `name`
        self.`slug` = `slug`
        self.`port` = `port`
    }

    enum CodingKeys: String, CodingKey {
        case `name` = "name"
        case `slug` = "slug"
        case `port` = "port"
    }
}

public struct EdgeTunnelListResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `tunnels`: [EdgeTunnelData]

    public init(`success`: Bool,
                `tunnels`: [EdgeTunnelData]) {
        self.`success` = `success`
        self.`tunnels` = `tunnels`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `tunnels` = "tunnels"
    }
}

public struct EdgeTunnelIssueTokenParams: Codable, Sendable {
    public var `expiresIn`: String?

    public init(`expiresIn`: String? = nil) {
        self.`expiresIn` = `expiresIn`
    }

    enum CodingKeys: String, CodingKey {
        case `expiresIn` = "expiresIn"
    }
}

public struct EdgeTunnelTokenResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `token`: String
    public var `tunnelId`: String
    @APINumber public var `port`: Int
    public var `expiresIn`: String
    public var `expiresAt`: String
    public var `connectUrl`: String

    public init(`success`: Bool,
                `token`: String,
                `tunnelId`: String,
                `port`: Int,
                `expiresIn`: String,
                `expiresAt`: String,
                `connectUrl`: String) {
        self.`success` = `success`
        self.`token` = `token`
        self.`tunnelId` = `tunnelId`
        self.`port` = `port`
        self.`expiresIn` = `expiresIn`
        self.`expiresAt` = `expiresAt`
        self.`connectUrl` = `connectUrl`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `token` = "token"
        case `tunnelId` = "tunnel_id"
        case `port` = "port"
        case `expiresIn` = "expires_in"
        case `expiresAt` = "expires_at"
        case `connectUrl` = "connect_url"
    }
}

public struct EdgeTunnelSSLRenewResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `domain`: String
    public var `ssl`: EdgeTunnelSSLState
    public var `tunnel`: EdgeTunnelData

    public init(`success`: Bool,
                `domain`: String,
                `ssl`: EdgeTunnelSSLState,
                `tunnel`: EdgeTunnelData) {
        self.`success` = `success`
        self.`domain` = `domain`
        self.`ssl` = `ssl`
        self.`tunnel` = `tunnel`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `domain` = "domain"
        case `ssl` = "ssl"
        case `tunnel` = "tunnel"
    }
}
