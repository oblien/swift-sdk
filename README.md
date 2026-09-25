# OblienKit

A Swift SDK for [Oblien](https://oblien.com), using Foundation, URLSession and async/await. Supports iOS 16+ and macOS 12+ without third-party dependencies.

The management and runtime APIs cover the portable surface of the TypeScript `oblien` SDK **2.4.0**. They also include the current disk and desktop installation APIs. See [TypeScript coverage](docs/TypeScriptCoverage.md) for the API mapping, native equivalents, verification, and platform boundaries.

## Install

```swift
.package(url: "https://github.com/oblien/swift-sdk.git", branch: "main")
// Target dependency:
.product(name: "OblienKit", package: "swift-sdk")
```

Applications can pin a reviewed commit using Swift Package Manager's `revision:` requirement.

## Create and use a workspace

```swift
import OblienKit

let client = OblienClient(clientId: "CLIENT_ID", clientSecret: "CLIENT_SECRET")
let workspace = try await client.workspaces.create(.init(
    image: "oblien/node:24",
    name: "Development",
    config: .init(cpus: 2, memoryMb: 4096, diskSizeMb: 20480),
    idempotencyKey: UUID().uuidString
))
// create waits for readiness by default. Keep the key for retries of this creation.
let handle = client.workspace(workspace.id)
let runtime = try await handle.runtime()
let result = try await runtime.exec.run(["node", "--version"])
let file = try await runtime.files.write(
    fullPath: "/app/hello.js", content: "console.log('hello')", createDirs: true
)
let listing = try await runtime.files.list(path: "/app")
```

Set `waitReady: false` to return the accepted workspace immediately. Resume progress with `handle.waitUntilReady(options:)`; cancelling the wait leaves creation running on Oblien. Catalog entries have a display `id`, an `image` reference, optional `preset`, resource minimums and VM defaults. Preserve the preset when creating from a catalog entry.

## Authentication and runtime ownership

The client supports API keys, scoped bearer tokens, and app-managed bearer sessions:

```swift
let client = OblienClient(.init(auth: .bearerSession { forceRefresh in
    try await mySession.token(forceRefresh: forceRefresh)
}))
```

`withToken(_:)` creates an independent identity. Mutating `setToken(_:)` and `restoreAuth()` replace the client's transport; handles already created from it retain their original credentials. Discard handles on sign-out. Inject a URLSession through `OblienClient(configuration, session:)` for custom networking or tests.

Retain and reuse a RuntimeClient. It shares credential acquisition between concurrent calls and target clients, refreshes rejected gateway credentials, and caches tokens for the configured TTL. `handle.runtime(enableIfNeeded: false)` respects disabled runtime access. `runtime.invalidate()` clears cached credentials. A standalone `RuntimeClient(token:baseURL:session:)` accepts an existing scoped runtime token.

## Streams and native sockets

```swift
for try await event in runtime.exec.stream(["npm", "test"], keepLogs: false) {
    if let text = event.text { /* render stdout/stderr */ }
    if let code = event.exitCode { /* command completed */ }
}

let terminal = try await runtime.terminal.create(cols: 80, rows: 24, shell: "/bin/sh")
let socket = try await runtime.ws()
socket.onTerminalOutput = { id, bytes in /* route bytes to the matching terminal */ }
socket.onWatcherEvent = { event in /* refresh the changed path */ }
socket.connect() // Install callbacks first; ws() does not connect automatically.
socket.writeTerminalInput(terminal.id, "pwd\n")
```

Use one multiplexed socket per runtime. `WSOptions` controls reconnect behavior; the older `terminalMux()` convenience still connects automatically. `forTarget(_:)` selects files, exec, terminal, search, watcher and proxy traffic. Desktop access always belongs to the root runtime.

`handle.workloads.followLogs(id)` and `handle.logs.follow()` subscribe before reading retained history, emit an initial `cleared` snapshot, then reconcile the historical/live boundary. Cancel a consuming task to stop its subscription. The lower-level stream methods remain available for future events only.

`runtime.proxy(port).fetch` preserves upstream status, headers and body, including errors. `fetchStream` returns incremental bytes. Both accept redirect policies. Upstream authentication failures do not replay a proxied POST. `webSocket` provides the native URLSession equivalent of the TypeScript proxy socket.

`runtime.transfer` downloads tar.gz chunks and uploads Data, file URLs, or a fresh InputStream factory, with measured byte progress.

## Management APIs

| Area | Swift entry point |
| --- | --- |
| Workspaces, image catalog, quota, estimates, readiness, archives | `client.workspaces` |
| Resources, lifecycle/idle, network, public ports, domains, SSH, runtime access, metadata, logs, metrics, usage, workloads, backups | `client.workspace(id)` |
| Persistent disks, saved roots, copies/forks, moves, software, operation polling/retry | `client.disks`, `handle.disks` |
| Desktop preparation, installation status and native SSH grants | `handle.desktop` |
| Desktop availability, enable/disable, credentials and VNC socket requests | `runtime.desktop` |
| Namespaces, quotas and defaults | `client.namespaces` |
| Pages and route rules | `client.pages`, `client.routes` |
| Edge proxies, verifications and tunnel management | `client.edgeProxy`, `client.edgeTunnel` |
| Account domains, DNS verification, SSL and routing | `client.domain` |
| Webhooks and event catalog | `client.webhooks` |
| Billing, entitlements, credits, quota policies and defaults | `client.billing` |
| Analytics and stream grants | `client.analytics` |
| CDN uploads, URL processing, files, quotas, usage and domains | `client.cdn` |
| Scoped tokens and workspace notifications | `client.tokens`, `client.notifications` |

Disk mutations return durable operation IDs. Reuse a `DiskOperationOptions.idempotencyKey` for retries of an uncertain request. Wait, inspect failure, or resume with `client.disks.operation(id)`; cancelling a wait does not cancel the server operation. Only reads and explicitly idempotent mutations receive automatic transient retries.

Models preserve documented casing and nullable patch semantics. Use `JSONField.null` when a patch must explicitly clear a nullable value; `nil` omits it. Extensible response/configuration types expose `additionalProperties` for unknown fields. Errors use `OblienError` and do not include entire response bodies.

## Verification

```sh
swift test
NODE_PATH=/path/to/node_modules node scripts/audit-typescript-sdk.cjs /path/to/oblien/dist
```

The audit compares declarations and the reviewed Swift method mapping with a checked-in 2.4.0 snapshot. Optional live tests require `OBLIEN_LIVE_TOKEN_FILE`; see the coverage document before running them.

## License

MIT
