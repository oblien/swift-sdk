// Models audited against oblien 2.8.0. Regenerate with scripts/generate-platform-models.cjs.
import Foundation

public struct AnalyticsOverview: Codable, Sendable {
    @APINumber public var `requests`: Double
    @APINumber public var `bandwidthIn`: Double
    @APINumber public var `bandwidthOut`: Double

    public init(`requests`: Double,
                `bandwidthIn`: Double,
                `bandwidthOut`: Double) {
        self.`requests` = `requests`
        self.`bandwidthIn` = `bandwidthIn`
        self.`bandwidthOut` = `bandwidthOut`
    }

    enum CodingKeys: String, CodingKey {
        case `requests` = "requests"
        case `bandwidthIn` = "bandwidth_in"
        case `bandwidthOut` = "bandwidth_out"
    }
}

public struct AnalyticsDomainSummary: Codable, Sendable {
    public var `domain`: String
    @APINumber public var `requests`: Double
    @APINumber public var `bandwidthIn`: Double
    @APINumber public var `bandwidthOut`: Double

    public init(`domain`: String,
                `requests`: Double,
                `bandwidthIn`: Double,
                `bandwidthOut`: Double) {
        self.`domain` = `domain`
        self.`requests` = `requests`
        self.`bandwidthIn` = `bandwidthIn`
        self.`bandwidthOut` = `bandwidthOut`
    }

    enum CodingKeys: String, CodingKey {
        case `domain` = "domain"
        case `requests` = "requests"
        case `bandwidthIn` = "bandwidth_in"
        case `bandwidthOut` = "bandwidth_out"
    }
}

public struct AnalyticsHomeSummaryTotals: Codable, Sendable {
    @APINumber public var `requests`: Double
    @APINumber public var `bandwidthIn`: Double
    @APINumber public var `bandwidthOut`: Double
    @APINumber public var `domainCount`: Int

    public init(`requests`: Double,
                `bandwidthIn`: Double,
                `bandwidthOut`: Double,
                `domainCount`: Int) {
        self.`requests` = `requests`
        self.`bandwidthIn` = `bandwidthIn`
        self.`bandwidthOut` = `bandwidthOut`
        self.`domainCount` = `domainCount`
    }

    enum CodingKeys: String, CodingKey {
        case `requests` = "requests"
        case `bandwidthIn` = "bandwidth_in"
        case `bandwidthOut` = "bandwidth_out"
        case `domainCount` = "domain_count"
    }
}

public struct AnalyticsHomeSummary: Codable, Sendable {
    public var `domains`: [AnalyticsDomainSummary]
    public var `totals`: AnalyticsHomeSummaryTotals

    public init(`domains`: [AnalyticsDomainSummary],
                `totals`: AnalyticsHomeSummaryTotals) {
        self.`domains` = `domains`
        self.`totals` = `totals`
    }

    enum CodingKeys: String, CodingKey {
        case `domains` = "domains"
        case `totals` = "totals"
    }
}

public struct AnalyticsBucket: Codable, Sendable {
    @APINumber public var `timestamp`: Double
    @APINumber public var `requests`: Double
    @APINumber public var `bandwidthIn`: Double
    @APINumber public var `bandwidthOut`: Double
    @APINumber public var `responseTimeSum`: Double
    @APINumber public var `uniqueVisitors`: Double
    public var `countries`: [String: Double]

    public init(`timestamp`: Double,
                `requests`: Double,
                `bandwidthIn`: Double,
                `bandwidthOut`: Double,
                `responseTimeSum`: Double,
                `uniqueVisitors`: Double,
                `countries`: [String: Double]) {
        self.`timestamp` = `timestamp`
        self.`requests` = `requests`
        self.`bandwidthIn` = `bandwidthIn`
        self.`bandwidthOut` = `bandwidthOut`
        self.`responseTimeSum` = `responseTimeSum`
        self.`uniqueVisitors` = `uniqueVisitors`
        self.`countries` = `countries`
    }

    enum CodingKeys: String, CodingKey {
        case `timestamp` = "timestamp"
        case `requests` = "requests"
        case `bandwidthIn` = "bandwidth_in"
        case `bandwidthOut` = "bandwidth_out"
        case `responseTimeSum` = "response_time_sum"
        case `uniqueVisitors` = "unique_visitors"
        case `countries` = "countries"
    }
}

public struct AnalyticsTimeseriesParams: Codable, Sendable {
    @APIOptionalNumber public var `from`: Double?
    @APIOptionalNumber public var `to`: Double?
    /// Accepted values: 'minute' | 'hour' | 'day'.
    public var `interval`: String?

    public init(`from`: Double? = nil,
                `to`: Double? = nil,
                `interval`: String? = nil) {
        self.`from` = `from`
        self.`to` = `to`
        self.`interval` = `interval`
    }

    enum CodingKeys: String, CodingKey {
        case `from` = "from"
        case `to` = "to"
        case `interval` = "interval"
    }
}

public struct AnalyticsTimeseriesResponseMeta: Codable, Sendable {
    @APINumber public var `from`: Double
    @APINumber public var `to`: Double
    public var `interval`: String
    @APINumber public var `count`: Int

    public init(`from`: Double,
                `to`: Double,
                `interval`: String,
                `count`: Int) {
        self.`from` = `from`
        self.`to` = `to`
        self.`interval` = `interval`
        self.`count` = `count`
    }

    enum CodingKeys: String, CodingKey {
        case `from` = "from"
        case `to` = "to"
        case `interval` = "interval"
        case `count` = "count"
    }
}

public struct AnalyticsTimeseriesResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: [AnalyticsBucket]
    public var `meta`: AnalyticsTimeseriesResponseMeta

    public init(`success`: Bool,
                `data`: [AnalyticsBucket],
                `meta`: AnalyticsTimeseriesResponseMeta) {
        self.`success` = `success`
        self.`data` = `data`
        self.`meta` = `meta`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
        case `meta` = "meta"
    }
}

public struct AnalyticsGeoEntry: Codable, Sendable {
    public var `code`: String
    @APINumber public var `count`: Int
    @APINumber public var `pct`: Double

    public init(`code`: String,
                `count`: Int,
                `pct`: Double) {
        self.`code` = `code`
        self.`count` = `count`
        self.`pct` = `pct`
    }

    enum CodingKeys: String, CodingKey {
        case `code` = "code"
        case `count` = "count"
        case `pct` = "pct"
    }
}

public struct AnalyticsGeoParams: Codable, Sendable {
    @APIOptionalNumber public var `from`: Double?
    @APIOptionalNumber public var `to`: Double?

    public init(`from`: Double? = nil,
                `to`: Double? = nil) {
        self.`from` = `from`
        self.`to` = `to`
    }

    enum CodingKeys: String, CodingKey {
        case `from` = "from"
        case `to` = "to"
    }
}

public struct AnalyticsGeoResponseData: Codable, Sendable {
    @APINumber public var `total`: Int
    public var `countries`: [AnalyticsGeoEntry]

    public init(`total`: Int,
                `countries`: [AnalyticsGeoEntry]) {
        self.`total` = `total`
        self.`countries` = `countries`
    }

    enum CodingKeys: String, CodingKey {
        case `total` = "total"
        case `countries` = "countries"
    }
}

public struct AnalyticsGeoResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: AnalyticsGeoResponseData

    public init(`success`: Bool,
                `data`: AnalyticsGeoResponseData) {
        self.`success` = `success`
        self.`data` = `data`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
    }
}

public struct AnalyticsRequestEntry: Codable, Sendable {
    public var `ip`: String
    public var `timestamp`: String
    public var `date`: String
    public var `method`: String
    public var `status`: String
    public var `uri`: String
    public var `ua`: String
    public var `reqSize`: String
    public var `resSize`: String
    public var `reqTime`: String

    public init(`ip`: String,
                `timestamp`: String,
                `date`: String,
                `method`: String,
                `status`: String,
                `uri`: String,
                `ua`: String,
                `reqSize`: String,
                `resSize`: String,
                `reqTime`: String) {
        self.`ip` = `ip`
        self.`timestamp` = `timestamp`
        self.`date` = `date`
        self.`method` = `method`
        self.`status` = `status`
        self.`uri` = `uri`
        self.`ua` = `ua`
        self.`reqSize` = `reqSize`
        self.`resSize` = `resSize`
        self.`reqTime` = `reqTime`
    }

    enum CodingKeys: String, CodingKey {
        case `ip` = "ip"
        case `timestamp` = "timestamp"
        case `date` = "date"
        case `method` = "method"
        case `status` = "status"
        case `uri` = "uri"
        case `ua` = "ua"
        case `reqSize` = "req_size"
        case `resSize` = "res_size"
        case `reqTime` = "req_time"
    }
}

public struct AnalyticsRequestsParams: Codable, Sendable {
    @APIOptionalNumber public var `limit`: Int?

    public init(`limit`: Int? = nil) {
        self.`limit` = `limit`
    }

    enum CodingKeys: String, CodingKey {
        case `limit` = "limit"
    }
}

public struct AnalyticsRequestsResponseMeta: Codable, Sendable {
    @APINumber public var `count`: Int

    public init(`count`: Int) {
        self.`count` = `count`
    }

    enum CodingKeys: String, CodingKey {
        case `count` = "count"
    }
}

public struct AnalyticsRequestsResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: [AnalyticsRequestEntry]
    public var `meta`: AnalyticsRequestsResponseMeta

    public init(`success`: Bool,
                `data`: [AnalyticsRequestEntry],
                `meta`: AnalyticsRequestsResponseMeta) {
        self.`success` = `success`
        self.`data` = `data`
        self.`meta` = `meta`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
        case `meta` = "meta"
    }
}

public struct AnalyticsStreamTokenResponseData: Codable, Sendable {
    public var `token`: String
    @APINumber public var `expiresIn`: Double
    public var `streamUrl`: String
    public var `usage`: String

    public init(`token`: String,
                `expiresIn`: Double,
                `streamUrl`: String,
                `usage`: String) {
        self.`token` = `token`
        self.`expiresIn` = `expiresIn`
        self.`streamUrl` = `streamUrl`
        self.`usage` = `usage`
    }

    enum CodingKeys: String, CodingKey {
        case `token` = "token"
        case `expiresIn` = "expires_in"
        case `streamUrl` = "stream_url"
        case `usage` = "usage"
    }
}

public struct AnalyticsStreamTokenResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: AnalyticsStreamTokenResponseData

    public init(`success`: Bool,
                `data`: AnalyticsStreamTokenResponseData) {
        self.`success` = `success`
        self.`data` = `data`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
    }
}
