import Foundation

/// Domain utilities across workspaces, pages, proxies and tunnels.
public struct AccountDomainsAPI: Sendable {
    let transport: Transport
    public func checkSlug(_ params: CheckSlugParams) async throws -> CheckSlugResponse {
        try await transport.api("POST", "/domain/check-slug", body: APIJSON.encode(params))
    }
    public func verify(_ params: VerifyDomainParams) async throws -> VerifyDomainResponse {
        try await transport.api("POST", "/domain/verify", body: APIJSON.encode(params))
    }
    public func routes(namespace: String? = nil) async throws -> DomainRoutesResponse {
        try await transport.api("GET", "/domain/routes", query: ["namespace": namespace])
    }
    public func ssls(namespace: String? = nil) async throws -> SslListResponse {
        try await transport.api("GET", "/domain/ssls", query: ["namespace": namespace])
    }
    public func setSslAutoRenew(_ domain: String, enabled: Bool) async throws -> SslAutoRenewResponse {
        try await transport.api("PUT", "/domain/ssls/\(domain.pathEscaped)/auto-renew", body: APIJSON.encode(["enabled": enabled]))
    }
}

extension OblienClient {
    public var domain: AccountDomainsAPI { AccountDomainsAPI(transport: transport) }
}
