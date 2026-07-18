# OblienKit

A dependency-free Swift SDK for the [Oblien](https://oblien.com) API — isolated, secure
VMs for AI agents. Mirrors the official TypeScript `oblien` package: a client with
resource sub-APIs plus a per-workspace runtime client for files/exec/terminal.

Pure `Foundation` + `URLSession` async/await. `Codable` models (snake_case ⇄ camelCase),
typed `OblienError`, automatic retry (5xx/429) and bearer-session refresh.

## Install (Swift Package Manager)

```swift
.package(url: "https://github.com/oblien/oblien-swift.git", from: "0.1.0")
// target dependency: .product(name: "OblienKit", package: "oblien-swift")
```

## Usage

```swift
import OblienKit

// API key (account/admin) — or .init(token:) for a scoped token.
let client = OblienClient(clientId: "…", clientSecret: "…")

// Create + boot a workspace.
let ws = try await client.workspaces.create(.init(image: "node-20", config: .init(cpus: 1, memoryMb: 512)))
let handle = client.workspace(ws.id)
try await handle.start()

// Management sub-resources.
let resources = try await handle.resources.get()
let ports = try await handle.publicAccess.list()
_ = try await handle.publicAccess.expose(port: 3000, label: "web")

// Runtime (data plane) — gateway JWT is enabled + cached automatically.
let rt = try await handle.runtime()
let result = try await rt.exec.run(["node", "-v"])      // result.stdout / .exitCode
try await rt.files.write(fullPath: "/app/hello.js", content: "console.log('hi')")
let listing = try await rt.files.list(path: "/app")

// Live terminal over the binary WebSocket.
let term = try await rt.openTerminal(cols: 80, rows: 24)
term.onData = { data in /* decode UTF-8, render */ }
term.send("ls -la\n")

await handle.delete() // try await
```

### Authentication

`OblienAuth` supports three schemes:

- `.apiKey(clientId:clientSecret:)` → `X-Client-ID` / `X-Client-Secret`
- `.scopedToken(_:)` → `Authorization: Bearer <jwt>` (mint via `client.tokens.create(...)`)
- `.bearerSession { forceRefresh in … }` → app-managed bearer (e.g. an anonymous session
  token); refreshed once on a 401.

```swift
let client = OblienClient(.init(auth: .bearerSession { force in try await myTokenStore.token(force) }))
```

## Surface (full documented API)

Management (`client.workspaces.*` and the scoped `client.workspace(id)` handle):

- **workspaces** — create · list · get · getDetails · getEstimate · update · delete · getQuota · images · archived
- **lifecycle** — start · stop · restart · pause · resume · ping · get · makePermanent · makeTemporary · updateTTL · destroy
- **resources** — get · update · patch
- **network** — get · update · applyOutboundIp · zones
- **publicAccess** — list · expose · updateSlug · revoke
- **domains** — get · set · remove · check · renewSSL · checkSlug · verifyDomain
- **ssh** — status · enable · disable · setPassword · setKey
- **snapshots** — snapshot · restore · createArchive · listArchives · getArchive · deleteArchive · deleteAllArchives
- **runtimeAccess** — status · enable · disable · getToken · rotateToken · rawToken · reconnect · workspaceToken
- **metadata** — get · update · patch
- **logs** — get · clear · listFiles · getFile · streamBoot · streamCmd
- **usage** — get · totals · creditsChart · startTracking · stopTracking · wipe · usageGlobal · activity
- **metrics** — stats · statsStream · info · config
- **workloads** — create · list · get · update · patch · delete · deleteAll · start · stop · status · logs · stats
- `client.tokens.create(...)` — scoped tokens

Runtime data plane (`let rt = try await handle.runtime()`):

- **rt.files** — list · read · write · mkdir · stat · delete · streamList · download · upload
- **rt.exec** — run · list · get · kill · input · deleteAll · stream
- **rt.terminal** — create · list · close · scrollback (+ `rt.openTerminal()` → live `TerminalConnection` over the binary WebSocket)
- **rt.search** — files · content · initStatus · initialize
- **rt.watcher** — create · list · get · delete
- `rt.websocketURL()` · `rt.token()`

## License

AGPL-3.0
