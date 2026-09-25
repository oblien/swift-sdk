import Foundation

/// Desktop preparation and native SSH/VNC grants use the management API. Access switches
/// and OS credentials use `RuntimeClient.desktop` and the existing runtime authentication.
public struct DesktopAPI: Sendable {
    let transport: Transport
    let workspaceId: String
    private var base: String { "/workspace/\(workspaceId.pathEscaped)/desktop" }

    public func installation() async throws -> DesktopInstallation {
        try OblienJSON.decode(DesktopInstallation.self, await transport.request("GET", base + "/installation"))
    }
    /// Restarting a running workspace requires an explicit `restart: true` from the caller.
    public func install(desktop: String? = nil, restart: Bool = false) async throws -> DesktopInstallation {
        struct Body: Encodable { let desktop: String?; let restart: Bool }
        return try OblienJSON.decode(DesktopInstallation.self, await transport.request("POST", base + "/install",
            body: OblienJSON.encode(Body(desktop: desktop, restart: restart))))
    }
    /// Contains a temporary password; keep the grant in memory and never log or persist it.
    public func sshConnection() async throws -> DesktopSSHConnection {
        try OblienJSON.decode(DesktopSSHConnection.self, await transport.request("POST", base + "/ssh"))
    }
}

public struct RuntimeDesktopAPI: Sendable {
    let runtime: RuntimeClient
    public func status() async throws -> DesktopStatus {
        try OblienJSON.decode(DesktopStatus.self, await runtime.perform("GET", "/desktop/status", root: true))
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
    public func url() async throws -> URL {
        var components = URLComponents(url: try await runtime.endpoint("/desktop", root: true), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "token", value: try await runtime.token())]
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
    public struct Choice: Codable, Sendable, Identifiable {
        public let id: String
        public let label: String
        public var description: String?
        public var minimumMemoryMb: Int?
    }
}

public struct DesktopStatus: Codable, Sendable {
    public let supported: Bool
    public let enabled: Bool
    public let available: Bool
    public var credentials: Bool?
    public var transports: [String]?
}
public struct DesktopCredentials: Codable, Sendable {
    public let username: String
    public let password: String
}
public struct DesktopSSHConnection: Codable, Sendable {
    public let expiresAt: String
    public let ssh: SSH
    public let vnc: VNC
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
