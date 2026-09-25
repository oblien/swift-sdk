// Models audited against oblien 2.4.0. Regenerate with scripts/generate-platform-models.cjs.
import Foundation

public struct RuntimeInfoBootSubsystem: Codable, Sendable {
    public var `subsystem`: String
    public var `state`: String
    @APINumber public var `supervisorPid`: Double
    @APIOptionalNumber public var `pid`: Double?
    @APINumber public var `attempts`: Int
    @APIOptionalNumber public var `exitCode`: Double?
    public var `updatedAt`: String

    public init(`subsystem`: String,
                `state`: String,
                `supervisorPid`: Double,
                `pid`: Double? = nil,
                `attempts`: Int,
                `exitCode`: Double? = nil,
                `updatedAt`: String) {
        self.`subsystem` = `subsystem`
        self.`state` = `state`
        self.`supervisorPid` = `supervisorPid`
        self.`pid` = `pid`
        self.`attempts` = `attempts`
        self.`exitCode` = `exitCode`
        self.`updatedAt` = `updatedAt`
    }

    enum CodingKeys: String, CodingKey {
        case `subsystem` = "subsystem"
        case `state` = "state"
        case `supervisorPid` = "supervisor_pid"
        case `pid` = "pid"
        case `attempts` = "attempts"
        case `exitCode` = "exit_code"
        case `updatedAt` = "updated_at"
    }
}

public struct RuntimeInfo: Codable, Sendable {
    public var `os`: String
    public var `arch`: String
    @APINumber public var `cpus`: Double
    public var `home`: String
    public var `shell`: String
    public var `agentSha256`: String?
    @APIOptionalNumber public var `protocolVersion`: Double?
    public var `capabilities`: [String]?
    public var `bootServices`: [String: RuntimeBootService]?
    public var `bootSubsystem`: RuntimeInfoBootSubsystem?

    public init(`os`: String,
                `arch`: String,
                `cpus`: Double,
                `home`: String,
                `shell`: String,
                `agentSha256`: String? = nil,
                `protocolVersion`: Double? = nil,
                `capabilities`: [String]? = nil,
                `bootServices`: [String: RuntimeBootService]? = nil,
                `bootSubsystem`: RuntimeInfoBootSubsystem? = nil) {
        self.`os` = `os`
        self.`arch` = `arch`
        self.`cpus` = `cpus`
        self.`home` = `home`
        self.`shell` = `shell`
        self.`agentSha256` = `agentSha256`
        self.`protocolVersion` = `protocolVersion`
        self.`capabilities` = `capabilities`
        self.`bootServices` = `bootServices`
        self.`bootSubsystem` = `bootSubsystem`
    }

    enum CodingKeys: String, CodingKey {
        case `os` = "os"
        case `arch` = "arch"
        case `cpus` = "cpus"
        case `home` = "home"
        case `shell` = "shell"
        case `agentSha256` = "agent_sha256"
        case `protocolVersion` = "protocol_version"
        case `capabilities` = "capabilities"
        case `bootServices` = "boot_services"
        case `bootSubsystem` = "boot_subsystem"
    }
}

public struct RuntimeBootService: Codable, Sendable {
    public var `subsystem`: String
    public var `state`: String
    @APINumber public var `supervisorPid`: Double
    @APIOptionalNumber public var `pid`: Double?
    @APINumber public var `attempts`: Int
    @APIOptionalNumber public var `exitCode`: Double?
    public var `updatedAt`: String

    public init(`subsystem`: String,
                `state`: String,
                `supervisorPid`: Double,
                `pid`: Double? = nil,
                `attempts`: Int,
                `exitCode`: Double? = nil,
                `updatedAt`: String) {
        self.`subsystem` = `subsystem`
        self.`state` = `state`
        self.`supervisorPid` = `supervisorPid`
        self.`pid` = `pid`
        self.`attempts` = `attempts`
        self.`exitCode` = `exitCode`
        self.`updatedAt` = `updatedAt`
    }

    enum CodingKeys: String, CodingKey {
        case `subsystem` = "subsystem"
        case `state` = "state"
        case `supervisorPid` = "supervisor_pid"
        case `pid` = "pid"
        case `attempts` = "attempts"
        case `exitCode` = "exit_code"
        case `updatedAt` = "updated_at"
    }
}

public struct RuntimeTarget: Codable, Sendable {
    public var `id`: String
    @APIBoolean public var `local`: Bool
    @APIBoolean public var `available`: Bool
    @APIOptionalNumber public var `version`: Int?
    public var `capabilities`: [String]?
    public var `runtime`: RuntimeInfo?
    public var `error`: String?

    public init(`id`: String,
                `local`: Bool,
                `available`: Bool,
                `version`: Int? = nil,
                `capabilities`: [String]? = nil,
                `runtime`: RuntimeInfo? = nil,
                `error`: String? = nil) {
        self.`id` = `id`
        self.`local` = `local`
        self.`available` = `available`
        self.`version` = `version`
        self.`capabilities` = `capabilities`
        self.`runtime` = `runtime`
        self.`error` = `error`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `local` = "local"
        case `available` = "available"
        case `version` = "version"
        case `capabilities` = "capabilities"
        case `runtime` = "runtime"
        case `error` = "error"
    }
}

public struct RuntimeDiscovery: Codable, Sendable {
    @APINumber public var `version`: Int
    public var `capabilities`: [String]?
    public var `defaultTarget`: String
    public var `aliases`: [String: String]?
    public var `targets`: [RuntimeTarget]

    public init(`version`: Int,
                `capabilities`: [String]? = nil,
                `defaultTarget`: String,
                `aliases`: [String: String]? = nil,
                `targets`: [RuntimeTarget]) {
        self.`version` = `version`
        self.`capabilities` = `capabilities`
        self.`defaultTarget` = `defaultTarget`
        self.`aliases` = `aliases`
        self.`targets` = `targets`
    }

    enum CodingKeys: String, CodingKey {
        case `version` = "version"
        case `capabilities` = "capabilities"
        case `defaultTarget` = "default_target"
        case `aliases` = "aliases"
        case `targets` = "targets"
    }
}

public struct ContentSearchParams: Codable, Sendable {
    public var `query`: String
    public var `path`: String?
    @APIOptionalBoolean public var `caseSensitive`: Bool?
    @APIOptionalBoolean public var `regex`: Bool?
    @APIOptionalBoolean public var `wholeWord`: Bool?
    @APIOptionalNumber public var `maxResults`: Double?
    @APIOptionalNumber public var `timeout`: Double?
    @APIOptionalNumber public var `contextLines`: Double?
    public var `fileTypes`: String?
    @APIOptionalBoolean public var `includeHidden`: Bool?
    @APIOptionalBoolean public var `noGitignore`: Bool?
    public var `ignorePatterns`: String?

    public init(`query`: String,
                `path`: String? = nil,
                `caseSensitive`: Bool? = nil,
                `regex`: Bool? = nil,
                `wholeWord`: Bool? = nil,
                `maxResults`: Double? = nil,
                `timeout`: Double? = nil,
                `contextLines`: Double? = nil,
                `fileTypes`: String? = nil,
                `includeHidden`: Bool? = nil,
                `noGitignore`: Bool? = nil,
                `ignorePatterns`: String? = nil) {
        self.`query` = `query`
        self.`path` = `path`
        self.`caseSensitive` = `caseSensitive`
        self.`regex` = `regex`
        self.`wholeWord` = `wholeWord`
        self.`maxResults` = `maxResults`
        self.`timeout` = `timeout`
        self.`contextLines` = `contextLines`
        self.`fileTypes` = `fileTypes`
        self.`includeHidden` = `includeHidden`
        self.`noGitignore` = `noGitignore`
        self.`ignorePatterns` = `ignorePatterns`
    }

    enum CodingKeys: String, CodingKey {
        case `query` = "query"
        case `path` = "path"
        case `caseSensitive` = "caseSensitive"
        case `regex` = "regex"
        case `wholeWord` = "wholeWord"
        case `maxResults` = "maxResults"
        case `timeout` = "timeout"
        case `contextLines` = "contextLines"
        case `fileTypes` = "fileTypes"
        case `includeHidden` = "includeHidden"
        case `noGitignore` = "noGitignore"
        case `ignorePatterns` = "ignorePatterns"
    }
}

public struct SearchMatch: Codable, Sendable {
    @APINumber public var `line`: Double
    @APIOptionalNumber public var `column`: Double?
    public var `text`: String

    public init(`line`: Double,
                `column`: Double? = nil,
                `text`: String) {
        self.`line` = `line`
        self.`column` = `column`
        self.`text` = `text`
    }

    enum CodingKeys: String, CodingKey {
        case `line` = "line"
        case `column` = "column"
        case `text` = "text"
    }
}

public struct ContentSearchResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `query`: String
    public var `path`: String
    public var `results`: [String: [SearchMatch]]
    @APINumber public var `totalMatches`: Double
    @APINumber public var `totalFiles`: Double
    @APIBoolean public var `capped`: Bool

    public init(`success`: Bool,
                `query`: String,
                `path`: String,
                `results`: [String: [SearchMatch]],
                `totalMatches`: Double,
                `totalFiles`: Double,
                `capped`: Bool) {
        self.`success` = `success`
        self.`query` = `query`
        self.`path` = `path`
        self.`results` = `results`
        self.`totalMatches` = `totalMatches`
        self.`totalFiles` = `totalFiles`
        self.`capped` = `capped`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `query` = "query"
        case `path` = "path"
        case `results` = "results"
        case `totalMatches` = "total_matches"
        case `totalFiles` = "total_files"
        case `capped` = "capped"
    }
}

public struct FileSearchParams: Codable, Sendable {
    public var `query`: String
    public var `path`: String?
    @APIOptionalBoolean public var `caseSensitive`: Bool?
    @APIOptionalBoolean public var `includeHidden`: Bool?
    @APIOptionalNumber public var `maxResults`: Double?
    public var `ignorePatterns`: String?

    public init(`query`: String,
                `path`: String? = nil,
                `caseSensitive`: Bool? = nil,
                `includeHidden`: Bool? = nil,
                `maxResults`: Double? = nil,
                `ignorePatterns`: String? = nil) {
        self.`query` = `query`
        self.`path` = `path`
        self.`caseSensitive` = `caseSensitive`
        self.`includeHidden` = `includeHidden`
        self.`maxResults` = `maxResults`
        self.`ignorePatterns` = `ignorePatterns`
    }

    enum CodingKeys: String, CodingKey {
        case `query` = "query"
        case `path` = "path"
        case `caseSensitive` = "caseSensitive"
        case `includeHidden` = "includeHidden"
        case `maxResults` = "maxResults"
        case `ignorePatterns` = "ignorePatterns"
    }
}

public struct FileSearchResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `query`: String
    public var `path`: String
    public var `files`: [String]
    @APINumber public var `totalFiles`: Double

    public init(`success`: Bool,
                `query`: String,
                `path`: String,
                `files`: [String],
                `totalFiles`: Double) {
        self.`success` = `success`
        self.`query` = `query`
        self.`path` = `path`
        self.`files` = `files`
        self.`totalFiles` = `totalFiles`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `query` = "query"
        case `path` = "path"
        case `files` = "files"
        case `totalFiles` = "total_files"
    }
}

public struct SearchStatusResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    @APIBoolean public var `installed`: Bool
    public var `path`: String?
    public var `version`: String?
    public var `message`: String?

    public init(`success`: Bool,
                `installed`: Bool,
                `path`: String? = nil,
                `version`: String? = nil,
                `message`: String? = nil) {
        self.`success` = `success`
        self.`installed` = `installed`
        self.`path` = `path`
        self.`version` = `version`
        self.`message` = `message`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `installed` = "installed"
        case `path` = "path"
        case `version` = "version"
        case `message` = "message"
    }
}

public struct SearchInitResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `path`: String?
    public var `version`: String?

    public init(`success`: Bool,
                `path`: String? = nil,
                `version`: String? = nil) {
        self.`success` = `success`
        self.`path` = `path`
        self.`version` = `version`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `path` = "path"
        case `version` = "version"
    }
}

public struct TerminalScrollbackResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `scrollback`: String
    @APINumber public var `size`: Int
    @APIBoolean public var `alive`: Bool
    @APINumber public var `exitCode`: Double

    public init(`success`: Bool,
                `scrollback`: String,
                `size`: Int,
                `alive`: Bool,
                `exitCode`: Double) {
        self.`success` = `success`
        self.`scrollback` = `scrollback`
        self.`size` = `size`
        self.`alive` = `alive`
        self.`exitCode` = `exitCode`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `scrollback` = "scrollback"
        case `size` = "size"
        case `alive` = "alive"
        case `exitCode` = "exit_code"
    }
}

public struct WatcherCreateParams: Codable, Sendable {
    public var `path`: String
    public var `root`: String?
    public var `excludes`: [String]?
    public var `exclude`: [String]?

    public init(`path`: String,
                `root`: String? = nil,
                `excludes`: [String]? = nil,
                `exclude`: [String]? = nil) {
        self.`path` = `path`
        self.`root` = `root`
        self.`excludes` = `excludes`
        self.`exclude` = `exclude`
    }

    enum CodingKeys: String, CodingKey {
        case `path` = "path"
        case `root` = "root"
        case `excludes` = "excludes"
        case `exclude` = "exclude"
    }
}

public struct WatcherInfo: Codable, Sendable {
    public var `id`: String
    public var `root`: String
    @APINumber public var `dirCount`: Int
    public var `excludes`: [String]?
    @APIOptionalBoolean public var `active`: Bool?

    public init(`id`: String,
                `root`: String,
                `dirCount`: Int,
                `excludes`: [String]? = nil,
                `active`: Bool? = nil) {
        self.`id` = `id`
        self.`root` = `root`
        self.`dirCount` = `dirCount`
        self.`excludes` = `excludes`
        self.`active` = `active`
    }

    enum CodingKeys: String, CodingKey {
        case `id` = "id"
        case `root` = "root"
        case `dirCount` = "dir_count"
        case `excludes` = "excludes"
        case `active` = "active"
    }
}

public struct WatcherListResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `watchers`: [WatcherInfo]

    public init(`success`: Bool,
                `watchers`: [WatcherInfo]) {
        self.`success` = `success`
        self.`watchers` = `watchers`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `watchers` = "watchers"
    }
}

public struct WSOptions: Codable, Sendable {
    @APIOptionalBoolean public var `reconnect`: Bool?
    @APIOptionalNumber public var `reconnectDelay`: Double?
    @APIOptionalNumber public var `maxReconnectAttempts`: Int?

    public init(`reconnect`: Bool? = nil,
                `reconnectDelay`: Double? = nil,
                `maxReconnectAttempts`: Int? = nil) {
        self.`reconnect` = `reconnect`
        self.`reconnectDelay` = `reconnectDelay`
        self.`maxReconnectAttempts` = `maxReconnectAttempts`
    }

    enum CodingKeys: String, CodingKey {
        case `reconnect` = "reconnect"
        case `reconnectDelay` = "reconnectDelay"
        case `maxReconnectAttempts` = "maxReconnectAttempts"
    }
}

public struct WSMessage: Codable, Sendable {
    public var `channel`: String
    public var additionalProperties: [String: JSONValue]

    public init(`channel`: String,
                additionalProperties: [String: JSONValue] = [:]) {
        self.`channel` = `channel`
        self.additionalProperties = additionalProperties
    }

    enum CodingKeys: String, CodingKey {
        case `channel` = "channel"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        `channel` = try c.decode(String.self, forKey: .`channel`)
        additionalProperties = try [String: JSONValue](from: decoder).filter { CodingKeys(rawValue: $0.key) == nil }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(`channel`, forKey: .`channel`)
        var extra = encoder.container(keyedBy: APIKey.self)
        for (key, value) in additionalProperties where CodingKeys(rawValue: key) == nil {
            try extra.encode(value, forKey: APIKey(key))
        }
    }
}

public struct WSTerminalExit: Codable, Sendable {
    public var `channel`: String
    public var `type`: String
    public var `id`: String
    @APINumber public var `code`: Double

    public init(`channel`: String = "terminal",
                `type`: String = "exit",
                `id`: String,
                `code`: Double) {
        self.`channel` = `channel`
        self.`type` = `type`
        self.`id` = `id`
        self.`code` = `code`
    }

    enum CodingKeys: String, CodingKey {
        case `channel` = "channel"
        case `type` = "type"
        case `id` = "id"
        case `code` = "code"
    }
}

public struct WSWatcherChange: Codable, Sendable {
    public var `channel`: String
    public var `type`: String
    public var `watcherId`: String
    public var `path`: String
    /// Accepted values: 'create' | 'write' | 'remove' | 'rename' | 'unknown'.
    public var `op`: String

    public init(`channel`: String = "watcher",
                `type`: String = "change",
                `watcherId`: String,
                `path`: String,
                `op`: String) {
        self.`channel` = `channel`
        self.`type` = `type`
        self.`watcherId` = `watcherId`
        self.`path` = `path`
        self.`op` = `op`
    }

    enum CodingKeys: String, CodingKey {
        case `channel` = "channel"
        case `type` = "type"
        case `watcherId` = "watcher_id"
        case `path` = "path"
        case `op` = "op"
    }
}

public struct WSWatcherReady: Codable, Sendable {
    public var `channel`: String
    public var `type`: String
    public var `watcherId`: String
    public var `root`: String
    @APINumber public var `dirs`: Double

    public init(`channel`: String = "watcher",
                `type`: String = "ready",
                `watcherId`: String,
                `root`: String,
                `dirs`: Double) {
        self.`channel` = `channel`
        self.`type` = `type`
        self.`watcherId` = `watcherId`
        self.`root` = `root`
        self.`dirs` = `dirs`
    }

    enum CodingKeys: String, CodingKey {
        case `channel` = "channel"
        case `type` = "type"
        case `watcherId` = "watcher_id"
        case `root` = "root"
        case `dirs` = "dirs"
    }
}

public struct TransferUploadResponse: Codable, Sendable {
    @APIBoolean public var `success`: Bool
    public var `dest`: String
    @APINumber public var `filesExtracted`: Double

    public init(`success`: Bool,
                `dest`: String,
                `filesExtracted`: Double) {
        self.`success` = `success`
        self.`dest` = `dest`
        self.`filesExtracted` = `filesExtracted`
    }

    enum CodingKeys: String, CodingKey {
        case `success` = "success"
        case `dest` = "dest"
        case `filesExtracted` = "files_extracted"
    }
}

public struct WSWatcherOverflow: Codable, Sendable {
    public var `channel`: String
    public var `type`: String
    public var `watcherId`: String
    public var `message`: String

    public init(`channel`: String = "watcher",
                `type`: String = "overflow",
                `watcherId`: String,
                `message`: String) {
        self.`channel` = `channel`
        self.`type` = `type`
        self.`watcherId` = `watcherId`
        self.`message` = `message`
    }

    enum CodingKeys: String, CodingKey {
        case `channel` = "channel"
        case `type` = "type"
        case `watcherId` = "watcher_id"
        case `message` = "message"
    }
}
