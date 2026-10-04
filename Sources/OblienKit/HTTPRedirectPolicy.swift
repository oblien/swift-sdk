import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Matches fetch's redirect options. Manual returns the redirect response and body.
public enum HTTPRedirectPolicy: Sendable { case follow, manual, error }

class HTTPRedirectDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    private let policy: HTTPRedirectPolicy
    private let lock = NSLock()
    private var failure: Error?
    var redirectFailure: Error? { lock.lock(); defer { lock.unlock() }; return failure }

    init(policy: HTTPRedirectPolicy) { self.policy = policy; super.init() }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        switch policy {
        case .manual: completionHandler(nil)
        case .error:
            lock.lock()
            failure = OblienError(kind: .transport, status: response.statusCode, code: "redirect_not_allowed",
                                  message: "The request returned a redirect.", details: nil)
            lock.unlock()
            completionHandler(nil)
        case .follow:
            var request = request
            if response.url?.host != request.url?.host || response.url?.scheme != request.url?.scheme || response.url?.port != request.url?.port {
                // URLSession normally removes Authorization across origins. Explicitly remove
                // the custom Oblien headers too so a proxied redirect cannot leak credentials.
                for field in ["Authorization", "X-Client-ID", "X-Client-Secret", "X-Oblien-Account", "X-Oblien-Proxy-Target"] {
                    request.setValue(nil, forHTTPHeaderField: field)
                }
            }
            completionHandler(request)
        }
    }
}
