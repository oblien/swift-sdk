import Foundation

struct ExecRequest: Encodable {
    let cmd: [String]
    let timeoutSeconds: Int?
    let execMode: ExecMode?
    let ttlSeconds: Int?
    let keepLogs: Bool?
}

extension SearchAPI {
    public func content(_ params: ContentSearchParams) async throws -> ContentSearchResponse {
        let query = try searchQuery(params)
        return try APIJSON.decode(ContentSearchResponse.self, await runtime.perform("GET", "/files/search", query: query))
    }
    public func files(_ params: FileSearchParams) async throws -> FileSearchResponse {
        let query = try searchQuery(params)
        return try APIJSON.decode(FileSearchResponse.self, await runtime.perform("GET", "/files/search/files", query: query))
    }
    public func status() async throws -> SearchStatusResponse {
        try APIJSON.decode(SearchStatusResponse.self, await runtime.perform("GET", "/files/search/init"))
    }
    public func install() async throws -> SearchInitResponse {
        try APIJSON.decode(SearchInitResponse.self, await runtime.perform("POST", "/files/search/init"))
    }
    private func searchQuery<Params: Encodable>(_ params: Params) throws -> [String: String?] {
        let wireNames = ["query": "q", "caseSensitive": "case_sensitive", "wholeWord": "whole_word", "maxResults": "max_results",
                         "contextLines": "context_lines", "fileTypes": "file_types", "includeHidden": "include_hidden",
                         "noGitignore": "no_gitignore", "ignorePatterns": "ignore_patterns"]
        return Dictionary(uniqueKeysWithValues: try APIJSON.query(params).map { (wireNames[$0.key] ?? $0.key, $0.value) })
    }
}

extension WatcherAPI {
    private struct Envelope: Decodable { let watcher: WatcherInfo }
    public func create(_ params: WatcherCreateParams) async throws -> WatcherInfo {
        try APIJSON.decode(Envelope.self, await runtime.perform("POST", "/watchers", body: APIJSON.encode(params))).watcher
    }
    public func listWatchers() async throws -> [WatcherInfo] {
        try APIJSON.decode(WatcherListResponse.self, await runtime.perform("GET", "/watchers")).watchers
    }
    public func getWatcher(_ id: String) async throws -> WatcherInfo {
        try APIJSON.decode(Envelope.self, await runtime.perform("GET", "/watchers/\(id.pathEscaped)")).watcher
    }
}

extension TerminalAPI {
    public func scrollbackInfo(_ id: Int, bytes: Int? = nil) async throws -> TerminalScrollbackResponse {
        try APIJSON.decode(TerminalScrollbackResponse.self,
            await runtime.perform("GET", "/terminals/\(id)/scrollback", query: ["bytes": bytes.map(String.init)]))
    }
}

extension NetworkAPI {
    public func setCustomProxy(_ proxy: NetworkUpdateParams.CustomProxy) async throws -> Network {
        try await update(.init(outboundMode: "custom", customProxy: proxy))
    }
    public func clearCustomProxy() async throws -> Network { try await update(.init(outboundMode: "managed")) }
}

extension WorkloadsAPI {
    public func statsStream(_ id: String) -> AsyncThrowingStream<JSONValue, Error> {
        jsonEventStream(transport: transport, path: "/workspace/\(workspaceId.pathEscaped)/workloads/\(id.pathEscaped)/stats/stream")
    }
    public func allStatsStream() -> AsyncThrowingStream<JSONValue, Error> {
        jsonEventStream(transport: transport, path: "/workspace/\(workspaceId.pathEscaped)/workloads/stats/stream")
    }
}

func jsonEventStream(transport: Transport, path: String) -> AsyncThrowingStream<JSONValue, Error> {
    AsyncThrowingStream(bufferingPolicy: .bufferingNewest(128)) { continuation in
        let task = Task {
            do {
                let bytes = try await transport.openStream("GET", path)
                for try await event in sseEvents(bytes) where event.data != "[DONE]" {
                    continuation.yield(try APIJSON.decode(JSONValue.self, Data(event.data.utf8)))
                }
                continuation.finish()
            } catch { continuation.finish(throwing: error) }
        }
        continuation.onTermination = { _ in task.cancel() }
    }
}
