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
