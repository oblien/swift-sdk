import Foundation

/// Workspace collection + lifecycle operations (`client.workspaces.*`).
public struct WorkspacesAPI: Sendable {
    let transport: Transport

    private struct WorkspaceEnvelope: Decodable { let workspace: Workspace }

    // MARK: CRUD

    public func create(_ params: WorkspaceCreateParams = .init(), waitOptions: WorkspaceWaitOptions? = nil) async throws -> Workspace {
        let options = waitOptions ?? .init(timeout: TimeInterval(params.readyTimeoutSeconds ?? 600))
        try options.validate()
        var request = params
        var config = request.config ?? .init()
        if let cpus = request.cpus { config.cpus = cpus }
        if let memory = request.memoryMb { config.memoryMb = memory }
        if let disk = request.diskSizeMb { config.diskSizeMb = disk }
        if let rootDiskId = request.rootDiskId { config.rootDiskId = rootDiskId }
        if let disks = request.disks { config.disks = disks }
        request.config = config
        request.cpus = nil; request.memoryMb = nil; request.diskSizeMb = nil
        request.rootDiskId = nil; request.disks = nil
        request.waitReady = false; request.readyTimeoutSeconds = nil
        let body = try OblienJSON.encode(request)
        let data = try await transport.request("POST", "/workspace", body: body,
            retrySafe: params.idempotencyKey?.isEmpty == false)
        let workspace = try OblienJSON.decode(WorkspaceEnvelope.self, data).workspace
        if params.waitReady == false { return workspace }
        return try await waitForWorkspace(workspace.id, options: options, initial: workspace)
    }

    public func list(_ params: WorkspaceListParams = .init()) async throws -> WorkspaceList {
        let data = try await transport.request("GET", "/workspace", query: params.query)
        return try OblienJSON.decode(WorkspaceList.self, data)
    }

    public func get(_ id: String) async throws -> Workspace {
        let data = try await transport.request("GET", "/workspace/\(id.pathEscaped)")
        return try OblienJSON.decode(WorkspaceEnvelope.self, data).workspace
    }

    public func update(_ id: String, _ params: WorkspaceUpdateParams) async throws -> Workspace {
        let body = try OblienJSON.encode(params)
        let data = try await transport.request("PUT", "/workspace/\(id.pathEscaped)", body: body)
        return try OblienJSON.decode(WorkspaceEnvelope.self, data).workspace
    }

    public func delete(_ id: String) async throws {
        _ = try await transport.request("DELETE", "/workspace/\(id.pathEscaped)")
    }

    public func getQuota() async throws -> Quota {
        let data = try await transport.request("GET", "/workspace/quota")
        return try OblienJSON.decode(Quota.self, data)
    }

    public func images(search: String? = nil, category: String? = nil) async throws -> ImageList {
        let data = try await transport.request("GET", "/workspace/images",
                                               query: ["search": search, "category": category])
        return try OblienJSON.decode(ImageList.self, data)
    }

    // MARK: Lifecycle

    public func start(_ id: String, force: Bool = false) async throws {
        let body = try OblienJSON.encode(ForceBody(force: force))
        _ = try await transport.request("POST", "/workspace/\(id.pathEscaped)/start", body: body, timeout: 600)
    }
    public func stop(_ id: String) async throws {
        _ = try await transport.request("POST", "/workspace/\(id.pathEscaped)/stop", timeout: 600)
    }
    public func restart(_ id: String) async throws {
        _ = try await transport.request("POST", "/workspace/\(id.pathEscaped)/restart", timeout: 600)
    }
    public func pause(_ id: String) async throws {
        _ = try await transport.request("POST", "/workspace/\(id.pathEscaped)/pause", timeout: 600)
    }
    public func resume(_ id: String) async throws {
        _ = try await transport.request("POST", "/workspace/\(id.pathEscaped)/resume", timeout: 600)
    }
    public func ping(_ id: String, ttlSeconds: Int? = nil) async throws {
        struct Body: Encodable { let ttlSeconds: Int? }
        let body = try OblienJSON.encode(Body(ttlSeconds: ttlSeconds))
        _ = try await transport.request("POST", "/workspace/\(id.pathEscaped)/ping", body: body)
    }
    public func reinstall(_ id: String) async throws {
        _ = try await transport.request("POST", "/workspace/\(id.pathEscaped)/reinstall", timeout: 600)
    }
    public func retryProvisioning(_ id: String) async throws -> Workspace {
        let data = try await transport.request("POST", "/workspace/\(id.pathEscaped)/provisioning/retry")
        return try OblienJSON.decode(WorkspaceEnvelope.self, data).workspace
    }
    public func retryCreation(_ id: String) async throws -> Workspace { try await retryProvisioning(id) }

    /// Poll durable creation progress. Cancellation stops waiting and leaves the workspace intact.
    public func waitUntilReady(_ id: String, timeout: TimeInterval = 600) async throws -> Workspace {
        try await waitForWorkspace(id, options: .init(timeout: timeout))
    }
    public func waitUntilReady(_ id: String, options: WorkspaceWaitOptions) async throws -> Workspace {
        try await waitForWorkspace(id, options: options)
    }
    private func waitForWorkspace(_ id: String, options: WorkspaceWaitOptions, initial: Workspace? = nil) async throws -> Workspace {
        try options.validate()
        let deadline = Date().addingTimeInterval(options.timeout)
        var workspace = initial
        while true {
            try Task.checkCancellation()
            guard deadline.timeIntervalSinceNow > 0 else {
                throw OblienError(kind: .transport, status: nil, code: "WORKSPACE_READY_TIMEOUT",
                    message: "Workspace preparation is still running. Resume checking its status.", details: .object(["workspace_id": .string(id)]))
            }
            if workspace == nil {
                do {
                    let data = try await transport.request("GET", "/workspace/\(id.pathEscaped)", timeout: min(30, deadline.timeIntervalSinceNow))
                    workspace = try OblienJSON.decode(WorkspaceEnvelope.self, data).workspace
                } catch let error as OblienError where error.isRetryable || error.kind == .transport {
                    try Task.checkCancellation()
                }
            }
            if let current = workspace {
                await options.onProgress?(current)
                if current.provisioning?.phase == "deleting" {
                    throw OblienError(kind: .conflict, status: 409, code: "WORKSPACE_CREATION_CANCELLED", message: "Workspace creation was cancelled.", details: nil)
                }
                if current.provisioning?.state == "failed" {
                    throw OblienError(kind: .validation, status: 422, code: current.provisioning?.errorCode ?? "CREATE_FAILED",
                        message: current.provisioning?.error ?? "Workspace preparation failed.", details: .object(["workspace_id": .string(id)]))
                }
                if current.ready == true || (current.provisioning == nil && current.isRunning && current.info?.ready != false) { return current }
                if current.provisioning?.state == "ready", current.ready != true {
                    throw OblienError(kind: .conflict, status: 409, code: "WORKSPACE_STOPPED", message: "Workspace preparation completed, but the workspace is stopped.", details: nil)
                }
            }
            workspace = nil
            try await Task.sleep(nanoseconds: UInt64(max(0, min(options.pollInterval, deadline.timeIntervalSinceNow)) * 1_000_000_000))
        }
    }

    // MARK: Sub-resources (bound to an id)

    public func resources(_ id: String) -> ResourcesAPI { ResourcesAPI(transport: transport, workspaceId: id) }
    public func network(_ id: String) -> NetworkAPI { NetworkAPI(transport: transport, workspaceId: id) }
    public func publicAccess(_ id: String) -> PublicAccessAPI { PublicAccessAPI(transport: transport, workspaceId: id) }
    public func runtimeAccess(_ id: String) -> RuntimeAccessAPI { RuntimeAccessAPI(transport: transport, workspaceId: id) }
    public func metrics(_ id: String) -> MetricsAPI { MetricsAPI(transport: transport, workspaceId: id) }
}
