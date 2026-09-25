// Models audited against oblien 2.4.0. Regenerate with scripts/generate-platform-models.cjs.
import Foundation

/// Open string enum; preserves new server values.
public struct WebhookEvent: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(from decoder: Decoder) throws { rawValue = try decoder.singleValueContainer().decode(String.self) }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public static let `vmStopped` = Self(rawValue: "vm.stopped")
    public static let `vmArchived` = Self(rawValue: "vm.archived")
    public static let `workloadStarted` = Self(rawValue: "workload.started")
    public static let `workloadExited` = Self(rawValue: "workload.exited")
    public static let `workloadFailed` = Self(rawValue: "workload.failed")
    public static let `workloadStopped` = Self(rawValue: "workload.stopped")
    public static let `workloadRestartLoop` = Self(rawValue: "workload.restart_loop")
    public static let `creditsLow` = Self(rawValue: "credits.low")
    public static let `creditsDepleted` = Self(rawValue: "credits.depleted")
    public static let `creditsUsage` = Self(rawValue: "credits.usage")
    public static let `namespaceQuotaThreshold` = Self(rawValue: "namespace.quota.threshold")
    public static let `paymentSucceeded` = Self(rawValue: "payment.succeeded")
    public static let `subscriptionTierChanged` = Self(rawValue: "subscription.tier_changed")
    public static let `subscriptionRenewed` = Self(rawValue: "subscription.renewed")
    public static let `subscriptionPastDue` = Self(rawValue: "subscription.past_due")
    public static let `subscriptionCanceled` = Self(rawValue: "subscription.canceled")
    public static let `subscriptionUpdated` = Self(rawValue: "subscription.updated")
    public static let `entitlementChanged` = Self(rawValue: "entitlement.changed")
    public static let `namespaceSuspended` = Self(rawValue: "namespace.suspended")
    public static let `namespaceRestored` = Self(rawValue: "namespace.restored")
}

public struct Webhook: Codable, Sendable {
    @APINumber public var `id`: Int
    public var `url`: String
    @APIJSONString public var `events`: [WebhookEvent]
    @APIBoolean public var `active`: Bool
    public var `description`: String?
    public var `namespace`: String?
    public var `secret`: String?
    public var `lastTriggeredAt`: String?
    @APIOptionalNumber public var `lastStatusCode`: Double?
    public var `createdAt`: String?

    public init(`id`: Int,
                `url`: String,
                `events`: [WebhookEvent],
                `active`: Bool,
                `description`: String? = nil,
                `namespace`: String? = nil,
                `secret`: String? = nil,
                `lastTriggeredAt`: String? = nil,
                `lastStatusCode`: Double? = nil,
                `createdAt`: String? = nil) {
        self.`id` = `id`
        self.`url` = `url`
        self.`events` = `events`
        self.`active` = `active`
        self.`description` = `description`
        self.`namespace` = `namespace`
        self.`secret` = `secret`
        self.`lastTriggeredAt` = `lastTriggeredAt`
        self.`lastStatusCode` = `lastStatusCode`
        self.`createdAt` = `createdAt`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `url` = "url"
        case `events` = "events"
        case `active` = "active"
        case `description` = "description"
        case `namespace` = "namespace"
        case `secret` = "secret"
        case `lastTriggeredAt` = "last_triggered_at"
        case `lastStatusCode` = "last_status_code"
        case `createdAt` = "created_at"
    }
}

public struct WebhookCreateParams: Codable, Sendable {
    public var `url`: String
    public var `events`: [WebhookEvent]
    public var `secret`: String?
    public var `description`: String?
    public var `namespace`: String?

    public init(`url`: String,
                `events`: [WebhookEvent],
                `secret`: String? = nil,
                `description`: String? = nil,
                `namespace`: String? = nil) {
        self.`url` = `url`
        self.`events` = `events`
        self.`secret` = `secret`
        self.`description` = `description`
        self.`namespace` = `namespace`
    }

    enum CodingKeys: String, CodingKey {
        case `url` = "url"
        case `events` = "events"
        case `secret` = "secret"
        case `description` = "description"
        case `namespace` = "namespace"
    }
}

public struct WebhookUpdateParams: Codable, Sendable {
    public var `url`: String?
    public var `events`: [WebhookEvent]?
    public var `secret`: JSONField<String>?
    public var `description`: JSONField<String>?
    public var `namespace`: JSONField<String>?
    @APIOptionalBoolean public var `active`: Bool?

    public init(`url`: String? = nil,
                `events`: [WebhookEvent]? = nil,
                `secret`: JSONField<String>? = nil,
                `description`: JSONField<String>? = nil,
                `namespace`: JSONField<String>? = nil,
                `active`: Bool? = nil) {
        self.`url` = `url`
        self.`events` = `events`
        self.`secret` = `secret`
        self.`description` = `description`
        self.`namespace` = `namespace`
        self.`active` = `active`
    }

    enum CodingKeys: String, CodingKey {
        case `url` = "url"
        case `events` = "events"
        case `secret` = "secret"
        case `description` = "description"
        case `namespace` = "namespace"
        case `active` = "active"
    }
}

public struct WebhookListParams: Codable, Sendable {
    public var `namespace`: String?

    public init(`namespace`: String? = nil) {
        self.`namespace` = `namespace`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
    }
}

public struct WebhookListResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `webhooks`: [Webhook]

    public init(`success`: Bool,
                `webhooks`: [Webhook]) {
        self.`success` = `success`
        self.`webhooks` = `webhooks`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `webhooks` = "webhooks"
    }
}

public struct WebhookEventsResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `events`: [WebhookEvent]

    public init(`success`: Bool,
                `events`: [WebhookEvent]) {
        self.`success` = `success`
        self.`events` = `events`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `events` = "events"
    }
}
