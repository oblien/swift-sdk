import Foundation

public struct PagesAPI: Sendable {
    let transport: Transport
    private struct PageEnvelope: Decodable { let page: PageData }
    private struct DomainEnvelope: Decodable { let domain: PageDomainResponse? }
    private func path(_ slug: String) -> String { "/pages/\(slug.pathEscaped)" }

    public func list() async throws -> PageListResponse { try await transport.api("GET", "/pages") }
    public func get(_ slug: String) async throws -> PageData {
        let response: PageEnvelope = try await transport.api("GET", path(slug)); return response.page
    }
    public func create(_ params: PageCreateParams) async throws -> PageData {
        let response: PageEnvelope = try await transport.api("POST", "/pages", body: APIJSON.encode(params)); return response.page
    }
    public func deploy(_ slug: String, _ params: PageDeployParams) async throws -> PageData {
        let response: PageEnvelope = try await transport.api("POST", path(slug) + "/deploy", body: APIJSON.encode(params)); return response.page
    }
    public func update(_ slug: String, _ params: PageUpdateParams) async throws -> PageData {
        let response: PageEnvelope = try await transport.api("PUT", path(slug), body: APIJSON.encode(params)); return response.page
    }
    @discardableResult public func enable(_ slug: String) async throws -> PageData {
        let response: PageEnvelope = try await transport.api("POST", path(slug) + "/enable"); return response.page
    }
    @discardableResult public func disable(_ slug: String) async throws -> PageData {
        let response: PageEnvelope = try await transport.api("POST", path(slug) + "/disable"); return response.page
    }
    @discardableResult public func delete(_ slug: String) async throws -> APIResponse {
        try await transport.api("DELETE", path(slug))
    }
    public func getDomain(_ slug: String) async throws -> PageDomainResponse? {
        let response: DomainEnvelope = try await transport.api("GET", path(slug) + "/domain"); return response.domain
    }
    public func connectDomain(_ slug: String, domain: String, includeWww: Bool? = nil) async throws -> PageDomainResponse {
        struct Params: Encodable { let domain: String; let includeWww: Bool? }
        return try await transport.api("POST", path(slug) + "/domain", body: APIJSON.encode(Params(domain: domain, includeWww: includeWww)))
    }
    @discardableResult public func disconnectDomain(_ slug: String) async throws -> APIResponse {
        try await transport.api("DELETE", path(slug) + "/domain")
    }
    public func checkDNS(_ slug: String, domain: String) async throws -> PageDNSCheckResponse {
        try await transport.api("POST", path(slug) + "/domain/check", body: APIJSON.encode(["domain": domain]))
    }
    public func renewSSL(_ slug: String) async throws -> PageSSLRenewResponse {
        try await transport.api("POST", path(slug) + "/domain/ssl/renew")
    }
    public func setRoutes(_ slug: String, _ input: PageRoutesInput) async throws -> PageRoutesResponse {
        try await transport.api("PUT", path(slug) + "/routes", body: APIJSON.encode(input))
    }
    public func getRoutes(_ slug: String) async throws -> PageRoutesGetResponse {
        try await transport.api("GET", path(slug) + "/routes")
    }
    public func rollbackRoutes(_ slug: String, version: Int) async throws -> PageRoutesResponse {
        try await transport.api("POST", path(slug) + "/routes/rollback", body: APIJSON.encode(["version": version]))
    }
}

public struct RoutesAPI: Sendable {
    let transport: Transport
    private func path(_ hostname: String) -> String { "/domain/routes/\(hostname.pathEscaped)" }
    public func set(_ hostname: String, _ input: RoutesInput) async throws -> RoutesResult {
        try await transport.api("PUT", path(hostname), body: APIJSON.encode(input))
    }
    public func get(_ hostname: String) async throws -> RoutesGetResponse { try await transport.api("GET", path(hostname)) }
    public func rollback(_ hostname: String, version: Int) async throws -> RoutesResult {
        try await transport.api("POST", path(hostname) + "/rollback", body: APIJSON.encode(["version": version]))
    }
}

/// Routing actions use the same discriminated JSON union as the edge API.
public enum RouteAction: Codable, Sendable {
    case proxy(RouteProxyAction)
    case rewrite(RouteRewriteAction)
    case redirect(RouteRedirectAction)
    case headers(RouteHeadersAction)
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        let value = try JSONValue(from: decoder)
        switch value["kind"]?.stringValue {
        case "proxy": self = .proxy(try RouteProxyAction(from: decoder))
        case "rewrite": self = .rewrite(try RouteRewriteAction(from: decoder))
        case "redirect": self = .redirect(try RouteRedirectAction(from: decoder))
        case "headers": self = .headers(try RouteHeadersAction(from: decoder))
        default: self = .unknown(value)
        }
    }
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .proxy(let value): try value.encode(to: encoder)
        case .rewrite(let value): try value.encode(to: encoder)
        case .redirect(let value): try value.encode(to: encoder)
        case .headers(let value): try value.encode(to: encoder)
        case .unknown(let value): try value.encode(to: encoder)
        }
    }
}

extension OblienClient {
    public var pages: PagesAPI { PagesAPI(transport: transport) }
    public var routes: RoutesAPI { RoutesAPI(transport: transport) }
    @available(*, deprecated, renamed: "pages") public var sites: PagesAPI { pages }
}
