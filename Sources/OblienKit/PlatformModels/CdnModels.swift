// Models audited against oblien 2.4.0. Regenerate with scripts/generate-platform-models.cjs.
import Foundation

/// Open string enum; preserves new server values.
public struct CdnTokenScope: RawRepresentable, Codable, Sendable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(from decoder: Decoder) throws { rawValue = try decoder.singleValueContainer().decode(String.self) }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public static let `user` = Self(rawValue: "user")
    public static let `admin` = Self(rawValue: "admin")
}

public struct CdnFile: Codable, Sendable {
    @APINumber public var `id`: Int
    public var `userId`: String
    public var `namespace`: String?
    public var `tag`: String?
    public var `filename`: String
    public var `originalFilename`: String?
    public var `originalUrl`: String?
    public var `filePath`: String
    public var `cdnUrl`: String
    @APINumber public var `size`: Int
    public var `mimeType`: String
    public var `variants`: [JSONValue]
    public var `metadata`: [String: JSONValue]
    /// Accepted values: 'upload' | 'url'.
    public var `uploadType`: String
    @APIBoolean public var `isDeleted`: Bool
    public var `deletedAt`: String?
    public var `createdAt`: String
    public var `updatedAt`: String

    public init(`id`: Int,
                `userId`: String,
                `namespace`: String? = nil,
                `tag`: String? = nil,
                `filename`: String,
                `originalFilename`: String? = nil,
                `originalUrl`: String? = nil,
                `filePath`: String,
                `cdnUrl`: String,
                `size`: Int,
                `mimeType`: String,
                `variants`: [JSONValue],
                `metadata`: [String: JSONValue],
                `uploadType`: String,
                `isDeleted`: Bool,
                `deletedAt`: String? = nil,
                `createdAt`: String,
                `updatedAt`: String) {
        self.`id` = `id`
        self.`userId` = `userId`
        self.`namespace` = `namespace`
        self.`tag` = `tag`
        self.`filename` = `filename`
        self.`originalFilename` = `originalFilename`
        self.`originalUrl` = `originalUrl`
        self.`filePath` = `filePath`
        self.`cdnUrl` = `cdnUrl`
        self.`size` = `size`
        self.`mimeType` = `mimeType`
        self.`variants` = `variants`
        self.`metadata` = `metadata`
        self.`uploadType` = `uploadType`
        self.`isDeleted` = `isDeleted`
        self.`deletedAt` = `deletedAt`
        self.`createdAt` = `createdAt`
        self.`updatedAt` = `updatedAt`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `userId` = "user_id"
        case `namespace` = "namespace"
        case `tag` = "tag"
        case `filename` = "filename"
        case `originalFilename` = "original_filename"
        case `originalUrl` = "original_url"
        case `filePath` = "file_path"
        case `cdnUrl` = "cdn_url"
        case `size` = "size"
        case `mimeType` = "mime_type"
        case `variants` = "variants"
        case `metadata` = "metadata"
        case `uploadType` = "upload_type"
        case `isDeleted` = "is_deleted"
        case `deletedAt` = "deleted_at"
        case `createdAt` = "created_at"
        case `updatedAt` = "updated_at"
    }
}

public struct CdnVariantSpec: Codable, Sendable {
    @APIOptionalNumber public var `width`: Int?
    @APIOptionalNumber public var `height`: Int?
    /// Accepted values: 'cover' | 'contain' | 'fill' | 'inside' | 'outside'.
    public var `fit`: String?
    @APIOptionalNumber public var `quality`: Int?
    @APIOptionalNumber public var `blur`: Double?
    /// Accepted values: 'jpeg' | 'png' | 'webp'.
    public var `format`: String?
    @APIOptionalBoolean public var `withoutEnlargement`: Bool?

    public init(`width`: Int? = nil,
                `height`: Int? = nil,
                `fit`: String? = nil,
                `quality`: Int? = nil,
                `blur`: Double? = nil,
                `format`: String? = nil,
                `withoutEnlargement`: Bool? = nil) {
        self.`width` = `width`
        self.`height` = `height`
        self.`fit` = `fit`
        self.`quality` = `quality`
        self.`blur` = `blur`
        self.`format` = `format`
        self.`withoutEnlargement` = `withoutEnlargement`
    }

    enum CodingKeys: String, CodingKey {
        case `width` = "width"
        case `height` = "height"
        case `fit` = "fit"
        case `quality` = "quality"
        case `blur` = "blur"
        case `format` = "format"
        case `withoutEnlargement` = "withoutEnlargement"
    }
}

public struct CdnVariantOptionsOptimizeOriginal: Codable, Sendable {
    @APIOptionalNumber public var `maxBytes`: Int?
    @APIOptionalNumber public var `quality`: Int?
    /// Accepted values: 'jpeg' | 'png' | 'webp'.
    public var `format`: String?

    public init(`maxBytes`: Int? = nil,
                `quality`: Int? = nil,
                `format`: String? = nil) {
        self.`maxBytes` = `maxBytes`
        self.`quality` = `quality`
        self.`format` = `format`
    }

    enum CodingKeys: String, CodingKey {
        case `maxBytes` = "maxBytes"
        case `quality` = "quality"
        case `format` = "format"
    }
}

public struct CdnVariantOptions: Codable, Sendable {
    public var `variantNames`: [String]?
    public var `customVariants`: [String: CdnVariantSpec]?
    @APIOptionalBoolean public var `keepOriginal`: Bool?
    public var `primary`: String?
    public var `optimizeOriginal`: CdnVariantOptionsOptimizeOriginal?
    @APIOptionalNumber public var `ttl`: Int?
    @APIOptionalNumber public var `expireAt`: Double?
    @APIOptionalNumber public var `maxBytes`: Int?
    public var additionalProperties: [String: JSONValue]

    public init(`variantNames`: [String]? = nil,
                `customVariants`: [String: CdnVariantSpec]? = nil,
                `keepOriginal`: Bool? = nil,
                `primary`: String? = nil,
                `optimizeOriginal`: CdnVariantOptionsOptimizeOriginal? = nil,
                `ttl`: Int? = nil,
                `expireAt`: Double? = nil,
                `maxBytes`: Int? = nil,
                additionalProperties: [String: JSONValue] = [:]) {
        self.`variantNames` = `variantNames`
        self.`customVariants` = `customVariants`
        self.`keepOriginal` = `keepOriginal`
        self.`primary` = `primary`
        self.`optimizeOriginal` = `optimizeOriginal`
        self.`ttl` = `ttl`
        self.`expireAt` = `expireAt`
        self.`maxBytes` = `maxBytes`
        self.additionalProperties = additionalProperties
    }

    enum CodingKeys: String, CodingKey {
        case `variantNames` = "variantNames"
        case `customVariants` = "customVariants"
        case `keepOriginal` = "keepOriginal"
        case `primary` = "primary"
        case `optimizeOriginal` = "optimizeOriginal"
        case `ttl` = "ttl"
        case `expireAt` = "expireAt"
        case `maxBytes` = "maxBytes"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        `variantNames` = try c.decodeIfPresent([String].self, forKey: .`variantNames`)
        `customVariants` = try c.decodeIfPresent([String: CdnVariantSpec].self, forKey: .`customVariants`)
        `keepOriginal` = try c.decode(APIOptionalBoolean.self, forKey: .`keepOriginal`).wrappedValue
        `primary` = try c.decodeIfPresent(String.self, forKey: .`primary`)
        `optimizeOriginal` = try c.decodeIfPresent(CdnVariantOptionsOptimizeOriginal.self, forKey: .`optimizeOriginal`)
        `ttl` = try c.decode(APIOptionalNumber<Int>.self, forKey: .`ttl`).wrappedValue
        `expireAt` = try c.decode(APIOptionalNumber<Double>.self, forKey: .`expireAt`).wrappedValue
        `maxBytes` = try c.decode(APIOptionalNumber<Int>.self, forKey: .`maxBytes`).wrappedValue
        additionalProperties = try [String: JSONValue](from: decoder).filter { CodingKeys(rawValue: $0.key) == nil }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(`variantNames`, forKey: .`variantNames`)
        try c.encodeIfPresent(`customVariants`, forKey: .`customVariants`)
        try c.encodeIfPresent(`keepOriginal`, forKey: .`keepOriginal`)
        try c.encodeIfPresent(`primary`, forKey: .`primary`)
        try c.encodeIfPresent(`optimizeOriginal`, forKey: .`optimizeOriginal`)
        try c.encodeIfPresent(`ttl`, forKey: .`ttl`)
        try c.encodeIfPresent(`expireAt`, forKey: .`expireAt`)
        try c.encodeIfPresent(`maxBytes`, forKey: .`maxBytes`)
        var extra = encoder.container(keyedBy: APIKey.self)
        for (key, value) in additionalProperties where CodingKeys(rawValue: key) == nil {
            try extra.encode(value, forKey: APIKey(key))
        }
    }
}

public struct CdnTokenParams: Codable, Sendable {
    public var `namespace`: String?
    public var `variants`: CdnVariantOptions?
    public var `tag`: String?
    public var `metadata`: [String: JSONValue]?

    public init(`namespace`: String? = nil,
                `variants`: CdnVariantOptions? = nil,
                `tag`: String? = nil,
                `metadata`: [String: JSONValue]? = nil) {
        self.`namespace` = `namespace`
        self.`variants` = `variants`
        self.`tag` = `tag`
        self.`metadata` = `metadata`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `variants` = "variants"
        case `tag` = "tag"
        case `metadata` = "metadata"
    }
}

public struct CdnTokenResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `token`: String
    public var `scope`: CdnTokenScope
    public var `permissions`: [String]
    public var `namespace`: String?
    public var `expiresIn`: String
    public var `message`: String?

    public init(`success`: Bool,
                `token`: String,
                `scope`: CdnTokenScope,
                `permissions`: [String],
                `namespace`: String? = nil,
                `expiresIn`: String,
                `message`: String? = nil) {
        self.`success` = `success`
        self.`token` = `token`
        self.`scope` = `scope`
        self.`permissions` = `permissions`
        self.`namespace` = `namespace`
        self.`expiresIn` = `expiresIn`
        self.`message` = `message`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `token` = "token"
        case `scope` = "scope"
        case `permissions` = "permissions"
        case `namespace` = "namespace"
        case `expiresIn` = "expiresIn"
        case `message` = "message"
    }
}

public struct CdnUploadParams: Codable, Sendable {
    public var `namespace`: String?
    public var `token`: String?
    public var `variants`: CdnVariantOptions?
    public var `tag`: String?
    public var `metadata`: [String: JSONValue]?

    public init(`namespace`: String? = nil,
                `token`: String? = nil,
                `variants`: CdnVariantOptions? = nil,
                `tag`: String? = nil,
                `metadata`: [String: JSONValue]? = nil) {
        self.`namespace` = `namespace`
        self.`token` = `token`
        self.`variants` = `variants`
        self.`tag` = `tag`
        self.`metadata` = `metadata`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `token` = "token"
        case `variants` = "variants"
        case `tag` = "tag"
        case `metadata` = "metadata"
    }
}

public struct CdnUploadVariant: Codable, Sendable {
    public var `variant`: String
    public var `url`: String
    @APIOptionalNumber public var `size`: Int?
    @APIOptionalNumber public var `width`: Int?
    @APIOptionalNumber public var `height`: Int?

    public init(`variant`: String,
                `url`: String,
                `size`: Int? = nil,
                `width`: Int? = nil,
                `height`: Int? = nil) {
        self.`variant` = `variant`
        self.`url` = `url`
        self.`size` = `size`
        self.`width` = `width`
        self.`height` = `height`
    }

    enum CodingKeys: String, CodingKey {
        case `variant` = "variant"
        case `url` = "url"
        case `size` = "size"
        case `width` = "width"
        case `height` = "height"
    }
}

public struct CdnUploadResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `fileId`: String
    public var `url`: String
    public var `filename`: String
    @APINumber public var `size`: Int
    public var `mime`: String
    public var `tag`: String?
    public var `variants`: [CdnUploadVariant]
    @APIBoolean public var `recorded`: Bool
    public var `expiresAt`: JSONValue?

    public init(`success`: Bool,
                `fileId`: String,
                `url`: String,
                `filename`: String,
                `size`: Int,
                `mime`: String,
                `tag`: String? = nil,
                `variants`: [CdnUploadVariant],
                `recorded`: Bool,
                `expiresAt`: JSONValue? = nil) {
        self.`success` = `success`
        self.`fileId` = `fileId`
        self.`url` = `url`
        self.`filename` = `filename`
        self.`size` = `size`
        self.`mime` = `mime`
        self.`tag` = `tag`
        self.`variants` = `variants`
        self.`recorded` = `recorded`
        self.`expiresAt` = `expiresAt`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `fileId` = "file_id"
        case `url` = "url"
        case `filename` = "filename"
        case `size` = "size"
        case `mime` = "mime"
        case `tag` = "tag"
        case `variants` = "variants"
        case `recorded` = "recorded"
        case `expiresAt` = "expires_at"
    }
}

public struct CdnUploadManyResponseFilesItem: Codable, Sendable {
    public var `fileId`: String
    public var `originalFilename`: String?
    public var `url`: String
    public var `filename`: String
    @APINumber public var `size`: Int
    public var `mime`: String
    public var `variants`: [CdnUploadVariant]
    public var `expiresAt`: JSONValue?

    public init(`fileId`: String,
                `originalFilename`: String? = nil,
                `url`: String,
                `filename`: String,
                `size`: Int,
                `mime`: String,
                `variants`: [CdnUploadVariant],
                `expiresAt`: JSONValue? = nil) {
        self.`fileId` = `fileId`
        self.`originalFilename` = `originalFilename`
        self.`url` = `url`
        self.`filename` = `filename`
        self.`size` = `size`
        self.`mime` = `mime`
        self.`variants` = `variants`
        self.`expiresAt` = `expiresAt`
    }

    enum CodingKeys: String, CodingKey {
        case `fileId` = "file_id"
        case `originalFilename` = "originalFilename"
        case `url` = "url"
        case `filename` = "filename"
        case `size` = "size"
        case `mime` = "mime"
        case `variants` = "variants"
        case `expiresAt` = "expires_at"
    }
}

public struct CdnUploadManyResponseInvalidFilesItem: Codable, Sendable {
    public var `originalFilename`: String
    public var `error`: String

    public init(`originalFilename`: String,
                `error`: String) {
        self.`originalFilename` = `originalFilename`
        self.`error` = `error`
    }

    enum CodingKeys: String, CodingKey {
        case `originalFilename` = "originalFilename"
        case `error` = "error"
    }
}

public struct CdnUploadManyResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `files`: [CdnUploadManyResponseFilesItem]
    public var `invalidFiles`: [CdnUploadManyResponseInvalidFilesItem]?
    @APINumber public var `totalCount`: Int
    @APIBoolean public var `recorded`: Bool

    public init(`success`: Bool,
                `files`: [CdnUploadManyResponseFilesItem],
                `invalidFiles`: [CdnUploadManyResponseInvalidFilesItem]? = nil,
                `totalCount`: Int,
                `recorded`: Bool) {
        self.`success` = `success`
        self.`files` = `files`
        self.`invalidFiles` = `invalidFiles`
        self.`totalCount` = `totalCount`
        self.`recorded` = `recorded`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `files` = "files"
        case `invalidFiles` = "invalidFiles"
        case `totalCount` = "totalCount"
        case `recorded` = "recorded"
    }
}

public struct CdnProcessUrlsParams: Codable, Sendable {
    public var `urls`: [String]
    @APIOptionalNumber public var `maxBatch`: Int?
    @APIOptionalNumber public var `concurrency`: Int?
    public var `namespace`: String?
    public var `token`: String?
    public var `variants`: CdnVariantOptions?
    public var `metadata`: [String: JSONValue]?

    public init(`urls`: [String],
                `maxBatch`: Int? = nil,
                `concurrency`: Int? = nil,
                `namespace`: String? = nil,
                `token`: String? = nil,
                `variants`: CdnVariantOptions? = nil,
                `metadata`: [String: JSONValue]? = nil) {
        self.`urls` = `urls`
        self.`maxBatch` = `maxBatch`
        self.`concurrency` = `concurrency`
        self.`namespace` = `namespace`
        self.`token` = `token`
        self.`variants` = `variants`
        self.`metadata` = `metadata`
    }

    enum CodingKeys: String, CodingKey {
        case `urls` = "urls"
        case `maxBatch` = "maxBatch"
        case `concurrency` = "concurrency"
        case `namespace` = "namespace"
        case `token` = "token"
        case `variants` = "variants"
        case `metadata` = "metadata"
    }
}

public struct CdnProcessUrlsResponseFilesItem: Codable, Sendable {
    public var `fileId`: String
    public var `originalUrl`: String?
    public var `url`: String
    public var `filename`: String
    @APINumber public var `size`: Int
    public var `mime`: String
    public var `variants`: [CdnUploadVariant]
    public var `expiresAt`: JSONValue?

    public init(`fileId`: String,
                `originalUrl`: String? = nil,
                `url`: String,
                `filename`: String,
                `size`: Int,
                `mime`: String,
                `variants`: [CdnUploadVariant],
                `expiresAt`: JSONValue? = nil) {
        self.`fileId` = `fileId`
        self.`originalUrl` = `originalUrl`
        self.`url` = `url`
        self.`filename` = `filename`
        self.`size` = `size`
        self.`mime` = `mime`
        self.`variants` = `variants`
        self.`expiresAt` = `expiresAt`
    }

    enum CodingKeys: String, CodingKey {
        case `fileId` = "file_id"
        case `originalUrl` = "originalUrl"
        case `url` = "url"
        case `filename` = "filename"
        case `size` = "size"
        case `mime` = "mime"
        case `variants` = "variants"
        case `expiresAt` = "expires_at"
    }
}

public struct CdnProcessUrlsResponseErrorsItem: Codable, Sendable {
    public var `url`: String
    public var `error`: String
    @APIOptionalNumber public var `index`: Double?

    public init(`url`: String,
                `error`: String,
                `index`: Double? = nil) {
        self.`url` = `url`
        self.`error` = `error`
        self.`index` = `index`
    }

    enum CodingKeys: String, CodingKey {
        case `url` = "url"
        case `error` = "error"
        case `index` = "index"
    }
}

public struct CdnProcessUrlsResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `files`: [CdnProcessUrlsResponseFilesItem]
    public var `errors`: [CdnProcessUrlsResponseErrorsItem]?
    @APINumber public var `totalProcessed`: Double
    @APINumber public var `totalErrors`: Double
    @APIBoolean public var `recorded`: Bool

    public init(`success`: Bool,
                `files`: [CdnProcessUrlsResponseFilesItem],
                `errors`: [CdnProcessUrlsResponseErrorsItem]? = nil,
                `totalProcessed`: Double,
                `totalErrors`: Double,
                `recorded`: Bool) {
        self.`success` = `success`
        self.`files` = `files`
        self.`errors` = `errors`
        self.`totalProcessed` = `totalProcessed`
        self.`totalErrors` = `totalErrors`
        self.`recorded` = `recorded`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `files` = "files"
        case `errors` = "errors"
        case `totalProcessed` = "totalProcessed"
        case `totalErrors` = "totalErrors"
        case `recorded` = "recorded"
    }
}

public struct CdnLimitsResponse: Codable, Sendable {
    public var `limits`: [String: Double]
    @APINumber public var `totalLimit`: Double
    @APINumber public var `maxFiles`: Int

    public init(`limits`: [String: Double],
                `totalLimit`: Double,
                `maxFiles`: Int) {
        self.`limits` = `limits`
        self.`totalLimit` = `totalLimit`
        self.`maxFiles` = `maxFiles`
    }

    enum CodingKeys: String, CodingKey {
        case `limits` = "limits"
        case `totalLimit` = "totalLimit"
        case `maxFiles` = "maxFiles"
    }
}

public struct CdnVariantOptionsResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `defaultVariants`: [String: JSONValue]
    public var `customVariantSchema`: [String: JSONValue]

    public init(`success`: Bool,
                `defaultVariants`: [String: JSONValue],
                `customVariantSchema`: [String: JSONValue]) {
        self.`success` = `success`
        self.`defaultVariants` = `defaultVariants`
        self.`customVariantSchema` = `customVariantSchema`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `defaultVariants` = "defaultVariants"
        case `customVariantSchema` = "customVariantSchema"
    }
}

public struct CdnListParams: Codable, Sendable {
    @APIOptionalNumber public var `page`: Int?
    @APIOptionalNumber public var `limit`: Int?
    public var `namespace`: String?
    public var `tag`: String?
    @APIOptionalBoolean public var `includeDeleted`: Bool?
    /// Accepted values: 'upload' | 'url'.
    public var `uploadType`: String?
    /// Accepted values: 'created_at' | 'size' | 'filename'.
    public var `sortBy`: String?
    /// Accepted values: 'ASC' | 'DESC'.
    public var `sortOrder`: String?

    public init(`page`: Int? = nil,
                `limit`: Int? = nil,
                `namespace`: String? = nil,
                `tag`: String? = nil,
                `includeDeleted`: Bool? = nil,
                `uploadType`: String? = nil,
                `sortBy`: String? = nil,
                `sortOrder`: String? = nil) {
        self.`page` = `page`
        self.`limit` = `limit`
        self.`namespace` = `namespace`
        self.`tag` = `tag`
        self.`includeDeleted` = `includeDeleted`
        self.`uploadType` = `uploadType`
        self.`sortBy` = `sortBy`
        self.`sortOrder` = `sortOrder`
    }

    enum CodingKeys: String, CodingKey {
        case `page` = "page"
        case `limit` = "limit"
        case `namespace` = "namespace"
        case `tag` = "tag"
        case `includeDeleted` = "include_deleted"
        case `uploadType` = "upload_type"
        case `sortBy` = "sort_by"
        case `sortOrder` = "sort_order"
    }
}

public struct CdnTagsParams: Codable, Sendable {
    public var `namespace`: String?

    public init(`namespace`: String? = nil) {
        self.`namespace` = `namespace`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
    }
}

public struct CdnTagsResponseData: Codable, Sendable {
    public var `namespace`: String?
    public var `tags`: [String]

    public init(`namespace`: String? = nil,
                `tags`: [String]) {
        self.`namespace` = `namespace`
        self.`tags` = `tags`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `tags` = "tags"
    }
}

public struct CdnTagsResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: CdnTagsResponseData

    public init(`success`: Bool,
                `data`: CdnTagsResponseData) {
        self.`success` = `success`
        self.`data` = `data`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
    }
}

public struct CdnPagination: Codable, Sendable {
    @APINumber public var `page`: Int
    @APINumber public var `limit`: Int
    @APINumber public var `total`: Int
    @APINumber public var `totalPages`: Double
    @APIBoolean public var `hasMore`: Bool

    public init(`page`: Int,
                `limit`: Int,
                `total`: Int,
                `totalPages`: Double,
                `hasMore`: Bool) {
        self.`page` = `page`
        self.`limit` = `limit`
        self.`total` = `total`
        self.`totalPages` = `totalPages`
        self.`hasMore` = `hasMore`
    }

    enum CodingKeys: String, CodingKey {
        case `page` = "page"
        case `limit` = "limit"
        case `total` = "total"
        case `totalPages` = "totalPages"
        case `hasMore` = "hasMore"
    }
}

public struct CdnListResponseData: Codable, Sendable {
    public var `files`: [CdnFile]
    public var `pagination`: CdnPagination

    public init(`files`: [CdnFile],
                `pagination`: CdnPagination) {
        self.`files` = `files`
        self.`pagination` = `pagination`
    }

    enum CodingKeys: String, CodingKey {
        case `files` = "files"
        case `pagination` = "pagination"
    }
}

public struct CdnListResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: CdnListResponseData

    public init(`success`: Bool,
                `data`: CdnListResponseData) {
        self.`success` = `success`
        self.`data` = `data`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
    }
}

public struct CdnStatsParams: Codable, Sendable {
    public var `namespace`: String?

    public init(`namespace`: String? = nil) {
        self.`namespace` = `namespace`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
    }
}

public struct CdnStats: Codable, Sendable {
    @APINumber public var `totalFiles`: Double
    @APINumber public var `totalSize`: Int
    @APINumber public var `activeFiles`: Double
    @APINumber public var `activeSize`: Int
    @APINumber public var `uploadedFiles`: Double
    @APINumber public var `urlFiles`: Double

    public init(`totalFiles`: Double,
                `totalSize`: Int,
                `activeFiles`: Double,
                `activeSize`: Int,
                `uploadedFiles`: Double,
                `urlFiles`: Double) {
        self.`totalFiles` = `totalFiles`
        self.`totalSize` = `totalSize`
        self.`activeFiles` = `activeFiles`
        self.`activeSize` = `activeSize`
        self.`uploadedFiles` = `uploadedFiles`
        self.`urlFiles` = `urlFiles`
    }

    enum CodingKeys: String, CodingKey {
        case `totalFiles` = "totalFiles"
        case `totalSize` = "totalSize"
        case `activeFiles` = "activeFiles"
        case `activeSize` = "activeSize"
        case `uploadedFiles` = "uploadedFiles"
        case `urlFiles` = "urlFiles"
    }
}

public struct CdnStatsResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: CdnStats

    public init(`success`: Bool,
                `data`: CdnStats) {
        self.`success` = `success`
        self.`data` = `data`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
    }
}

public struct CdnUsageParams: Codable, Sendable {
    public var `namespace`: String?
    public var `period`: String?

    public init(`namespace`: String? = nil,
                `period`: String? = nil) {
        self.`namespace` = `namespace`
        self.`period` = `period`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `period` = "period"
    }
}

public struct CdnCaps: Codable, Sendable {
    public var `cdnMaxBytes`: JSONField<Int>
    public var `cdnMonthlyBytes`: JSONField<Int>

    public init(`cdnMaxBytes`: JSONField<Int>,
                `cdnMonthlyBytes`: JSONField<Int>) {
        self.`cdnMaxBytes` = `cdnMaxBytes`
        self.`cdnMonthlyBytes` = `cdnMonthlyBytes`
    }

    enum CodingKeys: String, CodingKey {
        case `cdnMaxBytes` = "cdn_max_bytes"
        case `cdnMonthlyBytes` = "cdn_monthly_bytes"
    }
}

public struct CdnUsageResponseDataIngest: Codable, Sendable {
    @APINumber public var `bytes`: Int
    @APINumber public var `files`: Double

    public init(`bytes`: Int,
                `files`: Double) {
        self.`bytes` = `bytes`
        self.`files` = `files`
    }

    enum CodingKeys: String, CodingKey {
        case `bytes` = "bytes"
        case `files` = "files"
    }
}

public struct CdnUsageResponseDataActive: Codable, Sendable {
    @APINumber public var `bytes`: Int
    @APINumber public var `files`: Double

    public init(`bytes`: Int,
                `files`: Double) {
        self.`bytes` = `bytes`
        self.`files` = `files`
    }

    enum CodingKeys: String, CodingKey {
        case `bytes` = "bytes"
        case `files` = "files"
    }
}

public struct CdnUsageResponseData: Codable, Sendable {
    public var `namespace`: String?
    public var `period`: String
    public var `ingest`: CdnUsageResponseDataIngest
    public var `active`: CdnUsageResponseDataActive
    public var `limits`: CdnCaps?
    public var `namespaceLimits`: CdnCaps?
    public var `defaults`: CdnCaps?

    public init(`namespace`: String? = nil,
                `period`: String,
                `ingest`: CdnUsageResponseDataIngest,
                `active`: CdnUsageResponseDataActive,
                `limits`: CdnCaps? = nil,
                `namespaceLimits`: CdnCaps? = nil,
                `defaults`: CdnCaps? = nil) {
        self.`namespace` = `namespace`
        self.`period` = `period`
        self.`ingest` = `ingest`
        self.`active` = `active`
        self.`limits` = `limits`
        self.`namespaceLimits` = `namespaceLimits`
        self.`defaults` = `defaults`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `period` = "period"
        case `ingest` = "ingest"
        case `active` = "active"
        case `limits` = "limits"
        case `namespaceLimits` = "namespace_limits"
        case `defaults` = "defaults"
    }
}

public struct CdnUsageResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: CdnUsageResponseData

    public init(`success`: Bool,
                `data`: CdnUsageResponseData) {
        self.`success` = `success`
        self.`data` = `data`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
    }
}

public struct CdnQuotaDefaultsResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: CdnCaps

    public init(`success`: Bool,
                `data`: CdnCaps) {
        self.`success` = `success`
        self.`data` = `data`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
    }
}

public struct CdnNamespaceRow: Codable, Sendable {
    public var `namespace`: String
    @APINumber public var `files`: Double
    @APINumber public var `activeBytes`: Int
    public var `limits`: CdnCaps
    public var `override`: CdnCaps
    @APIBoolean public var `hasOverride`: Bool

    public init(`namespace`: String,
                `files`: Double,
                `activeBytes`: Int,
                `limits`: CdnCaps,
                `override`: CdnCaps,
                `hasOverride`: Bool) {
        self.`namespace` = `namespace`
        self.`files` = `files`
        self.`activeBytes` = `activeBytes`
        self.`limits` = `limits`
        self.`override` = `override`
        self.`hasOverride` = `hasOverride`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `files` = "files"
        case `activeBytes` = "active_bytes"
        case `limits` = "limits"
        case `override` = "override"
        case `hasOverride` = "has_override"
    }
}

public struct CdnNamespacesParams: Codable, Sendable {
    public var `search`: String?
    @APIOptionalNumber public var `page`: Int?
    @APIOptionalNumber public var `limit`: Int?

    public init(`search`: String? = nil,
                `page`: Int? = nil,
                `limit`: Int? = nil) {
        self.`search` = `search`
        self.`page` = `page`
        self.`limit` = `limit`
    }

    enum CodingKeys: String, CodingKey {
        case `search` = "search"
        case `page` = "page"
        case `limit` = "limit"
    }
}

public struct CdnNamespacesResponseData: Codable, Sendable {
    public var `defaults`: CdnCaps
    public var `namespaces`: [CdnNamespaceRow]
    public var `pagination`: CdnPagination

    public init(`defaults`: CdnCaps,
                `namespaces`: [CdnNamespaceRow],
                `pagination`: CdnPagination) {
        self.`defaults` = `defaults`
        self.`namespaces` = `namespaces`
        self.`pagination` = `pagination`
    }

    enum CodingKeys: String, CodingKey {
        case `defaults` = "defaults"
        case `namespaces` = "namespaces"
        case `pagination` = "pagination"
    }
}

public struct CdnNamespacesResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: CdnNamespacesResponseData

    public init(`success`: Bool,
                `data`: CdnNamespacesResponseData) {
        self.`success` = `success`
        self.`data` = `data`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
    }
}

public struct CdnNamespaceQuotaResponseData: Codable, Sendable {
    public var `namespace`: String
    @APIOptionalNumber public var `cdnMaxBytes`: Int?
    @APIOptionalNumber public var `cdnMonthlyBytes`: Int?

    public init(`namespace`: String,
                `cdnMaxBytes`: Int? = nil,
                `cdnMonthlyBytes`: Int? = nil) {
        self.`namespace` = `namespace`
        self.`cdnMaxBytes` = `cdnMaxBytes`
        self.`cdnMonthlyBytes` = `cdnMonthlyBytes`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `cdnMaxBytes` = "cdn_max_bytes"
        case `cdnMonthlyBytes` = "cdn_monthly_bytes"
    }
}

public struct CdnNamespaceQuotaResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: CdnNamespaceQuotaResponseData

    public init(`success`: Bool,
                `data`: CdnNamespaceQuotaResponseData) {
        self.`success` = `success`
        self.`data` = `data`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
    }
}

public struct CdnUsageSeriesParams: Codable, Sendable {
    public var `namespace`: String?
    /// Accepted values: 'day' | 'month'.
    public var `interval`: String?
    @APIOptionalNumber public var `days`: Double?
    @APIOptionalNumber public var `months`: Double?

    public init(`namespace`: String? = nil,
                `interval`: String? = nil,
                `days`: Double? = nil,
                `months`: Double? = nil) {
        self.`namespace` = `namespace`
        self.`interval` = `interval`
        self.`days` = `days`
        self.`months` = `months`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `interval` = "interval"
        case `days` = "days"
        case `months` = "months"
    }
}

public struct CdnUsageSeriesResponseDataSeriesItem: Codable, Sendable {
    public var `bucket`: String
    @APINumber public var `bytes`: Int
    @APINumber public var `files`: Double

    public init(`bucket`: String,
                `bytes`: Int,
                `files`: Double) {
        self.`bucket` = `bucket`
        self.`bytes` = `bytes`
        self.`files` = `files`
    }

    enum CodingKeys: String, CodingKey {
        case `bucket` = "bucket"
        case `bytes` = "bytes"
        case `files` = "files"
    }
}

public struct CdnUsageSeriesResponseData: Codable, Sendable {
    public var `namespace`: String?
    /// Accepted values: 'day' | 'month'.
    public var `interval`: String
    public var `from`: String
    public var `to`: String
    public var `series`: [CdnUsageSeriesResponseDataSeriesItem]

    public init(`namespace`: String? = nil,
                `interval`: String,
                `from`: String,
                `to`: String,
                `series`: [CdnUsageSeriesResponseDataSeriesItem]) {
        self.`namespace` = `namespace`
        self.`interval` = `interval`
        self.`from` = `from`
        self.`to` = `to`
        self.`series` = `series`
    }

    enum CodingKeys: String, CodingKey {
        case `namespace` = "namespace"
        case `interval` = "interval"
        case `from` = "from"
        case `to` = "to"
        case `series` = "series"
    }
}

public struct CdnUsageSeriesResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: CdnUsageSeriesResponseData

    public init(`success`: Bool,
                `data`: CdnUsageSeriesResponseData) {
        self.`success` = `success`
        self.`data` = `data`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
    }
}

public struct CdnFileResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `data`: CdnFile
    public var `error`: String?

    public init(`success`: Bool,
                `data`: CdnFile,
                `error`: String? = nil) {
        self.`success` = `success`
        self.`data` = `data`
        self.`error` = `error`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `data` = "data"
        case `error` = "error"
    }
}

public struct CdnDomainAddParams: Codable, Sendable {
    public var `domain`: String

    public init(`domain`: String) {
        self.`domain` = `domain`
    }

    enum CodingKeys: String, CodingKey {
        case `domain` = "domain"
    }
}

public typealias CdnDomainListParams = [String: JSONValue]

public struct CdnDomainSsl: Codable, Sendable {
    public var `status`: String
    public var `expiresAt`: String?
    public var `error`: String?

    public init(`status`: String,
                `expiresAt`: String? = nil,
                `error`: String? = nil) {
        self.`status` = `status`
        self.`expiresAt` = `expiresAt`
        self.`error` = `error`
    }

    enum CodingKeys: String, CodingKey {
        case `status` = "status"
        case `expiresAt` = "expiresAt"
        case `error` = "error"
    }
}

public struct CdnDomainDnsRequiredRecordsCname: Codable, Sendable {
    public var `host`: String
    public var `target`: String

    public init(`host`: String,
                `target`: String) {
        self.`host` = `host`
        self.`target` = `target`
    }

    enum CodingKeys: String, CodingKey {
        case `host` = "host"
        case `target` = "target"
    }
}

public struct CdnDomainDnsRequiredRecordsTxt: Codable, Sendable {
    public var `host`: String
    public var `value`: String

    public init(`host`: String,
                `value`: String) {
        self.`host` = `host`
        self.`value` = `value`
    }

    enum CodingKeys: String, CodingKey {
        case `host` = "host"
        case `value` = "value"
    }
}

public struct CdnDomainDnsRequiredRecords: Codable, Sendable {
    public var `cname`: CdnDomainDnsRequiredRecordsCname?
    public var `txt`: CdnDomainDnsRequiredRecordsTxt?

    public init(`cname`: CdnDomainDnsRequiredRecordsCname? = nil,
                `txt`: CdnDomainDnsRequiredRecordsTxt? = nil) {
        self.`cname` = `cname`
        self.`txt` = `txt`
    }

    enum CodingKeys: String, CodingKey {
        case `cname` = "cname"
        case `txt` = "txt"
    }
}

public struct CdnDomainDns: Codable, Sendable {
    @APIOptionalBoolean public var `verified`: Bool?
    @APIOptionalBoolean public var `cname`: Bool?
    @APIOptionalBoolean public var `ownership`: Bool?
    public var `records`: [String: JSONValue]?
    public var `errors`: [String]?
    public var `requiredRecords`: CdnDomainDnsRequiredRecords?
    public var additionalProperties: [String: JSONValue]

    public init(`verified`: Bool? = nil,
                `cname`: Bool? = nil,
                `ownership`: Bool? = nil,
                `records`: [String: JSONValue]? = nil,
                `errors`: [String]? = nil,
                `requiredRecords`: CdnDomainDnsRequiredRecords? = nil,
                additionalProperties: [String: JSONValue] = [:]) {
        self.`verified` = `verified`
        self.`cname` = `cname`
        self.`ownership` = `ownership`
        self.`records` = `records`
        self.`errors` = `errors`
        self.`requiredRecords` = `requiredRecords`
        self.additionalProperties = additionalProperties
    }

    enum CodingKeys: String, CodingKey {
        case `verified` = "verified"
        case `cname` = "cname"
        case `ownership` = "ownership"
        case `records` = "records"
        case `errors` = "errors"
        case `requiredRecords` = "required_records"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        `verified` = try c.decode(APIOptionalBoolean.self, forKey: .`verified`).wrappedValue
        `cname` = try c.decode(APIOptionalBoolean.self, forKey: .`cname`).wrappedValue
        `ownership` = try c.decode(APIOptionalBoolean.self, forKey: .`ownership`).wrappedValue
        `records` = try c.decodeIfPresent([String: JSONValue].self, forKey: .`records`)
        `errors` = try c.decodeIfPresent([String].self, forKey: .`errors`)
        `requiredRecords` = try c.decodeIfPresent(CdnDomainDnsRequiredRecords.self, forKey: .`requiredRecords`)
        additionalProperties = try [String: JSONValue](from: decoder).filter { CodingKeys(rawValue: $0.key) == nil }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(`verified`, forKey: .`verified`)
        try c.encodeIfPresent(`cname`, forKey: .`cname`)
        try c.encodeIfPresent(`ownership`, forKey: .`ownership`)
        try c.encodeIfPresent(`records`, forKey: .`records`)
        try c.encodeIfPresent(`errors`, forKey: .`errors`)
        try c.encodeIfPresent(`requiredRecords`, forKey: .`requiredRecords`)
        var extra = encoder.container(keyedBy: APIKey.self)
        for (key, value) in additionalProperties where CodingKeys(rawValue: key) == nil {
            try extra.encode(value, forKey: APIKey(key))
        }
    }
}

public struct CdnDomainAddResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `domain`: String
    public var `host`: String
    public var `url`: String
    public var `ssl`: CdnDomainSsl
    public var `dns`: CdnDomainDns

    public init(`success`: Bool,
                `domain`: String,
                `host`: String,
                `url`: String,
                `ssl`: CdnDomainSsl,
                `dns`: CdnDomainDns) {
        self.`success` = `success`
        self.`domain` = `domain`
        self.`host` = `host`
        self.`url` = `url`
        self.`ssl` = `ssl`
        self.`dns` = `dns`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `domain` = "domain"
        case `host` = "host"
        case `url` = "url"
        case `ssl` = "ssl"
        case `dns` = "dns"
    }
}

public struct CdnDomain: Codable, Sendable {
    public var `domain`: String
    public var `namespace`: String?
    @APIBoolean public var `custom`: Bool
    public var `status`: String
    public var `createdAt`: String

    public init(`domain`: String,
                `namespace`: String? = nil,
                `custom`: Bool,
                `status`: String,
                `createdAt`: String) {
        self.`domain` = `domain`
        self.`namespace` = `namespace`
        self.`custom` = `custom`
        self.`status` = `status`
        self.`createdAt` = `createdAt`
    }

    enum CodingKeys: String, CodingKey {
        case `domain` = "domain"
        case `namespace` = "namespace"
        case `custom` = "custom"
        case `status` = "status"
        case `createdAt` = "createdAt"
    }
}

public struct CdnDomainListResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `domains`: [CdnDomain]

    public init(`success`: Bool,
                `domains`: [CdnDomain]) {
        self.`success` = `success`
        self.`domains` = `domains`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `domains` = "domains"
    }
}

public struct CdnDomainRemoveResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `removed`: String

    public init(`success`: Bool,
                `removed`: String) {
        self.`success` = `success`
        self.`removed` = `removed`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `removed` = "removed"
    }
}
