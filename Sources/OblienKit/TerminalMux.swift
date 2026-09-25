import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// One native WebSocket for every terminal and watcher in a runtime. Binary terminal
/// frames, JSON controls and watcher events share the same connection.
public final class TerminalMux: NSObject, @unchecked Sendable {
    private let webSocketURL: URL
    private let token: String
    private let session: URLSession
    private let options: WSOptions?
    private let lock = NSLock()
    private var task: URLSessionWebSocketTask?
    private var retry: DispatchWorkItem?
    private var handlers: [Int: (Data) -> Void] = [:]
    private var intentionallyClosed = false
    private var isConnected = false
    private var attempts = 0
    private var delegateBridge: TerminalMuxDelegate!

    private struct Callbacks {
        var open: (() -> Void)?
        var close: ((String?) -> Void)?
        var disconnect: ((Int, String?) -> Void)?
        var error: ((Error) -> Void)?
        var message: ((WSMessage) -> Void)?
        var watcher: ((RuntimeWatcherEvent) -> Void)?
        var output: ((Int, Data) -> Void)?
        var exit: ((Int, Int) -> Void)?
    }
    private var callbacks = Callbacks()
    /// Callbacks run on the URLSession delegate queue. Registration is thread-safe.
    public var onOpen: (() -> Void)? {
        get { lock.withLock { callbacks.open } }
        set { lock.withLock { callbacks.open = newValue } }
    }
    public var onClose: ((String?) -> Void)? {
        get { lock.withLock { callbacks.close } }
        set { lock.withLock { callbacks.close = newValue } }
    }
    public var onDisconnect: ((Int, String?) -> Void)? {
        get { lock.withLock { callbacks.disconnect } }
        set { lock.withLock { callbacks.disconnect = newValue } }
    }
    public var onError: ((Error) -> Void)? {
        get { lock.withLock { callbacks.error } }
        set { lock.withLock { callbacks.error = newValue } }
    }
    public var onMessage: ((WSMessage) -> Void)? {
        get { lock.withLock { callbacks.message } }
        set { lock.withLock { callbacks.message = newValue } }
    }
    public var onWatcherEvent: ((RuntimeWatcherEvent) -> Void)? {
        get { lock.withLock { callbacks.watcher } }
        set { lock.withLock { callbacks.watcher = newValue } }
    }
    public var onTerminalOutput: ((Int, Data) -> Void)? {
        get { lock.withLock { callbacks.output } }
        set { lock.withLock { callbacks.output = newValue } }
    }
    public var onTerminalExit: ((Int, Int) -> Void)? {
        get { lock.withLock { callbacks.exit } }
        set { lock.withLock { callbacks.exit = newValue } }
    }

    public var connected: Bool { lock.lock(); defer { lock.unlock() }; return isConnected }

    /// Omitted options preserve the original caller-owned reconnect behavior. Passing
    /// options enables the TypeScript SDK's reconnect defaults unless explicitly disabled.
    public init(webSocketURL: URL, token: String, session: URLSession = .shared, options: WSOptions? = nil) {
        self.webSocketURL = webSocketURL; self.token = token; self.session = session; self.options = options
        super.init()
        delegateBridge = TerminalMuxDelegate(owner: self)
    }

    public func connect() { open(manual: true) }

    private func open(manual: Bool) {
        lock.lock()
        guard task == nil, manual || !intentionallyClosed else { lock.unlock(); return }
        retry?.cancel(); retry = nil; intentionallyClosed = false
        if manual { attempts = 0 }
        var request = URLRequest(url: webSocketURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let socket = session.webSocketTask(with: request)
        task = socket
        socket.delegate = delegateBridge
        lock.unlock()
        socket.resume()
        receive(socket)
    }

    private func receive(_ socket: URLSessionWebSocketTask) {
        socket.receive { [weak self, weak socket] result in
            guard let self, let socket, self.isCurrent(socket) else { return }
            switch result {
            case .failure(let error): self.dropped(socket, error: error)
            case .success(let message):
                self.handle(message)
                if self.isCurrent(socket) { self.receive(socket) }
            }
        }
    }

    /// Protocol routing is independent of connection lifecycle so reconnects retain PTY handlers.
    func handle(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data(let frame):
            guard let first = frame.first else { return }
            let id = Int(first), bytes = Data(frame.dropFirst())
            lock.lock(); let handler = handlers[id]; lock.unlock()
            handler?(bytes); onTerminalOutput?(id, bytes)
        case .string(let text):
            do {
                let data = Data(text.utf8)
                let message = try APIJSON.decode(WSMessage.self, data)
                onMessage?(message)
                if message.channel == "watcher" {
                    onWatcherEvent?(try APIJSON.decode(RuntimeWatcherEvent.self, data))
                } else if message.channel == "terminal", message.additionalProperties["type"]?.stringValue == "exit" {
                    let fields = message.additionalProperties
                    if let id = fields["id"]?.intValue ?? fields["id"]?.stringValue.flatMap(Int.init),
                       let code = fields["code"]?.intValue { onTerminalExit?(id, code) }
                }
            } catch { onError?(error) }
        @unknown default: break
        }
    }

    public func attach(_ id: Int, onData: @escaping (Data) -> Void) {
        lock.lock(); handlers[id] = onData; lock.unlock()
    }
    public func detach(_ id: Int) { lock.lock(); handlers.removeValue(forKey: id); lock.unlock() }

    public func send(_ id: Int, _ data: Data) {
        guard (0...255).contains(id) else { onError?(invalidID()); return }
        var frame = Data([UInt8(id)]); frame.append(data)
        sendMessage(.data(frame))
    }
    public func writeTerminalInput(_ id: Int, _ data: Data) { send(id, data) }
    public func writeTerminalInput(_ id: Int, _ text: String) { send(id, Data(text.utf8)) }
    public func resize(_ id: Int, cols: Int, rows: Int) {
        guard (0...255).contains(id), cols > 0, rows > 0 else { onError?(invalidID()); return }
        sendJSON(["channel": .string("terminal"), "type": .string("resize"), "id": .number(Double(id)),
                  "cols": .number(Double(cols)), "rows": .number(Double(rows))])
    }
    public func resizeTerminal(_ id: Int, cols: Int, rows: Int) { resize(id, cols: cols, rows: rows) }
    public func sendJSON(_ message: [String: JSONValue]) {
        do { sendMessage(.string(String(decoding: try APIJSON.encode(message), as: UTF8.self))) }
        catch { onError?(error) }
    }
    private func sendMessage(_ message: URLSessionWebSocketTask.Message) {
        lock.lock(); let socket = task; lock.unlock()
        guard let socket else {
            onError?(OblienError(kind: .transport, status: nil, code: nil, message: "The runtime socket is disconnected.", details: nil))
            return
        }
        socket.send(message) { [weak self, weak socket] error in
            if let error, let socket { self?.dropped(socket, error: error) }
        }
    }

    public func close() {
        lock.lock()
        intentionallyClosed = true; isConnected = false
        retry?.cancel(); retry = nil
        let socket = task; task = nil
        handlers.removeAll()
        lock.unlock()
        socket?.cancel(with: .goingAway, reason: nil)
    }
    deinit { retry?.cancel(); task?.cancel(with: .goingAway, reason: nil) }

    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        lock.lock()
        guard task === webSocketTask else { lock.unlock(); return }
        isConnected = true; attempts = 0
        lock.unlock()
        onOpen?()
    }
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                           didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        dropped(webSocketTask, error: nil, code: closeCode.rawValue,
                reason: reason.flatMap { String(data: $0, encoding: .utf8) })
    }
    private func isCurrent(_ socket: URLSessionWebSocketTask) -> Bool {
        lock.lock(); defer { lock.unlock() }; return task === socket && !intentionallyClosed
    }
    private func dropped(_ socket: URLSessionWebSocketTask, error: Error?, code: Int = 1006, reason: String? = nil) {
        lock.lock()
        guard task === socket, !intentionallyClosed else { lock.unlock(); return }
        task = nil; isConnected = false
        let reconnect = options != nil && options?.reconnect != false && attempts < (options?.maxReconnectAttempts ?? Int.max)
        if reconnect { attempts += 1 }
        let attempt = attempts
        let retry = reconnect ? DispatchWorkItem { [weak self] in self?.reconnect() } : nil
        self.retry = retry
        lock.unlock()
        socket.cancel(with: .goingAway, reason: nil)
        if let error { onError?(error) }
        onClose?(reason ?? error?.localizedDescription)
        onDisconnect?(code, reason ?? error?.localizedDescription)
        if let retry {
            let milliseconds = options?.reconnectDelay ?? 1000
            let base = milliseconds.isFinite ? max(0.1, milliseconds / 1000) : 1
            let delay = min(30, base * pow(1.5, Double(min(100, max(0, attempt - 1)))))
            DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: retry)
        }
    }
    private func reconnect() {
        open(manual: false)
    }
    private func invalidID() -> Error {
        OblienError(kind: .validation, status: nil, code: nil, message: "Invalid terminal ID or dimensions.", details: nil)
    }
}

/// URLSession retains task delegates. This weak bridge lets releasing a mux cancel its
/// socket instead of forming mux → task → delegate → mux.
private final class TerminalMuxDelegate: NSObject, URLSessionWebSocketDelegate, @unchecked Sendable {
    weak var owner: TerminalMux?
    init(owner: TerminalMux) { self.owner = owner }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        owner?.urlSession(session, webSocketTask: webSocketTask, didOpenWithProtocol: `protocol`)
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        owner?.urlSession(session, webSocketTask: webSocketTask, didCloseWith: closeCode, reason: reason)
    }
}

public enum RuntimeWatcherEvent: Codable, Sendable {
    case change(WSWatcherChange)
    case ready(WSWatcherReady)
    case overflow(WSWatcherOverflow)
    case unknown(JSONValue)
    public init(from decoder: Decoder) throws {
        let value = try JSONValue(from: decoder)
        switch value["type"]?.stringValue {
        case "change": self = .change(try WSWatcherChange(from: decoder))
        case "ready": self = .ready(try WSWatcherReady(from: decoder))
        case "overflow": self = .overflow(try WSWatcherOverflow(from: decoder))
        default: self = .unknown(value)
        }
    }
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .change(let value): try value.encode(to: encoder)
        case .ready(let value): try value.encode(to: encoder)
        case .overflow(let value): try value.encode(to: encoder)
        case .unknown(let value): try value.encode(to: encoder)
        }
    }
}
