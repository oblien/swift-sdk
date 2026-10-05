import Foundation

/// How the client authenticates to the management API.
public enum OblienAuth: Sendable {
    /// Account/admin API key pair → `X-Client-ID` / `X-Client-Secret`.
    case apiKey(clientId: String, clientSecret: String)
    /// Short-lived scoped JWT → `Authorization: Bearer <jwt>`.
    case scopedToken(String)
    /// App-managed bearer session (e.g. an anonymous `/auth/token` flow). The closure
    /// returns the current token; pass `forceRefresh: true` to mint a fresh one (called
    /// once on a 401). The closure owns its own caching.
    case bearerSession(@Sendable (_ forceRefresh: Bool) async throws -> String)
}

public struct OblienConfiguration: Sendable {
    public var baseURL: URL
    public var runtimeURL: URL
    /// CDN edge upload API; receives only a CDN-scoped token, never account credentials.
    public var cdnURL: URL
    public var auth: OblienAuth
    /// Account context for a personal login. The server verifies membership.
    public var accountId: String?
    public var maxRetries: Int
    /// Gateway (runtime) JWT cache lifetime. Docs are contradictory (1h vs 30d); 55m is safe.
    public var runtimeTokenTTL: TimeInterval

    public init(
        auth: OblienAuth,
        baseURL: URL = URL(string: "https://api.oblien.com")!,
        runtimeURL: URL = URL(string: "https://workspace.oblien.com")!,
        maxRetries: Int = 3,
        runtimeTokenTTL: TimeInterval = 55 * 60,
        cdnURL: URL = URL(string: "https://cdn.oblien.com/api")!,
        accountId: String? = nil
    ) {
        self.auth = auth
        self.accountId = accountId
        self.baseURL = baseURL
        self.runtimeURL = runtimeURL
        self.cdnURL = cdnURL
        self.maxRetries = maxRetries
        self.runtimeTokenTTL = runtimeTokenTTL
    }
}
