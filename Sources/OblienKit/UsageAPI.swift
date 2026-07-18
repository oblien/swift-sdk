import Foundation

/// Usage / billing endpoints. Bound per-workspace via `handle.usage` / `client.workspaces.usage(id)`,
/// and account-level aggregates via `client.workspaces.usageGlobal()` / `client.workspaces.activity(from:to:)`.

// MARK: - Models

/// Per-workspace usage counters from the account-level `GET /workspace/usage` map.
public struct UsageCounters: Codable, Sendable {
    public var totalCpuTimeNs: Int?     // total_cpu_time_ns
    public var totalDiskRead: Int?      // total_disk_read
    public var totalDiskWrite: Int?     // total_disk_write
    public var totalNetRx: Int?         // total_net_rx
    public var totalNetTx: Int?         // total_net_tx
}

/// `GET /workspace/usage` → `{ usage: { <wsId>: {…} }, total }`.
public struct UsageSummary: Codable, Sendable {
    public let usage: [String: UsageCounters]
    public var total: JSONValue?
}

/// `GET /workspace/:id/usage/credits/chart` → `{ granularity, data:[{date,creditsBurned}], total }`.
public struct CreditsChart: Codable, Sendable {
    public struct Point: Codable, Sendable {
        public let date: String
        public var creditsBurned: Double?   // creditsBurned (camelCase on the wire — see CodingKeys)

        enum CodingKeys: String, CodingKey {
            case date
            case creditsBurned = "creditsBurned"
        }
    }
    public var granularity: String?
    public let data: [Point]
    public var total: Double?
}

// MARK: - API

/// `client.workspaces.usage(id)` / `handle.usage` — per-workspace usage + tracking control.
public struct UsageAPI: Sendable {
    let transport: Transport
    let workspaceId: String
    private var base: String { "/workspace/\(workspaceId.pathEscaped)/usage" }

    /// `GET /workspace/:id/usage` — loose shape, returned as `JSONValue`.
    public func get(from: String? = nil, to: String? = nil, tier: String? = nil,
                    last: String? = nil, all: Bool? = nil) async throws -> JSONValue {
        let query: [String: String?] = ["from": from, "to": to, "tier": tier,
                                        "last": last, "all": all.map(String.init)]
        let data = try await transport.request("GET", base, query: query)
        return try OblienJSON.decode(JSONValue.self, data)
    }

    /// `GET /workspace/:id/usage/totals` — loose shape, returned as `JSONValue`.
    public func totals() async throws -> JSONValue {
        let data = try await transport.request("GET", base + "/totals")
        return try OblienJSON.decode(JSONValue.self, data)
    }

    /// `GET /workspace/:id/usage/credits/chart`.
    public func creditsChart() async throws -> CreditsChart {
        let data = try await transport.request("GET", base + "/credits/chart")
        return try OblienJSON.decode(CreditsChart.self, data)
    }

    /// `POST /workspace/:id/usage/tracking/start`.
    public func startTracking() async throws {
        _ = try await transport.request("POST", base + "/tracking/start")
    }

    /// `POST /workspace/:id/usage/tracking/stop`.
    public func stopTracking() async throws {
        _ = try await transport.request("POST", base + "/tracking/stop")
    }

    /// `DELETE /workspace/:id/usage` — wipe recorded usage.
    public func wipe() async throws {
        _ = try await transport.request("DELETE", base)
    }
}

// MARK: - Accessors

extension WorkspaceHandle {
    /// Per-workspace usage / billing.
    public var usage: UsageAPI { UsageAPI(transport: transport, workspaceId: id) }
}

extension WorkspacesAPI {
    /// Per-workspace usage / billing.
    public func usage(_ id: String) -> UsageAPI { UsageAPI(transport: transport, workspaceId: id) }

    /// Account-level usage aggregate (`GET /workspace/usage`).
    public func usageGlobal() async throws -> UsageSummary {
        let data = try await transport.request("GET", "/workspace/usage")
        return try OblienJSON.decode(UsageSummary.self, data)
    }

    /// Account-level activity history (`GET /workspace/activity?from,to`) — loose shape.
    public func activity(from: String? = nil, to: String? = nil) async throws -> JSONValue {
        let data = try await transport.request("GET", "/workspace/activity",
                                               query: ["from": from, "to": to])
        return try OblienJSON.decode(JSONValue.self, data)
    }
}
