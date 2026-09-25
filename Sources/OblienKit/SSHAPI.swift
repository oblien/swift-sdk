import Foundation

/// SSH access for a workspace (`client.workspaces.ssh(id)` / `handle.ssh`): enable/disable
/// SSH, set a password or public key, and read the current status.

/// Lenient SSH status. `enable()` may include a one-time `sshPassword`; `connection`
/// is an undocumented loose shape kept as `JSONValue`.
public struct SSHStatus: Codable, Sendable {
    public let sshEnabled: Bool?
    public let sshId: String?
    public let sshPasswordChanged: Bool?
    public let sshPassword: String?
    public let connection: JSONValue?
    public let user: String?
    public let passwordSet: Bool?
    public let keySet: Bool?
    public var supported: Bool?
    public var authMethods: [String]?
    public var passwordAuthEnabled: Bool?
    public var passwordAffectsDesktop: Bool?
    public var sshKeySet: Bool?

    public var connectionInfo: SSHConnectionInfo? {
        guard let connection else { return nil }
        return try? OblienJSON.decode(SSHConnectionInfo.self, OblienJSON.encode(connection))
    }

    public var additionalProperties: [String: JSONValue] = [:]

    public init(from decoder: Decoder) throws {
        var fields = try JSONFields(from: decoder)
        sshEnabled = try fields.take("ssh_enabled", as: Bool.self)
        sshId = try fields.take("ssh_id", as: String.self)
        sshPasswordChanged = try fields.take("ssh_password_changed", as: Bool.self)
        sshPassword = try fields.take("ssh_password", as: String.self)
        connection = try fields.take("connection", as: JSONValue.self)
        user = try fields.take("user", as: String.self)
        passwordSet = try fields.take("password_set", as: Bool.self)
        keySet = try fields.take("key_set", as: Bool.self)
        supported = try fields.take("supported", as: Bool.self)
        authMethods = try fields.take("auth_methods", as: [String].self)
        passwordAuthEnabled = try fields.take("password_auth_enabled", as: Bool.self)
        passwordAffectsDesktop = try fields.take("password_affects_desktop", as: Bool.self)
        sshKeySet = try fields.take("ssh_key_set", as: Bool.self)
        additionalProperties = fields.values
    }

    public func encode(to encoder: Encoder) throws {
        var fields = JSONFields(additionalProperties)
        try fields.set("ssh_enabled", sshEnabled)
        try fields.set("ssh_id", sshId)
        try fields.set("ssh_password_changed", sshPasswordChanged)
        try fields.set("ssh_password", sshPassword)
        try fields.set("connection", connection)
        try fields.set("user", user)
        try fields.set("password_set", passwordSet)
        try fields.set("key_set", keySet)
        try fields.set("supported", supported)
        try fields.set("auth_methods", authMethods)
        try fields.set("password_auth_enabled", passwordAuthEnabled)
        try fields.set("password_affects_desktop", passwordAffectsDesktop)
        try fields.set("ssh_key_set", sshKeySet)
        try fields.encode(to: encoder)
    }
}

public struct SSHConnectionInfo: Codable, Sendable {
    public var command: String?
    public var user: String?
    public var host: String?
    public var bastion: String?
    public var scpUpload: String?
    public var scpDownload: String?
}

/// `client.workspaces.ssh(id)` / `handle.ssh`.
public struct SSHAPI: Sendable {
    let transport: Transport
    let workspaceId: String
    private var base: String { "/workspace/\(workspaceId.pathEscaped)/ssh" }

    public func status() async throws -> SSHStatus {
        try OblienJSON.decode(SSHStatus.self, try await transport.request("GET", base))
    }

    public func enable() async throws -> SSHStatus {
        try OblienJSON.decode(SSHStatus.self, try await transport.request("POST", base + "/enable"))
    }

    public func disable() async throws {
        _ = try await transport.request("POST", base + "/disable")
    }

    public func setPassword(_ password: String, user: String? = nil) async throws {
        struct Body: Encodable { let password: String; let user: String? }
        let body = try OblienJSON.encode(Body(password: password, user: user))
        _ = try await transport.request("POST", base + "/password", body: body)
    }

    public func setKey(publicKey: String, user: String? = nil) async throws {
        struct Body: Encodable { let publicKey: String; let user: String? }
        let body = try OblienJSON.encode(Body(publicKey: publicKey, user: user))
        _ = try await transport.request("POST", base + "/key", body: body)
    }
}

extension WorkspaceHandle {
    public var ssh: SSHAPI { SSHAPI(transport: transport, workspaceId: id) }
}

extension WorkspacesAPI {
    public func ssh(_ id: String) -> SSHAPI { SSHAPI(transport: transport, workspaceId: id) }
}
