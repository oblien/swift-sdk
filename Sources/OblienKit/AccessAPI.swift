import Foundation

public struct AccessResource: Codable, Sendable {
    public var accountId: String
    public var resourceType: String
    public var resourceId: String?
    public init(accountId: String, resourceType: String, resourceId: String? = nil) {
        self.accountId = accountId; self.resourceType = resourceType; self.resourceId = resourceId
    }
}
public struct AccountLabel: Codable, Sendable {
    public let id: String
    public let name: String
    public var image: String?
}
public struct AccessibleAccount: Codable, Sendable {
    public let id: String
    public let name: String
    public var image: String?
    public let personal: Bool
    public let role: String
    public let permissions: [String]
    public var membershipId: String?
}
public struct WorkspaceSharing: Codable, Sendable {
    public let ownerId: String
    public let actorId: String
    public let role: String
    public let permissions: [String]
    public var owner: AccountLabel?
    public var namespaceAccess: Bool?
    public var namespaceId: String?
}
public struct AccessInvitation: Codable, Sendable, Identifiable {
    public let id: String
    public let owner: AccountLabel
    public let resourceType: String
    public let resourceId: String
    public var resourceName: String?
    public let role: String
    public let expiresAt: String
    public var accessExpiresAt: String?
}
public struct AccessMember: Codable, Sendable, Identifiable {
    public let id: String
    public let user: AccountLabel
    public let role: String
    public let version: String
    public var expiresAt: String?
}
public struct AccessMembers: Codable, Sendable {
    public let success: Bool
    public let owner: AccessibleAccount
    public let members: [AccessMember]
    public let invitations: [AccessInvitation]
}
public struct SharedWorkspaceList: Codable, Sendable {
    public let success: Bool
    public let workspaces: [Workspace]
    public var nextCursor: String?
}
public struct CreatedAccessInvitation: Codable, Sendable {
    public let success: Bool
    public let invitation: Invitation
    public let invitationUrl: String
    public struct Invitation: Codable, Sendable {
        public let id: String
        public let email: String
        public let role: String
        public let expiresAt: String
    }
}
public struct AccessToken: Decodable, Sendable {
    public let success: Bool
    public let token: String
    public let expiresAt: String
    public let ttl: Int
    public let scope: String
    public let permissions: [String]
}
public struct AccessAudit: Codable, Sendable {
    public let success: Bool
    public let events: [Event]
    public var nextCursor: String?
    public struct Event: Codable, Sendable, Identifiable {
        public let id: String
        public let action: String
        public let actorId: String
        public let actorName: String
        public let createdAt: String
    }
}
public struct SharedSSHConnection: Decodable, Sendable {
    public let success: Bool
    public let delegated: Bool
    public let expiresAt: String
    public let ssh: DesktopSSHConnection.SSH
}

/// Identity-based sharing. Tokens and invitation URLs are secrets; keep them out of logs.
public struct AccessAPI: Sendable {
    let transport: Transport
    private func request<T: Decodable>(_ method: String, _ path: String, query: [String: String?] = [:], body: Data? = nil) async throws -> T {
        try OblienJSON.decode(T.self, await transport.request(method, "/access" + path, query: query, body: body))
    }
    private func fields(_ resource: AccessResource) throws -> [String: JSONValue] {
        try JSONDecoder().decode([String: JSONValue].self, from: OblienJSON.encode(resource))
    }
    private func query(_ resource: AccessResource) -> [String: String?] {
        ["account_id": resource.accountId, "resource_type": resource.resourceType, "resource_id": resource.resourceId]
    }
    public func accounts() async throws -> [AccessibleAccount] {
        struct Result: Decodable { let accounts: [AccessibleAccount] }
        let value: Result = try await request("GET", "/accounts"); return value.accounts
    }
    public func sharedWorkspaces(before: String? = nil, limit: Int? = nil) async throws -> SharedWorkspaceList {
        try await request("GET", "/shared-workspaces", query: ["before": before, "limit": limit.map(String.init)])
    }
    public func invitations() async throws -> [AccessInvitation] {
        struct Result: Decodable { let invitations: [AccessInvitation] }
        let value: Result = try await request("GET", "/invitations"); return value.invitations
    }
    public func invite(_ resource: AccessResource, email: String, role: String? = nil, expiresAt: String? = nil) async throws -> CreatedAccessInvitation {
        var body = try fields(resource); body["email"] = .string(email)
        body["role"] = role.map(JSONValue.string); body["expires_at"] = expiresAt.map(JSONValue.string)
        return try await request("POST", "/invitations", body: OblienJSON.encode(body))
    }
    public enum InvitationReference: Sendable { case id(String), token(String) }
    public func accept(_ invitation: InvitationReference) async throws -> APIResponse {
        let body: [String: String]
        switch invitation { case .id(let id): body = ["id": id]; case .token(let token): body = ["token": token] }
        return try await request("POST", "/invitations/accept", body: OblienJSON.encode(body))
    }
    public func revokeInvitation(_ id: String) async throws -> APIResponse { try await request("DELETE", "/invitations/" + id.pathEscaped) }
    public func members(_ resource: AccessResource) async throws -> AccessMembers { try await request("GET", "/members", query: query(resource)) }
    public func updateMember(_ id: String, role: String, version: String? = nil, expiresAt: JSONField<String>? = nil) async throws -> APIResponse {
        struct Body: Encodable { let role: String; let version: String?; let expiresAt: JSONField<String>? }
        return try await request("PATCH", "/members/" + id.pathEscaped, body: OblienJSON.encode(Body(role: role, version: version, expiresAt: expiresAt)))
    }
    public func removeMember(_ id: String, version: String? = nil) async throws -> APIResponse {
        try await request("DELETE", "/members/" + id.pathEscaped, body: OblienJSON.encode(["version": version]))
    }
    public func issueToken(_ resource: AccessResource, role: String? = nil, ttl: Int? = nil, label: String? = nil) async throws -> AccessToken {
        var body = try fields(resource); body["role"] = role.map(JSONValue.string)
        body["ttl"] = ttl.map { .number(Double($0)) }; body["label"] = label.map(JSONValue.string)
        return try await request("POST", "/tokens", body: OblienJSON.encode(body))
    }
    public func audit(_ resource: AccessResource, before: String? = nil) async throws -> AccessAudit {
        var parameters = query(resource); parameters["before"] = before
        return try await request("GET", "/audit", query: parameters)
    }
}
extension OblienClient { public var access: AccessAPI { .init(transport: transport) } }
