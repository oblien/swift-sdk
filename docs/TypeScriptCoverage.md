# TypeScript SDK coverage

Reference: npm `oblien@2.8.0`, reviewed October 4, 2026. The checked-in inventory maps **362 portable methods/accessors** to Swift sources and identifies **two Node hosting helpers**. Declaration hashes include request/response types, nested options and event definitions so an upstream change requires another review.

This is API coverage, not a promise that every endpoint is enabled for every plan, credential scope, image or workspace runtime. UI clients should read capabilities and permissions, preserve durable operation IDs, and show the API's recoverable failure.

## API mapping

| TypeScript module | Swift implementation | Coverage |
| --- | --- | --- |
| client, tokens | `OblienClient`, `TokensAPI` | Identity changes, restore authentication, handles and scoped token creation |
| workspace, workspace-handle | `WorkspacesAPI`, `WorkspaceHandle`, `WorkspaceOptions` | CRUD, durable readiness/progress/retry, image catalog, presets, quota/pools, estimates, lifecycle and runtime cache |
| resources/* | Resource APIs bound to a workspace | CPU/RAM/disk, outbound/private network, public ports, DNS/SSL, SSH credentials, runtime tokens, idle/lifecycle, metadata, usage/metrics, archives/snapshots and logs |
| resources/workloads | `WorkloadsAPI`, `WorkloadStatistics`, `LogEvents` | Create/update/patch/delete/start/stop, targets/environment/cwd, command and restart options, retained/live logs, retention/clear, process stats streams with typed gateway/legacy decoding |
| resources/desktop | `DesktopAPI` | Installation options/status and native SSH connection grants |
| runtime | `RuntimeClient` | Standalone or managed tokens, discovery, health, OS/shell/capabilities, target clients, shared credential invalidation/TTL |
| runtime/files | `FilesAPI` | All 14 listing options, reads/ranges/line numbers, writing/appending/modes, mkdir/stat/delete, streaming listings, download/upload |
| runtime/exec | `ExecAPI`, `Streaming` | Command modes/timeouts/TTL/log settings, run/list/get/kill/stdin/deleteAll, task subscription, base64 stdout/stderr and exit events |
| runtime/terminal, runtime/ws | `TerminalAPI`, `TerminalMux` | Shell/command/size/scrollback options, sessions, binary input/output, resize, watcher and control events, reconnect settings |
| runtime/search, runtime/watcher | `SearchAPI`, `WatcherAPI` | All search and watcher options, initialization/status, typed results and socket events |
| runtime/proxy | `ProxyAPI`, `HTTPRedirectPolicy` | HTTP method/headers/body, response status/headers, raw streams/SSE, redirect policy and native WebSockets |
| runtime/transfer | `TransferAPI` | tar.gz paths/exclusions, streaming download, Data/file/InputStream upload, destination and byte progress |
| runtime/desktop | `RuntimeDesktopAPI` | Status/access/credentials and authenticated VNC WebSocket requests; independent of execution target |
| namespace | `NamespacesAPI` | CRUD/suspend/activate/stop workspaces, resources, activity, usage units, quota reset/defaults/auto-apply |
| pages, routes | `PagesAPI`, `RoutesAPI` | Page lifecycle and domains, route tables/versions/rollback, every route action and its nested options |
| edge-proxy, edge-tunnel | `EdgeProxyAPI`, `EdgeTunnelAPI` | Proxies, upstreams, verifications, tunnel CRUD/status and renewable connection tokens |
| domain | `AccountDomainsAPI` | Slug checks, DNS verification, domain routes, SSL inventory and automatic renewal settings |
| webhooks | `WebhooksAPI` | List/create/update/delete, event catalog, namespace filters, enabled state and secret options |
| billing | `BillingAPI` | Catalog/checkout/portal/subscription, credits/balance/entitlements, policies/defaults, usage and quotas |
| analytics | `AnalyticsAPI` | Summary, requests, timeseries, geography, filter/pagination options and stream tokens |
| cdn | `CDNAPI`, `CDNDomainsAPI` | Single/multiple uploads, remote URLs, processing variants/options, files/trash/restore, tags/stats/usage, quotas and domains |
| notifications | `NotificationsAPI` | Workspace send-token lifecycle, send requests and per-provider delivery errors |

The reviewed release includes persistent disks/software, desktop preparation, saved desktop sessions, account sharing, plan changes and terminal history controls. `DisksAPI` covers create/get/list/delete/copy/save/fork/resize/attach/detach/move, root retention, saved execution discard, software library and durable operation polling/retry. Saved desktops have independent IDs and lifecycles. Management and runtime clients share the same session API. Closing a viewer does not stop or delete its desktop. Console creation may omit resolution, and deletion may return a `deleting` session, as documented by the newer provider API.

## Native equivalents and boundaries

- JavaScript `Uint8Array`, Blob/File and readable streams map to `Data`, file URLs, `InputStream` factories and `AsyncThrowingStream<Data, Error>`.
- JS callbacks/async iterables map to Swift callbacks and async streams. Task cancellation closes local reads; it does not undo accepted workspace, disk, process or installation operations.
- Swift resource methods bind IDs on a handle. Some older convenience methods return the decoded resource or `Void` instead of `{ success, resource }`; throwing errors provide the failure signal. Full loose responses are retained by `APIResponse`/`JSONValue` where the contract is open-ended. `logs.files`, `logs.fileResponse`, exec stdin/deleteAll and raw proxy responses expose useful result metadata.
- Swift defaults to actor-owned runtime credential caches. `withToken`/`setToken` start a separate transport; existing handles retain their identity. Keep RuntimeClient references while using a workspace.
- `runtime.ws()` returns an unconnected socket so callbacks can be installed before `connect()`. The original Swift `terminalMux()` retains its connected behavior.
- `edgeTunnel.connect` hosts a tunnel from a Node process to local ports. Swift covers tunnel management and token/grant issuance; it does not run that Node tunnel host. A laptop can run the TypeScript host while its mobile client uses these management APIs.
- `runtime.desktop.tunnel` starts a Node localhost proxy server for a desktop viewer. Native clients use the SSH desktop grant for SSH/VNC, or the authenticated WebSocket request with their own viewer. The Swift SDK does not start a local Node proxy server or implement a VNC renderer.
- Node CLI, static-site server and MCP server launchers are not portable management/runtime APIs. They continue to run in their host environments.

The two host-side helpers are explicitly recorded in the audit, not silently counted as Swift implementations. The app-internal mobile device registry is a separate concern from workspace notification sending and is not part of this developer-facing endpoint guide.

## Wire behavior

Generated platform models use explicit CodingKeys for the API's mixed camel/snake casing. Workspace/runtime models keep compatibility with earlier Swift decoding. Nullable patches distinguish omission from explicit JSON null. Extensible dictionaries preserve literal unknown keys.

The transport isolates CDN-scoped bearer credentials from account credentials, strips credentials on cross-origin redirects, shares runtime token acquisition, and does not replay non-idempotent mutations after transient failures. It recognizes `success: false` even on HTTP 200. Proxy responses preserve upstream errors without replaying an upstream request.

Exec streams decode the actual JSON/base64 wire frames. Log following subscribes before loading history, emits a replacement snapshot and reconciles initial overlap. History seeding has a bounded buffer and fails with a reconnect error on overflow. Line/event limits protect parsers; this is not a guarantee of end-to-end backpressure for every consumer.

## Validation and maintenance

`swift test` runs wire-contract, retry, credentials, stream, log reconciliation, nullable model and lifecycle tests. The declaration audit is a drift check, not a network test:

```sh
npm pack oblien@2.8.0
# Extract the package, then:
NODE_PATH=/path/to/node_modules node scripts/audit-typescript-sdk.cjs /path/to/package/dist
```

`NODE_PATH` must contain TypeScript (the snapshot uses 6.0.3). To review an upgrade, inspect declaration changes, update implementations and tests, regenerate platform models with `scripts/generate-platform-models.cjs`, and only then use the audit's `--record` option. Preserve reviewed wire-format overrides in the model generator.

The SDK verification workflow runs the Swift tests, this audit and model-generation reproducibility against pinned npm references on pull requests and pushes to `main`.

Live tests are opt-in:

```sh
OBLIEN_LIVE_TOKEN_FILE=/secure/path/session \
OBLIEN_LIVE_ARTIFACT_DIR=/secure/path/results \
swift test --filter 'WorkspaceControlLiveTests|PlatformReadLiveTests'
```

`WorkspaceControlLiveTests` creates a disposable workspace and disks, writes an ID receipt for recovery, exercises runtime and infrastructure controls, and removes its fixtures. It incurs temporary resource usage. `PlatformReadLiveTests` performs account read groups. They do not alter existing workspaces or exercise destructive account/billing actions.

The verified workspace image currently rejects workload log retention/clear with HTTP 409 when its Oblien runtime agent is too old. The methods and wire contracts are implemented; upgrading that runtime is required to use them. This is reported as an unavailable backend capability, not a passing live mutation.

`withAccount` isolates management account headers and runtime caches. `access` supports invitations, member roles/expiry, shared workspaces, delegated SSH, token issuance and audit. `namespaces.usageData` exposes typed quota alerts while the older `usage` response remains available. Terminal scrollback changes require a matching server acknowledgment; an older runtime cannot silently report success.

The audit is pinned to published npm `oblien@2.8.0`, including capacity billing, network top-ups, savings, desktop deletion/resize capabilities and deletion progress.
