#!/usr/bin/env node
// Checks declaration drift and the reviewed Swift equivalents. This is a surface
// inventory, not a substitute for wire-contract and integration tests.
// Usage: NODE_PATH=<node_modules containing typescript> node scripts/audit-typescript-sdk.cjs <package>/dist
// After reviewing an upgrade, --record updates the declaration snapshot.
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const ts = require('typescript');
const dist = process.argv[2];
if (!dist) throw new Error('Pass the extracted oblien package dist directory');
const source = path.resolve(__dirname, '../Sources/OblienKit');
const snapshotPath = path.join(__dirname, 'typescript-surface.json');
const text = files => files.split(' ').map(file => fs.readFileSync(path.join(source, file + '.swift'), 'utf8')).join('\n');
// [Swift sources, method renames]. Swift binds resource IDs before calling methods.
const modules = {
  'access.d.ts': ['AccessAPI'],
  'analytics.d.ts': ['AnalyticsAPI'],
  'billing.d.ts': ['BillingAPI'],
  'cdn.d.ts': ['CDNAPI'],
  'client.d.ts': ['OblienClient PagesAPI'],
  'domain.d.ts': ['AccountDomainsAPI'],
  'disks.d.ts': ['DisksAPI'],
  'edge-proxy.d.ts': ['EdgeAPI'],
  'edge-tunnel.d.ts': ['EdgeAPI'],
  'namespace.d.ts': ['NamespacesAPI', { usage: 'usageData' }],
  'notifications.d.ts': ['NotificationsAPI'],
  'pages.d.ts': ['PagesAPI'],
  'routes.d.ts': ['PagesAPI'],
  'runtime.d.ts': ['RuntimeClient'],
  'tokens.d.ts': ['SubAPIs'],
  'webhooks.d.ts': ['WebhooksAPI'],
  'workspace.d.ts': ['WorkspacesAPI WorkspaceHandle Extras', { setTokenTtl: 'setTokenTTL' }],
  'workspace-handle.d.ts': ['WorkspaceHandle WorkspaceOptions'],
  'resources/api-access.d.ts': ['SubAPIs'],
  'resources/desktop.d.ts': ['DesktopAPI DesktopSessions'],
  'resources/domains.d.ts': ['DomainsAPI', { connect: 'set', disconnect: 'remove', checkDNS: 'check' }],
  'resources/images.d.ts': ['WorkspacesAPI', { list: 'images' }],
  'resources/lifecycle.d.ts': ['LifecycleAPI', { updateTtl: 'updateTTL' }],
  'resources/logs.d.ts': ['LogsAPI Streaming LogEvents'],
  'resources/metadata.d.ts': ['MetadataAPI'],
  'resources/metrics.d.ts': ['SubAPIs Extras Streaming'],
  'resources/network.d.ts': ['SubAPIs Extras RuntimeOptions'],
  'resources/public-access.d.ts': ['SubAPIs'],
  'resources/resources.d.ts': ['SubAPIs'],
  'resources/snapshots.d.ts': ['SnapshotsAPI', { create: 'snapshot' }],
  'resources/ssh.d.ts': ['SSHAPI'],
  'resources/usage.d.ts': ['UsageAPI', { global: 'usageGlobal' }],
  'resources/workloads.d.ts': ['WorkloadsAPI RuntimeOptions'],
  'runtime/desktop.d.ts': ['DesktopAPI DesktopSessions'],
  'runtime/exec.d.ts': ['RuntimeAPIs Extras Streaming'],
  'runtime/files.d.ts': ['RuntimeAPIs Streaming'],
  'runtime/proxy.d.ts': ['RuntimeAPIs', { ws: 'webSocket' }],
  'runtime/search.d.ts': ['RuntimeOptions', { init: 'install' }],
  'runtime/terminal.d.ts': ['RuntimeAPIs Extras RuntimeOptions'],
  'runtime/transfer.d.ts': ['TransferAPI'],
  'runtime/watcher.d.ts': ['RuntimeOptions RuntimeAPIs', { list: 'listWatchers', get: 'getWatcher' }],
  'runtime/ws.d.ts': ['TerminalMux'],
};
const boundaries = {
  'edge-tunnel.d.ts:EdgeTunnel.connect': 'Node local-port tunnel host; management and renewable tunnel grants are in EdgeTunnelAPI.',
  'runtime/desktop.d.ts:DesktopResource.tunnel': 'Node localhost WebSocket proxy server; native clients use DesktopAPI.sshConnection and SSH/VNC.',
};
const excludedFiles = new Set(['index.d.ts', 'http.d.ts', 'runtime-http.d.ts', 'error.d.ts', 'http-error.d.ts', 'base.d.ts']);
const printer = ts.createPrinter({ removeComments: true });
const snapshot = { version: JSON.parse(fs.readFileSync(path.join(dist, '../package.json'), 'utf8')).version, methods: {}, declarations: {} };
let portable = 0, bounded = 0;
for (const folder of ['', 'resources', 'runtime', 'types']) {
  for (const filename of fs.readdirSync(path.join(dist, folder)).filter(x => x.endsWith('.d.ts')).sort()) {
    if (excludedFiles.has(filename)) continue;
    const relative = path.join(folder, filename);
    const file = ts.createSourceFile(relative, fs.readFileSync(path.join(dist, relative), 'utf8'), ts.ScriptTarget.Latest, true);
    snapshot.declarations[relative] = crypto.createHash('sha256').update(printer.printFile(file)).digest('hex');
    for (const declaration of file.statements) {
      if (!ts.isClassDeclaration(declaration)) continue;
      for (const member of declaration.members) {
        if (ts.getJSDocTags(member).some(tag => tag.tagName.text === 'internal')) continue;
        if (!member.name || member.name.getText(file).startsWith('_') || member.modifiers?.some(m => [ts.SyntaxKind.PrivateKeyword, ts.SyntaxKind.ProtectedKeyword].includes(m.kind))) continue;
        if (!ts.isMethodDeclaration(member) && !ts.isGetAccessorDeclaration(member)) continue;
        const method = member.name.getText(file);
        const id = `${relative}:${declaration.name.text}.${method}`;
        const signature = printer.printNode(ts.EmitHint.Unspecified, member, file).replace(/\s+/g, ' ').trim();
        if (boundaries[id]) { snapshot.methods[id] = { signature, boundary: boundaries[id] }; bounded++; continue; }
        const mapping = modules[relative];
        if (!mapping) throw new Error(`Unreviewed API module: ${relative}`);
        const symbol = mapping[1]?.[method] ?? method;
        if (!new RegExp(`(?:func|var) ${symbol}\\b`).test(text(mapping[0]))) throw new Error(`Missing Swift equivalent for ${id}: ${symbol}`);
        snapshot.methods[id] = { signature, swift: symbol, sources: mapping[0] };
        portable++;
      }
    }
  }
}
if (process.argv.includes('--record')) {
  fs.writeFileSync(snapshotPath, JSON.stringify(snapshot, null, 2) + '\n');
} else {
  const previous = JSON.parse(fs.readFileSync(snapshotPath, 'utf8'));
  const changed = [];
  for (const group of ['methods', 'declarations']) {
    const keys = new Set([...Object.keys(previous[group]), ...Object.keys(snapshot[group])]);
    for (const key of keys) if (JSON.stringify(previous[group][key]) !== JSON.stringify(snapshot[group][key])) changed.push(`${group}: ${key}`);
  }
  if (previous.version !== snapshot.version) changed.push(`version: ${previous.version} → ${snapshot.version}`);
  if (changed.length) throw new Error('Review SDK parity before updating the snapshot:\n' + changed.join('\n'));
}
console.log(`oblien ${snapshot.version}: ${portable} portable methods/accessors mapped; ${bounded} Node hosting helpers documented.`);
