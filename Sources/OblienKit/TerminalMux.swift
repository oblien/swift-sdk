import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// One multiplexed terminal WebSocket shared by every PTY in a runtime.
///
/// The runtime exposes a single `wss://…/ws` connection that carries *all* terminals, framed as
/// binary `[terminalId, ...bytes]`. Opening a separate socket per terminal makes the runtime treat
/// each new connection as a takeover and tear down the previous one — so tabs kill each other.
/// `TerminalMux` keeps a single socket and fans incoming frames out to the per-terminal handler
/// registered for that id, prefixing outgoing keystrokes/resize with the right id. Pair it with
/// `TerminalAPI.create`/`list`/`close`/`scrollback` for the full lifecycle.
public final class TerminalMux: @unchecked Sendable {
    private let webSocketURL: URL
    private let token: String
    private let session: URLSession
    private var task: URLSessionWebSocketTask?

    private let lock = NSLock()
    private var handlers: [Int: (Data) -> Void] = [:]
    private var didClose = false

    /// Called once when the socket drops; `reason` is nil on a clean close.
    public var onClose: ((String?) -> Void)?

    public init(webSocketURL: URL, token: String, session: URLSession = .shared) {
        self.webSocketURL = webSocketURL
        self.token = token
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
                self.broadcastClose(error.localizedDescription)
            case .success(let message):
                if case .data(let frame) = message, let first = frame.first {
                    let id = Int(first)
                    self.lock.lock(); let handler = self.handlers[id]; self.lock.unlock()
                    handler?(Data(frame.dropFirst()))
                }
                self.receive()
            }
        }
    }

    /// Register a terminal's output handler (decoded pty bytes, leading id byte stripped).
    public func attach(_ id: Int, onData: @escaping (Data) -> Void) {
        lock.lock(); handlers[id] = onData; lock.unlock()
    }

    /// Stop routing a terminal's output (the PTY stays alive server-side until `close`d).
    public func detach(_ id: Int) {
        lock.lock(); handlers.removeValue(forKey: id); lock.unlock()
    }

    /// Send keystrokes / raw bytes to a terminal (prefixed with its id byte).
    public func send(_ id: Int, _ data: Data) {
        var frame: [UInt8] = [UInt8(truncatingIfNeeded: id)]
        frame.append(contentsOf: data)
        task?.send(.data(Data(frame))) { _ in }
    }

    /// Resize a terminal — a JSON control frame on the `"terminal"` channel.
    public func resize(_ id: Int, cols: Int, rows: Int) {
        let control: [String: Any] = ["channel": "terminal", "type": "resize", "id": id, "cols": cols, "rows": rows]
        if let data = try? JSONSerialization.data(withJSONObject: control),
           let json = String(data: data, encoding: .utf8) {
            task?.send(.string(json)) { _ in }
        }
    }

    /// Close the shared socket (does not kill the PTYs — use `TerminalAPI.close` for that).
    public func close() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        lock.lock(); handlers.removeAll(); lock.unlock()
    }

    private func broadcastClose(_ reason: String?) {
        lock.lock(); let already = didClose; didClose = true; lock.unlock()
        guard !already else { return }
        onClose?(reason)
    }
}
