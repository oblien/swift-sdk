// Models audited against oblien 2.8.0. Regenerate with scripts/generate-platform-models.cjs.
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

public struct BillingCatalogReseller: Codable, Sendable {
    @APINumber public var `contractVersion`: Double
    @APIBoolean public var `offerPolicy`: Bool
    @APIBoolean public var `resourceLimits`: Bool
    @APIOptionalBoolean public var `effectiveResourceLimits`: Bool?
    @APIOptionalBoolean public var `aggregateResourceLimits`: Bool?
    public var `requiredAccountTier`: String?

    public init(`contractVersion`: Double,
                `offerPolicy`: Bool,
                `resourceLimits`: Bool,
                `effectiveResourceLimits`: Bool? = nil,
                `aggregateResourceLimits`: Bool? = nil,
                `requiredAccountTier`: String? = nil) {
        self.`contractVersion` = `contractVersion`
        self.`offerPolicy` = `offerPolicy`
        self.`resourceLimits` = `resourceLimits`
        self.`effectiveResourceLimits` = `effectiveResourceLimits`
        self.`aggregateResourceLimits` = `aggregateResourceLimits`
        self.`requiredAccountTier` = `requiredAccountTier`
    }

    enum CodingKeys: String, CodingKey {
        case `contractVersion` = "contractVersion"
        case `offerPolicy` = "offerPolicy"
        case `resourceLimits` = "resourceLimits"
        case `effectiveResourceLimits` = "effectiveResourceLimits"
        case `aggregateResourceLimits` = "aggregateResourceLimits"
        case `requiredAccountTier` = "requiredAccountTier"
    }
}

public struct BillingCatalogPromotionsCustom: Codable, Sendable {
    public var `issuer`: String
    public var `customerEntry`: String
    @APIBoolean public var `firstPaymentOnly`: Bool
    @APIBoolean public var `scoped`: Bool
    @APIBoolean public var `capped`: Bool

    public init(`issuer`: String = "oblien_admin",
                `customerEntry`: String = "oblien_hosted",
                `firstPaymentOnly`: Bool,
                `scoped`: Bool,
                `capped`: Bool) {
        self.`issuer` = `issuer`
        self.`customerEntry` = `customerEntry`
        self.`firstPaymentOnly` = `firstPaymentOnly`
        self.`scoped` = `scoped`
        self.`capped` = `capped`
    }

    enum CodingKeys: String, CodingKey {
        case `issuer` = "issuer"
        case `customerEntry` = "customerEntry"
        case `firstPaymentOnly` = "firstPaymentOnly"
        case `scoped` = "scoped"
        case `capped` = "capped"
    }
}

public struct BillingCatalogPromotions: Codable, Sendable {
    @APIBoolean public var `enabled`: Bool
    /// Accepted values: 'stripe' | 'oblien_admin'.
    public var `issuer`: String
    /// Accepted values: 'stripe_hosted' | 'oblien_hosted'.
    public var `customerEntry`: String
    /// Accepted values: 'stripe' | 'oblien'.
    public var `defaultCheckoutMode`: String?
    public var `checkoutModes`: [String]?
    @APIOptionalBoolean public var `firstPaymentOnly`: Bool?
    @APIBoolean public var `canDisable`: Bool
    @APIBoolean public var `preservesCredits`: Bool
    @APIBoolean public var `namespaceOptIn`: Bool
    public var `custom`: BillingCatalogPromotionsCustom?

    public init(`enabled`: Bool,
                `issuer`: String,
                `customerEntry`: String,
                `defaultCheckoutMode`: String? = nil,
                `checkoutModes`: [String]? = nil,
                `firstPaymentOnly`: Bool? = nil,
                `canDisable`: Bool,
                `preservesCredits`: Bool,
                `namespaceOptIn`: Bool,
                `custom`: BillingCatalogPromotionsCustom? = nil) {
        self.`enabled` = `enabled`
        self.`issuer` = `issuer`
        self.`customerEntry` = `customerEntry`
        self.`defaultCheckoutMode` = `defaultCheckoutMode`
        self.`checkoutModes` = `checkoutModes`
        self.`firstPaymentOnly` = `firstPaymentOnly`
        self.`canDisable` = `canDisable`
        self.`preservesCredits` = `preservesCredits`
        self.`namespaceOptIn` = `namespaceOptIn`
        self.`custom` = `custom`
    }

    enum CodingKeys: String, CodingKey {
        case `enabled` = "enabled"
        case `issuer` = "issuer"
        case `customerEntry` = "customerEntry"
        case `defaultCheckoutMode` = "defaultCheckoutMode"
        case `checkoutModes` = "checkoutModes"
        case `firstPaymentOnly` = "firstPaymentOnly"
        case `canDisable` = "canDisable"
        case `preservesCredits` = "preservesCredits"
        case `namespaceOptIn` = "namespaceOptIn"
        case `custom` = "custom"
    }
}

public struct BillingCatalog: Codable, Sendable {
    public var `plans`: [BillingPlan]
    public var `creditPacks`: [CreditPack]
    public var `reseller`: BillingCatalogReseller?
    public var `promotions`: BillingCatalogPromotions?

    public init(`plans`: [BillingPlan],
                `creditPacks`: [CreditPack],
                `reseller`: BillingCatalogReseller? = nil,
                `promotions`: BillingCatalogPromotions? = nil) {
        self.`plans` = `plans`
        self.`creditPacks` = `creditPacks`
        self.`reseller` = `reseller`
        self.`promotions` = `promotions`
    }

    enum CodingKeys: String, CodingKey {
        case `plans` = "plans"
        case `creditPacks` = "creditPacks"
        case `reseller` = "reseller"
        case `promotions` = "promotions"
    }
}

public struct BillingOfferPolicy: Codable, Sendable {
    @APIOptionalNumber public var `overdraft`: Double?
    @APIOptionalNumber public var `suspendThreshold`: Double?
    /// Accepted values: 'stop_workspaces' | 'block'.
    public var `onOverdraftAction`: String?

    public init(`overdraft`: Double? = nil,
                `suspendThreshold`: Double? = nil,
                `onOverdraftAction`: String? = nil) {
        self.`overdraft` = `overdraft`
        self.`suspendThreshold` = `suspendThreshold`
        self.`onOverdraftAction` = `onOverdraftAction`
    }

    enum CodingKeys: String, CodingKey {
        case `overdraft` = "overdraft"
        case `suspendThreshold` = "suspendThreshold"
        case `onOverdraftAction` = "onOverdraftAction"
    }
}

public struct BillingOffer: Codable, Sendable {
    public var `billingMode`: ComputeBillingMode?
    public var `capacity`: WorkspaceCapacity?
    public var `tariffId`: String?
    public var `reference`: String?
    public var `name`: String
    public var `description`: String?
    @APINumber public var `unitAmount`: Double
    public var `currency`: String?
    @APINumber public var `credits`: Double
    public var `policy`: BillingOfferPolicy?
    public var `resourceLimits`: NamespaceResourceLimits?

    public init(`billingMode`: ComputeBillingMode? = nil,
                `capacity`: WorkspaceCapacity? = nil,
                `tariffId`: String? = nil,
                `reference`: String? = nil,
                `name`: String,
                `description`: String? = nil,
                `unitAmount`: Double,
                `currency`: String? = nil,
                `credits`: Double,
                `policy`: BillingOfferPolicy? = nil,
                `resourceLimits`: NamespaceResourceLimits? = nil) {
        self.`billingMode` = `billingMode`
        self.`capacity` = `capacity`
        self.`tariffId` = `tariffId`
        self.`reference` = `reference`
        self.`name` = `name`
        self.`description` = `description`
        self.`unitAmount` = `unitAmount`
        self.`currency` = `currency`
        self.`credits` = `credits`
        self.`policy` = `policy`
        self.`resourceLimits` = `resourceLimits`
    }

    enum CodingKeys: String, CodingKey {
        case `billingMode` = "billingMode"
        case `capacity` = "capacity"
        case `tariffId` = "tariffId"
        case `reference` = "reference"
        case `name` = "name"
        case `description` = "description"
        case `unitAmount` = "unitAmount"
        case `currency` = "currency"
        case `credits` = "credits"
        case `policy` = "policy"
        case `resourceLimits` = "resourceLimits"
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
    /// Accepted values: 'stripe' | 'oblien'.
    public var `checkoutMode`: String?
    @APIOptionalBoolean public var `allowPromotionCodes`: Bool?

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
                `customer`: CheckoutParamsCustomer? = nil,
                `checkoutMode`: String? = nil,
                `allowPromotionCodes`: Bool? = nil) {
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
        self.`checkoutMode` = `checkoutMode`
        self.`allowPromotionCodes` = `allowPromotionCodes`
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
        case `checkoutMode` = "checkoutMode"
        case `allowPromotionCodes` = "allowPromotionCodes"
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

public struct BillingCheckoutPrice: Codable, Sendable {
    @APINumber public var `subtotal`: Double
    @APINumber public var `discount`: Int
    @APINumber public var `total`: Int
    public var `currency`: String

    public init(`subtotal`: Double,
                `discount`: Int,
                `total`: Int,
                `currency`: String) {
        self.`subtotal` = `subtotal`
        self.`discount` = `discount`
        self.`total` = `total`
        self.`currency` = `currency`
    }

    enum CodingKeys: String, CodingKey {
        case `subtotal` = "subtotal"
        case `discount` = "discount"
        case `total` = "total"
        case `currency` = "currency"
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
    /// Accepted values: 'pending' | 'completed' | 'partially_refunded' | 'refunded' | 'disputed' | 'expired' | 'failed' | 'superseded' | 'reversed'.
    public var `fulfillmentStatus`: String
    @APINumber public var `walletCreditsGranted`: Double
    @APIOptionalNumber public var `walletCreditsFunded`: Double?
    @APIOptionalNumber public var `capacityCreditsCharged`: Double?
    @APIOptionalNumber public var `walletCreditDelta`: Double?
    @APINumber public var `namespaceCreditsGranted`: Double
    /// Accepted values: 'monthly' | 'yearly' | null.
    public var `billingInterval`: String?
    public var `subscriptionId`: String?
    public var `price`: BillingCheckoutPrice?

    public init(`id`: String,
                `kind`: String,
                `status`: String,
                `paymentStatus`: String,
                `fulfilled`: Bool,
                `offer`: BillingOffer,
                `metadata`: [String: String],
                `fulfillmentStatus`: String,
                `walletCreditsGranted`: Double,
                `walletCreditsFunded`: Double? = nil,
                `capacityCreditsCharged`: Double? = nil,
                `walletCreditDelta`: Double? = nil,
                `namespaceCreditsGranted`: Double,
                `billingInterval`: String? = nil,
                `subscriptionId`: String? = nil,
                `price`: BillingCheckoutPrice? = nil) {
        self.`id` = `id`
        self.`kind` = `kind`
        self.`status` = `status`
        self.`paymentStatus` = `paymentStatus`
        self.`fulfilled` = `fulfilled`
        self.`offer` = `offer`
        self.`metadata` = `metadata`
        self.`fulfillmentStatus` = `fulfillmentStatus`
        self.`walletCreditsGranted` = `walletCreditsGranted`
        self.`walletCreditsFunded` = `walletCreditsFunded`
        self.`capacityCreditsCharged` = `capacityCreditsCharged`
        self.`walletCreditDelta` = `walletCreditDelta`
        self.`namespaceCreditsGranted` = `namespaceCreditsGranted`
        self.`billingInterval` = `billingInterval`
        self.`subscriptionId` = `subscriptionId`
        self.`price` = `price`
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
        case `walletCreditsFunded` = "walletCreditsFunded"
        case `capacityCreditsCharged` = "capacityCreditsCharged"
        case `walletCreditDelta` = "walletCreditDelta"
        case `namespaceCreditsGranted` = "namespaceCreditsGranted"
        case `billingInterval` = "billingInterval"
        case `subscriptionId` = "subscriptionId"
        case `price` = "price"
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
    public var `pendingChange`: BillingPlanChange?

    public init(`tierId`: String,
                `status`: String,
                `billingInterval`: String,
                `periodStart`: String? = nil,
                `periodEnd`: String? = nil,
                `cancelAtPeriodEnd`: Bool,
                `canceledAt`: String? = nil,
                `offer`: BillingOffer? = nil,
                `metadata`: [String: String]? = nil,
                `pendingChange`: BillingPlanChange? = nil) {
        self.`tierId` = `tierId`
        self.`status` = `status`
        self.`billingInterval` = `billingInterval`
        self.`periodStart` = `periodStart`
        self.`periodEnd` = `periodEnd`
        self.`cancelAtPeriodEnd` = `cancelAtPeriodEnd`
        self.`canceledAt` = `canceledAt`
        self.`offer` = `offer`
        self.`metadata` = `metadata`
        self.`pendingChange` = `pendingChange`
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
        case `pendingChange` = "pendingChange"
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

public struct PreviewPlanChangeParams: Codable, Sendable {
    public var `offer`: BillingOffer
    public var `metadata`: [String: String]?
    /// Accepted values: 'monthly' | 'yearly'.
    public var `billingInterval`: String?
    public var `idempotencyKey`: String

    public init(`offer`: BillingOffer,
                `metadata`: [String: String]? = nil,
                `billingInterval`: String? = nil,
                `idempotencyKey`: String) {
        self.`offer` = `offer`
        self.`metadata` = `metadata`
        self.`billingInterval` = `billingInterval`
        self.`idempotencyKey` = `idempotencyKey`
    }

    enum CodingKeys: String, CodingKey {
        case `offer` = "offer"
        case `metadata` = "metadata"
        case `billingInterval` = "billingInterval"
        case `idempotencyKey` = "idempotencyKey"
    }
}

public struct BillingPlanChangeQuote: Codable, Sendable {
    public var `id`: String
    public var `namespace`: String
    /// Accepted values: 'upgrade' | 'downgrade'.
    public var `direction`: String
    public var `expiresAt`: String
    public var `effectiveAt`: String
    /// Accepted values: 'monthly' | 'yearly'.
    public var `billingInterval`: String
    public var `current`: BillingOffer
    public var `next`: BillingOffer
    public var `currency`: String
    @APINumber public var `unusedTimeCredit`: Double
    @APINumber public var `remainingTimeCharge`: Double
    @APINumber public var `amountDueNow`: Double
    @APIOptionalNumber public var `nextInvoiceAmount`: Double?
    @APINumber public var `includedCreditIncrease`: Double
    @APIBoolean public var `preservesUsage`: Bool
    @APIBoolean public var `preservesPurchasedCredits`: Bool

    public init(`id`: String,
                `namespace`: String,
                `direction`: String,
                `expiresAt`: String,
                `effectiveAt`: String,
                `billingInterval`: String,
                `current`: BillingOffer,
                `next`: BillingOffer,
                `currency`: String = "usd",
                `unusedTimeCredit`: Double,
                `remainingTimeCharge`: Double,
                `amountDueNow`: Double,
                `nextInvoiceAmount`: Double? = nil,
                `includedCreditIncrease`: Double,
                `preservesUsage`: Bool,
                `preservesPurchasedCredits`: Bool) {
        self.`id` = `id`
        self.`namespace` = `namespace`
        self.`direction` = `direction`
        self.`expiresAt` = `expiresAt`
        self.`effectiveAt` = `effectiveAt`
        self.`billingInterval` = `billingInterval`
        self.`current` = `current`
        self.`next` = `next`
        self.`currency` = `currency`
        self.`unusedTimeCredit` = `unusedTimeCredit`
        self.`remainingTimeCharge` = `remainingTimeCharge`
        self.`amountDueNow` = `amountDueNow`
        self.`nextInvoiceAmount` = `nextInvoiceAmount`
        self.`includedCreditIncrease` = `includedCreditIncrease`
        self.`preservesUsage` = `preservesUsage`
        self.`preservesPurchasedCredits` = `preservesPurchasedCredits`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `namespace` = "namespace"
        case `direction` = "direction"
        case `expiresAt` = "expiresAt"
        case `effectiveAt` = "effectiveAt"
        case `billingInterval` = "billingInterval"
        case `current` = "current"
        case `next` = "next"
        case `currency` = "currency"
        case `unusedTimeCredit` = "unusedTimeCredit"
        case `remainingTimeCharge` = "remainingTimeCharge"
        case `amountDueNow` = "amountDueNow"
        case `nextInvoiceAmount` = "nextInvoiceAmount"
        case `includedCreditIncrease` = "includedCreditIncrease"
        case `preservesUsage` = "preservesUsage"
        case `preservesPurchasedCredits` = "preservesPurchasedCredits"
    }
}

public struct BillingPlanChangeQuoteResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `namespace`: String
    public var `quote`: BillingPlanChangeQuote

    public init(`success`: Bool,
                `namespace`: String,
                `quote`: BillingPlanChangeQuote) {
        self.`success` = `success`
        self.`namespace` = `namespace`
        self.`quote` = `quote`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `namespace` = "namespace"
        case `quote` = "quote"
    }
}

public struct ChangePlanParams: Codable, Sendable {
    public var `quoteId`: String
    public var `idempotencyKey`: String

    public init(`quoteId`: String,
                `idempotencyKey`: String) {
        self.`quoteId` = `quoteId`
        self.`idempotencyKey` = `idempotencyKey`
    }

    enum CodingKeys: String, CodingKey {
        case `quoteId` = "quoteId"
        case `idempotencyKey` = "idempotencyKey"
    }
}

/// Open string enum; preserves new server values.
public struct BillingPlanChangeStatus: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(from decoder: Decoder) throws { rawValue = try decoder.singleValueContainer().decode(String.self) }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public static let `queued` = Self(rawValue: "queued")
    public static let `dispatching` = Self(rawValue: "dispatching")
    public static let `paymentPending` = Self(rawValue: "payment_pending")
    public static let `scheduled` = Self(rawValue: "scheduled")
    public static let `canceling` = Self(rawValue: "canceling")
    public static let `reconciliationRequired` = Self(rawValue: "reconciliation_required")
    public static let `applied` = Self(rawValue: "applied")
    public static let `canceled` = Self(rawValue: "canceled")
    public static let `expired` = Self(rawValue: "expired")
    public static let `failed` = Self(rawValue: "failed")
}

public struct BillingPlanChangePayment: Codable, Sendable {
    public var `status`: String
    public var `url`: String?
    public var `expiresAt`: String?

    public init(`status`: String,
                `url`: String? = nil,
                `expiresAt`: String? = nil) {
        self.`status` = `status`
        self.`url` = `url`
        self.`expiresAt` = `expiresAt`
    }

    enum CodingKeys: String, CodingKey {
        case `status` = "status"
        case `url` = "url"
        case `expiresAt` = "expiresAt"
    }
}

public struct BillingPlanChangeError: Codable, Sendable {
    public var `code`: String
    public var `message`: String

    public init(`code`: String,
                `message`: String) {
        self.`code` = `code`
        self.`message` = `message`
    }

    enum CodingKeys: String, CodingKey {
        case `code` = "code"
        case `message` = "message"
    }
}

public struct BillingPlanChange: Codable, Sendable {
    public var `id`: String
    public var `quoteId`: String
    public var `namespace`: String
    /// Accepted values: 'upgrade' | 'downgrade'.
    public var `direction`: String
    public var `status`: BillingPlanChangeStatus
    public var `effectiveAt`: String
    public var `current`: BillingOffer
    public var `next`: BillingOffer
    @APINumber public var `amountDueNow`: Double
    public var `currency`: String
    @APINumber public var `includedCreditIncrease`: Double
    public var `payment`: BillingPlanChangePayment?
    public var `error`: BillingPlanChangeError?
    @APIBoolean public var `cancelable`: Bool
    public var `appliedAt`: String?

    public init(`id`: String,
                `quoteId`: String,
                `namespace`: String,
                `direction`: String,
                `status`: BillingPlanChangeStatus,
                `effectiveAt`: String,
                `current`: BillingOffer,
                `next`: BillingOffer,
                `amountDueNow`: Double,
                `currency`: String = "usd",
                `includedCreditIncrease`: Double,
                `payment`: BillingPlanChangePayment? = nil,
                `error`: BillingPlanChangeError? = nil,
                `cancelable`: Bool,
                `appliedAt`: String? = nil) {
        self.`id` = `id`
        self.`quoteId` = `quoteId`
        self.`namespace` = `namespace`
        self.`direction` = `direction`
        self.`status` = `status`
        self.`effectiveAt` = `effectiveAt`
        self.`current` = `current`
        self.`next` = `next`
        self.`amountDueNow` = `amountDueNow`
        self.`currency` = `currency`
        self.`includedCreditIncrease` = `includedCreditIncrease`
        self.`payment` = `payment`
        self.`error` = `error`
        self.`cancelable` = `cancelable`
        self.`appliedAt` = `appliedAt`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `quoteId` = "quoteId"
        case `namespace` = "namespace"
        case `direction` = "direction"
        case `status` = "status"
        case `effectiveAt` = "effectiveAt"
        case `current` = "current"
        case `next` = "next"
        case `amountDueNow` = "amountDueNow"
        case `currency` = "currency"
        case `includedCreditIncrease` = "includedCreditIncrease"
        case `payment` = "payment"
        case `error` = "error"
        case `cancelable` = "cancelable"
        case `appliedAt` = "appliedAt"
    }
}

public struct BillingPlanChangeResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `namespace`: String
    public var `change`: BillingPlanChange

    public init(`success`: Bool,
                `namespace`: String,
                `change`: BillingPlanChange) {
        self.`success` = `success`
        self.`namespace` = `namespace`
        self.`change` = `change`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `namespace` = "namespace"
        case `change` = "change"
    }
}

public struct CancelPlanChangeParams: Codable, Sendable {
    public var `idempotencyKey`: String

    public init(`idempotencyKey`: String) {
        self.`idempotencyKey` = `idempotencyKey`
    }

    enum CodingKeys: String, CodingKey {
        case `idempotencyKey` = "idempotencyKey"
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
    public var `alert`: NamespaceQuotaAlert?
    @APIOptionalNumber public var `limit`: Int?
    @APINumber public var `used`: Double
    @APIOptionalNumber public var `overdraft`: Double?
    @APIOptionalNumber public var `suspendThreshold`: Double?
    @APIOptionalNumber public var `balance`: Double?

    public init(`alert`: NamespaceQuotaAlert? = nil,
                `limit`: Int? = nil,
                `used`: Double,
                `overdraft`: Double? = nil,
                `suspendThreshold`: Double? = nil,
                `balance`: Double? = nil) {
        self.`alert` = `alert`
        self.`limit` = `limit`
        self.`used` = `used`
        self.`overdraft` = `overdraft`
        self.`suspendThreshold` = `suspendThreshold`
        self.`balance` = `balance`
    }

    enum CodingKeys: String, CodingKey {
        case `alert` = "alert"
        case `limit` = "limit"
        case `used` = "used"
        case `overdraft` = "overdraft"
        case `suspendThreshold` = "suspendThreshold"
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
    public var `billingMode`: ComputeBillingMode?
    @APIOptionalBoolean public var `computeCovered`: Bool?
    public var `capacity`: NamespaceCapacity?

    public init(`namespace`: String,
                `tierId`: String,
                `status`: EntitlementStatus,
                `periodStart`: String? = nil,
                `periodEnd`: String? = nil,
                `quota`: EntitlementQuota,
                `billingMode`: ComputeBillingMode? = nil,
                `computeCovered`: Bool? = nil,
                `capacity`: NamespaceCapacity? = nil) {
        self.`namespace` = `namespace`
        self.`tierId` = `tierId`
        self.`status` = `status`
        self.`periodStart` = `periodStart`
        self.`periodEnd` = `periodEnd`
        self.`quota` = `quota`
        self.`billingMode` = `billingMode`
        self.`computeCovered` = `computeCovered`
        self.`capacity` = `capacity`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `tierId` = "tierId"
        case `status` = "status"
        case `periodStart` = "periodStart"
        case `periodEnd` = "periodEnd"
        case `quota` = "quota"
        case `billingMode` = "billingMode"
        case `computeCovered` = "computeCovered"
        case `capacity` = "capacity"
    }
}

public struct BillingBalance: Codable, Sendable {
    public var `alert`: NamespaceQuotaAlert?
    public var `namespace`: String
    @APIBoolean public var `blocking`: Bool
    @APIOptionalNumber public var `balance`: Double?
    public var `billingMode`: ComputeBillingMode?
    @APIOptionalBoolean public var `computeCovered`: Bool?
    public var `paidThrough`: String?

    public init(`alert`: NamespaceQuotaAlert? = nil,
                `namespace`: String,
                `blocking`: Bool,
                `balance`: Double? = nil,
                `billingMode`: ComputeBillingMode? = nil,
                `computeCovered`: Bool? = nil,
                `paidThrough`: String? = nil) {
        self.`alert` = `alert`
        self.`namespace` = `namespace`
        self.`blocking` = `blocking`
        self.`balance` = `balance`
        self.`billingMode` = `billingMode`
        self.`computeCovered` = `computeCovered`
        self.`paidThrough` = `paidThrough`
    }

    enum CodingKeys: String, CodingKey {
        case `alert` = "alert"
        case `namespace` = "namespace"
        case `blocking` = "blocking"
        case `balance` = "balance"
        case `billingMode` = "billingMode"
        case `computeCovered` = "computeCovered"
        case `paidThrough` = "paidThrough"
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

/// Open string enum; preserves new server values.
public struct ComputeBillingMode: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(from decoder: Decoder) throws { rawValue = try decoder.singleValueContainer().decode(String.self) }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public static let `payg` = Self(rawValue: "payg")
    public static let `monthly` = Self(rawValue: "monthly")
}

public struct WorkspaceCapacity: Codable, Sendable {
    @APINumber public var `vcpus`: Double
    @APINumber public var `memoryMb`: Int
    @APINumber public var `diskGb`: Int
    @APINumber public var `workspaces`: Double

    public init(`vcpus`: Double,
                `memoryMb`: Int,
                `diskGb`: Int,
                `workspaces`: Double) {
        self.`vcpus` = `vcpus`
        self.`memoryMb` = `memoryMb`
        self.`diskGb` = `diskGb`
        self.`workspaces` = `workspaces`
    }

    enum CodingKeys: String, CodingKey {
        case `vcpus` = "vcpus"
        case `memoryMb` = "memoryMb"
        case `diskGb` = "diskGb"
        case `workspaces` = "workspaces"
    }
}

public struct CapacityTariffMonthly: Codable, Sendable {
    @APINumber public var `vcpuCents`: Double
    @APINumber public var `memoryGiBCents`: Double
    @APINumber public var `diskGiBCents`: Double
    @APINumber public var `minimumCents`: Double

    public init(`vcpuCents`: Double,
                `memoryGiBCents`: Double,
                `diskGiBCents`: Double,
                `minimumCents`: Double) {
        self.`vcpuCents` = `vcpuCents`
        self.`memoryGiBCents` = `memoryGiBCents`
        self.`diskGiBCents` = `diskGiBCents`
        self.`minimumCents` = `minimumCents`
    }

    enum CodingKeys: String, CodingKey {
        case `vcpuCents` = "vcpuCents"
        case `memoryGiBCents` = "memoryGiBCents"
        case `diskGiBCents` = "diskGiBCents"
        case `minimumCents` = "minimumCents"
    }
}

public struct CapacityTariffUsage: Codable, Sendable {
    @APINumber public var `activeVcpuHourCents`: Double
    @APINumber public var `reservedGiBHourCents`: Double
    @APINumber public var `retainedGiBMonthCents`: Double
    @APINumber public var `monthHours`: Double

    public init(`activeVcpuHourCents`: Double,
                `reservedGiBHourCents`: Double,
                `retainedGiBMonthCents`: Double,
                `monthHours`: Double) {
        self.`activeVcpuHourCents` = `activeVcpuHourCents`
        self.`reservedGiBHourCents` = `reservedGiBHourCents`
        self.`retainedGiBMonthCents` = `retainedGiBMonthCents`
        self.`monthHours` = `monthHours`
    }

    enum CodingKeys: String, CodingKey {
        case `activeVcpuHourCents` = "activeVcpuHourCents"
        case `reservedGiBHourCents` = "reservedGiBHourCents"
        case `retainedGiBMonthCents` = "retainedGiBMonthCents"
        case `monthHours` = "monthHours"
    }
}

public struct CapacityTariffNetwork: Codable, Sendable {
    @APINumber public var `managedProxyGiBCents`: Double
    @APINumber public var `minimumTopupCents`: Double

    public init(`managedProxyGiBCents`: Double,
                `minimumTopupCents`: Double) {
        self.`managedProxyGiBCents` = `managedProxyGiBCents`
        self.`minimumTopupCents` = `minimumTopupCents`
    }

    enum CodingKeys: String, CodingKey {
        case `managedProxyGiBCents` = "managedProxyGiBCents"
        case `minimumTopupCents` = "minimumTopupCents"
    }
}

public struct CapacityTariffTerms: Codable, Sendable {
    public var `cpuClass`: String
    @APIBoolean public var `networkIncluded`: Bool
    @APIBoolean public var `backupsIncluded`: Bool
    @APIBoolean public var `autoRenewDefault`: Bool
    public var `calendar`: String
    @APINumber public var `expiryGraceHours`: Double
    @APINumber public var `retainedAfterExpiryDays`: Double
    @APIBoolean public var `automaticDeletion`: Bool
    public var `retentionBilling`: String

    public init(`cpuClass`: String = "shared",
                `networkIncluded`: Bool,
                `backupsIncluded`: Bool,
                `autoRenewDefault`: Bool,
                `calendar`: String = "subscription_anniversary",
                `expiryGraceHours`: Double,
                `retainedAfterExpiryDays`: Double,
                `automaticDeletion`: Bool,
                `retentionBilling`: String = "storage_until_deleted") {
        self.`cpuClass` = `cpuClass`
        self.`networkIncluded` = `networkIncluded`
        self.`backupsIncluded` = `backupsIncluded`
        self.`autoRenewDefault` = `autoRenewDefault`
        self.`calendar` = `calendar`
        self.`expiryGraceHours` = `expiryGraceHours`
        self.`retainedAfterExpiryDays` = `retainedAfterExpiryDays`
        self.`automaticDeletion` = `automaticDeletion`
        self.`retentionBilling` = `retentionBilling`
    }

    enum CodingKeys: String, CodingKey {
        case `cpuClass` = "cpuClass"
        case `networkIncluded` = "networkIncluded"
        case `backupsIncluded` = "backupsIncluded"
        case `autoRenewDefault` = "autoRenewDefault"
        case `calendar` = "calendar"
        case `expiryGraceHours` = "expiryGraceHours"
        case `retainedAfterExpiryDays` = "retainedAfterExpiryDays"
        case `automaticDeletion` = "automaticDeletion"
        case `retentionBilling` = "retentionBilling"
    }
}

public struct CapacityTariff: Codable, Sendable {
    public var `id`: String
    public var `currency`: String
    @APINumber public var `creditsPerDollar`: Double
    public var `monthly`: CapacityTariffMonthly
    @APINumber public var `paygCapPercent`: Int
    public var `usage`: CapacityTariffUsage
    public var `network`: CapacityTariffNetwork
    @APINumber public var `requiredMeterVersion`: Double
    public var `terms`: CapacityTariffTerms

    public init(`id`: String,
                `currency`: String = "usd",
                `creditsPerDollar`: Double,
                `monthly`: CapacityTariffMonthly,
                `paygCapPercent`: Int,
                `usage`: CapacityTariffUsage,
                `network`: CapacityTariffNetwork,
                `requiredMeterVersion`: Double,
                `terms`: CapacityTariffTerms) {
        self.`id` = `id`
        self.`currency` = `currency`
        self.`creditsPerDollar` = `creditsPerDollar`
        self.`monthly` = `monthly`
        self.`paygCapPercent` = `paygCapPercent`
        self.`usage` = `usage`
        self.`network` = `network`
        self.`requiredMeterVersion` = `requiredMeterVersion`
        self.`terms` = `terms`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `currency` = "currency"
        case `creditsPerDollar` = "creditsPerDollar"
        case `monthly` = "monthly"
        case `paygCapPercent` = "paygCapPercent"
        case `usage` = "usage"
        case `network` = "network"
        case `requiredMeterVersion` = "requiredMeterVersion"
        case `terms` = "terms"
    }
}

public struct CapacityCatalogPresetsItem: Codable, Sendable {
    public var `id`: String
    public var `capacity`: WorkspaceCapacity
    @APINumber public var `monthlyAmount`: Double
    @APINumber public var `paygCapAmount`: Double
    public var `resourceLimits`: NamespaceResourceLimits

    public init(`id`: String,
                `capacity`: WorkspaceCapacity,
                `monthlyAmount`: Double,
                `paygCapAmount`: Double,
                `resourceLimits`: NamespaceResourceLimits) {
        self.`id` = `id`
        self.`capacity` = `capacity`
        self.`monthlyAmount` = `monthlyAmount`
        self.`paygCapAmount` = `paygCapAmount`
        self.`resourceLimits` = `resourceLimits`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `capacity` = "capacity"
        case `monthlyAmount` = "monthlyAmount"
        case `paygCapAmount` = "paygCapAmount"
        case `resourceLimits` = "resourceLimits"
    }
}

public struct CapacityCatalog: Codable, Sendable {
    public var `currency`: String
    public var `billingModes`: [ComputeBillingMode]
    public var `tariffId`: String
    public var `tariff`: CapacityTariff
    public var `paymentSources`: [String: [String]]
    public var `presets`: [CapacityCatalogPresetsItem]

    public init(`currency`: String = "usd",
                `billingModes`: [ComputeBillingMode],
                `tariffId`: String,
                `tariff`: CapacityTariff,
                `paymentSources`: [String: [String]],
                `presets`: [CapacityCatalogPresetsItem]) {
        self.`currency` = `currency`
        self.`billingModes` = `billingModes`
        self.`tariffId` = `tariffId`
        self.`tariff` = `tariff`
        self.`paymentSources` = `paymentSources`
        self.`presets` = `presets`
    }

    enum CodingKeys: String, CodingKey {
        case `currency` = "currency"
        case `billingModes` = "billingModes"
        case `tariffId` = "tariffId"
        case `tariff` = "tariff"
        case `paymentSources` = "paymentSources"
        case `presets` = "presets"
    }
}

public struct CapacityQuoteCurrent: Codable, Sendable {
    public var `capacity`: WorkspaceCapacity
    public var `billingMode`: ComputeBillingMode
    @APINumber public var `monthlyAmount`: Double

    public init(`capacity`: WorkspaceCapacity,
                `billingMode`: ComputeBillingMode,
                `monthlyAmount`: Double) {
        self.`capacity` = `capacity`
        self.`billingMode` = `billingMode`
        self.`monthlyAmount` = `monthlyAmount`
    }

    enum CodingKeys: String, CodingKey {
        case `capacity` = "capacity"
        case `billingMode` = "billingMode"
        case `monthlyAmount` = "monthlyAmount"
    }
}

public struct CapacityQuote: Codable, Sendable {
    public var `id`: String
    public var `namespace`: String
    public var `status`: String
    /// Accepted values: 'start' | 'upgrade' | 'scheduled' | 'network_topup'.
    public var `action`: String
    public var `expiresAt`: String
    public var `effectiveAt`: String
    public var `periodEnd`: String?
    public var `billingMode`: ComputeBillingMode
    /// Accepted values: 'wallet' | 'stripe'.
    public var `paymentSource`: String
    public var `currency`: String
    public var `current`: CapacityQuoteCurrent?
    public var `capacity`: WorkspaceCapacity?
    public var `tariffId`: String
    @APIOptionalNumber public var `monthlyAmount`: Double?
    @APIOptionalNumber public var `paygCapAmount`: Double?
    @APINumber public var `unusedTimeCredit`: Double
    @APINumber public var `remainingTimeCharge`: Double
    @APINumber public var `amountDueNow`: Double
    @APINumber public var `walletCreditsRequired`: Double
    @APINumber public var `retainedStorageAmountDue`: Double
    @APIOptionalNumber public var `nextPaymentAmount`: Double?
    @APIBoolean public var `autoRenew`: Bool
    @APIBoolean public var `networkIncluded`: Bool
    @APIOptionalNumber public var `networkBytes`: Int?
    @APIBoolean public var `preservesUsage`: Bool
    @APIBoolean public var `preservesPurchasedCredits`: Bool

    public init(`id`: String,
                `namespace`: String,
                `status`: String,
                `action`: String,
                `expiresAt`: String,
                `effectiveAt`: String,
                `periodEnd`: String? = nil,
                `billingMode`: ComputeBillingMode,
                `paymentSource`: String,
                `currency`: String = "usd",
                `current`: CapacityQuoteCurrent? = nil,
                `capacity`: WorkspaceCapacity? = nil,
                `tariffId`: String,
                `monthlyAmount`: Double? = nil,
                `paygCapAmount`: Double? = nil,
                `unusedTimeCredit`: Double,
                `remainingTimeCharge`: Double,
                `amountDueNow`: Double,
                `walletCreditsRequired`: Double,
                `retainedStorageAmountDue`: Double,
                `nextPaymentAmount`: Double? = nil,
                `autoRenew`: Bool,
                `networkIncluded`: Bool,
                `networkBytes`: Int? = nil,
                `preservesUsage`: Bool,
                `preservesPurchasedCredits`: Bool) {
        self.`id` = `id`
        self.`namespace` = `namespace`
        self.`status` = `status`
        self.`action` = `action`
        self.`expiresAt` = `expiresAt`
        self.`effectiveAt` = `effectiveAt`
        self.`periodEnd` = `periodEnd`
        self.`billingMode` = `billingMode`
        self.`paymentSource` = `paymentSource`
        self.`currency` = `currency`
        self.`current` = `current`
        self.`capacity` = `capacity`
        self.`tariffId` = `tariffId`
        self.`monthlyAmount` = `monthlyAmount`
        self.`paygCapAmount` = `paygCapAmount`
        self.`unusedTimeCredit` = `unusedTimeCredit`
        self.`remainingTimeCharge` = `remainingTimeCharge`
        self.`amountDueNow` = `amountDueNow`
        self.`walletCreditsRequired` = `walletCreditsRequired`
        self.`retainedStorageAmountDue` = `retainedStorageAmountDue`
        self.`nextPaymentAmount` = `nextPaymentAmount`
        self.`autoRenew` = `autoRenew`
        self.`networkIncluded` = `networkIncluded`
        self.`networkBytes` = `networkBytes`
        self.`preservesUsage` = `preservesUsage`
        self.`preservesPurchasedCredits` = `preservesPurchasedCredits`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `namespace` = "namespace"
        case `status` = "status"
        case `action` = "action"
        case `expiresAt` = "expiresAt"
        case `effectiveAt` = "effectiveAt"
        case `periodEnd` = "periodEnd"
        case `billingMode` = "billingMode"
        case `paymentSource` = "paymentSource"
        case `currency` = "currency"
        case `current` = "current"
        case `capacity` = "capacity"
        case `tariffId` = "tariffId"
        case `monthlyAmount` = "monthlyAmount"
        case `paygCapAmount` = "paygCapAmount"
        case `unusedTimeCredit` = "unusedTimeCredit"
        case `remainingTimeCharge` = "remainingTimeCharge"
        case `amountDueNow` = "amountDueNow"
        case `walletCreditsRequired` = "walletCreditsRequired"
        case `retainedStorageAmountDue` = "retainedStorageAmountDue"
        case `nextPaymentAmount` = "nextPaymentAmount"
        case `autoRenew` = "autoRenew"
        case `networkIncluded` = "networkIncluded"
        case `networkBytes` = "networkBytes"
        case `preservesUsage` = "preservesUsage"
        case `preservesPurchasedCredits` = "preservesPurchasedCredits"
    }
}

public struct CapacitySavings: Codable, Sendable {
    public var `currency`: String
    public var `baseline`: String
    @APINumber public var `usageBeforeCap`: Double
    @APINumber public var `capDiscount`: Int
    @APINumber public var `usageAfterCap`: Double
    @APINumber public var `usageCharged`: Double
    @APINumber public var `prepaidAmount`: Double
    @APINumber public var `monthlyDifference`: Double
    @APIBoolean public var `networkIncluded`: Bool
    @APIBoolean public var `refundsIncluded`: Bool

    public init(`currency`: String = "usd",
                `baseline`: String = "recorded_usage_at_saved_payg_rates",
                `usageBeforeCap`: Double,
                `capDiscount`: Int,
                `usageAfterCap`: Double,
                `usageCharged`: Double,
                `prepaidAmount`: Double,
                `monthlyDifference`: Double,
                `networkIncluded`: Bool,
                `refundsIncluded`: Bool) {
        self.`currency` = `currency`
        self.`baseline` = `baseline`
        self.`usageBeforeCap` = `usageBeforeCap`
        self.`capDiscount` = `capDiscount`
        self.`usageAfterCap` = `usageAfterCap`
        self.`usageCharged` = `usageCharged`
        self.`prepaidAmount` = `prepaidAmount`
        self.`monthlyDifference` = `monthlyDifference`
        self.`networkIncluded` = `networkIncluded`
        self.`refundsIncluded` = `refundsIncluded`
    }

    enum CodingKeys: String, CodingKey {
        case `currency` = "currency"
        case `baseline` = "baseline"
        case `usageBeforeCap` = "usageBeforeCap"
        case `capDiscount` = "capDiscount"
        case `usageAfterCap` = "usageAfterCap"
        case `usageCharged` = "usageCharged"
        case `prepaidAmount` = "prepaidAmount"
        case `monthlyDifference` = "monthlyDifference"
        case `networkIncluded` = "networkIncluded"
        case `refundsIncluded` = "refundsIncluded"
    }
}

public struct NamespaceCapacityRetention: Codable, Sendable {
    @APINumber public var `minimumDays`: Double
    @APIBoolean public var `automaticDeletion`: Bool
    public var `reviewAt`: String
    @APINumber public var `storagePerGiBMonth`: Double
    @APINumber public var `amountDue`: Double
    public var `currency`: String

    public init(`minimumDays`: Double,
                `automaticDeletion`: Bool,
                `reviewAt`: String,
                `storagePerGiBMonth`: Double,
                `amountDue`: Double,
                `currency`: String = "usd") {
        self.`minimumDays` = `minimumDays`
        self.`automaticDeletion` = `automaticDeletion`
        self.`reviewAt` = `reviewAt`
        self.`storagePerGiBMonth` = `storagePerGiBMonth`
        self.`amountDue` = `amountDue`
        self.`currency` = `currency`
    }

    enum CodingKeys: String, CodingKey {
        case `minimumDays` = "minimumDays"
        case `automaticDeletion` = "automaticDeletion"
        case `reviewAt` = "reviewAt"
        case `storagePerGiBMonth` = "storagePerGiBMonth"
        case `amountDue` = "amountDue"
        case `currency` = "currency"
    }
}

public struct NamespaceCapacityPendingChange: Codable, Sendable {
    public var `id`: String
    public var `billingMode`: ComputeBillingMode
    public var `capacity`: WorkspaceCapacity
    @APINumber public var `monthlyAmount`: Double
    public var `effectiveAt`: String

    public init(`id`: String,
                `billingMode`: ComputeBillingMode,
                `capacity`: WorkspaceCapacity,
                `monthlyAmount`: Double,
                `effectiveAt`: String) {
        self.`id` = `id`
        self.`billingMode` = `billingMode`
        self.`capacity` = `capacity`
        self.`monthlyAmount` = `monthlyAmount`
        self.`effectiveAt` = `effectiveAt`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `billingMode` = "billingMode"
        case `capacity` = "capacity"
        case `monthlyAmount` = "monthlyAmount"
        case `effectiveAt` = "effectiveAt"
    }
}

public struct NamespaceCapacityNetwork: Codable, Sendable {
    public var `service`: String
    @APIBoolean public var `included`: Bool
    @APINumber public var `purchasedBytes`: Int
    @APINumber public var `consumedBytes`: Int
    @APINumber public var `reservedBytes`: Int
    @APINumber public var `availableBytes`: Int

    public init(`service`: String = "managed_proxy_transfer",
                `included`: Bool,
                `purchasedBytes`: Int,
                `consumedBytes`: Int,
                `reservedBytes`: Int,
                `availableBytes`: Int) {
        self.`service` = `service`
        self.`included` = `included`
        self.`purchasedBytes` = `purchasedBytes`
        self.`consumedBytes` = `consumedBytes`
        self.`reservedBytes` = `reservedBytes`
        self.`availableBytes` = `availableBytes`
    }

    enum CodingKeys: String, CodingKey {
        case `service` = "service"
        case `included` = "included"
        case `purchasedBytes` = "purchasedBytes"
        case `consumedBytes` = "consumedBytes"
        case `reservedBytes` = "reservedBytes"
        case `availableBytes` = "availableBytes"
    }
}

public struct NamespaceCapacity: Codable, Sendable {
    public var `id`: String
    public var `namespace`: String
    public var `billingMode`: ComputeBillingMode
    /// Accepted values: 'active' | 'expired' | 'revoked' | 'payment_required' | 'storage_payment_required' | 'pending'.
    public var `status`: String
    /// Accepted values: 'wallet' | 'stripe'.
    public var `provider`: String
    public var `capacity`: WorkspaceCapacity
    public var `tariffId`: String
    public var `currency`: String
    @APINumber public var `monthlyAmount`: Double
    @APINumber public var `paygCapAmount`: Double
    public var `periodStart`: String
    public var `periodEnd`: String
    @APIBoolean public var `autoRenew`: Bool
    @APIBoolean public var `computeCovered`: Bool
    public var `retention`: NamespaceCapacityRetention
    public var `pendingChange`: NamespaceCapacityPendingChange?
    public var `resourceLimits`: NamespaceResourceLimits
    public var `savings`: CapacitySavings?
    public var `network`: NamespaceCapacityNetwork

    public init(`id`: String,
                `namespace`: String,
                `billingMode`: ComputeBillingMode,
                `status`: String,
                `provider`: String,
                `capacity`: WorkspaceCapacity,
                `tariffId`: String,
                `currency`: String = "usd",
                `monthlyAmount`: Double,
                `paygCapAmount`: Double,
                `periodStart`: String,
                `periodEnd`: String,
                `autoRenew`: Bool,
                `computeCovered`: Bool,
                `retention`: NamespaceCapacityRetention,
                `pendingChange`: NamespaceCapacityPendingChange? = nil,
                `resourceLimits`: NamespaceResourceLimits,
                `savings`: CapacitySavings? = nil,
                `network`: NamespaceCapacityNetwork) {
        self.`id` = `id`
        self.`namespace` = `namespace`
        self.`billingMode` = `billingMode`
        self.`status` = `status`
        self.`provider` = `provider`
        self.`capacity` = `capacity`
        self.`tariffId` = `tariffId`
        self.`currency` = `currency`
        self.`monthlyAmount` = `monthlyAmount`
        self.`paygCapAmount` = `paygCapAmount`
        self.`periodStart` = `periodStart`
        self.`periodEnd` = `periodEnd`
        self.`autoRenew` = `autoRenew`
        self.`computeCovered` = `computeCovered`
        self.`retention` = `retention`
        self.`pendingChange` = `pendingChange`
        self.`resourceLimits` = `resourceLimits`
        self.`savings` = `savings`
        self.`network` = `network`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `namespace` = "namespace"
        case `billingMode` = "billingMode"
        case `status` = "status"
        case `provider` = "provider"
        case `capacity` = "capacity"
        case `tariffId` = "tariffId"
        case `currency` = "currency"
        case `monthlyAmount` = "monthlyAmount"
        case `paygCapAmount` = "paygCapAmount"
        case `periodStart` = "periodStart"
        case `periodEnd` = "periodEnd"
        case `autoRenew` = "autoRenew"
        case `computeCovered` = "computeCovered"
        case `retention` = "retention"
        case `pendingChange` = "pendingChange"
        case `resourceLimits` = "resourceLimits"
        case `savings` = "savings"
        case `network` = "network"
    }
}

public struct CapacityResponsePendingCheckout: Codable, Sendable {
    public var `quote`: CapacityQuote
    public var `checkoutId`: String?
    public var `url`: String?

    public init(`quote`: CapacityQuote,
                `checkoutId`: String? = nil,
                `url`: String? = nil) {
        self.`quote` = `quote`
        self.`checkoutId` = `checkoutId`
        self.`url` = `url`
    }

    enum CodingKeys: String, CodingKey {
        case `quote` = "quote"
        case `checkoutId` = "checkoutId"
        case `url` = "url"
    }
}

public struct CapacityResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `namespace`: String
    public var `capacity`: NamespaceCapacity?
    public var `catalog`: CapacityCatalog?
    public var `pendingCheckout`: CapacityResponsePendingCheckout?

    public init(`success`: Bool,
                `namespace`: String,
                `capacity`: NamespaceCapacity? = nil,
                `catalog`: CapacityCatalog? = nil,
                `pendingCheckout`: CapacityResponsePendingCheckout? = nil) {
        self.`success` = `success`
        self.`namespace` = `namespace`
        self.`capacity` = `capacity`
        self.`catalog` = `catalog`
        self.`pendingCheckout` = `pendingCheckout`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `namespace` = "namespace"
        case `capacity` = "capacity"
        case `catalog` = "catalog"
        case `pendingCheckout` = "pendingCheckout"
    }
}

public struct CapacityQuoteResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `namespace`: String
    public var `quote`: CapacityQuote

    public init(`success`: Bool,
                `namespace`: String,
                `quote`: CapacityQuote) {
        self.`success` = `success`
        self.`namespace` = `namespace`
        self.`quote` = `quote`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `namespace` = "namespace"
        case `quote` = "quote"
    }
}

public struct PreviewCapacityParams: Codable, Sendable {
    public var `capacity`: WorkspaceCapacity
    public var `billingMode`: ComputeBillingMode
    public var `tariffId`: String?
    /// Accepted values: 'wallet' | 'stripe'.
    public var `paymentSource`: String?
    @APIOptionalBoolean public var `autoRenew`: Bool?
    public var `idempotencyKey`: String

    public init(`capacity`: WorkspaceCapacity,
                `billingMode`: ComputeBillingMode,
                `tariffId`: String? = nil,
                `paymentSource`: String? = nil,
                `autoRenew`: Bool? = nil,
                `idempotencyKey`: String) {
        self.`capacity` = `capacity`
        self.`billingMode` = `billingMode`
        self.`tariffId` = `tariffId`
        self.`paymentSource` = `paymentSource`
        self.`autoRenew` = `autoRenew`
        self.`idempotencyKey` = `idempotencyKey`
    }

    enum CodingKeys: String, CodingKey {
        case `capacity` = "capacity"
        case `billingMode` = "billingMode"
        case `tariffId` = "tariffId"
        case `paymentSource` = "paymentSource"
        case `autoRenew` = "autoRenew"
        case `idempotencyKey` = "idempotencyKey"
    }
}

public struct ConfirmCapacityParams: Codable, Sendable {
    public var `quoteId`: String
    public var `idempotencyKey`: String

    public init(`quoteId`: String,
                `idempotencyKey`: String) {
        self.`quoteId` = `quoteId`
        self.`idempotencyKey` = `idempotencyKey`
    }

    enum CodingKeys: String, CodingKey {
        case `quoteId` = "quoteId"
        case `idempotencyKey` = "idempotencyKey"
    }
}

public struct CapacityCheckoutParamsCustomer: Codable, Sendable {
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

public struct CapacityCheckoutParams: Codable, Sendable {
    public var `successUrl`: String?
    public var `cancelUrl`: String?
    public var `customer`: CapacityCheckoutParamsCustomer?
    @APIOptionalBoolean public var `allowPromotionCodes`: Bool?
    /// Accepted values: 'stripe' | 'oblien'.
    public var `checkoutMode`: String?
    public var `quoteId`: String
    public var `idempotencyKey`: String

    public init(`successUrl`: String? = nil,
                `cancelUrl`: String? = nil,
                `customer`: CapacityCheckoutParamsCustomer? = nil,
                `allowPromotionCodes`: Bool? = nil,
                `checkoutMode`: String? = nil,
                `quoteId`: String,
                `idempotencyKey`: String) {
        self.`successUrl` = `successUrl`
        self.`cancelUrl` = `cancelUrl`
        self.`customer` = `customer`
        self.`allowPromotionCodes` = `allowPromotionCodes`
        self.`checkoutMode` = `checkoutMode`
        self.`quoteId` = `quoteId`
        self.`idempotencyKey` = `idempotencyKey`
    }

    enum CodingKeys: String, CodingKey {
        case `successUrl` = "successUrl"
        case `cancelUrl` = "cancelUrl"
        case `customer` = "customer"
        case `allowPromotionCodes` = "allowPromotionCodes"
        case `checkoutMode` = "checkoutMode"
        case `quoteId` = "quoteId"
        case `idempotencyKey` = "idempotencyKey"
    }
}

public struct CapacityCheckoutResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `namespace`: String
    public var `url`: String?
    public var `checkoutId`: String?
    public var `quote`: CapacityQuote?

    public init(`success`: Bool,
                `namespace`: String,
                `url`: String? = nil,
                `checkoutId`: String? = nil,
                `quote`: CapacityQuote? = nil) {
        self.`success` = `success`
        self.`namespace` = `namespace`
        self.`url` = `url`
        self.`checkoutId` = `checkoutId`
        self.`quote` = `quote`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `namespace` = "namespace"
        case `url` = "url"
        case `checkoutId` = "checkoutId"
        case `quote` = "quote"
    }
}

public struct BillingSavingsPeriod: Codable, Sendable {
    public var `month`: String
    public var `start`: String
    public var `end`: String

    public init(`month`: String,
                `start`: String,
                `end`: String) {
        self.`month` = `month`
        self.`start` = `start`
        self.`end` = `end`
    }

    enum CodingKeys: String, CodingKey {
        case `month` = "month"
        case `start` = "start"
        case `end` = "end"
    }
}

public struct BillingSavingsTotals: Codable, Sendable {
    @APINumber public var `beforeCaps`: Double
    @APINumber public var `capDiscount`: Int
    @APINumber public var `monthlyCoveredUsage`: Double
    @APINumber public var `usageCharged`: Double

    public init(`beforeCaps`: Double,
                `capDiscount`: Int,
                `monthlyCoveredUsage`: Double,
                `usageCharged`: Double) {
        self.`beforeCaps` = `beforeCaps`
        self.`capDiscount` = `capDiscount`
        self.`monthlyCoveredUsage` = `monthlyCoveredUsage`
        self.`usageCharged` = `usageCharged`
    }

    enum CodingKeys: String, CodingKey {
        case `beforeCaps` = "beforeCaps"
        case `capDiscount` = "capDiscount"
        case `monthlyCoveredUsage` = "monthlyCoveredUsage"
        case `usageCharged` = "usageCharged"
    }
}

public struct BillingSavingsWorkspacesItem: Codable, Sendable {
    public var `namespace`: String?
    public var `workspaceId`: String?
    @APINumber public var `windows`: Double
    @APINumber public var `unavailableComponents`: Double
    @APINumber public var `beforeCaps`: Double
    @APINumber public var `capDiscount`: Int
    @APINumber public var `monthlyCoveredUsage`: Double
    @APINumber public var `usageCharged`: Double

    public init(`namespace`: String? = nil,
                `workspaceId`: String? = nil,
                `windows`: Double,
                `unavailableComponents`: Double,
                `beforeCaps`: Double,
                `capDiscount`: Int,
                `monthlyCoveredUsage`: Double,
                `usageCharged`: Double) {
        self.`namespace` = `namespace`
        self.`workspaceId` = `workspaceId`
        self.`windows` = `windows`
        self.`unavailableComponents` = `unavailableComponents`
        self.`beforeCaps` = `beforeCaps`
        self.`capDiscount` = `capDiscount`
        self.`monthlyCoveredUsage` = `monthlyCoveredUsage`
        self.`usageCharged` = `usageCharged`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `workspaceId` = "workspaceId"
        case `windows` = "windows"
        case `unavailableComponents` = "unavailableComponents"
        case `beforeCaps` = "beforeCaps"
        case `capDiscount` = "capDiscount"
        case `monthlyCoveredUsage` = "monthlyCoveredUsage"
        case `usageCharged` = "usageCharged"
    }
}

public struct BillingSavings: Codable, Sendable {
    public var `currency`: String
    public var `period`: BillingSavingsPeriod
    public var `comparison`: String
    @APIBoolean public var `complete`: Bool
    @APIBoolean public var `monthlySubscriptionFeesIncluded`: Bool
    @APIBoolean public var `refundsIncluded`: Bool
    public var `totals`: BillingSavingsTotals
    public var `workspaces`: [BillingSavingsWorkspacesItem]

    public init(`currency`: String = "usd",
                `period`: BillingSavingsPeriod,
                `comparison`: String = "saved_usage_rates_before_caps",
                `complete`: Bool,
                `monthlySubscriptionFeesIncluded`: Bool,
                `refundsIncluded`: Bool,
                `totals`: BillingSavingsTotals,
                `workspaces`: [BillingSavingsWorkspacesItem]) {
        self.`currency` = `currency`
        self.`period` = `period`
        self.`comparison` = `comparison`
        self.`complete` = `complete`
        self.`monthlySubscriptionFeesIncluded` = `monthlySubscriptionFeesIncluded`
        self.`refundsIncluded` = `refundsIncluded`
        self.`totals` = `totals`
        self.`workspaces` = `workspaces`
    }

    enum CodingKeys: String, CodingKey {
        case `currency` = "currency"
        case `period` = "period"
        case `comparison` = "comparison"
        case `complete` = "complete"
        case `monthlySubscriptionFeesIncluded` = "monthlySubscriptionFeesIncluded"
        case `refundsIncluded` = "refundsIncluded"
        case `totals` = "totals"
        case `workspaces` = "workspaces"
    }
}
