// Models audited against oblien 2.4.0. Regenerate with scripts/generate-platform-models.cjs.
import Foundation

public struct PageData: Codable, Sendable {
    public var `name`: String
    public var `slug`: String
    public var `domain`: String
    public var `namespace`: String?
    public var `url`: String
    public var `sourceWorkspaceId`: String?
    public var `exportedPath`: String?
    public var `customDomain`: String?
    /// Accepted values: 'active' | 'disabled'.
    public var `status`: String
    public var `config`: [String: JSONValue]?
    public var `createdAt`: String
    public var `updatedAt`: String

    public init(`name`: String,
                `slug`: String,
                `domain`: String,
                `namespace`: String? = nil,
                `url`: String,
                `sourceWorkspaceId`: String? = nil,
                `exportedPath`: String? = nil,
                `customDomain`: String? = nil,
                `status`: String,
                `config`: [String: JSONValue]? = nil,
                `createdAt`: String,
                `updatedAt`: String) {
        self.`name` = `name`
        self.`slug` = `slug`
        self.`domain` = `domain`
        self.`namespace` = `namespace`
        self.`url` = `url`
        self.`sourceWorkspaceId` = `sourceWorkspaceId`
        self.`exportedPath` = `exportedPath`
        self.`customDomain` = `customDomain`
        self.`status` = `status`
        self.`config` = `config`
        self.`createdAt` = `createdAt`
        self.`updatedAt` = `updatedAt`
    }

    enum CodingKeys: String, CodingKey {
        case `name` = "name"
        case `slug` = "slug"
        case `domain` = "domain"
        case `namespace` = "namespace"
        case `url` = "url"
        case `sourceWorkspaceId` = "source_workspace_id"
        case `exportedPath` = "exported_path"
        case `customDomain` = "custom_domain"
        case `status` = "status"
        case `config` = "config"
        case `createdAt` = "created_at"
        case `updatedAt` = "updated_at"
    }
}

public struct PageCreateParams: Codable, Sendable {
    public var `workspaceId`: String
    public var `path`: String
    public var `name`: String
    public var `slug`: String?
    public var `domain`: String?
    public var `namespace`: String?

    public init(`workspaceId`: String,
                `path`: String,
                `name`: String,
                `slug`: String? = nil,
                `domain`: String? = nil,
                `namespace`: String? = nil) {
        self.`workspaceId` = `workspaceId`
        self.`path` = `path`
        self.`name` = `name`
        self.`slug` = `slug`
        self.`domain` = `domain`
        self.`namespace` = `namespace`
    }

    enum CodingKeys: String, CodingKey {
        case `workspaceId` = "workspace_id"
        case `path` = "path"
        case `name` = "name"
        case `slug` = "slug"
        case `domain` = "domain"
        case `namespace` = "namespace"
    }
}

public struct PageDeployParams: Codable, Sendable {
    public var `workspaceId`: String
    public var `path`: String

    public init(`workspaceId`: String,
                `path`: String) {
        self.`workspaceId` = `workspaceId`
        self.`path` = `path`
    }

    enum CodingKeys: String, CodingKey {
        case `workspaceId` = "workspace_id"
        case `path` = "path"
    }
}

public struct PageUpdateParams: Codable, Sendable {
    public var `name`: String?
    public var `slug`: String?

    public init(`name`: String? = nil,
                `slug`: String? = nil) {
        self.`name` = `name`
        self.`slug` = `slug`
    }

    enum CodingKeys: String, CodingKey {
        case `name` = "name"
        case `slug` = "slug"
    }
}

public struct PageListResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `pages`: [PageData]

    public init(`success`: Bool,
                `pages`: [PageData]) {
        self.`success` = `success`
        self.`pages` = `pages`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `pages` = "pages"
    }
}

public struct PageDomainResponseSsl: Codable, Sendable {
    public var `status`: String
    public var `expiresAt`: String?

    public init(`status`: String,
                `expiresAt`: String? = nil) {
        self.`status` = `status`
        self.`expiresAt` = `expiresAt`
    }

    enum CodingKeys: String, CodingKey {
        case `status` = "status"
        case `expiresAt` = "expiresAt"
    }
}

public struct PageDomainResponse: Codable, Sendable {
    public var `domain`: String
    public var `ssl`: PageDomainResponseSsl
    public var `url`: String

    public init(`domain`: String,
                `ssl`: PageDomainResponseSsl,
                `url`: String) {
        self.`domain` = `domain`
        self.`ssl` = `ssl`
        self.`url` = `url`
    }

    enum CodingKeys: String, CodingKey {
        case `domain` = "domain"
        case `ssl` = "ssl"
        case `url` = "url"
    }
}

public struct PageDNSCheckResponseCname: Codable, Sendable {
    public var `expected`: String
    public var `actual`: String?
    @APIBoolean public var `ok`: Bool

    public init(`expected`: String,
                `actual`: String? = nil,
                `ok`: Bool) {
        self.`expected` = `expected`
        self.`actual` = `actual`
        self.`ok` = `ok`
    }

    enum CodingKeys: String, CodingKey {
        case `expected` = "expected"
        case `actual` = "actual"
        case `ok` = "ok"
    }
}

public struct PageDNSCheckResponseOwnership: Codable, Sendable {
    public var `expected`: String
    @APIBoolean public var `found`: Bool

    public init(`expected`: String,
                `found`: Bool) {
        self.`expected` = `expected`
        self.`found` = `found`
    }

    enum CodingKeys: String, CodingKey {
        case `expected` = "expected"
        case `found` = "found"
    }
}

public struct PageDNSCheckResponse: Codable, Sendable {
    @APIBoolean public var `verified`: Bool
    public var `cname`: PageDNSCheckResponseCname?
    public var `ownership`: PageDNSCheckResponseOwnership?
    public var `errors`: [String]?
    public var `records`: [String: JSONValue]?

    public init(`verified`: Bool,
                `cname`: PageDNSCheckResponseCname? = nil,
                `ownership`: PageDNSCheckResponseOwnership? = nil,
                `errors`: [String]? = nil,
                `records`: [String: JSONValue]? = nil) {
        self.`verified` = `verified`
        self.`cname` = `cname`
        self.`ownership` = `ownership`
        self.`errors` = `errors`
        self.`records` = `records`
    }

    enum CodingKeys: String, CodingKey {
        case `verified` = "verified"
        case `cname` = "cname"
        case `ownership` = "ownership"
        case `errors` = "errors"
        case `records` = "records"
    }
}

public struct PageSSLRenewResponseSsl: Codable, Sendable {
    public var `status`: String
    public var `expiresAt`: String?

    public init(`status`: String,
                `expiresAt`: String? = nil) {
        self.`status` = `status`
        self.`expiresAt` = `expiresAt`
    }

    enum CodingKeys: String, CodingKey {
        case `status` = "status"
        case `expiresAt` = "expiresAt"
    }
}

public struct PageSSLRenewResponse: Codable, Sendable {
    public var `domain`: String
    public var `ssl`: PageSSLRenewResponseSsl

    public init(`domain`: String,
                `ssl`: PageSSLRenewResponseSsl) {
        self.`domain` = `domain`
        self.`ssl` = `ssl`
    }

    enum CodingKeys: String, CodingKey {
        case `domain` = "domain"
        case `ssl` = "ssl"
    }
}

/// Open string enum; preserves new server values.
public struct RouteMatchType: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(from decoder: Decoder) throws { rawValue = try decoder.singleValueContainer().decode(String.self) }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public static let `exact` = Self(rawValue: "exact")
    public static let `prefix` = Self(rawValue: "prefix")
    public static let `wildcard` = Self(rawValue: "wildcard")
}

public struct RouteMatch: Codable, Sendable {
    public var `path`: String
    public var `type`: RouteMatchType?

    public init(`path`: String,
                `type`: RouteMatchType? = nil) {
        self.`path` = `path`
        self.`type` = `type`
    }

    enum CodingKeys: String, CodingKey {
        case `path` = "path"
        case `type` = "type"
    }
}

public struct RouteProxyAction: Codable, Sendable {
    public var `kind`: String
    public var `origin`: String?
    public var `workspace`: String?
    @APIOptionalNumber public var `port`: Int?
    @APIOptionalBoolean public var `stripPrefix`: Bool?
    public var `path`: String?

    public init(`kind`: String = "proxy",
                `origin`: String? = nil,
                `workspace`: String? = nil,
                `port`: Int? = nil,
                `stripPrefix`: Bool? = nil,
                `path`: String? = nil) {
        self.`kind` = `kind`
        self.`origin` = `origin`
        self.`workspace` = `workspace`
        self.`port` = `port`
        self.`stripPrefix` = `stripPrefix`
        self.`path` = `path`
    }

    enum CodingKeys: String, CodingKey {
        case `kind` = "kind"
        case `origin` = "origin"
        case `workspace` = "workspace"
        case `port` = "port"
        case `stripPrefix` = "stripPrefix"
        case `path` = "path"
    }
}

public struct RouteRewriteAction: Codable, Sendable {
    public var `kind`: String
    public var `to`: String

    public init(`kind`: String = "rewrite",
                `to`: String) {
        self.`kind` = `kind`
        self.`to` = `to`
    }

    enum CodingKeys: String, CodingKey {
        case `kind` = "kind"
        case `to` = "to"
    }
}

public struct RouteRedirectAction: Codable, Sendable {
    public var `kind`: String
    /// Accepted values: 301 | 302 | 307 | 308.
    @APIOptionalNumber public var `status`: Int?
    public var `to`: String

    public init(`kind`: String = "redirect",
                `status`: Int? = nil,
                `to`: String) {
        self.`kind` = `kind`
        self.`status` = `status`
        self.`to` = `to`
    }

    enum CodingKeys: String, CodingKey {
        case `kind` = "kind"
        case `status` = "status"
        case `to` = "to"
    }
}

public struct RouteHeadersActionSetItem: Codable, Sendable {
    public var `key`: String
    public var `value`: String

    public init(`key`: String,
                `value`: String) {
        self.`key` = `key`
        self.`value` = `value`
    }

    enum CodingKeys: String, CodingKey {
        case `key` = "key"
        case `value` = "value"
    }
}

public struct RouteHeadersAction: Codable, Sendable {
    public var `kind`: String
    public var `set`: [RouteHeadersActionSetItem]

    public init(`kind`: String = "headers",
                `set`: [RouteHeadersActionSetItem]) {
        self.`kind` = `kind`
        self.`set` = `set`
    }

    enum CodingKeys: String, CodingKey {
        case `kind` = "kind"
        case `set` = "set"
    }
}

public struct RouteRule: Codable, Sendable {
    public var `match`: RouteMatch
    public var `action`: RouteAction

    public init(`match`: RouteMatch,
                `action`: RouteAction) {
        self.`match` = `match`
        self.`action` = `action`
    }

    enum CodingKeys: String, CodingKey {
        case `match` = "match"
        case `action` = "action"
    }
}

public struct PageRoutesInput: Codable, Sendable {
    public var `routes`: [RouteRule]
    @APIOptionalBoolean public var `cleanUrls`: Bool?
    /// Accepted values: 'enforce' | 'strip'.
    public var `trailingSlash`: String?
    @APIOptionalBoolean public var `spa`: Bool?

    public init(`routes`: [RouteRule],
                `cleanUrls`: Bool? = nil,
                `trailingSlash`: String? = nil,
                `spa`: Bool? = nil) {
        self.`routes` = `routes`
        self.`cleanUrls` = `cleanUrls`
        self.`trailingSlash` = `trailingSlash`
        self.`spa` = `spa`
    }

    enum CodingKeys: String, CodingKey {
        case `routes` = "routes"
        case `cleanUrls` = "cleanUrls"
        case `trailingSlash` = "trailingSlash"
        case `spa` = "spa"
    }
}

public struct PageRouteConfigFlags: Codable, Sendable {
    @APIOptionalBoolean public var `cleanUrls`: Bool?
    /// Accepted values: 'enforce' | 'strip'.
    public var `trailingSlash`: String?
    @APIOptionalBoolean public var `spa`: Bool?

    public init(`cleanUrls`: Bool? = nil,
                `trailingSlash`: String? = nil,
                `spa`: Bool? = nil) {
        self.`cleanUrls` = `cleanUrls`
        self.`trailingSlash` = `trailingSlash`
        self.`spa` = `spa`
    }

    enum CodingKeys: String, CodingKey {
        case `cleanUrls` = "cleanUrls"
        case `trailingSlash` = "trailingSlash"
        case `spa` = "spa"
    }
}

public struct PageRouteConfig: Codable, Sendable {
    @APINumber public var `v`: Double
    public var `root`: String
    public var `flags`: PageRouteConfigFlags
    public var `headers`: [[String: JSONValue]]?
    public var `rules`: [[String: JSONValue]]?

    public init(`v`: Double,
                `root`: String,
                `flags`: PageRouteConfigFlags,
                `headers`: [[String: JSONValue]]? = nil,
                `rules`: [[String: JSONValue]]? = nil) {
        self.`v` = `v`
        self.`root` = `root`
        self.`flags` = `flags`
        self.`headers` = `headers`
        self.`rules` = `rules`
    }

    enum CodingKeys: String, CodingKey {
        case `v` = "v"
        case `root` = "root"
        case `flags` = "flags"
        case `headers` = "headers"
        case `rules` = "rules"
    }
}

public struct PageRoutesResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `slug`: String
    @APINumber public var `version`: Int
    public var `config`: PageRouteConfig

    public init(`success`: Bool,
                `slug`: String,
                `version`: Int,
                `config`: PageRouteConfig) {
        self.`success` = `success`
        self.`slug` = `slug`
        self.`version` = `version`
        self.`config` = `config`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `slug` = "slug"
        case `version` = "version"
        case `config` = "config"
    }
}

public struct PageRouteVersion: Codable, Sendable {
    @APINumber public var `version`: Int
    public var `createdBy`: String?
    public var `createdAt`: String

    public init(`version`: Int,
                `createdBy`: String? = nil,
                `createdAt`: String) {
        self.`version` = `version`
        self.`createdBy` = `createdBy`
        self.`createdAt` = `createdAt`
    }

    enum CodingKeys: String, CodingKey {
        case `version` = "version"
        case `createdBy` = "created_by"
        case `createdAt` = "created_at"
    }
}

public struct PageRoutesGetResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `slug`: String
    @APIOptionalNumber public var `activeVersion`: Double?
    public var `config`: PageRouteConfig?
    public var `versions`: [PageRouteVersion]

    public init(`success`: Bool,
                `slug`: String,
                `activeVersion`: Double? = nil,
                `config`: PageRouteConfig? = nil,
                `versions`: [PageRouteVersion]) {
        self.`success` = `success`
        self.`slug` = `slug`
        self.`activeVersion` = `activeVersion`
        self.`config` = `config`
        self.`versions` = `versions`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `slug` = "slug"
        case `activeVersion` = "active_version"
        case `config` = "config"
        case `versions` = "versions"
    }
}

public struct RoutesInputStatic: Codable, Sendable {
    public var `page`: String

    public init(`page`: String) {
        self.`page` = `page`
    }

    enum CodingKeys: String, CodingKey {
        case `page` = "page"
    }
}

public struct RoutesInput: Codable, Sendable {
    public var `static`: RoutesInputStatic?
    public var `routes`: [RouteRule]
    @APIOptionalBoolean public var `cleanUrls`: Bool?
    /// Accepted values: 'enforce' | 'strip'.
    public var `trailingSlash`: String?
    @APIOptionalBoolean public var `spa`: Bool?

    public init(`static`: RoutesInputStatic? = nil,
                `routes`: [RouteRule],
                `cleanUrls`: Bool? = nil,
                `trailingSlash`: String? = nil,
                `spa`: Bool? = nil) {
        self.`static` = `static`
        self.`routes` = `routes`
        self.`cleanUrls` = `cleanUrls`
        self.`trailingSlash` = `trailingSlash`
        self.`spa` = `spa`
    }

    enum CodingKeys: String, CodingKey {
        case `static` = "static"
        case `routes` = "routes"
        case `cleanUrls` = "cleanUrls"
        case `trailingSlash` = "trailingSlash"
        case `spa` = "spa"
    }
}

public struct RoutesResult: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `hostname`: String
    @APINumber public var `version`: Int
    public var `config`: PageRouteConfig

    public init(`success`: Bool,
                `hostname`: String,
                `version`: Int,
                `config`: PageRouteConfig) {
        self.`success` = `success`
        self.`hostname` = `hostname`
        self.`version` = `version`
        self.`config` = `config`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `hostname` = "hostname"
        case `version` = "version"
        case `config` = "config"
    }
}

public struct RoutesGetResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `hostname`: String
    @APIOptionalNumber public var `activeVersion`: Double?
    public var `config`: PageRouteConfig?
    public var `versions`: [PageRouteVersion]

    public init(`success`: Bool,
                `hostname`: String,
                `activeVersion`: Double? = nil,
                `config`: PageRouteConfig? = nil,
                `versions`: [PageRouteVersion]) {
        self.`success` = `success`
        self.`hostname` = `hostname`
        self.`activeVersion` = `activeVersion`
        self.`config` = `config`
        self.`versions` = `versions`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `hostname` = "hostname"
        case `activeVersion` = "active_version"
        case `config` = "config"
        case `versions` = "versions"
    }
}

public typealias SiteData = PageData

public typealias SiteCreateParams = PageCreateParams

public typealias SiteDeployParams = PageDeployParams

public typealias SiteUpdateParams = PageUpdateParams

public typealias SiteListResponse = PageListResponse
