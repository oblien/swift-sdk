// Models audited against oblien 2.8.0. Regenerate with scripts/generate-platform-models.cjs.
import Foundation

public struct CheckSlugParams: Codable, Sendable {
    public var `slug`: String
    public var `domain`: String?

    public init(`slug`: String,
                `domain`: String? = nil) {
        self.`slug` = `slug`
        self.`domain` = `domain`
    }

    enum CodingKeys: String, CodingKey {
        case `slug` = "slug"
        case `domain` = "domain"
    }
}

public struct CheckSlugResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `slug`: String
    public var `domain`: String
    public var `hostname`: String
    public var `url`: String
    @APIBoolean public var `available`: Bool

    public init(`success`: Bool,
                `slug`: String,
                `domain`: String,
                `hostname`: String,
                `url`: String,
                `available`: Bool) {
        self.`success` = `success`
        self.`slug` = `slug`
        self.`domain` = `domain`
        self.`hostname` = `hostname`
        self.`url` = `url`
        self.`available` = `available`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `slug` = "slug"
        case `domain` = "domain"
        case `hostname` = "hostname"
        case `url` = "url"
        case `available` = "available"
    }
}

public struct VerifyDomainParams: Codable, Sendable {
    public var `domain`: String
    public var `resourceId`: String?

    public init(`domain`: String,
                `resourceId`: String? = nil) {
        self.`domain` = `domain`
        self.`resourceId` = `resourceId`
    }

    enum CodingKeys: String, CodingKey {
        case `domain` = "domain"
        case `resourceId` = "resource_id"
    }
}

public struct VerifyDomainResponseRequiredRecordsCname: Codable, Sendable {
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

public struct VerifyDomainResponseRequiredRecordsTxt: Codable, Sendable {
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

public struct VerifyDomainResponseRequiredRecords: Codable, Sendable {
    public var `cname`: VerifyDomainResponseRequiredRecordsCname
    public var `txt`: VerifyDomainResponseRequiredRecordsTxt?

    public init(`cname`: VerifyDomainResponseRequiredRecordsCname,
                `txt`: VerifyDomainResponseRequiredRecordsTxt? = nil) {
        self.`cname` = `cname`
        self.`txt` = `txt`
    }

    enum CodingKeys: String, CodingKey {
        case `cname` = "cname"
        case `txt` = "txt"
    }
}

public struct VerifyDomainResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `domain`: String
    @APIBoolean public var `enterprise`: Bool
    @APIBoolean public var `verified`: Bool
    @APIBoolean public var `cname`: Bool
    @APIOptionalBoolean public var `ownership`: Bool?
    public var `records`: [String: [String]]
    public var `errors`: [String]
    public var `requiredRecords`: VerifyDomainResponseRequiredRecords
    public var `edgeIps`: [String]

    public init(`success`: Bool,
                `domain`: String,
                `enterprise`: Bool,
                `verified`: Bool,
                `cname`: Bool,
                `ownership`: Bool? = nil,
                `records`: [String: [String]],
                `errors`: [String],
                `requiredRecords`: VerifyDomainResponseRequiredRecords,
                `edgeIps`: [String]) {
        self.`success` = `success`
        self.`domain` = `domain`
        self.`enterprise` = `enterprise`
        self.`verified` = `verified`
        self.`cname` = `cname`
        self.`ownership` = `ownership`
        self.`records` = `records`
        self.`errors` = `errors`
        self.`requiredRecords` = `requiredRecords`
        self.`edgeIps` = `edgeIps`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `domain` = "domain"
        case `enterprise` = "enterprise"
        case `verified` = "verified"
        case `cname` = "cname"
        case `ownership` = "ownership"
        case `records` = "records"
        case `errors` = "errors"
        case `requiredRecords` = "required_records"
        case `edgeIps` = "edge_ips"
    }
}

public struct DomainListParams: Codable, Sendable {
    public var `namespace`: String?

    public init(`namespace`: String? = nil) {
        self.`namespace` = `namespace`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
    }
}

public struct DomainRoute: Codable, Sendable {
    @APINumber public var `id`: Int
    public var `hostname`: String
    public var `slug`: String?
    public var `domain`: String?
    public var `routeType`: String
    public var `target`: String
    public var `ownerType`: String
    public var `ownerId`: String
    public var `namespace`: String?
    @APIBoolean public var `isCustom`: Bool
    public var `status`: String
    public var `metadata`: [String: JSONValue]?
    public var `createdAt`: String?
    public var `updatedAt`: String?

    public init(`id`: Int,
                `hostname`: String,
                `slug`: String? = nil,
                `domain`: String? = nil,
                `routeType`: String,
                `target`: String,
                `ownerType`: String,
                `ownerId`: String,
                `namespace`: String? = nil,
                `isCustom`: Bool,
                `status`: String,
                `metadata`: [String: JSONValue]? = nil,
                `createdAt`: String? = nil,
                `updatedAt`: String? = nil) {
        self.`id` = `id`
        self.`hostname` = `hostname`
        self.`slug` = `slug`
        self.`domain` = `domain`
        self.`routeType` = `routeType`
        self.`target` = `target`
        self.`ownerType` = `ownerType`
        self.`ownerId` = `ownerId`
        self.`namespace` = `namespace`
        self.`isCustom` = `isCustom`
        self.`status` = `status`
        self.`metadata` = `metadata`
        self.`createdAt` = `createdAt`
        self.`updatedAt` = `updatedAt`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `hostname` = "hostname"
        case `slug` = "slug"
        case `domain` = "domain"
        case `routeType` = "route_type"
        case `target` = "target"
        case `ownerType` = "owner_type"
        case `ownerId` = "owner_id"
        case `namespace` = "namespace"
        case `isCustom` = "is_custom"
        case `status` = "status"
        case `metadata` = "metadata"
        case `createdAt` = "created_at"
        case `updatedAt` = "updated_at"
    }
}

public struct DomainRoutesResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: [DomainRoute]

    public init(`success`: Bool,
                `data`: [DomainRoute]) {
        self.`success` = `success`
        self.`data` = `data`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
    }
}

public struct SslCertificate: Codable, Sendable {
    public var `domain`: String
    public var `namespace`: String?
    @APIBoolean public var `active`: Bool
    @APIBoolean public var `autoRenew`: Bool
    public var `expiresAt`: JSONValue?
    public var `source`: String
    public var `lastAttemptAt`: String?
    public var `lastError`: String?
    @APIOptionalNumber public var `renewAttempts`: Int?

    public init(`domain`: String,
                `namespace`: String? = nil,
                `active`: Bool,
                `autoRenew`: Bool,
                `expiresAt`: JSONValue? = nil,
                `source`: String,
                `lastAttemptAt`: String? = nil,
                `lastError`: String? = nil,
                `renewAttempts`: Int? = nil) {
        self.`domain` = `domain`
        self.`namespace` = `namespace`
        self.`active` = `active`
        self.`autoRenew` = `autoRenew`
        self.`expiresAt` = `expiresAt`
        self.`source` = `source`
        self.`lastAttemptAt` = `lastAttemptAt`
        self.`lastError` = `lastError`
        self.`renewAttempts` = `renewAttempts`
    }

    enum CodingKeys: String, CodingKey {
        case `domain` = "domain"
        case `namespace` = "namespace"
        case `active` = "active"
        case `autoRenew` = "auto_renew"
        case `expiresAt` = "expires_at"
        case `source` = "source"
        case `lastAttemptAt` = "last_attempt_at"
        case `lastError` = "last_error"
        case `renewAttempts` = "renew_attempts"
    }
}

public struct SslListResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: [SslCertificate]

    public init(`success`: Bool,
                `data`: [SslCertificate]) {
        self.`success` = `success`
        self.`data` = `data`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
    }
}

public struct SslAutoRenewResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `domain`: String
    @APIBoolean public var `autoRenew`: Bool

    public init(`success`: Bool,
                `domain`: String,
                `autoRenew`: Bool) {
        self.`success` = `success`
        self.`domain` = `domain`
        self.`autoRenew` = `autoRenew`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `domain` = "domain"
        case `autoRenew` = "auto_renew"
    }
}
