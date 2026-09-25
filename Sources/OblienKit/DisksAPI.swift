import Foundation

/// Persistent storage is independent of a workspace's lifetime. Mutations return durable
/// operations; keep their IDs and idempotency keys when a request or a wait is interrupted.
public struct DisksAPI: Sendable {
    let transport: Transport

    public func list(namespace: String? = nil) async throws -> [ManagedDisk] {
        try await read(DiskList.self, "/disks", query: ["namespace": namespace]).disks
    }

    public func get(_ id: String) async throws -> ManagedDisk {
        struct Envelope: Decodable { let disk: ManagedDisk }
        return try await read(Envelope.self, "/disks/\(id.pathEscaped)").disk
    }

    public func listSoftware(workspaceId: String? = nil) async throws -> [SoftwareDisk] {
        struct Envelope: Decodable { let software: [SoftwareDisk] }
        return try await read(Envelope.self, "/disks/library", query: ["workspace_id": workspaceId]).software
    }

    public func create(_ params: DiskCreateParams, options: DiskOperationOptions = .init()) async throws -> DiskMutationResult {
        try await mutate("POST", "/disks", params, options)
    }

    public func delete(_ id: String, options: DiskOperationOptions = .init()) async throws -> DiskMutationResult {
        try await mutate("DELETE", "/disks/\(id.pathEscaped)", EmptyParams(), options)
    }

    public func clone(_ id: String, name: String? = nil, options: DiskOperationOptions = .init()) async throws -> DiskMutationResult {
        try await mutate("POST", "/disks/\(id.pathEscaped)/clone", NameParams(name: name), options)
    }

    public func save(_ id: String, name: String? = nil, options: DiskOperationOptions = .init()) async throws -> DiskMutationResult {
        try await mutate("POST", "/disks/\(id.pathEscaped)/save", NameParams(name: name), options)
    }

    public func fork(_ id: String, sizeMb: Int, name: String? = nil, options: DiskOperationOptions = .init()) async throws -> DiskMutationResult {
        try await mutate("POST", "/disks/\(id.pathEscaped)/fork", SizeParams(name: name, sizeMb: sizeMb), options)
    }

    public func resize(_ id: String, sizeMb: Int, options: DiskOperationOptions = .init()) async throws -> DiskMutationResult {
        try await mutate("POST", "/disks/\(id.pathEscaped)/resize", SizeParams(name: nil, sizeMb: sizeMb), options)
    }

    public func attach(_ id: String, _ params: DiskAttachParams, options: DiskOperationOptions = .init()) async throws -> DiskMutationResult {
        try await mutate("POST", "/disks/\(id.pathEscaped)/attach", params, options)
    }

    public func detach(_ id: String, workspaceId: String, options: DiskOperationOptions = .init()) async throws -> DiskMutationResult {
        try await mutate("POST", "/disks/\(id.pathEscaped)/detach", WorkspaceParams(workspaceId: workspaceId), options)
    }

    public func move(_ id: String, sourceWorkspaceId: String, targetWorkspaceId: String, mountPath: String? = nil,
                     options: DiskOperationOptions = .init()) async throws -> DiskMutationResult {
        try await mutate("POST", "/disks/\(id.pathEscaped)/move",
                         MoveParams(sourceWorkspaceId: sourceWorkspaceId, targetWorkspaceId: targetWorkspaceId, mountPath: mountPath), options)
    }

    public func attachSoftware(_ id: String, workspaceId: String, options: DiskOperationOptions = .init()) async throws -> DiskMutationResult {
        try await mutate("POST", "/disks/library/\(id.pathEscaped)/attach", WorkspaceParams(workspaceId: workspaceId), options)
    }

    public func operation(_ id: String) async throws -> DiskOperation {
        struct Envelope: Decodable { let operation: DiskOperation }
        return try await read(Envelope.self, "/disks/operations/\(id.pathEscaped)").operation
    }

    public func retry(_ operationId: String, options: DiskOperationOptions = .init()) async throws -> DiskMutationResult {
        try await mutate("POST", "/disks/operations/\(operationId.pathEscaped)/retry", EmptyParams(), options)
    }

    /// Canceling or timing out this wait never cancels the remote operation. A failed operation
    /// is returned (with its error) so callers can present the server's retry action.
    public func wait(_ operationId: String, timeout: TimeInterval = 1800,
                     pollInterval: TimeInterval = 2) async throws -> DiskOperation {
        guard timeout > 0, timeout.isFinite, pollInterval > 0, pollInterval.isFinite else {
            throw OblienError(kind: .validation, status: nil, code: nil, message: "Use positive, finite polling intervals.", details: nil)
        }
        let deadline = Date().addingTimeInterval(timeout)
        while true {
            try Task.checkCancellation()
            let value = try await operation(operationId)
            if !value.isPending { return value }
            let remaining = deadline.timeIntervalSinceNow
            guard remaining > 0 else {
                throw OblienError(kind: .transport, status: nil, code: "operation_wait_timeout",
                                  message: "The disk operation is still running. Resume checking with its operation ID.",
                                  details: .object(["operation_id": .string(operationId)]))
            }
            try await Task.sleep(nanoseconds: UInt64(min(pollInterval, remaining, 60) * 1_000_000_000))
        }
    }

    fileprivate func read<T: Decodable>(_ type: T.Type, _ path: String, query: [String: String?] = [:]) async throws -> T {
        try OblienJSON.decode(type, await transport.request("GET", path, query: query))
    }

    fileprivate func mutate<T: Encodable>(_ method: String, _ path: String, _ params: T,
                                          _ options: DiskOperationOptions) async throws -> DiskMutationResult {
        guard !options.idempotencyKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OblienError(kind: .validation, status: nil, code: nil, message: "A stable idempotency key is required for disk operations.", details: nil)
        }
        // Merge typed parameters with the operation envelope at the wire boundary only.
        var body = try OblienJSON.decoder().decode([String: JSONValue].self, from: OblienJSON.encode(params))
        body["idempotency_key"] = .string(options.idempotencyKey)
        body["wait_ready"] = .bool(false)
        let data = try await transport.request(method, path, body: OblienJSON.encode(body), retrySafe: true)
        var result = try OblienJSON.decode(DiskMutationResult.self, data)
        if options.waitUntilReady, let operation = result.operation, operation.isPending {
            result.operation = try await wait(operation.id, timeout: options.timeout)
            if method != "DELETE", result.operation?.state == "done", let id = result.disk?.id {
                do { result.disk = try await get(id) }
                catch is CancellationError { throw CancellationError() }
                catch { result.refreshError = error.localizedDescription }
            }
        }
        return result
    }

    fileprivate struct EmptyParams: Encodable {}
    fileprivate struct NameParams: Encodable { let name: String? }
    private struct SizeParams: Encodable { let name: String?; let sizeMb: Int }
    private struct WorkspaceParams: Encodable { let workspaceId: String }
    private struct MoveParams: Encodable { let sourceWorkspaceId: String; let targetWorkspaceId: String; let mountPath: String? }
}

public struct WorkspaceDisksAPI: Sendable {
    let transport: Transport
    let workspaceId: String
    private var disks: DisksAPI { DisksAPI(transport: transport) }
    private var base: String { "/disks/workspace/\(workspaceId.pathEscaped)" }

    public func list() async throws -> DiskList { try await disks.read(DiskList.self, base) }
    public func retainRoot(name: String? = nil, options: DiskOperationOptions = .init()) async throws -> DiskMutationResult {
        try await disks.mutate("POST", base + "/root", DisksAPI.NameParams(name: name), options)
    }
    /// Discards saved RAM, keeping the files. The next start is a cold boot.
    public func discardSavedExecution(options: DiskOperationOptions = .init()) async throws -> DiskMutationResult {
        try await disks.mutate("DELETE", base + "/saved-execution", DisksAPI.EmptyParams(), options)
    }
}

public struct DiskOperationOptions: Sendable {
    public var idempotencyKey: String
    public var waitUntilReady: Bool
    public var timeout: TimeInterval
    public init(idempotencyKey: String = UUID().uuidString, waitUntilReady: Bool = false, timeout: TimeInterval = 1800) {
        self.idempotencyKey = idempotencyKey; self.waitUntilReady = waitUntilReady; self.timeout = timeout
    }
}

public struct DiskCreateParams: Codable, Sendable {
    public var name: String
    public var sizeMb: Int
    public var format: String?
    public var namespace: String?
    public init(name: String, sizeMb: Int, format: String? = nil, namespace: String? = nil) {
        self.name = name; self.sizeMb = sizeMb; self.format = format; self.namespace = namespace
    }
}

public struct DiskAttachParams: Codable, Sendable {
    public var workspaceId: String
    public var mountPath: String?
    public var readOnly: Bool?
    public var role: String?
    public var target: String?
    public init(workspaceId: String, mountPath: String? = nil, readOnly: Bool? = nil, role: String? = nil, target: String? = nil) {
        self.workspaceId = workspaceId; self.mountPath = mountPath; self.readOnly = readOnly; self.role = role; self.target = target
    }
}

/// Used by `WorkspaceConfig.disks` during workspace creation.
public struct WorkspaceDiskAttachment: Codable, Sendable {
    public var diskId: String
    public var mountPath: String?
    public var readOnly: Bool?
    public var role: String?
    public var target: String?
    public init(diskId: String, mountPath: String? = nil, readOnly: Bool? = nil, role: String? = nil, target: String? = nil) {
        self.diskId = diskId; self.mountPath = mountPath; self.readOnly = readOnly; self.role = role; self.target = target
    }
}

public struct ManagedDisk: Codable, Sendable, Identifiable {
    public let id: String
    public var name: String?
    public var namespace: String?
    public var state: String?
    public var kind: String?
    public var format: String?
    public var sizeMb: Int?
    public var immutable: Bool?
    public var ownership: String?
    public var rootImage: String?
    public var operationId: String?
    public var permissions: [String: Bool]?
    public var attachments: [Attachment]?
    public var error: String?
    public var library: JSONValue?

    public struct Attachment: Codable, Sendable {
        public let workspaceId: String
        public var mountPath: String?
        public var role: String?
        public var target: String?
        public var readOnly: Bool?
    }
}

public struct DiskList: Codable, Sendable {
    public var disks: [ManagedDisk]
    public var operationId: String?
}

public struct DiskOperation: Codable, Sendable, Identifiable {
    public let id: String
    public var state: String
    public var phase: String?
    public var error: String?
    public var diskId: String?
    public var isPending: Bool { state == "queued" || state == "running" }
}

public struct DiskMutationResult: Codable, Sendable {
    public var accepted: Bool?
    public var disk: ManagedDisk?
    public var operation: DiskOperation?
    /// The operation completed but refreshing its disk failed. The operation ID and
    /// result remain available, so a failed read cannot turn success into a duplicate mutation.
    public var refreshError: String?
    enum CodingKeys: String, CodingKey { case accepted, disk, operation }
}

public struct SoftwareDisk: Codable, Sendable, Identifiable {
    public let id: String
    public var name: String?
    public var label: String?
    public var description: String?
    public var sizeMb: Int?
    public var compatibleImages: [String]?
    public var compatibleOs: JSONValue?
    public var attachment: Attachment?
    public var image: String?
    public struct Attachment: Codable, Sendable {
        public var target: String?
        public var role: String?
        public var readOnly: Bool?
    }
}

extension OblienClient {
    public var disks: DisksAPI { DisksAPI(transport: transport) }
}
extension WorkspaceHandle {
    public var disks: WorkspaceDisksAPI { WorkspaceDisksAPI(transport: transport, workspaceId: id) }
}
extension WorkspacesAPI {
    public func disks(_ id: String) -> WorkspaceDisksAPI { WorkspaceDisksAPI(transport: transport, workspaceId: id) }
}
