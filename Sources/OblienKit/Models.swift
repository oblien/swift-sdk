import Foundation

// MARK: - Enums

public enum WorkspaceMode: String, Codable, Sendable { case permanent, temporary }
public enum TTLAction: String, Codable, Sendable { case stop, pause, remove }
public enum RestartPolicy: String, Codable, Sendable {
    case no, always
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

    public init(cpus: Int? = nil, memoryMb: Int? = nil, diskSizeMb: Int? = nil, ttl: String? = nil,
                ttlAction: TTLAction? = nil, removeOnExit: Bool? = nil, restartPolicy: RestartPolicy? = nil,
                maxRestarts: Int? = nil, keepLogs: Bool? = nil, sshAccess: Bool? = nil,
                env: [EnvVar]? = nil, cmd: [String]? = nil) {
        self.cpus = cpus; self.memoryMb = memoryMb; self.diskSizeMb = diskSizeMb; self.ttl = ttl
        self.ttlAction = ttlAction; self.removeOnExit = removeOnExit; self.restartPolicy = restartPolicy
        self.maxRestarts = maxRestarts; self.keepLogs = keepLogs; self.sshAccess = sshAccess
        self.env = env; self.cmd = cmd
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
    public var image: String
    public var namespace: String?
    public var mode: WorkspaceMode?
    public var type: String?
    public var config: WorkspaceConfig?

    public init(image: String, name: String? = nil, slug: String? = nil, namespace: String? = nil,
                mode: WorkspaceMode? = nil, type: String? = nil, config: WorkspaceConfig? = nil) {
        self.image = image; self.name = name; self.slug = slug; self.namespace = namespace
        self.mode = mode; self.type = type; self.config = config
    }
}

public struct WorkspaceUpdateParams: Codable, Sendable {
    public var name: String?
    public var slug: String?
    public var config: WorkspaceConfig?
    public init(name: String? = nil, slug: String? = nil, config: WorkspaceConfig? = nil) {
        self.name = name; self.slug = slug; self.config = config
    }
}

public struct WorkspaceListParams: Sendable {
    public var page: Int?
    public var limit: Int?
    public var mode: WorkspaceMode?
    public init(page: Int? = nil, limit: Int? = nil, mode: WorkspaceMode? = nil) {
        self.page = page; self.limit = limit; self.mode = mode
    }
    var query: [String: String?] {
        ["page": page.map(String.init), "limit": limit.map(String.init), "mode": mode?.rawValue]
    }
}

// MARK: - Workspace (lenient — most fields optional for forward-compat)

public struct Workspace: Codable, Sendable {
    public let id: String
    public var name: String?
    public var namespace: String?
    public var mode: WorkspaceMode?
    public var image: String?
    public var ip: String?
    public var info: Info?
    public var resources: Resources?
    public var createdAt: String?
    public var updatedAt: String?

    public struct Info: Codable, Sendable {
        public var status: String?       // running|stopped|paused|creating|starting|stopping
        public var isRunning: Bool?
        public var userRequestedStop: Bool?
    }
    public var isRunning: Bool { info?.isRunning ?? (info?.status == "running") }
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
}

public struct NetworkUpdateParams: Codable, Sendable {
    public var allowInternet: Bool?
    public var publicAccess: Bool?
    public var ingressPorts: [Int]?
    public var egress: [String]?
    public var privateLinkIds: [String]?
    public var outboundMode: String?
    public init(allowInternet: Bool? = nil, publicAccess: Bool? = nil, ingressPorts: [Int]? = nil,
                egress: [String]? = nil, privateLinkIds: [String]? = nil, outboundMode: String? = nil) {
        self.allowInternet = allowInternet; self.publicAccess = publicAccess; self.ingressPorts = ingressPorts
        self.egress = egress; self.privateLinkIds = privateLinkIds; self.outboundMode = outboundMode
    }
}

// MARK: - Public access

public struct ExposedPort: Codable, Sendable {
    public let port: Int
    public var hash: String?
    public var label: String?
    public var url: String?
    public var slug: String?
}

// MARK: - Runtime access tokens

public struct RuntimeAccessStatus: Codable, Sendable {
    public var enabled: Bool?
    public var running: Bool?
}

public struct RuntimeAccessToken: Codable, Sendable {
    public var enabled: Bool?
    public let token: String
}

public struct RawToken: Codable, Sendable {
    public let token: String
    public var ip: String?
    public var port: Int?
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

    enum CodingKeys: String, CodingKey {
        case id, label, category, image, logo, color
        case description = "desc"
    }
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
    public var maxSandboxes: Int?
    public var currentSandboxes: Int?
    public var canCreate: Bool?
    public var reason: String?
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
}

// MARK: - Runtime: exec

public enum ExecMode: String, Codable, Sendable { case auto, foreground, background }

public struct ExecTask: Codable, Sendable {
    public var id: String?
    public var command: [String]?
    public var status: String?       // pending|running|exited|failed
    public var guestPid: Int?
    public var exitCode: Int?
    public var stdout: String?
    public var stderr: String?
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
    public init(path: String, nested: Bool? = nil, includeContent: Bool? = nil, maxDepth: Int? = nil,
                useGitignore: Bool? = nil, ignorePatterns: String? = nil, light: Bool? = nil) {
        self.path = path; self.nested = nested; self.includeContent = includeContent; self.maxDepth = maxDepth
        self.useGitignore = useGitignore; self.ignorePatterns = ignorePatterns; self.light = light
    }
    var query: [String: String?] {
        ["path": path, "nested": nested.map(String.init),
         "include_content": includeContent.map(String.init), "max_depth": maxDepth.map(String.init),
         "use_gitignore": useGitignore.map(String.init), "ignore_patterns": ignorePatterns,
         "light": light.map(String.init)]
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
}

// MARK: - Runtime: terminal

public struct TerminalCreateResult: Codable, Sendable {
    /// Multiplexing id used as the leading byte of binary WS frames. Accepts a number or string.
    public let id: Int
    public var cols: Int?
    public var rows: Int?
    public var command: [String]?

    enum CodingKeys: String, CodingKey { case id, cols, rows, command }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let i = try? c.decode(Int.self, forKey: .id) { id = i }
        else if let s = try? c.decode(String.self, forKey: .id), let i = Int(s) { id = i }
        else { id = 1 }
        cols = try? c.decodeIfPresent(Int.self, forKey: .cols)
        rows = try? c.decodeIfPresent(Int.self, forKey: .rows)
        command = try? c.decodeIfPresent([String].self, forKey: .command)
    }
}
