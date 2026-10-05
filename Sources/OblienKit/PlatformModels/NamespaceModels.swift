// Models audited against oblien 2.8.0. Regenerate with scripts/generate-platform-models.cjs.
import Foundation

/// Open string enum; preserves new server values.
public struct NamespaceStatus: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(from decoder: Decoder) throws { rawValue = try decoder.singleValueContainer().decode(String.self) }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public static let `active` = Self(rawValue: "active")
    public static let `inactive` = Self(rawValue: "inactive")
    public static let `suspended` = Self(rawValue: "suspended")
}

/// Open string enum; preserves new server values.
public struct NamespaceType: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(from decoder: Decoder) throws { rawValue = try decoder.singleValueContainer().decode(String.self) }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public static let `default` = Self(rawValue: "default")
    public static let `production` = Self(rawValue: "production")
    public static let `staging` = Self(rawValue: "staging")
    public static let `development` = Self(rawValue: "development")
    public static let `testing` = Self(rawValue: "testing")
}

public struct NamespaceResourceLimits: Codable, Sendable {
    public var `maxWorkspaces`: JSONField<Int>?
    public var `maxVcpus`: JSONField<Int>?
    public var `maxRamMb`: JSONField<Int>?
    public var `maxDiskGb`: JSONField<Int>?
    public var `maxTotalVcpus`: JSONField<Double>?
    public var `maxTotalRamMb`: JSONField<Int>?
    public var `maxTotalDiskGb`: JSONField<Int>?

    public init(`maxWorkspaces`: JSONField<Int>? = nil,
                `maxVcpus`: JSONField<Int>? = nil,
                `maxRamMb`: JSONField<Int>? = nil,
                `maxDiskGb`: JSONField<Int>? = nil,
                `maxTotalVcpus`: JSONField<Double>? = nil,
                `maxTotalRamMb`: JSONField<Int>? = nil,
                `maxTotalDiskGb`: JSONField<Int>? = nil) {
        self.`maxWorkspaces` = `maxWorkspaces`
        self.`maxVcpus` = `maxVcpus`
        self.`maxRamMb` = `maxRamMb`
        self.`maxDiskGb` = `maxDiskGb`
        self.`maxTotalVcpus` = `maxTotalVcpus`
        self.`maxTotalRamMb` = `maxTotalRamMb`
        self.`maxTotalDiskGb` = `maxTotalDiskGb`
    }

    enum CodingKeys: String, CodingKey {
        case `maxWorkspaces` = "max_workspaces"
        case `maxVcpus` = "max_vcpus"
        case `maxRamMb` = "max_ram_mb"
        case `maxDiskGb` = "max_disk_gb"
        case `maxTotalVcpus` = "max_total_vcpus"
        case `maxTotalRamMb` = "max_total_ram_mb"
        case `maxTotalDiskGb` = "max_total_disk_gb"
    }
}

public struct NamespaceDataAllocatedResourceUsage: Codable, Sendable {
    @APINumber public var `workspaces`: Double
    @APINumber public var `vcpus`: Double
    @APINumber public var `ramMb`: Int
    @APINumber public var `diskGb`: Int
    @APINumber public var `pendingUpdates`: Double

    public init(`workspaces`: Double,
                `vcpus`: Double,
                `ramMb`: Int,
                `diskGb`: Int,
                `pendingUpdates`: Double) {
        self.`workspaces` = `workspaces`
        self.`vcpus` = `vcpus`
        self.`ramMb` = `ramMb`
        self.`diskGb` = `diskGb`
        self.`pendingUpdates` = `pendingUpdates`
    }

    enum CodingKeys: String, CodingKey {
        case `workspaces` = "workspaces"
        case `vcpus` = "vcpus"
        case `ramMb` = "ram_mb"
        case `diskGb` = "disk_gb"
        case `pendingUpdates` = "pending_updates"
    }
}

public struct NamespaceData: Codable, Sendable {
    public var `id`: String
    public var `clientId`: String
    public var `name`: String
    public var `slug`: String
    public var `description`: String?
    public var `status`: NamespaceStatus
    public var `type`: String
    @APIBoolean public var `isDefault`: Bool
    public var `metadata`: [String: JSONValue]?
    public var `tags`: [String]?
    public var `resourceLimits`: NamespaceResourceLimits?
    public var `effectiveResourceLimits`: NamespaceResourceLimits?
    public var `allocatedResourceUsage`: NamespaceDataAllocatedResourceUsage?
    public var `createdAt`: String
    public var `updatedAt`: String
    public var `lastActiveAt`: String?

    public init(`id`: String,
                `clientId`: String,
                `name`: String,
                `slug`: String,
                `description`: String? = nil,
                `status`: NamespaceStatus,
                `type`: String,
                `isDefault`: Bool,
                `metadata`: [String: JSONValue]? = nil,
                `tags`: [String]? = nil,
                `resourceLimits`: NamespaceResourceLimits? = nil,
                `effectiveResourceLimits`: NamespaceResourceLimits? = nil,
                `allocatedResourceUsage`: NamespaceDataAllocatedResourceUsage? = nil,
                `createdAt`: String,
                `updatedAt`: String,
                `lastActiveAt`: String? = nil) {
        self.`id` = `id`
        self.`clientId` = `clientId`
        self.`name` = `name`
        self.`slug` = `slug`
        self.`description` = `description`
        self.`status` = `status`
        self.`type` = `type`
        self.`isDefault` = `isDefault`
        self.`metadata` = `metadata`
        self.`tags` = `tags`
        self.`resourceLimits` = `resourceLimits`
        self.`effectiveResourceLimits` = `effectiveResourceLimits`
        self.`allocatedResourceUsage` = `allocatedResourceUsage`
        self.`createdAt` = `createdAt`
        self.`updatedAt` = `updatedAt`
        self.`lastActiveAt` = `lastActiveAt`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `clientId` = "client_id"
        case `name` = "name"
        case `slug` = "slug"
        case `description` = "description"
        case `status` = "status"
        case `type` = "type"
        case `isDefault` = "is_default"
        case `metadata` = "metadata"
        case `tags` = "tags"
        case `resourceLimits` = "resource_limits"
        case `effectiveResourceLimits` = "effective_resource_limits"
        case `allocatedResourceUsage` = "allocated_resource_usage"
        case `createdAt` = "created_at"
        case `updatedAt` = "updated_at"
        case `lastActiveAt` = "last_active_at"
    }
}

public struct NamespaceCreateParams: Codable, Sendable {
    public var `name`: String
    public var `slug`: String?
    public var `description`: String?
    public var `type`: NamespaceType?
    @APIOptionalBoolean public var `isDefault`: Bool?
    public var `metadata`: [String: JSONValue]?
    public var `tags`: [String]?
    public var `resourceLimits`: NamespaceResourceLimits?

    public init(`name`: String,
                `slug`: String? = nil,
                `description`: String? = nil,
                `type`: NamespaceType? = nil,
                `isDefault`: Bool? = nil,
                `metadata`: [String: JSONValue]? = nil,
                `tags`: [String]? = nil,
                `resourceLimits`: NamespaceResourceLimits? = nil) {
        self.`name` = `name`
        self.`slug` = `slug`
        self.`description` = `description`
        self.`type` = `type`
        self.`isDefault` = `isDefault`
        self.`metadata` = `metadata`
        self.`tags` = `tags`
        self.`resourceLimits` = `resourceLimits`
    }

    enum CodingKeys: String, CodingKey {
        case `name` = "name"
        case `slug` = "slug"
        case `description` = "description"
        case `type` = "type"
        case `isDefault` = "isDefault"
        case `metadata` = "metadata"
        case `tags` = "tags"
        case `resourceLimits` = "resource_limits"
    }
}

public struct NamespaceEnsureParams: Codable, Sendable {
    public var `name`: String?
    public var `slug`: String?
    public var `description`: String?
    public var `type`: NamespaceType?
    @APIOptionalBoolean public var `isDefault`: Bool?
    public var `metadata`: [String: JSONValue]?
    public var `tags`: [String]?
    public var `resourceLimits`: NamespaceResourceLimits?

    public init(`name`: String? = nil,
                `slug`: String? = nil,
                `description`: String? = nil,
                `type`: NamespaceType? = nil,
                `isDefault`: Bool? = nil,
                `metadata`: [String: JSONValue]? = nil,
                `tags`: [String]? = nil,
                `resourceLimits`: NamespaceResourceLimits? = nil) {
        self.`name` = `name`
        self.`slug` = `slug`
        self.`description` = `description`
        self.`type` = `type`
        self.`isDefault` = `isDefault`
        self.`metadata` = `metadata`
        self.`tags` = `tags`
        self.`resourceLimits` = `resourceLimits`
    }

    enum CodingKeys: String, CodingKey {
        case `name` = "name"
        case `slug` = "slug"
        case `description` = "description"
        case `type` = "type"
        case `isDefault` = "isDefault"
        case `metadata` = "metadata"
        case `tags` = "tags"
        case `resourceLimits` = "resource_limits"
    }
}

public struct NamespaceEnsureResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    @APIBoolean public var `created`: Bool
    public var `data`: NamespaceData

    public init(`success`: Bool,
                `created`: Bool,
                `data`: NamespaceData) {
        self.`success` = `success`
        self.`created` = `created`
        self.`data` = `data`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `created` = "created"
        case `data` = "data"
    }
}

public struct NamespaceUpdateParams: Codable, Sendable {
    public var `name`: String?
    public var `description`: String?
    public var `status`: NamespaceStatus?
    public var `type`: NamespaceType?
    public var `tags`: [String]?
    public var `metadata`: [String: JSONValue]?
    public var `resourceLimits`: NamespaceResourceLimits?

    public init(`name`: String? = nil,
                `description`: String? = nil,
                `status`: NamespaceStatus? = nil,
                `type`: NamespaceType? = nil,
                `tags`: [String]? = nil,
                `metadata`: [String: JSONValue]? = nil,
                `resourceLimits`: NamespaceResourceLimits? = nil) {
        self.`name` = `name`
        self.`description` = `description`
        self.`status` = `status`
        self.`type` = `type`
        self.`tags` = `tags`
        self.`metadata` = `metadata`
        self.`resourceLimits` = `resourceLimits`
    }

    enum CodingKeys: String, CodingKey {
        case `name` = "name"
        case `description` = "description"
        case `status` = "status"
        case `type` = "type"
        case `tags` = "tags"
        case `metadata` = "metadata"
        case `resourceLimits` = "resource_limits"
    }
}

public struct NamespaceListParams: Codable, Sendable {
    @APIOptionalNumber public var `limit`: Int?
    @APIOptionalNumber public var `offset`: Int?
    public var `status`: NamespaceStatus?
    public var `type`: NamespaceType?
    public var `search`: String?
    /// Accepted values: 'created_at' | 'updated_at' | 'name'.
    public var `sortBy`: String?
    /// Accepted values: 'ASC' | 'DESC'.
    public var `sortOrder`: String?

    public init(`limit`: Int? = nil,
                `offset`: Int? = nil,
                `status`: NamespaceStatus? = nil,
                `type`: NamespaceType? = nil,
                `search`: String? = nil,
                `sortBy`: String? = nil,
                `sortOrder`: String? = nil) {
        self.`limit` = `limit`
        self.`offset` = `offset`
        self.`status` = `status`
        self.`type` = `type`
        self.`search` = `search`
        self.`sortBy` = `sortBy`
        self.`sortOrder` = `sortOrder`
    }

    enum CodingKeys: String, CodingKey {
        case `limit` = "limit"
        case `offset` = "offset"
        case `status` = "status"
        case `type` = "type"
        case `search` = "search"
        case `sortBy` = "sortBy"
        case `sortOrder` = "sortOrder"
    }
}

public struct NamespaceListResponsePagination: Codable, Sendable {
    @APINumber public var `total`: Int
    @APINumber public var `limit`: Int
    @APINumber public var `offset`: Int

    public init(`total`: Int,
                `limit`: Int,
                `offset`: Int) {
        self.`total` = `total`
        self.`limit` = `limit`
        self.`offset` = `offset`
    }

    enum CodingKeys: String, CodingKey {
        case `total` = "total"
        case `limit` = "limit"
        case `offset` = "offset"
    }
}

public struct NamespaceListResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: [NamespaceData]
    public var `pagination`: NamespaceListResponsePagination

    public init(`success`: Bool,
                `data`: [NamespaceData],
                `pagination`: NamespaceListResponsePagination) {
        self.`success` = `success`
        self.`data` = `data`
        self.`pagination` = `pagination`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
        case `pagination` = "pagination"
    }
}

public struct NamespaceActivity: Codable, Sendable {
    @APINumber public var `id`: Int
    public var `namespaceId`: String
    public var `userId`: String?
    public var `action`: String
    public var `description`: String?
    public var `changes`: [String: JSONValue]?
    public var `ipAddress`: String?
    public var `userAgent`: String?
    public var `createdAt`: String

    public init(`id`: Int,
                `namespaceId`: String,
                `userId`: String? = nil,
                `action`: String,
                `description`: String? = nil,
                `changes`: [String: JSONValue]? = nil,
                `ipAddress`: String? = nil,
                `userAgent`: String? = nil,
                `createdAt`: String) {
        self.`id` = `id`
        self.`namespaceId` = `namespaceId`
        self.`userId` = `userId`
        self.`action` = `action`
        self.`description` = `description`
        self.`changes` = `changes`
        self.`ipAddress` = `ipAddress`
        self.`userAgent` = `userAgent`
        self.`createdAt` = `createdAt`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `namespaceId` = "namespace_id"
        case `userId` = "user_id"
        case `action` = "action"
        case `description` = "description"
        case `changes` = "changes"
        case `ipAddress` = "ip_address"
        case `userAgent` = "user_agent"
        case `createdAt` = "created_at"
    }
}

public struct NamespaceActivityParams: Codable, Sendable {
    @APIOptionalNumber public var `limit`: Int?
    @APIOptionalNumber public var `offset`: Int?

    public init(`limit`: Int? = nil,
                `offset`: Int? = nil) {
        self.`limit` = `limit`
        self.`offset` = `offset`
    }

    enum CodingKeys: String, CodingKey {
        case `limit` = "limit"
        case `offset` = "offset"
    }
}

public struct NamespaceUsageParams: Codable, Sendable {
    public var `service`: String?
    @APIOptionalNumber public var `days`: Double?

    public init(`service`: String? = nil,
                `days`: Double? = nil) {
        self.`service` = `service`
        self.`days` = `days`
    }

    enum CodingKeys: String, CodingKey {
        case `service` = "service"
        case `days` = "days"
    }
}

public struct NamespaceUsageUnitsParams: Codable, Sendable {
    public var `from`: String?
    public var `to`: String?
    /// Accepted values: 'hour' | 'day'.
    public var `groupBy`: String?

    public init(`from`: String? = nil,
                `to`: String? = nil,
                `groupBy`: String? = nil) {
        self.`from` = `from`
        self.`to` = `to`
        self.`groupBy` = `groupBy`
    }

    enum CodingKeys: String, CodingKey {
        case `from` = "from"
        case `to` = "to"
        case `groupBy` = "groupBy"
    }
}

public struct NamespaceUsageUnitBucket: Codable, Sendable {
    public var `timestamp`: String
    @APINumber public var `cpuTimeMinutes`: Double
    @APINumber public var `memoryGbMinutes`: Double
    @APINumber public var `diskIoGb`: Int
    @APINumber public var `networkGb`: Int
    @APINumber public var `vcpuHours`: Double
    @APINumber public var `gbHours`: Double
    @APINumber public var `credits`: Double
    @APINumber public var `records`: Double

    public init(`timestamp`: String,
                `cpuTimeMinutes`: Double,
                `memoryGbMinutes`: Double,
                `diskIoGb`: Int,
                `networkGb`: Int,
                `vcpuHours`: Double,
                `gbHours`: Double,
                `credits`: Double,
                `records`: Double) {
        self.`timestamp` = `timestamp`
        self.`cpuTimeMinutes` = `cpuTimeMinutes`
        self.`memoryGbMinutes` = `memoryGbMinutes`
        self.`diskIoGb` = `diskIoGb`
        self.`networkGb` = `networkGb`
        self.`vcpuHours` = `vcpuHours`
        self.`gbHours` = `gbHours`
        self.`credits` = `credits`
        self.`records` = `records`
    }

    enum CodingKeys: String, CodingKey {
        case `timestamp` = "timestamp"
        case `cpuTimeMinutes` = "cpu_time_minutes"
        case `memoryGbMinutes` = "memory_gb_minutes"
        case `diskIoGb` = "disk_io_gb"
        case `networkGb` = "network_gb"
        case `vcpuHours` = "vcpu_hours"
        case `gbHours` = "gb_hours"
        case `credits` = "credits"
        case `records` = "records"
    }
}

public struct NamespaceUsageUnitsRange: Codable, Sendable {
    public var `from`: String
    public var `to`: String

    public init(`from`: String,
                `to`: String) {
        self.`from` = `from`
        self.`to` = `to`
    }

    enum CodingKeys: String, CodingKey {
        case `from` = "from"
        case `to` = "to"
    }
}

public struct NamespaceUsageUnitsTotals: Codable, Sendable {
    @APINumber public var `cpuTimeMinutes`: Double
    @APINumber public var `memoryGbMinutes`: Double
    @APINumber public var `diskIoGb`: Int
    @APINumber public var `networkGb`: Int
    @APINumber public var `vcpuHours`: Double
    @APINumber public var `gbHours`: Double
    @APINumber public var `credits`: Double
    @APINumber public var `records`: Double

    public init(`cpuTimeMinutes`: Double,
                `memoryGbMinutes`: Double,
                `diskIoGb`: Int,
                `networkGb`: Int,
                `vcpuHours`: Double,
                `gbHours`: Double,
                `credits`: Double,
                `records`: Double) {
        self.`cpuTimeMinutes` = `cpuTimeMinutes`
        self.`memoryGbMinutes` = `memoryGbMinutes`
        self.`diskIoGb` = `diskIoGb`
        self.`networkGb` = `networkGb`
        self.`vcpuHours` = `vcpuHours`
        self.`gbHours` = `gbHours`
        self.`credits` = `credits`
        self.`records` = `records`
    }

    enum CodingKeys: String, CodingKey {
        case `cpuTimeMinutes` = "cpu_time_minutes"
        case `memoryGbMinutes` = "memory_gb_minutes"
        case `diskIoGb` = "disk_io_gb"
        case `networkGb` = "network_gb"
        case `vcpuHours` = "vcpu_hours"
        case `gbHours` = "gb_hours"
        case `credits` = "credits"
        case `records` = "records"
    }
}

public struct NamespaceUsageUnits: Codable, Sendable {
    public var `namespace`: String
    public var `range`: NamespaceUsageUnitsRange
    /// Accepted values: 'hour' | 'day'.
    public var `groupBy`: String
    public var `buckets`: [NamespaceUsageUnitBucket]
    public var `totals`: NamespaceUsageUnitsTotals

    public init(`namespace`: String,
                `range`: NamespaceUsageUnitsRange,
                `groupBy`: String,
                `buckets`: [NamespaceUsageUnitBucket],
                `totals`: NamespaceUsageUnitsTotals) {
        self.`namespace` = `namespace`
        self.`range` = `range`
        self.`groupBy` = `groupBy`
        self.`buckets` = `buckets`
        self.`totals` = `totals`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `range` = "range"
        case `groupBy` = "group_by"
        case `buckets` = "buckets"
        case `totals` = "totals"
    }
}

public struct NamespaceDeleteParams: Codable, Sendable {
    @APIOptionalBoolean public var `deleteWorkspaces`: Bool?

    public init(`deleteWorkspaces`: Bool? = nil) {
        self.`deleteWorkspaces` = `deleteWorkspaces`
    }

    enum CodingKeys: String, CodingKey {
        case `deleteWorkspaces` = "deleteWorkspaces"
    }
}

/// Open string enum; preserves new server values.
public struct OverdraftAction: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(from decoder: Decoder) throws { rawValue = try decoder.singleValueContainer().decode(String.self) }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public static let `block` = Self(rawValue: "block")
    public static let `stopWorkspaces` = Self(rawValue: "stop_workspaces")
}

public struct NamespaceQuotaAlert: Codable, Sendable {
    /// Accepted values: 'ok' | 'low' | 'grace' | 'depleted' | 'unlimited' | 'disabled'.
    public var `state`: String
    public var `thresholds`: [Double]
    @APIOptionalNumber public var `threshold`: Double?
    @APIOptionalNumber public var `percent`: Int?
    @APINumber public var `used`: Double
    @APIOptionalNumber public var `limit`: Int?
    @APIOptionalNumber public var `remaining`: Double?
    @APIOptionalNumber public var `balance`: Double?
    @APINumber public var `overdraft`: Double
    @APIBoolean public var `blocking`: Bool

    public init(`state`: String,
                `thresholds`: [Double],
                `threshold`: Double? = nil,
                `percent`: Int? = nil,
                `used`: Double,
                `limit`: Int? = nil,
                `remaining`: Double? = nil,
                `balance`: Double? = nil,
                `overdraft`: Double,
                `blocking`: Bool) {
        self.`state` = `state`
        self.`thresholds` = `thresholds`
        self.`threshold` = `threshold`
        self.`percent` = `percent`
        self.`used` = `used`
        self.`limit` = `limit`
        self.`remaining` = `remaining`
        self.`balance` = `balance`
        self.`overdraft` = `overdraft`
        self.`blocking` = `blocking`
    }

    enum CodingKeys: String, CodingKey {
        case `state` = "state"
        case `thresholds` = "thresholds"
        case `threshold` = "threshold"
        case `percent` = "percent"
        case `used` = "used"
        case `limit` = "limit"
        case `remaining` = "remaining"
        case `balance` = "balance"
        case `overdraft` = "overdraft"
        case `blocking` = "blocking"
    }
}

public struct NamespaceQuota: Codable, Sendable {
    @APINumber public var `id`: Int
    public var `clientId`: String
    public var `namespace`: String
    public var `service`: String
    @APIOptionalNumber public var `quotaLimit`: Double?
    @APINumber public var `quotaUsed`: Double
    @APIOptionalNumber public var `purchasedCredits`: Double?
    @APIOptionalNumber public var `suspendThreshold`: Double?
    public var `alert`: NamespaceQuotaAlert?
    @APINumber public var `overdraft`: Double
    public var `onOverdraftAction`: OverdraftAction
    public var `notificationThresholds`: [Double]?
    @APIOptionalNumber public var `lastThresholdFired`: Double?
    @APIBoolean public var `enabled`: Bool
    public var `createdAt`: String
    public var `updatedAt`: String

    public init(`id`: Int,
                `clientId`: String,
                `namespace`: String,
                `service`: String,
                `quotaLimit`: Double? = nil,
                `quotaUsed`: Double,
                `purchasedCredits`: Double? = nil,
                `suspendThreshold`: Double? = nil,
                `alert`: NamespaceQuotaAlert? = nil,
                `overdraft`: Double,
                `onOverdraftAction`: OverdraftAction,
                `notificationThresholds`: [Double]? = nil,
                `lastThresholdFired`: Double? = nil,
                `enabled`: Bool,
                `createdAt`: String,
                `updatedAt`: String) {
        self.`id` = `id`
        self.`clientId` = `clientId`
        self.`namespace` = `namespace`
        self.`service` = `service`
        self.`quotaLimit` = `quotaLimit`
        self.`quotaUsed` = `quotaUsed`
        self.`purchasedCredits` = `purchasedCredits`
        self.`suspendThreshold` = `suspendThreshold`
        self.`alert` = `alert`
        self.`overdraft` = `overdraft`
        self.`onOverdraftAction` = `onOverdraftAction`
        self.`notificationThresholds` = `notificationThresholds`
        self.`lastThresholdFired` = `lastThresholdFired`
        self.`enabled` = `enabled`
        self.`createdAt` = `createdAt`
        self.`updatedAt` = `updatedAt`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `clientId` = "client_id"
        case `namespace` = "namespace"
        case `service` = "service"
        case `quotaLimit` = "quota_limit"
        case `quotaUsed` = "quota_used"
        case `purchasedCredits` = "purchased_credits"
        case `suspendThreshold` = "suspend_threshold"
        case `alert` = "alert"
        case `overdraft` = "overdraft"
        case `onOverdraftAction` = "on_overdraft_action"
        case `notificationThresholds` = "notification_thresholds"
        case `lastThresholdFired` = "last_threshold_fired"
        case `enabled` = "enabled"
        case `createdAt` = "created_at"
        case `updatedAt` = "updated_at"
    }
}

public struct NamespaceUsageData: Codable, Sendable {
    public var `usage`: [[String: JSONValue]]
    public var `summary`: [[String: JSONValue]]
    public var `quotas`: [NamespaceQuota]

    public init(`usage`: [[String: JSONValue]],
                `summary`: [[String: JSONValue]],
                `quotas`: [NamespaceQuota]) {
        self.`usage` = `usage`
        self.`summary` = `summary`
        self.`quotas` = `quotas`
    }

    enum CodingKeys: String, CodingKey {
        case `usage` = "usage"
        case `summary` = "summary"
        case `quotas` = "quotas"
    }
}

public struct SetNamespaceQuotaParams: Codable, Sendable {
    public var `namespace`: String
    public var `service`: String
    @APINumber public var `quotaLimit`: Double
    @APIOptionalNumber public var `overdraft`: Double?
    public var `onOverdraftAction`: OverdraftAction?
    public var `notificationThresholds`: JSONField<[Double]>?

    public init(`namespace`: String,
                `service`: String,
                `quotaLimit`: Double,
                `overdraft`: Double? = nil,
                `onOverdraftAction`: OverdraftAction? = nil,
                `notificationThresholds`: JSONField<[Double]>? = nil) {
        self.`namespace` = `namespace`
        self.`service` = `service`
        self.`quotaLimit` = `quotaLimit`
        self.`overdraft` = `overdraft`
        self.`onOverdraftAction` = `onOverdraftAction`
        self.`notificationThresholds` = `notificationThresholds`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `service` = "service"
        case `quotaLimit` = "quotaLimit"
        case `overdraft` = "overdraft"
        case `onOverdraftAction` = "onOverdraftAction"
        case `notificationThresholds` = "notificationThresholds"
    }
}

public struct ResetNamespaceQuotaParams: Codable, Sendable {
    public var `namespace`: String
    public var `service`: String

    public init(`namespace`: String,
                `service`: String) {
        self.`namespace` = `namespace`
        self.`service` = `service`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `service` = "service"
    }
}

public struct NamespaceListWithQuotasParams: Codable, Sendable {
    @APIOptionalNumber public var `limit`: Int?
    @APIOptionalNumber public var `offset`: Int?
    public var `search`: String?
    public var `status`: NamespaceStatus?

    public init(`limit`: Int? = nil,
                `offset`: Int? = nil,
                `search`: String? = nil,
                `status`: NamespaceStatus? = nil) {
        self.`limit` = `limit`
        self.`offset` = `offset`
        self.`search` = `search`
        self.`status` = `status`
    }

    enum CodingKeys: String, CodingKey {
        case `limit` = "limit"
        case `offset` = "offset"
        case `search` = "search"
        case `status` = "status"
    }
}

public struct NamespaceDetailsParams: Codable, Sendable {
    @APIOptionalNumber public var `days`: Double?

    public init(`days`: Double? = nil) {
        self.`days` = `days`
    }

    enum CodingKeys: String, CodingKey {
        case `days` = "days"
    }
}

public struct DefaultQuotaConfig: Codable, Sendable {
    @APINumber public var `id`: Int
    public var `clientId`: String
    /// Accepted values: 'namespace' | 'end_user'.
    public var `level`: String
    public var `service`: String
    @APINumber public var `quotaLimit`: Double
    @APINumber public var `overdraft`: Double
    public var `onOverdraftAction`: OverdraftAction
    @APIBoolean public var `autoApply`: Bool
    @APIBoolean public var `enabled`: Bool

    public init(`id`: Int,
                `clientId`: String,
                `level`: String,
                `service`: String,
                `quotaLimit`: Double,
                `overdraft`: Double,
                `onOverdraftAction`: OverdraftAction,
                `autoApply`: Bool,
                `enabled`: Bool) {
        self.`id` = `id`
        self.`clientId` = `clientId`
        self.`level` = `level`
        self.`service` = `service`
        self.`quotaLimit` = `quotaLimit`
        self.`overdraft` = `overdraft`
        self.`onOverdraftAction` = `onOverdraftAction`
        self.`autoApply` = `autoApply`
        self.`enabled` = `enabled`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `clientId` = "client_id"
        case `level` = "level"
        case `service` = "service"
        case `quotaLimit` = "quota_limit"
        case `overdraft` = "overdraft"
        case `onOverdraftAction` = "on_overdraft_action"
        case `autoApply` = "auto_apply"
        case `enabled` = "enabled"
    }
}

public struct SetDefaultQuotaParams: Codable, Sendable {
    public var `service`: String
    @APINumber public var `quotaLimit`: Double
    @APIOptionalBoolean public var `autoApply`: Bool?

    public init(`service`: String,
                `quotaLimit`: Double,
                `autoApply`: Bool? = nil) {
        self.`service` = `service`
        self.`quotaLimit` = `quotaLimit`
        self.`autoApply` = `autoApply`
    }

    enum CodingKeys: String, CodingKey {
        case `service` = "service"
        case `quotaLimit` = "quotaLimit"
        case `autoApply` = "autoApply"
    }
}

public struct ToggleDefaultQuotaAutoApplyParams: Codable, Sendable {
    public var `service`: String
    @APIBoolean public var `autoApply`: Bool

    public init(`service`: String,
                `autoApply`: Bool) {
        self.`service` = `service`
        self.`autoApply` = `autoApply`
    }

    enum CodingKeys: String, CodingKey {
        case `service` = "service"
        case `autoApply` = "autoApply"
    }
}

public struct DeleteDefaultQuotaParams: Codable, Sendable {
    public var `service`: String

    public init(`service`: String) {
        self.`service` = `service`
    }

    enum CodingKeys: String, CodingKey {
        case `service` = "service"
    }
}
