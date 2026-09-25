import Foundation

public struct AnalyticsParams: Codable, Sendable {
    public var from: Double?
    public var to: Double?
    public var interval: String?
    public var limit: Int?
    public init(from: Double? = nil, to: Double? = nil, interval: String? = nil, limit: Int? = nil) {
        self.from = from; self.to = to; self.interval = interval; self.limit = limit
    }
}
public struct AnalyticsResponse: Codable, Sendable {
    public let success: Bool
    public let data: DataSet
    public let meta: JSONValue?
    public struct DataSet: Codable, Sendable {
        public let overview: AnalyticsOverview
        public let timeseries: [JSONValue]
        public let geo: JSONValue
        public let requests: [JSONValue]
    }
}

public struct AnalyticsAPI: Sendable {
    let transport: Transport
    private func path(_ domain: String) -> String { "/analytics/\(domain.pathEscaped)" }
    public func home(namespace: String? = nil) async throws -> AnalyticsHomeSummary {
        let response: APIDataResponse<AnalyticsHomeSummary> = try await transport.api("GET", "/analytics/home/summary", query: ["ns": namespace])
        return response.data
    }
    public func get(_ domain: String, _ params: AnalyticsParams = .init()) async throws -> AnalyticsResponse {
        try await transport.api("GET", path(domain), query: APIJSON.query(params))
    }
    public func timeseries(_ domain: String, _ params: AnalyticsTimeseriesParams = .init()) async throws -> AnalyticsTimeseriesResponse {
        try await transport.api("GET", path(domain) + "/timeseries", query: APIJSON.query(params))
    }
    public func geo(_ domain: String, _ params: AnalyticsGeoParams = .init()) async throws -> AnalyticsGeoResponse {
        try await transport.api("GET", path(domain) + "/geo", query: APIJSON.query(params))
    }
    public func requests(_ domain: String, _ params: AnalyticsRequestsParams = .init()) async throws -> AnalyticsRequestsResponse {
        try await transport.api("GET", path(domain) + "/requests", query: APIJSON.query(params))
    }
    public func streamToken(_ domain: String) async throws -> AnalyticsStreamTokenResponse {
        try await transport.api("POST", path(domain) + "/live/token")
    }
}

extension OblienClient {
    public var analytics: AnalyticsAPI { AnalyticsAPI(transport: transport) }
}
