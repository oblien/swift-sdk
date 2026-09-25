import Foundation

/// Custom-domain binding for a workspace (`client.workspaces.domains(id)` / `handle.domains`)
/// plus the two account-level helpers (`client.workspaces.checkSlug` / `.verifyDomain`).
public struct DomainsAPI: Sendable {
    let transport: Transport
    let workspaceId: String
    private var base: String { "/workspace/\(workspaceId.pathEscaped)/domain" }
    private struct DomainEnvelope: Decodable { let domain: DomainInfo? }

    /// Current bound domain, or `nil` if none is configured.
    public func get() async throws -> DomainInfo? {
        let data = try await transport.request("GET", base)
        return try OblienJSON.decode(DomainEnvelope.self, data).domain
    }

    /// Bind a custom domain (optionally to a specific port, optionally including the `www` alias).
    public func set(_ domain: String, port: Int? = nil, includeWww: Bool? = nil) async throws -> DomainInfo {
        struct Body: Encodable { let domain: String; let port: Int?; let includeWww: Bool? }
        let body = try OblienJSON.encode(Body(domain: domain, port: port, includeWww: includeWww))
        let data = try await transport.request("POST", base, body: body)
        return try OblienJSON.decode(DomainInfo.self, data)
    }

    /// Remove the bound domain.
    public func remove() async throws {
        _ = try await transport.request("DELETE", base)
    }

    /// DNS check for a candidate domain (loose shape).
    public func check(_ domain: String) async throws -> DomainCheck {
        struct Body: Encodable { let domain: String }
        let body = try OblienJSON.encode(Body(domain: domain))
        let data = try await transport.request("POST", base + "/check", body: body)
        return try OblienJSON.decode(DomainCheck.self, data)
    }

    /// Force an SSL certificate renewal for the bound domain.
    public func renewSSL() async throws -> DomainInfo {
        let data = try await transport.request("POST", base + "/ssl/renew")
        return try OblienJSON.decode(DomainInfo.self, data)
    }
}

// MARK: - Models

/// A bound custom domain (lenient — most fields optional for forward-compat).
public struct DomainInfo: Codable, Sendable {
    public var domain: String?
    public var port: Int?
    public var url: String?
    public var ssl: JSONValue?
    public var dns: JSONValue?
    public var includeWww: Bool?
    public var removed: Bool?
    public var customDomain: String?
    public var sslStatus: String?
    public var sslExpiry: String?
    public var sslError: String?

    public var additionalProperties: [String: JSONValue] = [:]

    public init(from decoder: Decoder) throws {
        var fields = try JSONFields(from: decoder)
        domain = try fields.take("domain", as: String.self)
        port = try fields.take("port", as: Int.self)
        url = try fields.take("url", as: String.self)
        ssl = try fields.take("ssl", as: JSONValue.self)
        dns = try fields.take("dns", as: JSONValue.self)
        includeWww = try fields.take("include_www", as: Bool.self)
        removed = try fields.take("removed", as: Bool.self)
        customDomain = try fields.take("custom_domain", as: String.self)
        sslStatus = try fields.take("ssl_status", as: String.self)
        sslExpiry = try fields.take("ssl_expiry", as: String.self)
        sslError = try fields.take("ssl_error", as: String.self)
        additionalProperties = fields.values
    }

    public func encode(to encoder: Encoder) throws {
        var fields = JSONFields(additionalProperties)
        try fields.set("domain", domain)
        try fields.set("port", port)
        try fields.set("url", url)
        try fields.set("ssl", ssl)
        try fields.set("dns", dns)
        try fields.set("include_www", includeWww)
        try fields.set("removed", removed)
        try fields.set("custom_domain", customDomain)
        try fields.set("ssl_status", sslStatus)
        try fields.set("ssl_expiry", sslExpiry)
        try fields.set("ssl_error", sslError)
        try fields.encode(to: encoder)
    }
}

/// Result of a DNS / slug check (loose shape).
public struct DomainCheck: Codable, Sendable {
    public var domain: String?
    public var slug: String?
    public var hostname: String?
    public var url: String?
    public var available: Bool?
    public var dns: JSONValue?
    public var records: JSONValue?
    public var verified: Bool?
    public var enterprise: Bool?
    public var cname: Bool?
    public var ownership: Bool?
    public var errors: [String]?
    public var edgeIps: [String]?
    public var requiredRecords: RequiredRecords?
    public struct RequiredRecords: Codable, Sendable {
        public var cname: CNAME?
        public var txt: TXT?
        public struct CNAME: Codable, Sendable { public var host: String?; public var target: String? }
        public struct TXT: Codable, Sendable { public var host: String?; public var value: String?; public var note: String? }
    }
}

// MARK: - Accessors

extension WorkspaceHandle {
    public var domains: DomainsAPI { DomainsAPI(transport: transport, workspaceId: id) }
}

extension WorkspacesAPI {
    public func domains(_ id: String) -> DomainsAPI { DomainsAPI(transport: transport, workspaceId: id) }

    /// Account-level: check whether a preview slug is available (optionally scoped to a domain).
    public func checkSlug(_ slug: String, domain: String? = nil) async throws -> JSONValue {
        struct Body: Encodable { let slug: String; let domain: String? }
        let body = try OblienJSON.encode(Body(slug: slug, domain: domain))
        let data = try await transport.request("POST", "/domain/check-slug", body: body)
        return try OblienJSON.decode(JSONValue.self, data)
    }

    /// Account-level: verify a domain (optionally bound to a resource).
    public func verifyDomain(_ domain: String, resourceId: String? = nil) async throws -> JSONValue {
        struct Body: Encodable { let domain: String; let resourceId: String? }
        let body = try OblienJSON.encode(Body(domain: domain, resourceId: resourceId))
        let data = try await transport.request("POST", "/domain/verify", body: body)
        return try OblienJSON.decode(JSONValue.self, data)
    }
}
