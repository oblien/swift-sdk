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
    public var auth: OblienAuth
    public var maxRetries: Int
    /// Gateway (runtime) JWT cache lifetime. Docs are contradictory (1h vs 30d); 55m is safe.
    public var runtimeTokenTTL: TimeInterval

    public init(
        auth: OblienAuth,
        baseURL: URL = URL(string: "https://api.oblien.com")!,
        runtimeURL: URL = URL(string: "https://workspace.oblien.com")!,
        maxRetries: Int = 3,
        runtimeTokenTTL: TimeInterval = 55 * 60
    ) {
        self.auth = auth
        self.baseURL = baseURL
        self.runtimeURL = runtimeURL
        self.maxRetries = maxRetries
        self.runtimeTokenTTL = runtimeTokenTTL
    }
}
