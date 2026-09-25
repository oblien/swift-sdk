import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct TransferProgress: Sendable {
    public enum Phase: String, Sendable { case upload, download }
    public let phase: Phase
    public let loadedBytes: Int64
    public let totalBytes: Int64?
    public var percent: Double? {
        guard let totalBytes, totalBytes > 0 else { return nil }
        return min(100, Double(loadedBytes) / Double(totalBytes) * 100)
    }
}

public struct HTTPBodyStream: Sendable {
    public let chunks: AsyncThrowingStream<Data, Error>
    public let status: Int
    public let totalBytes: Int64?
    public let headers: [String: String]
}

/// tar.gz transfer. Downloads stream incrementally; uploads accept memory or a file URL
/// without reading an entire archive into memory. Progress reports measured network bytes.
public struct TransferAPI: Sendable {
    let runtime: RuntimeClient

    public func download(paths: [String], excludePatterns: [String]? = nil,
                         onProgress: (@Sendable (TransferProgress) -> Void)? = nil) async throws -> HTTPBodyStream {
        struct Body: Encodable { let paths: [String]; let excludePatterns: [String]? }
        let body = try OblienJSON.encode(Body(paths: paths, excludePatterns: excludePatterns))
        let response = try await runtime.download(body: body)
        guard let onProgress else { return response }
        let chunks = AsyncThrowingStream<Data, Error> { continuation in
            let task = Task {
                var loaded: Int64 = 0
                do {
                    for try await chunk in response.chunks {
                        try Task.checkCancellation()
                        loaded += Int64(chunk.count)
                        onProgress(.init(phase: .download, loadedBytes: loaded, totalBytes: response.totalBytes))
                        continuation.yield(chunk)
                    }
                    continuation.finish()
                } catch { continuation.finish(throwing: error) }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
        return HTTPBodyStream(chunks: chunks, status: response.status, totalBytes: response.totalBytes, headers: response.headers)
    }

    public func upload(dest: String = "/", tarGz: Data,
                       onProgress: (@Sendable (TransferProgress) -> Void)? = nil) async throws -> TransferUploadResponse {
        try APIJSON.decode(TransferUploadResponse.self, await runtime.upload(dest: dest, source: .data(tarGz), onProgress: onProgress))
    }
    public func upload(dest: String = "/", fileURL: URL,
                       onProgress: (@Sendable (TransferProgress) -> Void)? = nil) async throws -> TransferUploadResponse {
        guard fileURL.isFileURL else {
            throw OblienError(kind: .validation, status: nil, code: nil, message: "Choose a local archive file.", details: nil)
        }
        return try APIJSON.decode(TransferUploadResponse.self, await runtime.upload(dest: dest, source: .file(fileURL), onProgress: onProgress))
    }

    /// Streaming equivalent of a JavaScript ReadableStream. The factory must return a new,
    /// unopened stream on every call so authentication refresh can replay the body safely.
    /// Omit totalBytes for an unknown length; progress then reports bytes without a percentage.
    public func upload(dest: String = "/", totalBytes: Int64? = nil,
                       stream: @escaping @Sendable () throws -> InputStream,
                       onProgress: (@Sendable (TransferProgress) -> Void)? = nil) async throws -> TransferUploadResponse {
        if let totalBytes, totalBytes < 0 {
            throw OblienError(kind: .validation, status: nil, code: nil, message: "Upload size cannot be negative.", details: nil)
        }
        return try APIJSON.decode(TransferUploadResponse.self,
            await runtime.upload(dest: dest, source: .stream(stream, totalBytes: totalBytes), onProgress: onProgress))
    }
}

enum UploadSource: Sendable {
    case data(Data), file(URL)
    case stream(@Sendable () throws -> InputStream, totalBytes: Int64?)
}

extension Transport {
    func upload(_ path: String, query: [String: String?], bearer: String, source: UploadSource,
                onProgress: (@Sendable (TransferProgress) -> Void)?) async throws -> Data {
        var request = try await buildRequest("POST", path, query: query, body: nil, host: .runtime,
                                            bearer: bearer, contentType: nil, forceRefresh: false)
        request.timeoutInterval = 3600
        request.setValue("application/gzip", forHTTPHeaderField: "Content-Type")
        let delegate = TransferUploadDelegate(onProgress: onProgress)
        let result: (Data, URLResponse)
        switch source {
        case .data(let data): result = try await session.upload(for: request, from: data, delegate: delegate)
        case .file(let url): result = try await session.upload(for: request, fromFile: url, delegate: delegate)
        case .stream(let factory, let totalBytes):
            result = try await streamedUpload(request, stream: factory, totalBytes: totalBytes, onProgress: onProgress)
        }
        try Task.checkCancellation()
        guard let response = result.1 as? HTTPURLResponse else {
            throw OblienError(kind: .transport, status: nil, code: nil, message: "No upload response.", details: nil)
        }
        let flag = try? JSONDecoder().decode(JSONValue.self, from: result.0)["success"]?.boolValue
        guard (200..<300).contains(response.statusCode), flag != false else {
            throw Self.decodeError(result.0, status: response.statusCode)
        }
        return result.0
    }

    private func streamedUpload(_ request: URLRequest, stream: @escaping @Sendable () throws -> InputStream,
                                totalBytes: Int64?, onProgress: (@Sendable (TransferProgress) -> Void)?) async throws -> (Data, URLResponse) {
        var request = request
        request.httpBodyStream = try stream()
        if let totalBytes { request.setValue(String(totalBytes), forHTTPHeaderField: "Content-Length") }
        let holder = StreamHolder()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let bridge = TransferStreamUploadBridge(stream: stream, totalBytes: totalBytes, onProgress: onProgress) { result in
                    continuation.resume(with: result)
                    holder.cancel()
                }
                let uploadSession = URLSession(configuration: session.configuration, delegate: bridge, delegateQueue: nil)
                holder.start(session: uploadSession, task: uploadSession.uploadTask(withStreamedRequest: request))
            }
        } onCancel: { holder.cancel() }
    }
}

private final class TransferUploadDelegate: HTTPRedirectDelegate, @unchecked Sendable {
    let onProgress: (@Sendable (TransferProgress) -> Void)?
    init(onProgress: (@Sendable (TransferProgress) -> Void)?) { self.onProgress = onProgress; super.init(policy: .follow) }
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        onProgress?(.init(phase: .upload, loadedBytes: totalBytesSent,
                         totalBytes: totalBytesExpectedToSend >= 0 ? totalBytesExpectedToSend : nil))
    }
}

private final class TransferStreamUploadBridge: HTTPRedirectDelegate, URLSessionDataDelegate, @unchecked Sendable {
    private let stream: @Sendable () throws -> InputStream
    private let totalBytes: Int64?
    private let onProgress: (@Sendable (TransferProgress) -> Void)?
    private let onComplete: (Result<(Data, URLResponse), Error>) -> Void
    private var data = Data()
    private var streamError: Error?

    init(stream: @escaping @Sendable () throws -> InputStream, totalBytes: Int64?,
         onProgress: (@Sendable (TransferProgress) -> Void)?,
         onComplete: @escaping (Result<(Data, URLResponse), Error>) -> Void) {
        self.stream = stream; self.totalBytes = totalBytes; self.onProgress = onProgress; self.onComplete = onComplete
        super.init(policy: .follow)
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        do { completionHandler(try stream()) }
        catch { streamError = error; completionHandler(nil) }
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive bytes: Data) {
        guard data.count + bytes.count <= 1_048_576 else {
            streamError = OblienError(kind: .transport, status: nil, code: nil, message: "Upload response exceeded the size limit.", details: nil)
            dataTask.cancel(); return
        }
        data.append(bytes)
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        onProgress?(.init(phase: .upload, loadedBytes: totalBytesSent,
                         totalBytes: totalBytes ?? (totalBytesExpectedToSend >= 0 ? totalBytesExpectedToSend : nil)))
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = streamError ?? error { onComplete(.failure(error)) }
        else if let response = task.response { onComplete(.success((data, response))) }
        else { onComplete(.failure(OblienError(kind: .transport, status: nil, code: nil, message: "No upload response.", details: nil))) }
    }
}
