import Foundation

/// Account namespaces, resource caps, usage, quotas and quota defaults.
public struct NamespacesAPI: Sendable {
    let transport: Transport
    private func path(_ id: String) -> String { "/namespaces/\(id.pathEscaped)" }

    public func create(_ params: NamespaceCreateParams) async throws -> NamespaceData {
        let response: APIDataResponse<NamespaceData> = try await transport.api("POST", "/namespaces", body: APIJSON.encode(params))
        return response.data
    }
    public func ensure(_ params: NamespaceEnsureParams) async throws -> NamespaceEnsureResponse {
        try await transport.api("POST", "/namespaces/ensure", body: APIJSON.encode(params))
    }
    public func list(_ params: NamespaceListParams = .init()) async throws -> NamespaceListResponse {
        try await transport.api("GET", "/namespaces", query: APIJSON.query(params))
    }
    public func get(_ idOrSlug: String) async throws -> NamespaceData {
        let response: APIDataResponse<NamespaceData> = try await transport.api("GET", path(idOrSlug))
        return response.data
    }
    public func update(_ id: String, _ params: NamespaceUpdateParams) async throws -> NamespaceData {
        let response: APIDataResponse<NamespaceData> = try await transport.api("PUT", path(id), body: APIJSON.encode(params))
        return response.data
    }
    @discardableResult public func delete(_ id: String, deleteWorkspaces: Bool = false) async throws -> APIResponse {
        try await transport.api("DELETE", path(id), body: APIJSON.encode(NamespaceDeleteParams(deleteWorkspaces: deleteWorkspaces)))
    }
    @discardableResult public func suspend(_ id: String) async throws -> APIResponse {
        try await transport.api("POST", path(id) + "/suspend")
    }
    @discardableResult public func activate(_ id: String) async throws -> APIResponse {
        try await transport.api("POST", path(id) + "/activate")
    }
    @discardableResult public func stopWorkspaces(_ id: String) async throws -> APIResponse {
        try await transport.api("POST", path(id) + "/stop-workspaces")
    }
    public func activity(_ id: String, _ params: NamespaceActivityParams = .init()) async throws -> APIResponse {
        try await transport.api("GET", path(id) + "/activity", query: APIJSON.query(params))
    }
    public func usage(_ id: String, _ params: NamespaceUsageParams = .init()) async throws -> APIResponse {
        try await transport.api("GET", path(id) + "/usage", query: APIJSON.query(params))
    }
    public func usageUnits(_ id: String, _ params: NamespaceUsageUnitsParams = .init()) async throws -> NamespaceUsageUnits {
        let response: APIDataResponse<NamespaceUsageUnits> = try await transport.api("GET", path(id) + "/usage-units", query: APIJSON.query(params))
        return response.data
    }
    @discardableResult public func setQuota(_ params: SetNamespaceQuotaParams) async throws -> APIResponse {
        try await transport.api("POST", "/credits/namespace-quota", body: APIJSON.encode(params))
    }
    @discardableResult public func resetQuota(_ params: ResetNamespaceQuotaParams) async throws -> APIResponse {
        try await transport.api("POST", "/credits/reset-quota", body: APIJSON.encode(params))
    }
    public func listWithQuotas(_ params: NamespaceListWithQuotasParams = .init()) async throws -> APIResponse {
        try await transport.api("GET", "/credits/namespaces", query: APIJSON.query(params))
    }
    public func getDetails(_ namespace: String, _ params: NamespaceDetailsParams = .init()) async throws -> APIResponse {
        try await transport.api("GET", "/credits/namespaces/\(namespace.pathEscaped)", query: APIJSON.query(params))
    }
    @discardableResult public func setDefaultQuota(_ params: SetDefaultQuotaParams) async throws -> APIResponse {
        try await transport.api("POST", "/credits/defaults", body: APIJSON.encode(params, merging: ["level": .string("namespace")]))
    }
    public func getDefaultQuota(_ service: String) async throws -> APIResponse {
        try await transport.api("GET", "/credits/defaults", query: ["level": "namespace", "service": service])
    }
    public func getAllDefaultQuotas() async throws -> APIResponse {
        try await transport.api("GET", "/credits/defaults/all", query: ["level": "namespace"])
    }
    @discardableResult public func deleteDefaultQuota(_ service: String) async throws -> APIResponse {
        try await transport.api("DELETE", "/credits/defaults", body: APIJSON.encode(["level": "namespace", "service": service]))
    }
    @discardableResult public func toggleDefaultQuotaAutoApply(_ service: String, autoApply: Bool) async throws -> APIResponse {
        try await transport.api("POST", "/credits/defaults/toggle-auto-apply", body: APIJSON.encode([
            "level": JSONValue.string("namespace"), "service": .string(service), "autoApply": .bool(autoApply)]))
    }
}

extension OblienClient {
    public var namespaces: NamespacesAPI { NamespacesAPI(transport: transport) }
}
