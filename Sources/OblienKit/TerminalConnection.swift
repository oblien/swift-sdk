import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A live terminal over the Oblien multiplexed **binary** WebSocket.
///
/// Wire protocol: pty frames are binary `[terminalId, ...bytes]` (frames whose first byte
/// ≠ this terminal's id are dropped); keystrokes go out as `[terminalId, ...inputBytes]`;
/// resize is a JSON control frame on the `"terminal"` channel. The native
/// `URLSessionWebSocketTask` is required because it can set the `Authorization` header.
public final class TerminalConnection {
    private let webSocketURL: URL
    private let token: String
    private let terminalId: Int
    private let session: URLSession
    private var task: URLSessionWebSocketTask?

    /// Decoded pty output (the leading id byte already stripped).
    public var onData: ((Data) -> Void)?
    /// Called when the socket closes; `reason` is nil on a clean close.
    public var onClose: ((String?) -> Void)?

    public init(webSocketURL: URL, token: String, terminalId: Int, session: URLSession = .shared) {
        self.webSocketURL = webSocketURL
        self.token = token
        self.terminalId = terminalId
        self.session = session
    }

    public func connect() {
        var request = URLRequest(url: webSocketURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = session.webSocketTask(with: request)
        self.task = task
        task.resume()
        receive()
    }

    private func receive() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                self.onClose?(error.localizedDescription)
            case .success(let message):
                if case .data(let frame) = message, let first = frame.first, Int(first) == self.terminalId {
                    self.onData?(Data(frame.dropFirst()))
                }
                self.receive()
            }
        }
    }

    /// Send keystrokes (prefixed with the terminal id byte).
    public func send(_ text: String) { send(Data(text.utf8)) }

    /// Send raw bytes (prefixed with the terminal id byte) — for control codes / non-text input.
    public func send(_ data: Data) {
        var frame: [UInt8] = [UInt8(truncatingIfNeeded: terminalId)]
        frame.append(contentsOf: data)
        task?.send(.data(Data(frame))) { _ in }
    }

    public func resize(cols: Int, rows: Int) {
        let control: [String: Any] = ["channel": "terminal", "type": "resize", "id": terminalId, "cols": cols, "rows": rows]
        if let data = try? JSONSerialization.data(withJSONObject: control),
           let json = String(data: data, encoding: .utf8) {
            task?.send(.string(json)) { _ in }
        }
    }

    public func close() { task?.cancel(with: .goingAway, reason: nil) }
}
