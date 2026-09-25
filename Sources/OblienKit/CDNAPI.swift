import Foundation

public struct CdnUploadInput: Sendable {
    public var data: Data
    public var filename: String
    public var contentType: String?
    public init(data: Data, filename: String, contentType: String? = nil) {
        self.data = data; self.filename = filename; self.contentType = contentType
    }
}

/// Omit a cap to leave it unchanged; pass `.null` to inherit the account default.
public struct CdnCapsPatch: Codable, Sendable {
    public var cdnMaxBytes: JSONField<Int>?
    public var cdnMonthlyBytes: JSONField<Int>?
    public init(cdnMaxBytes: JSONField<Int>? = nil, cdnMonthlyBytes: JSONField<Int>? = nil) {
        self.cdnMaxBytes = cdnMaxBytes; self.cdnMonthlyBytes = cdnMonthlyBytes
    }
    enum CodingKeys: String, CodingKey { case cdnMaxBytes = "cdn_max_bytes", cdnMonthlyBytes = "cdn_monthly_bytes" }
}

public struct CDNAPI: Sendable {
    let transport: Transport
    public var domains: CDNDomainsAPI { CDNDomainsAPI(transport: transport) }

    public func token(_ params: CdnTokenParams = .init()) async throws -> CdnTokenResponse {
        try await transport.api("POST", "/cdn/token", body: APIJSON.encode(params))
    }
    public func adminToken(_ params: CdnTokenParams = .init()) async throws -> CdnTokenResponse {
        try await transport.api("POST", "/cdn/token/admin", body: APIJSON.encode(params))
    }
    public func upload(_ file: CdnUploadInput, _ params: CdnUploadParams = .init()) async throws -> CdnUploadResponse {
        let form = try multipart([file], field: "file")
        let token = try await uploadToken(params)
        return try await edge("POST", "/", token: token, body: form.data, contentType: form.contentType)
    }
    public func uploadMany(_ files: [CdnUploadInput], _ params: CdnUploadParams = .init()) async throws -> CdnUploadManyResponse {
        let form = try multipart(files, field: "files")
        let token = try await uploadToken(params)
        return try await edge("POST", "/multiple", token: token, body: form.data, contentType: form.contentType)
    }
    public func processUrls(_ params: CdnProcessUrlsParams) async throws -> CdnProcessUrlsResponse {
        let credential: String
        if let token = params.token { credential = token }
        else { credential = try await token(.init(namespace: params.namespace, variants: params.variants, metadata: params.metadata)).token }
        struct Body: Encodable { let urls: [String]; let maxBatch: Int?; let concurrency: Int? }
        return try await edge("POST", "/process-urls", token: credential,
                              body: APIJSON.encode(Body(urls: params.urls, maxBatch: params.maxBatch, concurrency: params.concurrency)))
    }
    public func getLimits(token: String? = nil, namespace: String? = nil) async throws -> CdnLimitsResponse {
        let credential = try await uploadToken(.init(namespace: namespace, token: token))
        return try await edge("GET", "/limits", token: credential)
    }
    public func getVariantOptions(token: String? = nil, namespace: String? = nil) async throws -> CdnVariantOptionsResponse {
        let credential = try await uploadToken(.init(namespace: namespace, token: token))
        return try await edge("GET", "/variants", token: credential)
    }
    public func list(_ params: CdnListParams = .init()) async throws -> CdnListResponse {
        try await transport.api("GET", "/cdn/files", query: APIJSON.query(params))
    }
    public func tags(_ params: CdnTagsParams = .init()) async throws -> CdnTagsResponse {
        try await transport.api("GET", "/cdn/tags", query: APIJSON.query(params))
    }
    public func stats(_ params: CdnStatsParams = .init()) async throws -> CdnStatsResponse {
        try await transport.api("GET", "/cdn/stats", query: APIJSON.query(params))
    }
    public func usage(_ params: CdnUsageParams = .init()) async throws -> CdnUsageResponse {
        try await transport.api("GET", "/cdn/usage", query: APIJSON.query(params))
    }
    public func usageSeries(_ params: CdnUsageSeriesParams = .init()) async throws -> CdnUsageSeriesResponse {
        try await transport.api("GET", "/cdn/usage/series", query: APIJSON.query(params))
    }
    public func quotaDefaults() async throws -> CdnQuotaDefaultsResponse { try await transport.api("GET", "/cdn/quota-defaults") }
    public func setQuotaDefaults(_ caps: CdnCapsPatch) async throws -> CdnQuotaDefaultsResponse {
        try await transport.api("PUT", "/cdn/quota-defaults", body: APIJSON.encode(caps))
    }
    public func namespaces(_ params: CdnNamespacesParams = .init()) async throws -> CdnNamespacesResponse {
        try await transport.api("GET", "/cdn/namespaces", query: APIJSON.query(params))
    }
    public func setNamespaceQuota(_ namespace: String, _ caps: CdnCapsPatch) async throws -> CdnNamespaceQuotaResponse {
        try await transport.api("PUT", "/cdn/namespaces/quota", body: APIJSON.encode(caps, merging: ["namespace": .string(namespace)]))
    }
    public func get(_ fileId: String) async throws -> CdnFileResponse { try await transport.api("GET", "/cdn/files/\(fileId.pathEscaped)") }
    public func get(_ fileId: Int) async throws -> CdnFileResponse { try await get(String(fileId)) }
    @discardableResult public func delete(_ fileId: String) async throws -> APIResponse {
        try await transport.api("DELETE", "/cdn/files/\(fileId.pathEscaped)")
    }
    @discardableResult public func delete(_ fileId: Int) async throws -> APIResponse { try await delete(String(fileId)) }
    @discardableResult public func restore(_ fileId: String) async throws -> APIResponse {
        try await transport.api("POST", "/cdn/files/\(fileId.pathEscaped)/restore")
    }
    @discardableResult public func restore(_ fileId: Int) async throws -> APIResponse { try await restore(String(fileId)) }

    private func uploadToken(_ params: CdnUploadParams) async throws -> String {
        if let token = params.token { return token }
        return try await token(.init(namespace: params.namespace, variants: params.variants, tag: params.tag, metadata: params.metadata)).token
    }
    private func edge<Response: Decodable>(_ method: String, _ path: String, token: String,
                                           body: Data? = nil, contentType: String? = nil) async throws -> Response {
        let data = try await transport.request(method, path, body: body, host: .cdn, bearer: token, contentType: contentType)
        return try APIJSON.decode(Response.self, data)
    }
    private func multipart(_ files: [CdnUploadInput], field: String) throws -> (data: Data, contentType: String) {
        guard !files.isEmpty else {
            throw OblienError(kind: .validation, status: nil, code: nil, message: "Choose at least one file.", details: nil)
        }
        let boundary = "Oblien-\(UUID().uuidString)"
        var data = Data()
        func append(_ text: String) { data.append(Data(text.utf8)) }
        for file in files {
            let mime = file.contentType ?? "application/octet-stream"
            guard !file.filename.isEmpty, !file.filename.contains(where: { $0 == "\r" || $0 == "\n" }),
                  !mime.contains(where: { $0 == "\r" || $0 == "\n" }) else {
                throw OblienError(kind: .validation, status: nil, code: nil, message: "Invalid upload filename or content type.", details: nil)
            }
            let filename = file.filename.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
            append("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(field)\"; filename=\"\(filename)\"\r\nContent-Type: \(mime)\r\n\r\n")
            data.append(file.data)
            append("\r\n")
        }
        append("--\(boundary)--\r\n")
        return (data, "multipart/form-data; boundary=\(boundary)")
    }
}

public struct CDNDomainsAPI: Sendable {
    let transport: Transport
    public func add(_ params: CdnDomainAddParams) async throws -> CdnDomainAddResponse {
        try await transport.api("POST", "/cdn/domains", body: APIJSON.encode(params))
    }
    public func list() async throws -> CdnDomainListResponse { try await transport.api("GET", "/cdn/domains") }
    public func remove(_ domain: String) async throws -> CdnDomainRemoveResponse {
        try await transport.api("DELETE", "/cdn/domains/\(domain.pathEscaped)")
    }
}

extension OblienClient { public var cdn: CDNAPI { CDNAPI(transport: transport) } }
