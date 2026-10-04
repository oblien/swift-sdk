import Foundation

/// Namespace billing. Mutations require an admin or billing-scoped credential.
public struct BillingAPI: Sendable {
    let transport: Transport
    public func capacityCatalog() async throws -> CapacityCatalog { try await transport.api("GET", "/billing/capacity/catalog") }
    public func capacity(_ namespace: String) async throws -> CapacityResponse {
        try await transport.api("GET", "/billing/capacity", query: ["namespace": namespace])
    }
    public func previewCapacity(_ namespace: String, _ params: PreviewCapacityParams) async throws -> CapacityQuoteResponse {
        try await transport.api("POST", "/billing/capacity/preview", body: APIJSON.encode(params, merging: ["namespace": .string(namespace)]))
    }
    public func confirmCapacity(_ namespace: String, _ params: ConfirmCapacityParams) async throws -> CapacityResponse {
        try await transport.api("POST", "/billing/capacity/confirm", body: APIJSON.encode(params, merging: ["namespace": .string(namespace)]))
    }
    public func capacityCheckout(_ namespace: String, _ params: CapacityCheckoutParams) async throws -> CapacityCheckoutResponse {
        try await transport.api("POST", "/billing/capacity/checkout", body: APIJSON.encode(params, merging: ["namespace": .string(namespace)]))
    }
    public func cancelCapacityChange(_ namespace: String, _ params: ConfirmCapacityParams) async throws -> CapacityResponse {
        try await transport.api("POST", "/billing/capacity/change/cancel", body: APIJSON.encode(params, merging: ["namespace": .string(namespace)]))
    }
    public func setCapacityAutoRenew(_ namespace: String, autoRenew: Bool, idempotencyKey: String) async throws -> CapacityResponse {
        struct Body: Encodable { let namespace: String; let autoRenew: Bool; let idempotencyKey: String }
        return try await transport.api("POST", "/billing/capacity/renewal", body: APIJSON.encode(Body(namespace: namespace, autoRenew: autoRenew, idempotencyKey: idempotencyKey)))
    }
    public func previewNetworkTopup(_ namespace: String, unitAmount: Double, idempotencyKey: String) async throws -> CapacityQuoteResponse {
        struct Body: Encodable { let namespace: String; let unitAmount: Double; let idempotencyKey: String }
        return try await transport.api("POST", "/billing/capacity/network/preview", body: APIJSON.encode(Body(namespace: namespace, unitAmount: unitAmount, idempotencyKey: idempotencyKey)))
    }
    public func savings(namespace: String? = nil, workspaceId: String? = nil, month: String? = nil) async throws -> BillingSavings {
        try await transport.api("GET", "/billing/savings", query: ["namespace": namespace, "workspaceId": workspaceId, "month": month])
    }
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
    public func previewPlanChange(_ namespace: String, _ params: PreviewPlanChangeParams) async throws -> BillingPlanChangeQuoteResponse {
        try await transport.api("POST", "/billing/subscription/changes/preview", body: APIJSON.encode(params, merging: ["namespace": .string(namespace)]))
    }
    public func changePlan(_ namespace: String, _ params: ChangePlanParams) async throws -> BillingPlanChangeResponse {
        try await transport.api("POST", "/billing/subscription/changes", body: APIJSON.encode(params, merging: ["namespace": .string(namespace)]))
    }
    public func planChange(_ namespace: String, changeId: String) async throws -> BillingPlanChangeResponse {
        try await transport.api("GET", "/billing/subscription/changes/\(changeId.pathEscaped)", query: ["namespace": namespace])
    }
    public func cancelPlanChange(_ namespace: String, changeId: String, _ params: CancelPlanChangeParams) async throws -> BillingPlanChangeResponse {
        try await transport.api("POST", "/billing/subscription/changes/\(changeId.pathEscaped)/cancel", body: APIJSON.encode(params, merging: ["namespace": .string(namespace)]))
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
