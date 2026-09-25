import Foundation

public struct WebhooksAPI: Sendable {
    let transport: Transport
    public func list(namespace: String? = nil) async throws -> WebhookListResponse {
        try await transport.api("GET", "/webhooks", query: ["namespace": namespace])
    }
    public func events() async throws -> WebhookEventsResponse { try await transport.api("GET", "/webhooks/events") }
    public func create(_ params: WebhookCreateParams) async throws -> APIResponse {
        try await transport.api("POST", "/webhooks", body: APIJSON.encode(params))
    }
    public func update(_ id: Int, _ params: WebhookUpdateParams) async throws -> APIResponse {
        try await transport.api("PUT", "/webhooks/\(id)", body: APIJSON.encode(params))
    }
    @discardableResult public func delete(_ id: Int) async throws -> APIResponse {
        try await transport.api("DELETE", "/webhooks/\(id)")
    }
}

extension OblienClient {
    public var webhooks: WebhooksAPI { WebhooksAPI(transport: transport) }
}
