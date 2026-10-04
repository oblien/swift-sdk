import Foundation

/// Desktop preparation and native SSH/VNC grants use the management API. Access switches
/// and OS credentials use `RuntimeClient.desktop` and the existing runtime authentication.
public struct DesktopAPI: Sendable {
    let transport: Transport
    let workspaceId: String
    private var base: String { "/workspace/\(workspaceId.pathEscaped)/desktop" }

    public func installation() async throws -> DesktopInstallation {
        let value = try OblienJSON.decode(DesktopInstallation.self, await transport.request("GET", base + "/installation"))
        if value.installed == true || value.phase == "installing" { await transport.invalidateRuntime(workspaceId) }
        return value
    }
    /// Restarting a running workspace requires an explicit `restart: true` from the caller.
    public func install(desktop: String? = nil, restart: Bool = false) async throws -> DesktopInstallation {
        struct Body: Encodable { let desktop: String?; let restart: Bool }
        do {
            let value = try OblienJSON.decode(DesktopInstallation.self, await transport.request("POST", base + "/install",
                body: OblienJSON.encode(Body(desktop: desktop, restart: restart))))
            await transport.invalidateRuntime(workspaceId)
            return value
        } catch { await transport.invalidateRuntime(workspaceId); throw error }
    }
    /// Contains a temporary password; keep the grant in memory and never log or persist it.
    public func sshConnection(sessionId: String? = nil) async throws -> DesktopSSHConnection {
        if let sessionId { _ = try desktopSessionPath(sessionId) }
        let body = try sessionId.map { try OblienJSON.encode(["session_id": $0]) }
        return try OblienJSON.decode(DesktopSSHConnection.self, await transport.request("POST", base + "/ssh", body: body))
    }
}

public struct RuntimeDesktopAPI: Sendable {
    let runtime: RuntimeClient
    public func status(sessionId: String? = nil) async throws -> DesktopStatus {
        let path = try sessionId.map { try desktopSessionPath($0) + "/status" } ?? "/desktop/status"
        return try OblienJSON.decode(DesktopStatus.self, await runtime.perform("GET", path, root: true))
    }
    @discardableResult public func enable() async throws -> DesktopStatus {
        try OblienJSON.decode(DesktopStatus.self, await runtime.perform("POST", "/desktop/enable", root: true))
    }
    @discardableResult public func disable() async throws -> DesktopStatus {
        try OblienJSON.decode(DesktopStatus.self, await runtime.perform("POST", "/desktop/disable", root: true))
    }
    /// Optional OS login credentials, distinct from the SSH transport grant.
    public func credentials() async throws -> DesktopCredentials {
        try OblienJSON.decode(DesktopCredentials.self, await runtime.perform("GET", "/desktop/credentials", root: true))
    }
    /// Authenticated web viewer URL. Treat it as a credential and do not log or persist it.
    /// Native viewers should use the management API's SSH grant instead.
    public func url(sessionId: String? = nil) async throws -> URL {
        if let sessionId { _ = try desktopSessionPath(sessionId) }
        var components = URLComponents(url: try await runtime.endpoint("/desktop", root: true), resolvingAgainstBaseURL: false)!
        let token = try await runtime.token()
        var fragment = URLComponents()
        fragment.queryItems = [URLQueryItem(name: "token", value: token)]
        if let sessionId { fragment.queryItems?.append(.init(name: "session", value: sessionId)) }
        components.percentEncodedFragment = fragment.percentEncodedQuery
        if components.scheme != "https" || components.host != "workspace.oblien.com" || (components.port != nil && components.port != 443) {
            components.queryItems = [.init(name: "token", value: token)]
        }
        return components.url!
    }
}

public struct DesktopInstallation: Codable, Sendable {
    public var installable: Bool?
    public var installed: Bool?
    public var phase: String
    public var stage: String?
    public var error: String?
    public var choices: [Choice]?
    public var workloadId: String?
    public var selected: String?
    public var success: Bool?
    public struct Choice: Codable, Sendable, Identifiable {
        public let id: String
        public let label: String
        public var description: String?
        public var minimumMemoryMb: Int?
        public var prepared: Bool?
    }
}

public struct DesktopStatus: Codable, Sendable {
    public let supported: Bool
    public let enabled: Bool
    public let available: Bool
    public var credentials: Bool?
    public var transports: [String]?
    public var sessions: DesktopSessionCapabilities?
}
public struct DesktopCredentials: Codable, Sendable {
    public let username: String
    public let password: String
}
public struct DesktopSSHConnection: Codable, Sendable {
    public let expiresAt: String
    public let ssh: SSH
    public let vnc: VNC
    public var sessionId: String?
    public struct SSH: Codable, Sendable {
        public let host: String
        public let port: Int
        public let username: String
        public let password: String
        public let hostKeyFingerprint: String
    }
    public struct VNC: Codable, Sendable {
        public let host: String
        public let port: Int
        public let authentication: String
    }
}

public struct RuntimeCatalog: Codable, Sendable {
    public let defaultTarget: String
    public let targets: [Target]
    public struct Target: Codable, Sendable, Identifiable {
        public let id: String
        public let runtime: Runtime
        public struct Runtime: Codable, Sendable { public let os: String }
    }
}
extension RuntimeClient {
    public nonisolated var desktop: RuntimeDesktopAPI { RuntimeDesktopAPI(runtime: self) }
    public func runtimes() async throws -> RuntimeCatalog {
        try OblienJSON.decode(RuntimeCatalog.self, await perform("GET", "/runtimes", root: true))
    }
}
extension WorkspaceHandle {
    public var desktop: DesktopAPI { DesktopAPI(transport: transport, workspaceId: id) }
}
extension WorkspacesAPI {
    public func desktop(_ id: String) -> DesktopAPI { DesktopAPI(transport: transport, workspaceId: id) }
}
