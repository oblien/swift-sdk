import Foundation

/// Namespace billing. Mutations require an admin or billing-scoped credential.
public struct BillingAPI: Sendable {
    let transport: Transport
    public func catalog() async throws -> BillingCatalog { try await transport.api("GET", "/billing/catalog") }
    public func checkout(_ params: CheckoutParams) async throws -> CheckoutResponse {
        try await transport.api("POST", "/billing/checkout", body: APIJSON.encode(params), retrySafe: params.idempotencyKey?.isEmpty == false)
    }
    public func checkoutStatus(namespace: String, checkoutId: String) async throws -> BillingCheckoutResponse {
        try await transport.api("GET", "/billing/checkout/\(checkoutId.pathEscaped)", query: ["namespace": namespace])
    }
    public func portal(_ params: PortalParams) async throws -> PortalResponse {
        guard !params.namespace.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OblienError(kind: .validation, status: nil, code: nil, message: "A namespace is required for the billing portal.", details: nil)
        }
        return try await transport.api("POST", "/billing/portal", body: APIJSON.encode(params))
    }
    public func subscription(_ namespace: String) async throws -> BillingSubscriptionResponse {
        try await transport.api("GET", "/billing/subscription", query: ["namespace": namespace])
    }
    public func cancelSubscription(_ namespace: String) async throws -> BillingSubscriptionResponse {
        try await transport.api("POST", "/billing/subscription/cancel", body: APIJSON.encode(["namespace": namespace]))
    }
    public func resumeSubscription(_ namespace: String) async throws -> BillingSubscriptionResponse {
        try await transport.api("POST", "/billing/subscription/resume", body: APIJSON.encode(["namespace": namespace]))
    }
    public func resetQuota(_ namespace: String, _ params: ResetQuotaParams) async throws -> ResetQuotaResponse {
        try await transport.api("POST", "/billing/policy/\(namespace.pathEscaped)/reset", body: APIJSON.encode(params))
    }
    public func entitlement(_ namespace: String) async throws -> Entitlement {
        try await transport.api("GET", "/billing/entitlement", query: ["namespace": namespace])
    }
    public func balance(_ namespace: String) async throws -> BillingBalance {
        try await transport.api("GET", "/billing/balance", query: ["namespace": namespace])
    }
    public func policy(_ namespace: String) async throws -> BillingPolicy {
        try await transport.api("GET", "/billing/policy/\(namespace.pathEscaped)")
    }
    public func setPolicy(_ namespace: String, _ params: BillingPolicyParams) async throws -> BillingPolicy {
        try await transport.api("PUT", "/billing/policy/\(namespace.pathEscaped)", body: APIJSON.encode(params))
    }
    public func defaults() async throws -> BillingDefaults { try await transport.api("GET", "/billing/defaults") }
    public func setDefaults(_ params: BillingDefaultsParams) async throws -> BillingDefaults {
        try await transport.api("PUT", "/billing/defaults", body: APIJSON.encode(params))
    }
}

extension OblienClient {
    public var billing: BillingAPI { BillingAPI(transport: transport) }
}
