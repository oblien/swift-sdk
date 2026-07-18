import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// HTTP transport: applies auth, retries 5xx/429 with backoff, refreshes a bearer session
/// once on 401, and maps non-2xx bodies to `OblienError`. Returns the raw response `Data`;
/// resource decoding lives in the resource APIs.
actor Transport {
    enum Host { case management, runtime }

    let config: OblienConfiguration
    private let session: URLSession

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
        contentType: String? = nil
    ) async throws -> Data {
        var attempt = 0
        var triedRefresh = false

        while true {
            let req = try await buildRequest(method, path, query: query, body: body,
                                             host: host, bearer: bearer, contentType: contentType,
                                             forceRefresh: triedRefresh)
            let data: Data
            let http: HTTPURLResponse
            do {
                let (d, resp) = try await session.data(for: req)
                guard let h = resp as? HTTPURLResponse else {
                    throw OblienError(kind: .transport, status: nil, code: nil, message: "No HTTP response", details: nil)
                }
                data = d
                http = h
            } catch let error as OblienError {
                throw error
            } catch {
                throw OblienError(kind: .transport, status: nil, code: nil,
                                  message: (error as NSError).localizedDescription, details: nil)
            }

            if (200..<300).contains(http.statusCode) { return data }

            let apiError = Self.decodeError(data, status: http.statusCode)

            // Bearer session: clear + re-mint once on 401.
            if http.statusCode == 401, bearer == nil, case .bearerSession = config.auth, !triedRefresh {
                triedRefresh = true
                continue
            }

            // Retry transient failures with exponential backoff.
            if apiError.isRetryable, attempt < config.maxRetries {
                attempt += 1
                let backoff = min(pow(2.0, Double(attempt - 1)), 10)
                try? await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
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
        contentType: String? = nil
    ) async throws -> (status: Int, data: Data) {
        let req = try await buildRequest(method, path, query: query, body: body,
                                         host: host, bearer: bearer, contentType: contentType,
                                         forceRefresh: false)
        do {
            let (data, resp) = try await session.data(for: req)
            guard let http = resp as? HTTPURLResponse else {
                throw OblienError(kind: .transport, status: nil, code: nil, message: "No HTTP response", details: nil)
            }
            return (http.statusCode, data)
        } catch let error as OblienError {
            throw error
        } catch {
            throw OblienError(kind: .transport, status: nil, code: nil,
                              message: (error as NSError).localizedDescription, details: nil)
        }
    }

    /// Open a streaming response (SSE / NDJSON) as a live stream of response-body `Data` chunks.
    /// No retry; refresh-on-401 is the caller's job.
    ///
    /// Deliberately NOT `session.bytes(for:)`: URLSession's `AsyncBytes` has been observed to
    /// withhold the body of a long-lived / proxied response until the request COMPLETES — which is
    /// fatal to SSE (the whole turn arrives in one burst at the end). We use a `URLSessionDataDelegate`
    /// instead: `urlSession(_:dataTask:didReceive:)` fires the instant bytes come off the socket, so
    /// each `data:` frame is delivered live. This is the approach every production SSE client uses.
    func openStream(
        _ method: String, _ path: String, query: [String: String?] = [:],
        body: Data? = nil, host: Host = .management, bearer: String? = nil
    ) async throws -> AsyncThrowingStream<Data, Error> {
        var req = try await buildRequest(method, path, query: query, body: body,
                                         host: host, bearer: bearer, contentType: nil,
                                         accept: "text/event-stream", forceRefresh: false)
        req.timeoutInterval = 3600 // long-lived SSE — don't drop on the default 60s idle timeout
        // Opt out of gzip: intermediaries that honour it can buffer compressed frames, and we also
        // don't want URLSession's automatic decompression. Raw `text/event-stream` bytes only.
        req.setValue("identity", forHTTPHeaderField: "Accept-Encoding")

        let (stream, continuation) = AsyncThrowingStream<Data, Error>.makeStream()
        let holder = StreamHolder()

        // Await the response headers (so a non-2xx becomes an error, parity with the old path),
        // then hand back the live body stream. The delegate fires on its own serial queue.
        let http: HTTPURLResponse = try await withCheckedThrowingContinuation { cont in
            var settled = false // delegate callbacks are serialized, so this is race-free
            let bridge = StreamBridge(
                onResponse: { resp in
                    if !settled { settled = true; cont.resume(returning: resp) }
                },
                onData: { data in continuation.yield(data) },
                onDone: { err in
                    if let err {
                        if !settled { settled = true; cont.resume(throwing: err) }
                        continuation.finish(throwing: err)
                    } else {
                        continuation.finish()
                    }
                })
            let cfg = URLSessionConfiguration.default
            cfg.timeoutIntervalForRequest = 3600
            cfg.requestCachePolicy = .reloadIgnoringLocalCacheData
            let s = URLSession(configuration: cfg, delegate: bridge, delegateQueue: nil)
            holder.session = s
            holder.task = s.dataTask(with: req)
            holder.task?.resume()
        }

        guard (200..<300).contains(http.statusCode) else {
            holder.cancel()
            throw OblienError(kind: OblienError.kind(forStatus: http.statusCode, code: nil),
                              status: http.statusCode, code: nil, message: "Stream request failed", details: nil)
        }
        #if DEBUG
        let enc = http.value(forHTTPHeaderField: "Content-Encoding") ?? "identity"
        print("🌐 ◦ openStream \(path) — \(http.statusCode), Content-Encoding: \(enc), Content-Type: \(http.value(forHTTPHeaderField: "Content-Type") ?? "?")")
        #endif
        continuation.onTermination = { _ in holder.cancel() }
        return stream
    }

    private func buildRequest(
        _ method: String, _ path: String, query: [String: String?],
        body: Data?, host: Host, bearer: String?, contentType: String?,
        accept: String = "application/json", forceRefresh: Bool
    ) async throws -> URLRequest {
        let base = (host == .management ? config.baseURL : config.runtimeURL).absoluteString
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
        req.setValue(accept, forHTTPHeaderField: "Accept")
        if let body {
            req.httpBody = body
            req.setValue(contentType ?? "application/json", forHTTPHeaderField: "Content-Type")
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

    private static func decodeError(_ data: Data, status: Int) -> OblienError {
        struct Body: Decodable { let error: String?; let code: String?; let message: String?; let details: JSONValue? }
        let body = try? OblienJSON.decoder().decode(Body.self, from: data)
        let message = body?.message ?? body?.error ?? String(data: data, encoding: .utf8)
        return OblienError(
            kind: OblienError.kind(forStatus: status, code: body?.code),
            status: status,
            code: body?.code,
            message: (message?.isEmpty == false) ? message : nil,
            details: body?.details
        )
    }
}

/// Owns the streaming URLSession + task so `openStream` can cancel/invalidate on termination.
/// A dedicated (non-shared) session is required because it must carry a delegate.
private final class StreamHolder: @unchecked Sendable {
    var session: URLSession?
    var task: URLSessionDataTask?
    func cancel() {
        task?.cancel()
        session?.invalidateAndCancel() // releases the delegate; the session is single-use
        session = nil
        task = nil
    }
}

/// Bridges `URLSessionDataDelegate` byte callbacks into the closures `openStream` wires to an
/// `AsyncThrowingStream`. The delegate methods are invoked serially on the session's delegate
/// queue, so the closures never run concurrently with each other.
private final class StreamBridge: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    private let onResponse: (HTTPURLResponse) -> Void
    private let onData: (Data) -> Void
    private let onDone: (Error?) -> Void

    init(onResponse: @escaping (HTTPURLResponse) -> Void,
         onData: @escaping (Data) -> Void,
         onDone: @escaping (Error?) -> Void) {
        self.onResponse = onResponse
        self.onData = onData
        self.onDone = onDone
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let http = response as? HTTPURLResponse { onResponse(http) }
        completionHandler(.allow) // let the body stream in via didReceive(data)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        onData(data) // fires the instant bytes arrive — the whole point vs. AsyncBytes
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // A cancel() surfaces as NSURLErrorCancelled — treat it as a clean end, not a stream error.
        if let ns = error as NSError?, ns.domain == NSURLErrorDomain, ns.code == NSURLErrorCancelled {
            onDone(nil)
        } else {
            onDone(error)
        }
    }
}
