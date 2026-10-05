import Foundation

// MARK: - Enums

public enum WorkspaceMode: String, Codable, Sendable { case permanent, temporary }
public enum TTLAction: String, Codable, Sendable { case stop, pause, suspend, remove }
public enum RestartPolicy: String, Codable, Sendable {
    case no, never, always
    case onFailure = "on-failure"
    case unlessStopped = "unless-stopped"
}
public enum TokenScope: String, Codable, Sendable { case namespace, workspace }

// MARK: - Workspace create / update params

public struct WorkspaceConfig: Codable, Sendable {
    public var cpus: Int?
    public var memoryMb: Int?       // memory_mb
    public var diskSizeMb: Int?     // disk_size_mb
    public var ttl: String?
    public var ttlAction: TTLAction?
    public var removeOnExit: Bool?
    public var restartPolicy: RestartPolicy?
    public var maxRestarts: Int?
    public var keepLogs: Bool?
    public var sshAccess: Bool?
    public var env: [EnvVar]?
    public var cmd: [String]?
    public var rootDiskId: String?
    public var disks: [WorkspaceDiskAttachment]?
    public var desktop: DesktopConfig?
    public var networkConfig: NetworkUpdateParams?
    public var workloads: [WorkloadCreateParams]?
    public var readyCheck: ReadyCheck?
    public var idle: IdlePolicy?
    public var macos: MacOSBootConfig?
    public var enableKvm: Bool?
    public var kernelId: String?
    public var staticNetwork: Bool?
    public var waitForInit: Bool?
    /// Shell-form command. Takes precedence over the legacy argument-array `cmd`.
    public var command: String?
    public var ttlSeconds: Int?
    /// Additional documented or future configuration fields, flattened into `config`.
    public var additionalProperties: [String: JSONValue] = [:]

    public struct DesktopConfig: Codable, Sendable {
        public var enabled: Bool
        public init(enabled: Bool) { self.enabled = enabled }
    }
    public struct ReadyCheck: Codable, Sendable {
        public var command: [String]?
        public var target: String?
        public var timeoutSeconds: Int?
        public init(command: [String]? = nil, target: String? = nil, timeoutSeconds: Int? = nil) {
            self.command = command; self.target = target; self.timeoutSeconds = timeoutSeconds
        }
    }

    public init(cpus: Int? = nil, memoryMb: Int? = nil, diskSizeMb: Int? = nil, ttl: String? = nil,
                ttlAction: TTLAction? = nil, removeOnExit: Bool? = nil, restartPolicy: RestartPolicy? = nil,
                maxRestarts: Int? = nil, keepLogs: Bool? = nil, sshAccess: Bool? = nil,
                env: [EnvVar]? = nil, cmd: [String]? = nil, rootDiskId: String? = nil,
                disks: [WorkspaceDiskAttachment]? = nil, desktop: DesktopConfig? = nil,
                networkConfig: NetworkUpdateParams? = nil, workloads: [WorkloadCreateParams]? = nil,
                readyCheck: ReadyCheck? = nil, idle: IdlePolicy? = nil, macos: MacOSBootConfig? = nil,
                enableKvm: Bool? = nil, kernelId: String? = nil, staticNetwork: Bool? = nil,
                waitForInit: Bool? = nil, command: String? = nil, ttlSeconds: Int? = nil,
                additionalProperties: [String: JSONValue] = [:]) {
        self.cpus = cpus; self.memoryMb = memoryMb; self.diskSizeMb = diskSizeMb; self.ttl = ttl
        self.ttlAction = ttlAction; self.removeOnExit = removeOnExit; self.restartPolicy = restartPolicy
        self.maxRestarts = maxRestarts; self.keepLogs = keepLogs; self.sshAccess = sshAccess
        self.env = env; self.cmd = cmd
        self.rootDiskId = rootDiskId; self.disks = disks; self.desktop = desktop
        self.networkConfig = networkConfig; self.workloads = workloads; self.readyCheck = readyCheck
        self.idle = idle; self.macos = macos; self.enableKvm = enableKvm; self.kernelId = kernelId
        self.staticNetwork = staticNetwork; self.waitForInit = waitForInit; self.command = command
        self.ttlSeconds = ttlSeconds; self.additionalProperties = additionalProperties
    }

    public init(from decoder: Decoder) throws {
        var fields = try JSONFields(from: decoder)
        cpus = try fields.take("cpus", as: Int.self)
        memoryMb = try fields.take("memory_mb", as: Int.self)
        diskSizeMb = try fields.take("disk_size_mb", as: Int.self)
        ttlAction = try fields.take("ttl_action", as: TTLAction.self)
        removeOnExit = try fields.take("remove_on_exit", as: Bool.self)
        restartPolicy = try fields.take("restart_policy", as: RestartPolicy.self)
        maxRestarts = try fields.take("max_restarts", as: Int.self)
        keepLogs = try fields.take("keep_logs", as: Bool.self)
        sshAccess = try fields.take("ssh_access", as: Bool.self)
        rootDiskId = try fields.take("root_disk_id", as: String.self)
        disks = try fields.take("disks", as: [WorkspaceDiskAttachment].self)
        desktop = try fields.take("desktop", as: DesktopConfig.self)
        networkConfig = try fields.take("network_config", as: NetworkUpdateParams.self)
        workloads = try fields.take("workloads", as: [WorkloadCreateParams].self)
        readyCheck = try fields.take("ready_check", as: ReadyCheck.self)
        idle = try fields.take("idle", as: IdlePolicy.self)
        macos = try fields.take("macos", as: MacOSBootConfig.self)
        enableKvm = try fields.take("enable_kvm", as: Bool.self)
        kernelId = try fields.take("kernel_id", as: String.self)
        staticNetwork = try fields.take("static_network", as: Bool.self)
        waitForInit = try fields.take("wait_for_init", as: Bool.self)
        env = try environmentValues(fields.values.removeValue(forKey: "env"))
        let ttlValue = fields.values.removeValue(forKey: "ttl")
        ttl = ttlValue?.stringValue
        ttlSeconds = ttlValue?.intValue
        let commandValue = fields.values.removeValue(forKey: "cmd")
        command = commandValue?.stringValue
        if case .array = commandValue { cmd = try APIJSON.decode([String].self, APIJSON.encode(commandValue)) }
        additionalProperties = fields.values
    }

    public func encode(to encoder: Encoder) throws {
        var fields = JSONFields(additionalProperties)
        try fields.set("cpus", cpus)
        try fields.set("memory_mb", memoryMb)
        try fields.set("disk_size_mb", diskSizeMb)
        try fields.set("ttl_action", ttlAction)
        try fields.set("remove_on_exit", removeOnExit)
        try fields.set("restart_policy", restartPolicy)
        try fields.set("max_restarts", maxRestarts)
        try fields.set("keep_logs", keepLogs)
        try fields.set("ssh_access", sshAccess)
        try fields.set("root_disk_id", rootDiskId)
        try fields.set("disks", disks)
        try fields.set("desktop", desktop)
        try fields.set("network_config", networkConfig)
        try fields.set("workloads", workloads)
        try fields.set("ready_check", readyCheck)
        try fields.set("idle", idle)
        try fields.set("macos", macos)
        try fields.set("enable_kvm", enableKvm)
        try fields.set("kernel_id", kernelId)
        try fields.set("static_network", staticNetwork)
        try fields.set("wait_for_init", waitForInit)
        try fields.set("env", env?.map { "\($0.key)=\($0.value)" })
        if let ttlSeconds { try fields.set("ttl", ttlSeconds) } else { try fields.set("ttl", ttl) }
        if let command { try fields.set("cmd", command) } else { try fields.set("cmd", cmd) }
        try fields.encode(to: encoder)
    }
}

public struct EnvVar: Codable, Sendable {
    public var key: String
    public var value: String
    public init(key: String, value: String) { self.key = key; self.value = value }
}

public struct WorkspaceCreateParams: Codable, Sendable {
    public var name: String?
    public var slug: String?
    public var image: String?
    public var preset: String?
    public var namespace: String?
    public var mode: WorkspaceMode?
    public var type: String?
    public var config: WorkspaceConfig?
    public var waitReady: Bool?
    public var idempotencyKey: String?
    public var readyTimeoutSeconds: Int?
    public var cpus: Int?
    public var memoryMb: Int?
    public var diskSizeMb: Int?
    public var rootDiskId: String?
    public var disks: [WorkspaceDiskAttachment]?
    public var additionalProperties: [String: JSONValue] = [:]

    public init(image: String? = nil, name: String? = nil, slug: String? = nil, namespace: String? = nil,
                mode: WorkspaceMode? = nil, type: String? = nil, config: WorkspaceConfig? = nil,
                preset: String? = nil, waitReady: Bool? = nil, idempotencyKey: String? = nil,
                readyTimeoutSeconds: Int? = nil, cpus: Int? = nil, memoryMb: Int? = nil,
                diskSizeMb: Int? = nil, rootDiskId: String? = nil, disks: [WorkspaceDiskAttachment]? = nil,
                additionalProperties: [String: JSONValue] = [:]) {
        self.image = image; self.name = name; self.slug = slug; self.namespace = namespace
        self.mode = mode; self.type = type; self.config = config
        self.preset = preset; self.waitReady = waitReady; self.idempotencyKey = idempotencyKey
        self.readyTimeoutSeconds = readyTimeoutSeconds
        self.cpus = cpus; self.memoryMb = memoryMb; self.diskSizeMb = diskSizeMb
        self.rootDiskId = rootDiskId; self.disks = disks
        self.additionalProperties = additionalProperties
    }

    public init(from decoder: Decoder) throws {
        var fields = try JSONFields(from: decoder)
        name = try fields.take("name", as: String.self)
        slug = try fields.take("slug", as: String.self)
        image = try fields.take("image", as: String.self)
        preset = try fields.take("preset", as: String.self)
        namespace = try fields.take("namespace", as: String.self)
        mode = try fields.take("mode", as: WorkspaceMode.self)
        type = try fields.take("type", as: String.self)
        config = try fields.take("config", as: WorkspaceConfig.self)
        waitReady = try fields.take("wait_ready", as: Bool.self)
        idempotencyKey = try fields.take("idempotency_key", as: String.self)
        readyTimeoutSeconds = try fields.take("ready_timeout_seconds", as: Int.self)
        cpus = try fields.take("cpus", as: Int.self)
        memoryMb = try fields.take("memory_mb", as: Int.self)
        diskSizeMb = try fields.take("disk_size_mb", as: Int.self)
        rootDiskId = try fields.take("root_disk_id", as: String.self)
        disks = try fields.take("disks", as: [WorkspaceDiskAttachment].self)
        additionalProperties = fields.values
    }

    public func encode(to encoder: Encoder) throws {
        var fields = JSONFields(additionalProperties)
        try fields.set("name", name)
        try fields.set("slug", slug)
        try fields.set("image", image)
        try fields.set("preset", preset)
        try fields.set("namespace", namespace)
        try fields.set("mode", mode)
        try fields.set("type", type)
        try fields.set("config", config)
        try fields.set("wait_ready", waitReady)
        try fields.set("idempotency_key", idempotencyKey)
        try fields.set("ready_timeout_seconds", readyTimeoutSeconds)
        try fields.set("cpus", cpus)
        try fields.set("memory_mb", memoryMb)
        try fields.set("disk_size_mb", diskSizeMb)
        try fields.set("root_disk_id", rootDiskId)
        try fields.set("disks", disks)
        try fields.encode(to: encoder)
    }
}

public struct WorkspaceUpdateParams: Codable, Sendable {
    public var name: String?
    public var slug: String?
    public var logo: String?
    public var config: WorkspaceConfig?
    /// Nil leaves a field unchanged; these flags explicitly remove optional identity fields.
    public var clearSlug: Bool = false
    public var clearLogo: Bool = false
    public init(name: String? = nil, slug: String? = nil, config: WorkspaceConfig? = nil,
                logo: String? = nil, clearSlug: Bool = false, clearLogo: Bool = false) {
        self.name = name; self.slug = slug; self.config = config; self.logo = logo
        self.clearSlug = clearSlug; self.clearLogo = clearLogo
    }
    enum CodingKeys: String, CodingKey { case name, slug, logo, config }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(name, forKey: .name)
        try c.encodeIfPresent(config, forKey: .config)
        if clearSlug { try c.encodeNil(forKey: .slug) } else { try c.encodeIfPresent(slug, forKey: .slug) }
        if clearLogo { try c.encodeNil(forKey: .logo) } else { try c.encodeIfPresent(logo, forKey: .logo) }
    }
}

public struct WorkspaceListParams: Sendable {
    public var page: Int?
    public var limit: Int?
    public var mode: WorkspaceMode?
    public var status: String?
    public init(page: Int? = nil, limit: Int? = nil, mode: WorkspaceMode? = nil, status: String? = nil) {
        self.page = page; self.limit = limit; self.mode = mode; self.status = status
    }
    var query: [String: String?] {
        ["page": page.map(String.init), "limit": limit.map(String.init), "mode": mode?.rawValue, "status": status]
    }
}

// MARK: - Workspace (lenient — most fields optional for forward-compat)

public struct Workspace: Codable, Sendable {
    public let id: String
    public var name: String?
    public var slug: String?
    public var logo: String?
    public var namespace: String?
    public var mode: WorkspaceMode?
    public var image: String?
    public var ip: String?
    public var info: Info?
    public var resources: Resources?
    public var lifecycle: Lifecycle?
    public var config: WorkspaceConfig?
    public var imageCapabilities: [String]?
    public var ready: Bool?
    public var provisioning: Provisioning?
    public var createdAt: String?
    public var updatedAt: String?
    public var status: String?
    public var owner: AccountLabel?
    public var sharing: WorkspaceSharing?
    public var baseOs: Image.BaseOS?
    public var preset: WorkspacePreset?
    public var additionalProperties: [String: JSONValue] = [:]

    public struct Info: Codable, Sendable {
        public var status: String?       // running|stopped|paused|creating|starting|stopping
        public var isRunning: Bool?
        public var userRequestedStop: Bool?
        public var ready: Bool?
    }
    public struct Provisioning: Codable, Sendable {
        public var state: String?
        public var phase: String?
        public var stage: String?
        public var error: String?
        public var errorCode: String?
        public var message: String?
        public var createdAt: String?
        public var updatedAt: String?
        public var completedAt: String?
        enum CodingKeys: String, CodingKey { case state, phase, stage, error, message, createdAt, updatedAt, completedAt }
        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            state = try c.decodeIfPresent(String.self, forKey: .state)
            phase = try c.decodeIfPresent(String.self, forKey: .phase)
            stage = try c.decodeIfPresent(String.self, forKey: .stage)
            message = try c.decodeIfPresent(String.self, forKey: .message)
            createdAt = try c.decodeIfPresent(String.self, forKey: .createdAt)
            updatedAt = try c.decodeIfPresent(String.self, forKey: .updatedAt)
            completedAt = try c.decodeIfPresent(String.self, forKey: .completedAt)
            if let raw = try c.decodeIfPresent(JSONValue.self, forKey: .error) {
                error = raw.stringValue ?? raw["message"]?.stringValue
                errorCode = raw["code"]?.stringValue
            }
        }
        public func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encodeIfPresent(state, forKey: .state); try c.encodeIfPresent(phase, forKey: .phase)
            try c.encodeIfPresent(stage, forKey: .stage); try c.encodeIfPresent(message, forKey: .message)
            try c.encodeIfPresent(createdAt, forKey: .createdAt); try c.encodeIfPresent(updatedAt, forKey: .updatedAt)
            try c.encodeIfPresent(completedAt, forKey: .completedAt)
            if let errorCode { try c.encode(["code": errorCode, "message": error ?? ""], forKey: .error) }
            else { try c.encodeIfPresent(error, forKey: .error) }
        }
    }
    public var isRunning: Bool { info?.isRunning ?? ((info?.status ?? status) == "running") }

    public init(from decoder: Decoder) throws {
        var fields = try JSONFields(from: decoder)
        guard let requiredId = try fields.take("id", as: String.self) else {
            throw OblienError(kind: .decoding, status: nil, code: nil, message: "Missing workspace id.", details: nil)
        }
        id = requiredId
        name = try fields.take("name", as: String.self)
        slug = try fields.take("slug", as: String.self)
        logo = try fields.take("logo", as: String.self)
        namespace = try fields.take("namespace", as: String.self)
        mode = try fields.take("mode", as: WorkspaceMode.self)
        image = try fields.take("image", as: String.self)
        ip = try fields.take("ip", as: String.self)
        info = try fields.take("info", as: Info.self)
        resources = try fields.take("resources", as: Resources.self)
        lifecycle = try fields.take("lifecycle", as: Lifecycle.self)
        config = try fields.take("config", as: WorkspaceConfig.self)
        imageCapabilities = try fields.take("image_capabilities", as: [String].self)
        ready = try fields.take("ready", as: Bool.self)
        provisioning = try fields.take("provisioning", as: Provisioning.self)
        createdAt = try fields.take("created_at", as: String.self)
        updatedAt = try fields.take("updated_at", as: String.self)
        status = try fields.take("status", as: String.self)
        owner = try fields.take("owner", as: AccountLabel.self)
        sharing = try fields.take("sharing", as: WorkspaceSharing.self)
        baseOs = try fields.take("base_os", as: Image.BaseOS.self)
        preset = try fields.take("preset", as: WorkspacePreset.self)
        additionalProperties = fields.values
    }

    public func encode(to encoder: Encoder) throws {
        var fields = JSONFields(additionalProperties)
        try fields.set("id", id)
        try fields.set("name", name)
        try fields.set("slug", slug)
        try fields.set("logo", logo)
        try fields.set("namespace", namespace)
        try fields.set("mode", mode)
        try fields.set("image", image)
        try fields.set("ip", ip)
        try fields.set("info", info)
        try fields.set("resources", resources)
        try fields.set("lifecycle", lifecycle)
        try fields.set("config", config)
        try fields.set("image_capabilities", imageCapabilities)
        try fields.set("ready", ready)
        try fields.set("provisioning", provisioning)
        try fields.set("created_at", createdAt)
        try fields.set("updated_at", updatedAt)
        try fields.set("status", status)
        try fields.set("owner", owner)
        try fields.set("sharing", sharing)
        try fields.set("base_os", baseOs)
        try fields.set("preset", preset)
        try fields.encode(to: encoder)
    }
}

public struct WorkspaceList: Codable, Sendable {
    public let workspaces: [Workspace]
    public let total: Int?
    public let page: Int?
    public let limit: Int?
}

// MARK: - Resources

public struct Resources: Codable, Sendable {
    public var cpus: Int?
    public var memoryMb: Int?       // memory_mb
    public var diskSizeMb: Int?     // disk_size_mb
    public var status: String?
}

public struct ResourcePatch: Codable, Sendable {
    public var cpus: Int?
    public var memoryMb: Int?
    public var diskSizeMb: Int?
    public var apply: Bool?
    public init(cpus: Int? = nil, memoryMb: Int? = nil, diskSizeMb: Int? = nil, apply: Bool? = nil) {
        self.cpus = cpus; self.memoryMb = memoryMb; self.diskSizeMb = diskSizeMb; self.apply = apply
    }
}

public struct ResourceUpdateResult: Codable, Sendable {
    public let updated: Resources
    public let relaunched: Bool?
}

// MARK: - Network

public struct Network: Codable, Sendable {
    public var ip: String?
    public var gateway: String?
    public var publicAccess: Bool?
    public var allowInternet: Bool?
    public var ingressPorts: [Int]?
    public var egressPorts: [Int]?
    public var outboundIp: String?
    public var outboundMode: String?
    public var egress: [String]?
    public var outboundCountryCode: String?
    public var outboundProxy: OutboundProxy?
    public var privateLinks: [PrivateLink]?
    public struct OutboundProxy: Codable, Sendable {
        public var host: String?
        public var port: Int?
        public var `protocol`: String?
        public var hasCredentials: Bool?
    }
    public struct PrivateLink: Codable, Sendable {
        public var id: String?
        public var workspaceId: String?
        public var name: String?
        public var ip: String?
    }

    public var additionalProperties: [String: JSONValue] = [:]

    public init(from decoder: Decoder) throws {
        var fields = try JSONFields(from: decoder)
        ip = try fields.take("ip", as: String.self)
        gateway = try fields.take("gateway", as: String.self)
        publicAccess = try fields.take("public_access", as: Bool.self)
        allowInternet = try fields.take("allow_internet", as: Bool.self)
        ingressPorts = try fields.take("ingress_ports", as: [Int].self)
        egressPorts = try fields.take("egress_ports", as: [Int].self)
        outboundIp = try fields.take("outbound_ip", as: String.self)
        outboundMode = try fields.take("outbound_mode", as: String.self)
        egress = try fields.take("egress", as: [String].self)
        outboundCountryCode = try fields.take("outbound_country_code", as: String.self)
        outboundProxy = try fields.take("outbound_proxy", as: OutboundProxy.self)
        privateLinks = try fields.take("private_links", as: [PrivateLink].self)
        additionalProperties = fields.values
    }

    public func encode(to encoder: Encoder) throws {
        var fields = JSONFields(additionalProperties)
        try fields.set("ip", ip)
        try fields.set("gateway", gateway)
        try fields.set("public_access", publicAccess)
        try fields.set("allow_internet", allowInternet)
        try fields.set("ingress_ports", ingressPorts)
        try fields.set("egress_ports", egressPorts)
        try fields.set("outbound_ip", outboundIp)
        try fields.set("outbound_mode", outboundMode)
        try fields.set("egress", egress)
        try fields.set("outbound_country_code", outboundCountryCode)
        try fields.set("outbound_proxy", outboundProxy)
        try fields.set("private_links", privateLinks)
        try fields.encode(to: encoder)
    }
}

public struct NetworkUpdateParams: Codable, Sendable {
    public var allowInternet: Bool?
    public var publicAccess: Bool?
    public var ingressPorts: [Int]?
    public var egress: [String]?
    public var privateLinkIds: [String]?
    public var outboundMode: String?
    public var customProxy: CustomProxy?
    public var publicIngress: Bool?
    public struct CustomProxy: Codable, Sendable {
        public var host: String
        public var port: Int
        public var `protocol`: String
        public var username: String?
        public var password: String?
        public init(host: String, port: Int, protocol: String = "http", username: String? = nil, password: String? = nil) {
            self.host = host; self.port = port; self.protocol = `protocol`; self.username = username; self.password = password
        }
    }
    public init(allowInternet: Bool? = nil, publicAccess: Bool? = nil, ingressPorts: [Int]? = nil,
                egress: [String]? = nil, privateLinkIds: [String]? = nil, outboundMode: String? = nil,
                customProxy: CustomProxy? = nil, publicIngress: Bool? = nil) {
        self.allowInternet = allowInternet; self.publicAccess = publicAccess; self.ingressPorts = ingressPorts
        self.egress = egress; self.privateLinkIds = privateLinkIds; self.outboundMode = outboundMode
        self.customProxy = customProxy; self.publicIngress = publicIngress
    }
}

// MARK: - Public access

public struct ExposedPort: Codable, Sendable {
    public let port: Int
    public var hash: String?
    public var label: String?
    public var url: String?
    public var slug: String?
    public var domain: String?

    public var additionalProperties: [String: JSONValue] = [:]

    public init(from decoder: Decoder) throws {
        var fields = try JSONFields(from: decoder)
        port = try fields.required("port", as: Int.self)
        hash = try fields.take("hash", as: String.self)
        label = try fields.take("label", as: String.self)
        url = try fields.take("url", as: String.self)
        slug = try fields.take("slug", as: String.self)
        domain = try fields.take("domain", as: String.self)
        additionalProperties = fields.values
    }

    public func encode(to encoder: Encoder) throws {
        var fields = JSONFields(additionalProperties)
        try fields.set("port", port)
        try fields.set("hash", hash)
        try fields.set("label", label)
        try fields.set("url", url)
        try fields.set("slug", slug)
        try fields.set("domain", domain)
        try fields.encode(to: encoder)
    }
}

// MARK: - Runtime access tokens

public struct RuntimeAccessStatus: Codable, Sendable {
    public var enabled: Bool?
    public var running: Bool?
    public var token: String?

    public var additionalProperties: [String: JSONValue] = [:]

    public init(from decoder: Decoder) throws {
        var fields = try JSONFields(from: decoder)
        enabled = try fields.take("enabled", as: Bool.self)
        running = try fields.take("running", as: Bool.self)
        token = try fields.take("token", as: String.self)
        additionalProperties = fields.values
    }

    public func encode(to encoder: Encoder) throws {
        var fields = JSONFields(additionalProperties)
        try fields.set("enabled", enabled)
        try fields.set("running", running)
        try fields.set("token", token)
        try fields.encode(to: encoder)
    }
}

public struct RuntimeAccessToken: Codable, Sendable {
    public var enabled: Bool?
    public let token: String

    public var additionalProperties: [String: JSONValue] = [:]

    public init(from decoder: Decoder) throws {
        var fields = try JSONFields(from: decoder)
        enabled = try fields.take("enabled", as: Bool.self)
        token = try fields.required("token", as: String.self)
        additionalProperties = fields.values
    }

    public func encode(to encoder: Encoder) throws {
        var fields = JSONFields(additionalProperties)
        try fields.set("enabled", enabled)
        try fields.set("token", token)
        try fields.encode(to: encoder)
    }
}

public struct RawToken: Codable, Sendable {
    public let token: String
    public var ip: String?
    public var port: Int?

    public var additionalProperties: [String: JSONValue] = [:]

    public init(from decoder: Decoder) throws {
        var fields = try JSONFields(from: decoder)
        token = try fields.required("token", as: String.self)
        ip = try fields.take("ip", as: String.self)
        port = try fields.take("port", as: Int.self)
        additionalProperties = fields.values
    }

    public func encode(to encoder: Encoder) throws {
        var fields = JSONFields(additionalProperties)
        try fields.set("token", token)
        try fields.set("ip", ip)
        try fields.set("port", port)
        try fields.encode(to: encoder)
    }
}

public struct ScopedToken: Codable, Sendable {
    public let token: String
    public var expiresAt: String?
    public var scope: String?
    public var ttl: Int?
}

// MARK: - Images / quota / metrics

public struct Image: Codable, Sendable {
    public let id: String
    public var label: String?
    public var description: String?   // wire key is `desc`
    public var category: String?
    public var image: String?         // Docker ref, e.g. `node:22`
    public var logo: String?          // brand logo URL (png/ico/svg)
    public var color: String?         // brand hex
    public var capabilities: [String]?
    public var diskTargets: [DiskTarget]?
    public var baseOs: BaseOS?
    public var minimumMemoryMb: Int?
    public var preset: String?
    public var minimumResources: Resources?
    public var vmDefaults: WorkspaceConfig?
    public var software: [JSONValue]?
    public var revision: String?
    public var baseImage: String?
    public var boot: Boot?
    public var desktop: Desktop?

    /// Typed catalog software without changing the existing extensible representation.
    public var softwareMetadata: [CatalogSoftware]? {
        get { software.flatMap { try? OblienJSON.decode([CatalogSoftware].self, OblienJSON.encode($0)) } }
        set { software = newValue.flatMap { try? OblienJSON.decode([JSONValue].self, OblienJSON.encode($0)) } }
    }
    public struct Boot: Codable, Sendable {
        public var workloads: [[String: JSONValue]]?
        public var readyCheck: [String: JSONValue]?
    }
    public struct Desktop: Codable, Sendable {
        public var runtimeTarget: String?
        public var installable: Bool?
        public var prepared: Bool?
        public var vmDefaults: Resources?
        public var minimumResources: Resources?
        public var env: [Environment]?
        public struct Environment: Codable, Sendable {
            public let key: String
            public var desc: String?
            public let required: Bool
        }
    }

    public struct DiskTarget: Codable, Sendable {
        public let id: String
        public var label: String?
        public var formats: [String]?
    }
    public struct BaseOS: Codable, Sendable {
        public var family: String?
        public var distribution: String?
        public var version: String?
    }

    enum CodingKeys: String, CodingKey {
        case id, label, category, image, logo, color, capabilities, diskTargets, baseOs, minimumMemoryMb, preset, minimumResources, vmDefaults, software, revision, baseImage, boot, desktop
        case description = "desc"
    }
}

public struct CatalogSoftware: Codable, Sendable, Identifiable {
    public let id: String
    public let label: String
    public let readOnly: Bool
    public let sizeMb: Int
    public var role: String?
    public var target: String?
}

public struct WorkspacePreset: Codable, Sendable {
    public let id: String
    public let revision: String
    public let label: String
    public let baseImage: String
    public var logo: String?
    public var color: String?
    public let software: [CatalogSoftware]
}

public struct ImageCategory: Codable, Sendable {
    public let id: String
    public var label: String?
}

public struct ImageList: Codable, Sendable {
    public let images: [Image]
    public var categories: [ImageCategory]?   // objects `{id,label}`, not strings
}

public struct Quota: Codable, Sendable {
    public var plan: String?
    public var planLabel: String?
    public var maxSandboxes: Int?
    public var currentSandboxes: Int?
    public var maxWorkspaces: Int?
    public var currentWorkspaces: Int?
    public var limits: Resources?
    public var pool: Resources?
    public var poolUsage: Usage?
    public var runningPool: Resources?
    public var runningPoolUsage: Usage?
    public var canCreate: Bool?
    public var reason: String?
    public var additionalProperties: [String: JSONValue] = [:]

    public struct Usage: Codable, Sendable {
        public var count: Int?
        public var cpus: Int?
        public var memoryMb: Int?
        public var diskSizeMb: Int?
    }

    public init(from decoder: Decoder) throws {
        var fields = try JSONFields(from: decoder)
        plan = try fields.take("plan")
        planLabel = try fields.take("plan_label")
        maxSandboxes = try fields.take("max_sandboxes")
        currentSandboxes = try fields.take("current_sandboxes")
        maxWorkspaces = try fields.take("max_workspaces")
        currentWorkspaces = try fields.take("current_workspaces")
        limits = try fields.take("limits")
        pool = try fields.take("pool")
        poolUsage = try fields.take("pool_usage")
        runningPool = try fields.take("running_pool")
        runningPoolUsage = try fields.take("running_pool_usage")
        canCreate = try fields.take("can_create")
        reason = try fields.take("reason")
        additionalProperties = fields.values
    }

    public func encode(to encoder: Encoder) throws {
        var fields = JSONFields(additionalProperties)
        try fields.set("plan", plan)
        try fields.set("planLabel", planLabel)
        try fields.set("maxSandboxes", maxSandboxes)
        try fields.set("currentSandboxes", currentSandboxes)
        try fields.set("maxWorkspaces", maxWorkspaces)
        try fields.set("currentWorkspaces", currentWorkspaces)
        try fields.set("limits", limits)
        try fields.set("pool", pool)
        try fields.set("pool_usage", poolUsage)
        try fields.set("running_pool", runningPool)
        try fields.set("running_pool_usage", runningPoolUsage)
        try fields.set("canCreate", canCreate)
        try fields.set("reason", reason)
        try fields.encode(to: encoder)
    }
}

public struct Stats: Codable, Sendable {
    public var cpuUsage: Double?            // percent 0–100
    public var memoryUsage: Double?         // percent 0–100
    public var memoryUsedMB: Double?
    public var memoryTotalMB: Double?
    public var guestDiskUsedBytes: Double?
    public var guestDiskTotalBytes: Double?
    public var guestDiskUsedPct: Double?    // disk percent, direct
    public var networkInBytes: Double?      // cumulative
    public var networkOutBytes: Double?     // cumulative
    public var networkIn: Double?
    public var networkOut: Double?
    public var uptime: Int?
    public var diskUsage: Double?
    public var network: NetworkTraffic?
    public var timestamp: String?
    public struct NetworkTraffic: Codable, Sendable { public var rx: Double?; public var tx: Double? }
    enum CodingKeys: String, CodingKey {
        case cpuUsage, memoryUsage, guestDiskUsedBytes, guestDiskTotalBytes, guestDiskUsedPct,
             networkInBytes, networkOutBytes, networkIn, networkOut, uptime, diskUsage, network, timestamp
        case memoryUsedMB = "memoryUsedMb", memoryTotalMB = "memoryTotalMb"
    }

    public var additionalProperties: [String: JSONValue] = [:]

    public init(from decoder: Decoder) throws {
        var fields = try JSONFields(from: decoder)
        cpuUsage = try fields.take("cpu_usage", as: Double.self)
        memoryUsage = try fields.take("memory_usage", as: Double.self)
        memoryUsedMB = try fields.take("memory_used_mb", as: Double.self)
        memoryTotalMB = try fields.take("memory_total_mb", as: Double.self)
        guestDiskUsedBytes = try fields.take("guest_disk_used_bytes", as: Double.self)
        guestDiskTotalBytes = try fields.take("guest_disk_total_bytes", as: Double.self)
        guestDiskUsedPct = try fields.take("guest_disk_used_pct", as: Double.self)
        networkInBytes = try fields.take("network_in_bytes", as: Double.self)
        networkOutBytes = try fields.take("network_out_bytes", as: Double.self)
        networkIn = try fields.take("network_in", as: Double.self)
        networkOut = try fields.take("network_out", as: Double.self)
        uptime = try fields.take("uptime", as: Int.self)
        diskUsage = try fields.take("disk_usage", as: Double.self)
        network = try fields.take("network", as: NetworkTraffic.self)
        timestamp = try fields.take("timestamp", as: String.self)
        additionalProperties = fields.values
    }

    public func encode(to encoder: Encoder) throws {
        var fields = JSONFields(additionalProperties)
        try fields.set("cpu_usage", cpuUsage)
        try fields.set("memory_usage", memoryUsage)
        try fields.set("memory_used_mb", memoryUsedMB)
        try fields.set("memory_total_mb", memoryTotalMB)
        try fields.set("guest_disk_used_bytes", guestDiskUsedBytes)
        try fields.set("guest_disk_total_bytes", guestDiskTotalBytes)
        try fields.set("guest_disk_used_pct", guestDiskUsedPct)
        try fields.set("network_in_bytes", networkInBytes)
        try fields.set("network_out_bytes", networkOutBytes)
        try fields.set("network_in", networkIn)
        try fields.set("network_out", networkOut)
        try fields.set("uptime", uptime)
        try fields.set("disk_usage", diskUsage)
        try fields.set("network", network)
        try fields.set("timestamp", timestamp)
        try fields.encode(to: encoder)
    }
}

// MARK: - Runtime: exec

public enum ExecMode: String, Codable, Sendable { case auto, shell, direct, foreground, background }

public struct ExecTask: Codable, Sendable {
    public var id: String?
    public var command: [String]?
    public var status: String?       // pending|running|exited|failed
    public var guestPid: Int?
    public var exitCode: Int?
    public var stdout: String?
    public var stderr: String?
    public var error: String?
    public var createdAt: String?
    public var startedAt: String?
    public var exitedAt: String?
    public var ttlSeconds: Int?
}

// MARK: - Runtime: files

public struct FileEntry: Codable, Sendable {
    public let name: String
    public let path: String
    public let type: String          // "dir" / "directory" / "folder" — or "file"
    public var size: Int?
    public var modified: String?
    public var fileExtension: String?
    public var content: String?
    public var hash: String?
    public var children: [FileEntry]?

    enum CodingKeys: String, CodingKey {
        case name, path, type, size, modified, content, hash, children
        case fileExtension = "extension"
    }
    /// Lenient: the runtime has used "dir" and "directory" across versions; accept the common
    /// directory spellings so the file browser classifies folders correctly.
    public var isDirectory: Bool {
        switch type.lowercased() {
        case "dir", "directory", "folder", "d": return true
        default: return false
        }
    }
}

public struct FileListParams: Sendable {
    public var path: String
    public var nested: Bool?
    public var includeContent: Bool?
    public var maxDepth: Int?
    /// When false, gitignored entries are INCLUDED in the listing (the API omits them when true,
    /// which is the default). Diff the two to know what's ignored.
    public var useGitignore: Bool?
    /// Comma-separated glob patterns to exclude (e.g. ".git").
    public var ignorePatterns: String?
    /// Omit size/modified — a smaller payload when only names/paths are needed.
    public var light: Bool?
    public var flatten: Bool?
    public var includeHash: Bool?
    public var includeExtensions: Bool?
    public var codeFilesOnly: Bool?
    public var pathFilter: String?
    public var includeExt: String?
    public var maxContentBudget: Int?
    public init(path: String = "/", nested: Bool? = nil, includeContent: Bool? = nil, maxDepth: Int? = nil,
                useGitignore: Bool? = nil, ignorePatterns: String? = nil, light: Bool? = nil,
                flatten: Bool? = nil, includeHash: Bool? = nil, includeExtensions: Bool? = nil,
                codeFilesOnly: Bool? = nil, pathFilter: String? = nil, includeExt: String? = nil,
                maxContentBudget: Int? = nil) {
        self.path = path; self.nested = nested; self.includeContent = includeContent; self.maxDepth = maxDepth
        self.useGitignore = useGitignore; self.ignorePatterns = ignorePatterns; self.light = light
        self.flatten = flatten; self.includeHash = includeHash; self.includeExtensions = includeExtensions
        self.codeFilesOnly = codeFilesOnly; self.pathFilter = pathFilter; self.includeExt = includeExt
        self.maxContentBudget = maxContentBudget
    }
    var query: [String: String?] {
        ["path": path, "nested": nested.map(String.init),
         "include_content": includeContent.map(String.init), "max_depth": maxDepth.map(String.init),
         "use_gitignore": useGitignore.map(String.init), "ignore_patterns": ignorePatterns,
         "light": light.map(String.init), "flatten": flatten.map(String.init), "include_hash": includeHash.map(String.init),
         "include_extensions": includeExtensions.map(String.init), "code_files_only": codeFilesOnly.map(String.init),
         "path_filter": pathFilter, "include_ext": includeExt, "max_content_budget": maxContentBudget.map(String.init)]
    }
}

public struct FileListResult: Codable, Sendable {
    public var path: String?
    public var count: Int?
    public var entries: [FileEntry]
}

public struct FileRead: Codable, Sendable {
    public var path: String?
    public let content: String
    public var size: Int?
    public var lines: Int?
    public var fileExtension: String?
    public var startLine: Int?
    public var endLine: Int?
    enum CodingKeys: String, CodingKey {
        case path, content, size, lines, startLine, endLine
        case fileExtension = "extension"
    }
}

public struct FileWriteResult: Codable, Sendable {
    public var path: String?
    public var size: Int?
}

public struct FileStat: Codable, Sendable {
    public var path: String?
    public var name: String?
    public var type: String?
    public var size: Int?
    public var modified: String?
    public var permissions: String?
    public var isCode: Bool?
    public var fileExtension: String?
    public var symlinkTarget: String?
    enum CodingKeys: String, CodingKey {
        case path, name, type, size, modified, permissions, isCode, symlinkTarget
        case fileExtension = "extension"
    }
}

// MARK: - Runtime: terminal

public typealias TerminalCreateResult = TerminalSession
