import Foundation

public struct EdgeProxyAPI: Sendable {
    let transport: Transport
    private struct Envelope: Decodable { let proxy: EdgeProxyData }
    private struct ChallengeEnvelope: Decodable { let verification: EdgeProxyVerificationChallenge }
    private struct VerificationEnvelope: Decodable { let verification: EdgeProxyVerificationCheckResult }
    private func path(_ id: Int) -> String { "/edge/proxies/\(id)" }

    public func list() async throws -> EdgeProxyListResponse { try await transport.api("GET", "/edge/proxies") }
    public func get(_ id: Int) async throws -> EdgeProxyData {
        let response: Envelope = try await transport.api("GET", path(id)); return response.proxy
    }
    public func create(_ params: EdgeProxyCreateParams) async throws -> EdgeProxyData {
        let response: Envelope = try await transport.api("POST", "/edge/proxies", body: APIJSON.encode(params)); return response.proxy
    }
    public func update(_ id: Int, _ params: EdgeProxyUpdateParams) async throws -> EdgeProxyData {
        let response: Envelope = try await transport.api("PUT", path(id), body: APIJSON.encode(params)); return response.proxy
    }
    @discardableResult public func enable(_ id: Int) async throws -> EdgeProxyData {
        let response: Envelope = try await transport.api("POST", path(id) + "/enable"); return response.proxy
    }
    @discardableResult public func disable(_ id: Int) async throws -> EdgeProxyData {
        let response: Envelope = try await transport.api("POST", path(id) + "/disable"); return response.proxy
    }
    @discardableResult public func delete(_ id: Int) async throws -> APIResponse {
        try await transport.api("DELETE", path(id))
    }
    public func requestVerification(target: String) async throws -> EdgeProxyVerificationChallenge {
        let response: ChallengeEnvelope = try await transport.api("POST", "/edge/verifications", body: APIJSON.encode(["target": target]))
        return response.verification
    }
    public func listVerifications() async throws -> EdgeProxyVerificationListResponse {
        try await transport.api("GET", "/edge/verifications")
    }
    public func checkVerification(_ id: Int) async throws -> EdgeProxyVerificationCheckResult {
        let response: VerificationEnvelope = try await transport.api("POST", "/edge/verifications/\(id)/check")
        return response.verification
    }
    @discardableResult public func deleteVerification(_ id: Int) async throws -> APIResponse {
        try await transport.api("DELETE", "/edge/verifications/\(id)")
    }
}

/// Tunnel management is portable. Hosting a reverse tunnel on the local machine is a
/// separate transport concern; the returned broker grant also supports native clients.
public struct EdgeTunnelAPI: Sendable {
    let transport: Transport
    private struct Envelope: Decodable { let tunnel: EdgeTunnelData }
    private func path(_ id: Int) -> String { "/edge/tunnels/\(id)" }

    public func list() async throws -> EdgeTunnelListResponse { try await transport.api("GET", "/edge/tunnels") }
    public func get(_ id: Int) async throws -> EdgeTunnelData {
        let response: Envelope = try await transport.api("GET", path(id)); return response.tunnel
    }
    public func create(_ params: EdgeTunnelCreateParams) async throws -> EdgeTunnelData {
        let response: Envelope = try await transport.api("POST", "/edge/tunnels", body: APIJSON.encode(params)); return response.tunnel
    }
    public func checkDomain(_ params: EdgeTunnelCheckDomainParams) async throws -> EdgeTunnelCheckDomainResponse {
        try await transport.api("POST", "/edge/tunnels/check-domain", body: APIJSON.encode(params))
    }
    public func update(_ id: Int, _ params: EdgeTunnelUpdateParams) async throws -> EdgeTunnelData {
        let response: Envelope = try await transport.api("PUT", path(id), body: APIJSON.encode(params)); return response.tunnel
    }
    @discardableResult public func enable(_ id: Int) async throws -> EdgeTunnelData {
        let response: Envelope = try await transport.api("POST", path(id) + "/enable"); return response.tunnel
    }
    @discardableResult public func disable(_ id: Int) async throws -> EdgeTunnelData {
        let response: Envelope = try await transport.api("POST", path(id) + "/disable"); return response.tunnel
    }
    @discardableResult public func delete(_ id: Int) async throws -> APIResponse {
        try await transport.api("DELETE", path(id))
    }
    public func renewSSL(_ id: Int) async throws -> EdgeTunnelSSLRenewResponse {
        try await transport.api("POST", path(id) + "/ssl/renew")
    }
    public func issueToken(_ id: Int, expiresIn: String? = nil) async throws -> EdgeTunnelTokenResponse {
        let body = try expiresIn.map { try APIJSON.encode(["expires_in": $0]) }
        return try await transport.api("POST", path(id) + "/token", body: body)
    }
}

extension OblienClient {
    public var edgeProxy: EdgeProxyAPI { EdgeProxyAPI(transport: transport) }
    public var edgeTunnel: EdgeTunnelAPI { EdgeTunnelAPI(transport: transport) }
}
