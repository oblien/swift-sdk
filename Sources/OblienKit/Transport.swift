import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// HTTP transport: applies auth, retries 5xx/429 with backoff, refreshes a bearer session
/// once on 401, and maps non-2xx bodies to `OblienError`. Returns the raw response `Data`;
/// resource decoding lives in the resource APIs.
actor Transport {
    enum Host { case management, runtime, cdn }

    let config: OblienConfiguration
    let session: URLSession
    private var runtimes: [String: WeakRuntime] = [:]
    private var tokenLifetime: TimeInterval?

    init(config: OblienConfiguration, session: URLSession = .shared) {
        self.config = config
        self.session = session
    }

    func request(
        _ method: String,
        _ path: String,
        query: [String: String?] = [:],
        body: Data? = nil,
        host: Host = .management,
        bearer: String? = nil,
        contentType: String? = nil,
        retrySafe: Bool = false,
        timeout: TimeInterval? = nil,
        headers: [String: String] = [:]
    ) async throws -> Data {
        var attempt = 0
        var triedRefresh = false

        while true {
            try Task.checkCancellation()
            var req = try await buildRequest(method, path, query: query, body: body,
                                             host: host, bearer: bearer, contentType: contentType,
                                             forceRefresh: triedRefresh, headers: headers)
            if let timeout { req.timeoutInterval = timeout }
            let data: Data
            let http: HTTPURLResponse
            do {
                let delegate = HTTPRedirectDelegate(policy: .follow)
                let (d, resp) = try await session.data(for: req, delegate: delegate)
                guard let h = resp as? HTTPURLResponse else {
                    throw OblienError(kind: .transport, status: nil, code: nil, message: "No HTTP response", details: nil)
                }
                data = d
                http = h
            } catch let error as OblienError {
                throw error
            } catch {
                try Task.checkCancellation()
                throw OblienError(kind: .transport, status: nil, code: nil,
                                  message: (error as NSError).localizedDescription, details: nil)
            }

            if (200..<300).contains(http.statusCode) {
                struct ResultFlag: Decodable { let success: Bool? }
                if (try? JSONDecoder().decode(ResultFlag.self, from: data))?.success != false { return data }
            }

            let apiError = Self.decodeError(data, status: http.statusCode)

            // Bearer session: clear + re-mint once on 401.
            if http.statusCode == 401, bearer == nil, case .bearerSession = config.auth, !triedRefresh {
                triedRefresh = true
                continue
            }

            // A lost mutation response may already have created or started something. Only
            // reads and explicitly idempotent requests can be replayed after a server failure.
            let canRetry = retrySafe || ["GET", "HEAD", "OPTIONS"].contains(method.uppercased())
            if canRetry, apiError.isRetryable, attempt < config.maxRetries {
                attempt += 1
                let backoff = min(pow(2.0, Double(attempt - 1)), 10)
                try await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
                continue
            }

            throw apiError
        }
    }

    /// Raw request that returns the upstream status + body **verbatim** — it does NOT map non-2xx
    /// to `OblienError`, retry, or refresh. For transparent passthroughs (the workspace `/proxy`
    /// reverse-proxy) where the upstream's own status code is meaningful and must reach the caller.
    /// Throws only on a genuine transport failure (no HTTP response).
    func rawRequest(
        _ method: String,
        _ path: String,
        query: [String: String?] = [:],
        body: Data? = nil,
        host: Host = .management,
        bearer: String? = nil,
        contentType: String? = nil,
        headers: [String: String] = [:],
        redirect: HTTPRedirectPolicy = .follow
    ) async throws -> (status: Int, data: Data, headers: [String: String]) {
        let req = try await buildRequest(method, path, query: query, body: body,
                                         host: host, bearer: bearer, contentType: contentType,
                                         forceRefresh: false, headers: headers)
        do {
            let delegate = HTTPRedirectDelegate(policy: redirect)
            let (data, resp) = try await session.data(for: req, delegate: delegate)
            try Task.checkCancellation()
            if let error = delegate.redirectFailure { throw error }
            guard let http = resp as? HTTPURLResponse else {
                throw OblienError(kind: .transport, status: nil, code: nil, message: "No HTTP response", details: nil)
            }
            let responseHeaders = Dictionary(uniqueKeysWithValues: http.allHeaderFields.map { (String(describing: $0.key), String(describing: $0.value)) })
            return (http.statusCode, data, responseHeaders)
        } catch let error as OblienError {
            throw error
        } catch {
            try Task.checkCancellation()
            throw OblienError(kind: .transport, status: nil, code: nil,
                              message: (error as NSError).localizedDescription, details: nil)
        }
    }

    /// A delegate-backed stream delivers bytes as they arrive. Management sessions refresh
    /// once on 401; runtime callers own their separate JWT refresh. Streams are never replayed
    /// after delivering data, and cancellation also cancels a request waiting for headers.
    func openStream(
        _ method: String, _ path: String, query: [String: String?] = [:],
        body: Data? = nil, host: Host = .management, bearer: String? = nil,
        headers: [String: String] = [:], accept: String = "text/event-stream"
    ) async throws -> AsyncThrowingStream<Data, Error> {
        try await openStreamResponse(method, path, query: query, body: body, host: host,
                                     bearer: bearer, headers: headers, accept: accept).chunks
    }

    func openStreamResponse(
        _ method: String, _ path: String, query: [String: String?] = [:],
        body: Data? = nil, host: Host = .management, bearer: String? = nil,
        headers: [String: String] = [:], accept: String = "text/event-stream",
        mapErrors: Bool = true, redirect: HTTPRedirectPolicy = .follow
    ) async throws -> HTTPBodyStream {
        for attempt in 0..<2 {
            try Task.checkCancellation()
            let request = try await buildRequest(method, path, query: query, body: body,
                host: host, bearer: bearer, contentType: nil, accept: accept, forceRefresh: attempt > 0, headers: headers)
            do { return try await openStreamRequest(request, mapErrors: mapErrors, redirect: redirect) }
            catch let error as OblienError where error.status == 401 && attempt == 0 && bearer == nil {
                if case .bearerSession = config.auth { continue }
                throw error
            }
        }
        throw OblienError(kind: .authentication, status: 401, code: nil, message: "Sign in again to reconnect.", details: nil)
    }

    private func openStreamRequest(_ request: URLRequest, mapErrors: Bool,
                                   redirect: HTTPRedirectPolicy) async throws -> HTTPBodyStream {
        var request = request
        request.timeoutInterval = 3600
        request.setValue("identity", forHTTPHeaderField: "Accept-Encoding")
        let (stream, continuation) = AsyncThrowingStream<Data, Error>.makeStream()
        let holder = StreamHolder()
        continuation.onTermination = { _ in holder.cancel() }
        return try await withTaskCancellationHandler {
            let response = try await withCheckedThrowingContinuation { (headers: CheckedContinuation<HTTPURLResponse, Error>) in
                // The URLSession delegate queue serializes these variables.
                var settled = false
                var status: Int?
                var errorBody = Data()
                let bridge = StreamBridge(redirect: redirect, onResponse: { response in
                    status = response.statusCode
                    if (!mapErrors || (200..<300).contains(response.statusCode)), !settled {
                        settled = true
                        headers.resume(returning: response)
                    }
                }, onData: { data in
                    if let status, !mapErrors || (200..<300).contains(status) { continuation.yield(data) }
                    else if errorBody.count < 65_536 { errorBody.append(data.prefix(65_536 - errorBody.count)) }
                }, onDone: { error in
                    let failure: Error?
                    if mapErrors, let status, !(200..<300).contains(status) { failure = Self.decodeError(errorBody, status: status) }
                    else { failure = error }
                    if !settled {
                        settled = true
                        headers.resume(throwing: failure ?? CancellationError())
                    }
                    continuation.finish(throwing: failure)
                    holder.cancel()
                })
                let configuration = session.configuration
                configuration.timeoutIntervalForRequest = 3600
                configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
                let streamingSession = URLSession(configuration: configuration, delegate: bridge, delegateQueue: nil)
                holder.start(session: streamingSession, task: streamingSession.dataTask(with: request))
            }
            try Task.checkCancellation()
            return HTTPBodyStream(chunks: stream, status: response.statusCode,
                totalBytes: response.expectedContentLength >= 0 ? response.expectedContentLength : nil,
                headers: Dictionary(uniqueKeysWithValues: response.allHeaderFields.map { (String(describing: $0.key), String(describing: $0.value)) }))
        } onCancel: { holder.cancel() }
    }

    func buildRequest(
        _ method: String, _ path: String, query: [String: String?],
        body: Data?, host: Host, bearer: String?, contentType: String?,
        accept: String = "application/json", forceRefresh: Bool, headers: [String: String] = [:]
    ) async throws -> URLRequest {
        let baseURL: URL
        switch host {
        case .management: baseURL = config.baseURL
        case .runtime: baseURL = config.runtimeURL
        case .cdn:
            guard bearer != nil else {
                throw OblienError(kind: .authentication, status: nil, code: nil, message: "A CDN-scoped token is required.", details: nil)
            }
            baseURL = config.cdnURL
        }
        let base = baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard var comps = URLComponents(string: base + path) else {
            throw OblienError(kind: .badURL, status: nil, code: nil, message: "Bad URL: \(base + path)", details: nil)
        }
        let items = query.compactMap { key, value in value.map { URLQueryItem(name: key, value: $0) } }
        if !items.isEmpty { comps.queryItems = items }
        guard let url = comps.url else {
            throw OblienError(kind: .badURL, status: nil, code: nil, message: "Bad URL: \(base + path)", details: nil)
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        for (key, value) in headers { req.setValue(value, forHTTPHeaderField: key) }
        if case .management = host, let accountId = config.accountId {
            guard accountId.range(of: "^[1-9][0-9]{0,14}$", options: .regularExpression) != nil else {
                throw OblienError(kind: .validation, status: nil, code: nil, message: "Invalid account ID.", details: nil)
            }
            req.setValue(accountId, forHTTPHeaderField: "X-Oblien-Account")
        }
        if req.value(forHTTPHeaderField: "Accept") == nil { req.setValue(accept, forHTTPHeaderField: "Accept") }
        if let body {
            req.httpBody = body
            req.setValue(contentType ?? req.value(forHTTPHeaderField: "Content-Type") ?? "application/json", forHTTPHeaderField: "Content-Type")
        }

        if let bearer {
            req.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        } else {
            switch config.auth {
            case .apiKey(let clientId, let clientSecret):
                req.setValue(clientId, forHTTPHeaderField: "X-Client-ID")
                req.setValue(clientSecret, forHTTPHeaderField: "X-Client-Secret")
            case .scopedToken(let token):
                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            case .bearerSession(let provider):
                let token = try await provider(forceRefresh)
                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        return req
    }

    func runtime(_ workspaceId: String, force: Bool, enableIfNeeded: Bool) async -> RuntimeClient {
        let key = workspaceId + (enableIfNeeded ? ":enable" : ":read")
        let runtime: RuntimeClient
        runtimes = runtimes.filter { $0.value.value != nil }
        if let cached = runtimes[key]?.value { runtime = cached }
        else {
            runtime = RuntimeClient(transport: self, workspaceId: workspaceId, runtimeURL: config.runtimeURL,
                ttl: tokenLifetime ?? config.runtimeTokenTTL, enableIfNeeded: enableIfNeeded)
            runtimes[key] = WeakRuntime(runtime)
        }
        if force { await runtime.invalidate() }
        return runtime
    }

    func invalidateRuntime(_ workspaceId: String? = nil) async {
        let keys = runtimes.keys.filter { workspaceId == nil || $0 == workspaceId! + ":enable" || $0 == workspaceId! + ":read" }
        for key in keys { if let runtime = runtimes[key]?.value { await runtime.invalidate() } }
    }

    func setTokenTTL(_ seconds: TimeInterval) async throws {
        guard seconds > 0, seconds.isFinite else {
            throw OblienError(kind: .validation, status: nil, code: nil, message: "Token lifetime must be positive and finite.", details: nil)
        }
        tokenLifetime = seconds
        for cached in runtimes.values { if let runtime = cached.value { await runtime.setTokenTTL(seconds) } }
    }

    static func decodeError(_ data: Data, status: Int) -> OblienError {
        struct Body: Decodable { let error: String?; let code: String?; let message: String?; let details: JSONValue? }
        let body = try? OblienJSON.decoder().decode(Body.self, from: data)
        // Unknown error bodies may contain credentials or proxy internals. Preserve only
        // the API's explicit error fields, never an entire JSON/HTML response.
        let message = body?.message ?? body?.error
        return OblienError(
            kind: OblienError.kind(forStatus: status, code: body?.code),
            status: status,
            code: body?.code,
            message: (message?.isEmpty == false) ? message : nil,
            details: body?.details
        )
    }
}

/// Avoid a transport → runtime → transport retain cycle. A retained runtime owns its
/// credential cache, and overlapping handles share the same runtime while it is in use.
private final class WeakRuntime: @unchecked Sendable {
    weak var value: RuntimeClient?
    init(_ value: RuntimeClient) { self.value = value }
}

/// Owns the streaming URLSession + task so `openStream` can cancel/invalidate on termination.
/// A dedicated (non-shared) session is required because it must carry a delegate.
final class StreamHolder: @unchecked Sendable {
    private let lock = NSLock()
    private var session: URLSession?
    private var task: URLSessionDataTask?
    private var cancelled = false
    func start(session: URLSession, task: URLSessionDataTask) {
        lock.lock()
        if cancelled {
            lock.unlock()
            task.resume()
            task.cancel()
            session.invalidateAndCancel()
            return
        }
        self.session = session; self.task = task
        task.resume()
        lock.unlock()
    }
    func cancel() {
        lock.lock()
        cancelled = true
        let session = self.session; let task = self.task
        self.session = nil; self.task = nil
        lock.unlock()
        task?.cancel()
        session?.invalidateAndCancel()
    }
}

/// Bridges `URLSessionDataDelegate` byte callbacks into the closures `openStream` wires to an
/// `AsyncThrowingStream`. The delegate methods are invoked serially on the session's delegate
/// queue, so the closures never run concurrently with each other.
private final class StreamBridge: HTTPRedirectDelegate, URLSessionDataDelegate, @unchecked Sendable {
    private let onResponse: (HTTPURLResponse) -> Void
    private let onData: (Data) -> Void
    private let onDone: (Error?) -> Void

    init(redirect: HTTPRedirectPolicy, onResponse: @escaping (HTTPURLResponse) -> Void,
         onData: @escaping (Data) -> Void,
         onDone: @escaping (Error?) -> Void) {
        self.onResponse = onResponse
        self.onData = onData
        self.onDone = onDone
        super.init(policy: redirect)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard redirectFailure == nil else { completionHandler(.cancel); return }
        if let http = response as? HTTPURLResponse { onResponse(http) }
        completionHandler(.allow) // let the body stream in via didReceive(data)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        onData(data) // fires the instant bytes arrive — the whole point vs. AsyncBytes
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = redirectFailure {
            onDone(error)
        } else if let ns = error as NSError?, ns.domain == NSURLErrorDomain, ns.code == NSURLErrorCancelled {
            onDone(nil)
        } else {
            onDone(error)
        }
    }
}
