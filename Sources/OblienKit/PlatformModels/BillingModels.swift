// Models audited against oblien 2.4.0. Regenerate with scripts/generate-platform-models.cjs.
import Foundation

public struct BillingPlan: Codable, Sendable {
    public var `tierId`: String
    public var `name`: String
    public var `description`: String?
    @APIOptionalNumber public var `priceMonthly`: Double?
    @APIOptionalNumber public var `priceYearly`: Double?
    public var `currency`: String
    @APIOptionalNumber public var `creditsPerCycle`: Double?
    @APIOptionalNumber public var `yearlyCreditsPerCycle`: Double?
    @APIOptionalNumber public var `overdraftCredits`: Double?
    public var `features`: [String]
    @APIBoolean public var `popular`: Bool

    public init(`tierId`: String,
                `name`: String,
                `description`: String? = nil,
                `priceMonthly`: Double? = nil,
                `priceYearly`: Double? = nil,
                `currency`: String,
                `creditsPerCycle`: Double? = nil,
                `yearlyCreditsPerCycle`: Double? = nil,
                `overdraftCredits`: Double? = nil,
                `features`: [String],
                `popular`: Bool) {
        self.`tierId` = `tierId`
        self.`name` = `name`
        self.`description` = `description`
        self.`priceMonthly` = `priceMonthly`
        self.`priceYearly` = `priceYearly`
        self.`currency` = `currency`
        self.`creditsPerCycle` = `creditsPerCycle`
        self.`yearlyCreditsPerCycle` = `yearlyCreditsPerCycle`
        self.`overdraftCredits` = `overdraftCredits`
        self.`features` = `features`
        self.`popular` = `popular`
    }

    enum CodingKeys: String, CodingKey {
        case `tierId` = "tierId"
        case `name` = "name"
        case `description` = "description"
        case `priceMonthly` = "priceMonthly"
        case `priceYearly` = "priceYearly"
        case `currency` = "currency"
        case `creditsPerCycle` = "creditsPerCycle"
        case `yearlyCreditsPerCycle` = "yearlyCreditsPerCycle"
        case `overdraftCredits` = "overdraftCredits"
        case `features` = "features"
        case `popular` = "popular"
    }
}

public struct CreditPack: Codable, Sendable {
    public var `packId`: String
    public var `name`: String
    @APINumber public var `credits`: Double
    @APINumber public var `price`: Double
    public var `currency`: String
    @APIBoolean public var `popular`: Bool

    public init(`packId`: String,
                `name`: String,
                `credits`: Double,
                `price`: Double,
                `currency`: String,
                `popular`: Bool) {
        self.`packId` = `packId`
        self.`name` = `name`
        self.`credits` = `credits`
        self.`price` = `price`
        self.`currency` = `currency`
        self.`popular` = `popular`
    }

    enum CodingKeys: String, CodingKey {
        case `packId` = "packId"
        case `name` = "name"
        case `credits` = "credits"
        case `price` = "price"
        case `currency` = "currency"
        case `popular` = "popular"
    }
}

public struct BillingCatalog: Codable, Sendable {
    public var `plans`: [BillingPlan]
    public var `creditPacks`: [CreditPack]

    public init(`plans`: [BillingPlan],
                `creditPacks`: [CreditPack]) {
        self.`plans` = `plans`
        self.`creditPacks` = `creditPacks`
    }

    enum CodingKeys: String, CodingKey {
        case `plans` = "plans"
        case `creditPacks` = "creditPacks"
    }
}

public struct BillingOffer: Codable, Sendable {
    public var `reference`: String?
    public var `name`: String
    public var `description`: String?
    @APINumber public var `unitAmount`: Double
    public var `currency`: String?
    @APINumber public var `credits`: Double

    public init(`reference`: String? = nil,
                `name`: String,
                `description`: String? = nil,
                `unitAmount`: Double,
                `currency`: String? = nil,
                `credits`: Double) {
        self.`reference` = `reference`
        self.`name` = `name`
        self.`description` = `description`
        self.`unitAmount` = `unitAmount`
        self.`currency` = `currency`
        self.`credits` = `credits`
    }

    enum CodingKeys: String, CodingKey {
        case `reference` = "reference"
        case `name` = "name"
        case `description` = "description"
        case `unitAmount` = "unitAmount"
        case `currency` = "currency"
        case `credits` = "credits"
    }
}

public struct CheckoutParamsCustomer: Codable, Sendable {
    public var `email`: String?
    public var `name`: String?

    public init(`email`: String? = nil,
                `name`: String? = nil) {
        self.`email` = `email`
        self.`name` = `name`
    }

    enum CodingKeys: String, CodingKey {
        case `email` = "email"
        case `name` = "name"
    }
}

public struct CheckoutParams: Codable, Sendable {
    public var `namespace`: String
    /// Accepted values: 'subscription' | 'topup'.
    public var `kind`: String
    public var `planTierId`: String?
    public var `packId`: String?
    public var `offer`: BillingOffer?
    public var `metadata`: [String: String]?
    /// Accepted values: 'monthly' | 'yearly'.
    public var `billingInterval`: String?
    public var `successUrl`: String?
    public var `cancelUrl`: String?
    public var `idempotencyKey`: String?
    public var `customer`: CheckoutParamsCustomer?

    public init(`namespace`: String,
                `kind`: String,
                `planTierId`: String? = nil,
                `packId`: String? = nil,
                `offer`: BillingOffer? = nil,
                `metadata`: [String: String]? = nil,
                `billingInterval`: String? = nil,
                `successUrl`: String? = nil,
                `cancelUrl`: String? = nil,
                `idempotencyKey`: String? = nil,
                `customer`: CheckoutParamsCustomer? = nil) {
        self.`namespace` = `namespace`
        self.`kind` = `kind`
        self.`planTierId` = `planTierId`
        self.`packId` = `packId`
        self.`offer` = `offer`
        self.`metadata` = `metadata`
        self.`billingInterval` = `billingInterval`
        self.`successUrl` = `successUrl`
        self.`cancelUrl` = `cancelUrl`
        self.`idempotencyKey` = `idempotencyKey`
        self.`customer` = `customer`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `kind` = "kind"
        case `planTierId` = "planTierId"
        case `packId` = "packId"
        case `offer` = "offer"
        case `metadata` = "metadata"
        case `billingInterval` = "billingInterval"
        case `successUrl` = "successUrl"
        case `cancelUrl` = "cancelUrl"
        case `idempotencyKey` = "idempotencyKey"
        case `customer` = "customer"
    }
}

public struct CheckoutResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `url`: String
    public var `checkoutId`: String

    public init(`success`: Bool,
                `url`: String,
                `checkoutId`: String) {
        self.`success` = `success`
        self.`url` = `url`
        self.`checkoutId` = `checkoutId`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `url` = "url"
        case `checkoutId` = "checkoutId"
    }
}

public struct BillingCheckout: Codable, Sendable {
    public var `id`: String
    /// Accepted values: 'subscription' | 'topup'.
    public var `kind`: String
    /// Accepted values: 'open' | 'complete' | 'expired'.
    public var `status`: String
    /// Accepted values: 'paid' | 'unpaid' | 'no_payment_required'.
    public var `paymentStatus`: String
    @APIBoolean public var `fulfilled`: Bool
    public var `offer`: BillingOffer
    public var `metadata`: [String: String]
    /// Accepted values: 'pending' | 'completed' | 'partially_refunded' | 'refunded' | 'disputed' | 'expired' | 'failed'.
    public var `fulfillmentStatus`: String
    @APINumber public var `walletCreditsGranted`: Double
    @APINumber public var `namespaceCreditsGranted`: Double
    /// Accepted values: 'monthly' | 'yearly' | null.
    public var `billingInterval`: String?
    public var `subscriptionId`: String?

    public init(`id`: String,
                `kind`: String,
                `status`: String,
                `paymentStatus`: String,
                `fulfilled`: Bool,
                `offer`: BillingOffer,
                `metadata`: [String: String],
                `fulfillmentStatus`: String,
                `walletCreditsGranted`: Double,
                `namespaceCreditsGranted`: Double,
                `billingInterval`: String? = nil,
                `subscriptionId`: String? = nil) {
        self.`id` = `id`
        self.`kind` = `kind`
        self.`status` = `status`
        self.`paymentStatus` = `paymentStatus`
        self.`fulfilled` = `fulfilled`
        self.`offer` = `offer`
        self.`metadata` = `metadata`
        self.`fulfillmentStatus` = `fulfillmentStatus`
        self.`walletCreditsGranted` = `walletCreditsGranted`
        self.`namespaceCreditsGranted` = `namespaceCreditsGranted`
        self.`billingInterval` = `billingInterval`
        self.`subscriptionId` = `subscriptionId`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `kind` = "kind"
        case `status` = "status"
        case `paymentStatus` = "paymentStatus"
        case `fulfilled` = "fulfilled"
        case `offer` = "offer"
        case `metadata` = "metadata"
        case `fulfillmentStatus` = "fulfillmentStatus"
        case `walletCreditsGranted` = "walletCreditsGranted"
        case `namespaceCreditsGranted` = "namespaceCreditsGranted"
        case `billingInterval` = "billingInterval"
        case `subscriptionId` = "subscriptionId"
    }
}

public struct BillingCheckoutResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `namespace`: String
    public var `checkout`: BillingCheckout

    public init(`success`: Bool,
                `namespace`: String,
                `checkout`: BillingCheckout) {
        self.`success` = `success`
        self.`namespace` = `namespace`
        self.`checkout` = `checkout`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `namespace` = "namespace"
        case `checkout` = "checkout"
    }
}

public struct PortalParams: Codable, Sendable {
    public var `namespace`: String
    public var `returnUrl`: String?

    public init(`namespace`: String,
                `returnUrl`: String? = nil) {
        self.`namespace` = `namespace`
        self.`returnUrl` = `returnUrl`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `returnUrl` = "returnUrl"
    }
}

public struct PortalResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `namespace`: String
    public var `url`: String

    public init(`success`: Bool,
                `namespace`: String,
                `url`: String) {
        self.`success` = `success`
        self.`namespace` = `namespace`
        self.`url` = `url`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `namespace` = "namespace"
        case `url` = "url"
    }
}

public struct BillingSubscription: Codable, Sendable {
    public var `tierId`: String
    /// Accepted values: 'active' | 'trialing' | 'past_due' | 'unpaid' | 'paused' | 'canceled'.
    public var `status`: String
    /// Accepted values: 'monthly' | 'yearly'.
    public var `billingInterval`: String
    public var `periodStart`: String?
    public var `periodEnd`: String?
    @APIBoolean public var `cancelAtPeriodEnd`: Bool
    public var `canceledAt`: String?
    public var `offer`: BillingOffer?
    public var `metadata`: [String: String]?

    public init(`tierId`: String,
                `status`: String,
                `billingInterval`: String,
                `periodStart`: String? = nil,
                `periodEnd`: String? = nil,
                `cancelAtPeriodEnd`: Bool,
                `canceledAt`: String? = nil,
                `offer`: BillingOffer? = nil,
                `metadata`: [String: String]? = nil) {
        self.`tierId` = `tierId`
        self.`status` = `status`
        self.`billingInterval` = `billingInterval`
        self.`periodStart` = `periodStart`
        self.`periodEnd` = `periodEnd`
        self.`cancelAtPeriodEnd` = `cancelAtPeriodEnd`
        self.`canceledAt` = `canceledAt`
        self.`offer` = `offer`
        self.`metadata` = `metadata`
    }

    enum CodingKeys: String, CodingKey {
        case `tierId` = "tierId"
        case `status` = "status"
        case `billingInterval` = "billingInterval"
        case `periodStart` = "periodStart"
        case `periodEnd` = "periodEnd"
        case `cancelAtPeriodEnd` = "cancelAtPeriodEnd"
        case `canceledAt` = "canceledAt"
        case `offer` = "offer"
        case `metadata` = "metadata"
    }
}

public struct BillingSubscriptionResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `namespace`: String
    public var `subscription`: BillingSubscription?

    public init(`success`: Bool,
                `namespace`: String,
                `subscription`: BillingSubscription? = nil) {
        self.`success` = `success`
        self.`namespace` = `namespace`
        self.`subscription` = `subscription`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `namespace` = "namespace"
        case `subscription` = "subscription"
    }
}

public struct ResetQuotaParams: Codable, Sendable {
    public var `periodEnd`: String

    public init(`periodEnd`: String) {
        self.`periodEnd` = `periodEnd`
    }

    enum CodingKeys: String, CodingKey {
        case `periodEnd` = "periodEnd"
    }
}

public struct ResetQuotaResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `namespace`: String
    @APIBoolean public var `applied`: Bool

    public init(`success`: Bool,
                `namespace`: String,
                `applied`: Bool) {
        self.`success` = `success`
        self.`namespace` = `namespace`
        self.`applied` = `applied`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `namespace` = "namespace"
        case `applied` = "applied"
    }
}

/// Open string enum; preserves new server values.
public struct EntitlementStatus: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(from decoder: Decoder) throws { rawValue = try decoder.singleValueContainer().decode(String.self) }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public static let `active` = Self(rawValue: "active")
    public static let `pastDue` = Self(rawValue: "past_due")
    public static let `canceled` = Self(rawValue: "canceled")
    public static let `creditExhausted` = Self(rawValue: "credit_exhausted")
}

public struct EntitlementQuota: Codable, Sendable {
    @APIOptionalNumber public var `limit`: Int?
    @APINumber public var `used`: Double
    @APIOptionalNumber public var `balance`: Double?

    public init(`limit`: Int? = nil,
                `used`: Double,
                `balance`: Double? = nil) {
        self.`limit` = `limit`
        self.`used` = `used`
        self.`balance` = `balance`
    }

    enum CodingKeys: String, CodingKey {
        case `limit` = "limit"
        case `used` = "used"
        case `balance` = "balance"
    }
}

public struct Entitlement: Codable, Sendable {
    public var `namespace`: String
    public var `tierId`: String
    public var `status`: EntitlementStatus
    public var `periodStart`: String?
    public var `periodEnd`: String?
    public var `quota`: EntitlementQuota

    public init(`namespace`: String,
                `tierId`: String,
                `status`: EntitlementStatus,
                `periodStart`: String? = nil,
                `periodEnd`: String? = nil,
                `quota`: EntitlementQuota) {
        self.`namespace` = `namespace`
        self.`tierId` = `tierId`
        self.`status` = `status`
        self.`periodStart` = `periodStart`
        self.`periodEnd` = `periodEnd`
        self.`quota` = `quota`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `tierId` = "tierId"
        case `status` = "status"
        case `periodStart` = "periodStart"
        case `periodEnd` = "periodEnd"
        case `quota` = "quota"
    }
}

public struct BillingBalance: Codable, Sendable {
    public var `namespace`: String
    @APIBoolean public var `blocking`: Bool
    @APIOptionalNumber public var `balance`: Double?

    public init(`namespace`: String,
                `blocking`: Bool,
                `balance`: Double? = nil) {
        self.`namespace` = `namespace`
        self.`blocking` = `blocking`
        self.`balance` = `balance`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `blocking` = "blocking"
        case `balance` = "balance"
    }
}

public struct BillingPolicy: Codable, Sendable {
    public var `service`: String
    @APIOptionalNumber public var `quotaLimit`: Double?
    @APINumber public var `purchasedCredits`: Double
    @APIOptionalNumber public var `effectiveCeiling`: Double?
    @APINumber public var `overdraft`: Double
    @APIOptionalNumber public var `suspendThreshold`: Double?
    public var `onOverdraftAction`: String

    public init(`service`: String,
                `quotaLimit`: Double? = nil,
                `purchasedCredits`: Double,
                `effectiveCeiling`: Double? = nil,
                `overdraft`: Double,
                `suspendThreshold`: Double? = nil,
                `onOverdraftAction`: String) {
        self.`service` = `service`
        self.`quotaLimit` = `quotaLimit`
        self.`purchasedCredits` = `purchasedCredits`
        self.`effectiveCeiling` = `effectiveCeiling`
        self.`overdraft` = `overdraft`
        self.`suspendThreshold` = `suspendThreshold`
        self.`onOverdraftAction` = `onOverdraftAction`
    }

    enum CodingKeys: String, CodingKey {
        case `service` = "service"
        case `quotaLimit` = "quotaLimit"
        case `purchasedCredits` = "purchasedCredits"
        case `effectiveCeiling` = "effectiveCeiling"
        case `overdraft` = "overdraft"
        case `suspendThreshold` = "suspendThreshold"
        case `onOverdraftAction` = "onOverdraftAction"
    }
}

public struct BillingPolicyParams: Codable, Sendable {
    public var `quotaLimit`: JSONField<Double>?
    @APIOptionalNumber public var `overdraft`: Double?
    public var `suspendThreshold`: JSONField<Double>?
    /// Accepted values: 'stop_workspaces' | 'block'.
    public var `onOverdraftAction`: String?

    public init(`quotaLimit`: JSONField<Double>? = nil,
                `overdraft`: Double? = nil,
                `suspendThreshold`: JSONField<Double>? = nil,
                `onOverdraftAction`: String? = nil) {
        self.`quotaLimit` = `quotaLimit`
        self.`overdraft` = `overdraft`
        self.`suspendThreshold` = `suspendThreshold`
        self.`onOverdraftAction` = `onOverdraftAction`
    }

    enum CodingKeys: String, CodingKey {
        case `quotaLimit` = "quotaLimit"
        case `overdraft` = "overdraft"
        case `suspendThreshold` = "suspendThreshold"
        case `onOverdraftAction` = "onOverdraftAction"
    }
}

public struct BillingDefaults: Codable, Sendable {
    @APIBoolean public var `autoApply`: Bool
    public var `service`: String
    @APIOptionalNumber public var `quotaLimit`: Double?
    @APINumber public var `overdraft`: Double
    @APIOptionalNumber public var `suspendThreshold`: Double?
    public var `onOverdraftAction`: String

    public init(`autoApply`: Bool,
                `service`: String,
                `quotaLimit`: Double? = nil,
                `overdraft`: Double,
                `suspendThreshold`: Double? = nil,
                `onOverdraftAction`: String) {
        self.`autoApply` = `autoApply`
        self.`service` = `service`
        self.`quotaLimit` = `quotaLimit`
        self.`overdraft` = `overdraft`
        self.`suspendThreshold` = `suspendThreshold`
        self.`onOverdraftAction` = `onOverdraftAction`
    }

    enum CodingKeys: String, CodingKey {
        case `autoApply` = "autoApply"
        case `service` = "service"
        case `quotaLimit` = "quotaLimit"
        case `overdraft` = "overdraft"
        case `suspendThreshold` = "suspendThreshold"
        case `onOverdraftAction` = "onOverdraftAction"
    }
}

public struct BillingDefaultsParams: Codable, Sendable {
    @APIOptionalBoolean public var `autoApply`: Bool?
    public var `quotaLimit`: JSONField<Double>?
    @APIOptionalNumber public var `overdraft`: Double?
    public var `suspendThreshold`: JSONField<Double>?
    /// Accepted values: 'stop_workspaces' | 'block'.
    public var `onOverdraftAction`: String?

    public init(`autoApply`: Bool? = nil,
                `quotaLimit`: JSONField<Double>? = nil,
                `overdraft`: Double? = nil,
                `suspendThreshold`: JSONField<Double>? = nil,
                `onOverdraftAction`: String? = nil) {
        self.`autoApply` = `autoApply`
        self.`quotaLimit` = `quotaLimit`
        self.`overdraft` = `overdraft`
        self.`suspendThreshold` = `suspendThreshold`
        self.`onOverdraftAction` = `onOverdraftAction`
    }

    enum CodingKeys: String, CodingKey {
        case `autoApply` = "autoApply"
        case `quotaLimit` = "quotaLimit"
        case `overdraft` = "overdraft"
        case `suspendThreshold` = "suspendThreshold"
        case `onOverdraftAction` = "onOverdraftAction"
    }
}
