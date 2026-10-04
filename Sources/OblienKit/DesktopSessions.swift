import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct DesktopResolution: Codable, Sendable, Hashable {
    public var width: Int
    public var height: Int
    public init(width: Int, height: Int) { self.width = width; self.height = height }
}

public struct DesktopSessionCapabilities: Codable, Sendable {
    /// `virtual` supports separate profiles; `console` is the OS's one display.
    public let mode: String
    public let maxSessions: Int
    public let canCreate: Bool
    public var resolution: ResolutionLimits?
    public struct ResolutionLimits: Codable, Sendable {
        public let min: DesktopResolution
        public let max: DesktopResolution
        public let `default`: DesktopResolution
    }
}

/// A saved provider desktop, distinct from a viewer connection or control lease.
public struct DesktopSession: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public var resolution: DesktopResolution?
    /// Preserves new states, including asynchronous `deleting`.
    public let state: String
    public let managed: Bool
    public let available: Bool
    public var canResize: Bool?
    public var canDelete: Bool?
    public var deletionPending: Bool?
    public var mode: String?
    public var createdAt: String?
    public var updatedAt: String?
    public var error: String?
}

public struct CreateDesktopSession: Codable, Sendable {
    public var name: String
    /// Omit when adding an OS console. Virtual desktops accept the advertised range.
    public var resolution: DesktopResolution?
    public var idempotencyKey: String?
    public init(name: String, resolution: DesktopResolution? = nil, idempotencyKey: String? = nil) {
        self.name = name; self.resolution = resolution; self.idempotencyKey = idempotencyKey
    }
}
public struct UpdateDesktopSession: Codable, Sendable {
    public var name: String?
    public var resolution: DesktopResolution?
    public init(name: String? = nil, resolution: DesktopResolution? = nil) { self.name = name; self.resolution = resolution }
}
public struct DesktopSessionList: Codable, Sendable {
    public let success: Bool
    public let sessions: [DesktopSession]
    public let capabilities: DesktopSessionCapabilities
}
public struct DesktopSessionResult: Codable, Sendable {
    public let success: Bool
    public let session: DesktopSession
}
public struct DesktopSessionDeletion: Codable, Sendable {
    public let success: Bool
    /// A virtual desktop may be deleting in the background after acceptance.
    public var session: DesktopSession?
}

func desktopSessionPath(_ id: String) throws -> String {
    guard id.range(of: "^(console|ds_[a-f0-9]{16})$", options: .regularExpression) != nil else {
        throw OblienError(kind: .validation, status: nil, code: nil, message: "Invalid desktop session ID.", details: nil)
    }
    return "/desktop/sessions/" + id
}

/// Shared session operations for management and direct runtime clients.
public struct DesktopSessionsAPI: Sendable {
    enum Endpoint: Sendable { case management(Transport, String), runtime(RuntimeClient) }
    let endpoint: Endpoint

    private func request<T: Decodable>(_ method: String, _ suffix: String = "", body: Data? = nil,
                                      retrySafe: Bool = false) async throws -> T {
        let data: Data
        switch endpoint {
        case .management(let transport, let workspaceId):
            data = try await transport.request(method, "/workspace/\(workspaceId.pathEscaped)/desktop/sessions" + suffix,
                                               body: body, retrySafe: retrySafe)
        case .runtime(let runtime):
            data = try await runtime.perform(method, "/desktop/sessions" + suffix, body: body, root: true)
        }
        return try OblienJSON.decode(T.self, data)
    }
    private func suffix(_ id: String) throws -> String { _ = try desktopSessionPath(id); return "/" + id }
    public func list() async throws -> DesktopSessionList { try await request("GET") }
    public func create(_ params: CreateDesktopSession) async throws -> DesktopSessionResult {
        try await request("POST", body: OblienJSON.encode(params), retrySafe: params.idempotencyKey?.isEmpty == false)
    }
    public func get(_ id: String) async throws -> DesktopSessionResult { try await request("GET", suffix(id)) }
    public func update(_ id: String, _ params: UpdateDesktopSession) async throws -> DesktopSessionResult {
        try await request("PATCH", suffix(id), body: OblienJSON.encode(params))
    }
    public func start(_ id: String) async throws -> DesktopSessionResult { try await request("POST", suffix(id) + "/start") }
    public func stop(_ id: String) async throws -> DesktopSessionResult { try await request("POST", suffix(id) + "/stop") }
    @discardableResult public func delete(_ id: String) async throws -> DesktopSessionDeletion { try await request("DELETE", suffix(id)) }
}

extension DesktopAPI {
    public var sessions: DesktopSessionsAPI { .init(endpoint: .management(transport, workspaceId)) }
    public func listSessions() async throws -> DesktopSessionList { try await sessions.list() }
    public func createSession(_ params: CreateDesktopSession) async throws -> DesktopSessionResult { try await sessions.create(params) }
    public func getSession(_ id: String) async throws -> DesktopSessionResult { try await sessions.get(id) }
    public func updateSession(_ id: String, _ params: UpdateDesktopSession) async throws -> DesktopSessionResult { try await sessions.update(id, params) }
    public func startSession(_ id: String) async throws -> DesktopSessionResult { try await sessions.start(id) }
    public func stopSession(_ id: String) async throws -> DesktopSessionResult { try await sessions.stop(id) }
    @discardableResult public func deleteSession(_ id: String) async throws -> DesktopSessionDeletion { try await sessions.delete(id) }
}
extension RuntimeDesktopAPI {
    public var sessions: DesktopSessionsAPI { .init(endpoint: .runtime(runtime)) }
    public func listSessions() async throws -> DesktopSessionList { try await sessions.list() }
    public func createSession(_ params: CreateDesktopSession) async throws -> DesktopSessionResult { try await sessions.create(params) }
    public func getSession(_ id: String) async throws -> DesktopSessionResult { try await sessions.get(id) }
    public func updateSession(_ id: String, _ params: UpdateDesktopSession) async throws -> DesktopSessionResult { try await sessions.update(id, params) }
    public func startSession(_ id: String) async throws -> DesktopSessionResult { try await sessions.start(id) }
    public func stopSession(_ id: String) async throws -> DesktopSessionResult { try await sessions.stop(id) }
    @discardableResult public func deleteSession(_ id: String) async throws -> DesktopSessionDeletion { try await sessions.delete(id) }
    /// Authenticates using a header, never a token in the WebSocket URL.
    public func webSocketRequest(sessionId: String? = nil) async throws -> URLRequest {
        let path = try sessionId.map { try desktopSessionPath($0) + "/ws" } ?? "/desktop/ws"
        var url = URLComponents(url: try await runtime.endpoint(path, root: true), resolvingAgainstBaseURL: false)!
        url.scheme = url.scheme == "https" ? "wss" : "ws"
        var request = URLRequest(url: url.url!)
        request.setValue("Bearer " + (try await runtime.token()), forHTTPHeaderField: "Authorization")
        request.setValue("binary", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        return request
    }
}
