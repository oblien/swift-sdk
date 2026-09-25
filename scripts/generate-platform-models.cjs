#!/usr/bin/env node
// Regenerates the portable account API models from the published oblien declarations.
// Usage: NODE_PATH=<directory containing typescript> node scripts/generate-platform-models.cjs <package>/dist
// API behavior and polymorphic route actions are maintained separately and tested against the wire contract.
const ts = require('typescript');
const fs = require('fs');
const path = require('path');
const root = process.argv[2];
if (!root) throw new Error('Pass the extracted oblien package dist directory');
const groups = ['namespace', 'pages', 'edge-proxy', 'edge-tunnel', 'webhooks', 'analytics', 'billing', 'cdn', 'notifications'];
const extra = ['CheckSlugParams', 'CheckSlugResponse', 'VerifyDomainParams', 'VerifyDomainResponse',
  'DomainListParams', 'DomainRoute', 'DomainRoutesResponse', 'SslCertificate', 'SslListResponse', 'SslAutoRenewResponse'];
const runtimeTypes = ['RuntimeInfo', 'RuntimeBootService', 'RuntimeTarget', 'RuntimeDiscovery',
  'ContentSearchParams', 'SearchMatch', 'ContentSearchResponse', 'FileSearchParams', 'FileSearchResponse',
  'SearchStatusResponse', 'SearchInitResponse', 'WatcherCreateParams', 'WatcherInfo', 'WatcherListResponse',
  'TerminalScrollbackResponse', 'WSWatcherChange', 'WSWatcherReady', 'WSWatcherOverflow', 'WSOptions',
  'WSMessage', 'WSTerminalExit', 'TransferUploadResponse'];
const inputs = [...groups, 'workspace-resources', 'runtime'].map(n => path.join(root, 'types', n + '.d.ts'));
const program = ts.createProgram(inputs, { target: ts.ScriptTarget.ESNext, module: ts.ModuleKind.NodeNext,
  moduleResolution: ts.ModuleResolutionKind.NodeNext, skipLibCheck: true });
const checker = program.getTypeChecker();
const declarations = new Map();
for (const input of inputs) {
  for (const node of program.getSourceFile(input).statements) {
    if (node.name && (ts.isInterfaceDeclaration(node) || ts.isTypeAliasDeclaration(node))) declarations.set(node.name.text, node);
  }
}
const manual = new Set(['RouteAction', 'CdnUploadInput']);
const outDir = path.resolve(__dirname, '../Sources/OblienKit/PlatformModels');
fs.mkdirSync(outDir, { recursive: true });
const upper = s => s[0].toUpperCase() + s.slice(1);
const camel = s => s.replace(/_([a-z])/g, (_, c) => c.toUpperCase());
const ident = s => '`' + camel(s) + '`';
const rendered = new Set();
let blocks = [];
function numberType(key) {
  return /(?:^id$|port$|count$|^limit$|^offset$|^page$|^total$|^version$|size$|bytes$|width$|height$|attempts$|percent$|quality$|^maxBatch$|^concurrency$|^maxFiles$|^ttl$|Seconds$|Mb$|Gb$|^maxWorkspaces$|^maxVcpus$)/i.test(camel(key)) ? 'Int' : 'Double';
}
function isNull(node) { return node.kind === ts.SyntaxKind.NullKeyword || (ts.isLiteralTypeNode(node) && node.literal.kind === ts.SyntaxKind.NullKeyword); }
function renderType(node, name, key) {
  if (!node) throw new Error('Missing type: ' + name);
  if (ts.isParenthesizedTypeNode(node)) return renderType(node.type, name, key);
  if (node.kind === ts.SyntaxKind.StringKeyword) return 'String';
  if (node.kind === ts.SyntaxKind.NumberKeyword) return numberType(key);
  if (node.kind === ts.SyntaxKind.BooleanKeyword) return 'Bool';
  if ([ts.SyntaxKind.UnknownKeyword, ts.SyntaxKind.AnyKeyword, ts.SyntaxKind.NeverKeyword].includes(node.kind)) return 'JSONValue';
  if (ts.isLiteralTypeNode(node)) {
    if (ts.isStringLiteral(node.literal)) return 'String';
    if (ts.isNumericLiteral(node.literal)) return 'Int';
    if ([ts.SyntaxKind.TrueKeyword, ts.SyntaxKind.FalseKeyword].includes(node.literal.kind)) return 'Bool';
  }
  if (ts.isUnionTypeNode(node)) {
    const nodes = node.types.filter(n => !isNull(n) && n.kind !== ts.SyntaxKind.UndefinedKeyword);
    if (nodes.length === 1) return renderType(nodes[0], name, key);
    const primitives = nodes.map(n => ts.isLiteralTypeNode(n) ?
      (ts.isStringLiteral(n.literal) ? 'String' : ts.isNumericLiteral(n.literal) ? 'Int' : 'Bool') :
      n.kind === ts.SyntaxKind.StringKeyword ? 'String' : n.kind === ts.SyntaxKind.NumberKeyword ? numberType(key) : undefined);
    if (primitives.every(t => t && t === primitives[0])) return primitives[0];
    // JSON scalar unions retain the exact number/string wire representation.
    if (primitives.every(Boolean)) return 'JSONValue';
    throw new Error('Unmodeled union: ' + name + ': ' + node.getText());
  }
  if (ts.isArrayTypeNode(node)) return '[' + renderType(node.elementType, name + 'Item', key) + ']';
  if (ts.isTypeReferenceNode(node)) {
    const ref = node.typeName.getText();
    if (ref === 'Record') return '[String: ' + renderType(node.typeArguments[1], name + 'Value', key) + ']';
    if (ref === 'Array') return '[' + renderType(node.typeArguments[0], name + 'Item', key) + ']';
    if (ref === 'Omit' || ref === 'Pick') { renderStruct(name, node, checker.getTypeAtLocation(node)); return name; }
    if (declarations.has(ref) || manual.has(ref)) return ref;
    throw new Error('Unresolved type ' + ref + ' in ' + name);
  }
  if (ts.isTypeLiteralNode(node) || ts.isIntersectionTypeNode(node)) {
    renderStruct(name, node, checker.getTypeAtLocation(node)); return name;
  }
  throw new Error('Unsupported type: ' + name + ': ' + node.getText());
}
function renderStruct(name, node, type = checker.getTypeAtLocation(node)) {
  if (rendered.has(name)) return;
  rendered.add(name);
  const isInput = /Params$|Input$|Options$|Limits$|Caps$|^WebhookUpdate/.test(name);
  const props = checker.getPropertiesOfType(type).map(prop => {
    const declaration = prop.valueDeclaration || prop.declarations[0];
    const n = declaration.type;
    const wire = prop.name;
    const optional = !!(prop.flags & ts.SymbolFlags.Optional) || (name === 'DomainRoute' && ['slug', 'domain'].includes(wire)) ||
      (['WorkspacePushToken', 'CreatedWorkspacePushToken', 'CreatePushTokenParams'].includes(name) && wire === 'workspace_id');
    const nullable = ts.isUnionTypeNode(n) && n.types.some(isNull);
    let fieldType = renderType(n, name + upper(camel(wire)), wire);
    const explicitNull = nullable && isInput;
    if (explicitNull) fieldType = 'JSONField<' + fieldType + '>';
    const maybe = optional || (nullable && !explicitNull);
    const defaultValue = maybe ? ' = nil' : ts.isLiteralTypeNode(n) && ts.isStringLiteral(n.literal) ? ' = ' + JSON.stringify(n.literal.text) : '';
    const docs = ts.isUnionTypeNode(n) && n.types.every(t => isNull(t) || ts.isLiteralTypeNode(t)) ?
      '    /// Accepted values: ' + n.getText().replace(/\n/g, ' ') + '.\n' : '';
    const wrapper = fieldType === 'Bool' ? (maybe ? 'APIOptionalBoolean' : 'APIBoolean') :
      ['Int', 'Double'].includes(fieldType) ? (maybe ? 'APIOptionalNumber' : 'APINumber') :
      name === 'Webhook' && wire === 'events' ? 'APIJSONString' : undefined;
    const wrapperType = wrapper && (wrapper.includes('Number') || wrapper === 'APIJSONString') ? wrapper + '<' + fieldType + '>' : wrapper;
    return { wire, key: ident(wire), fieldType: fieldType + (maybe ? '?' : ''), defaultValue, docs, wrapper, wrapperType };
  });
  // The device/send-token guide permits user-scoped tokens and stable tag refreshes.
  if (['WorkspacePushToken', 'CreatedWorkspacePushToken', 'CreatePushTokenParams'].includes(name)) {
    props.push({ wire: 'tag', key: '`tag`', fieldType: 'String?', defaultValue: ' = nil', docs: '' });
    props.push(name === 'CreatePushTokenParams' ?
      { wire: 'expires_in_days', key: '`expiresInDays`', fieldType: 'Int?', defaultValue: ' = nil', docs: '' } :
      { wire: 'refreshed', key: '`refreshed`', fieldType: 'Bool?', defaultValue: ' = nil', docs: '' });
  }
  const hasExtras = !!checker.getIndexTypeOfType(type, ts.IndexKind.String);
  let s = 'public struct ' + name + ': Codable, Sendable {\n';
  s += props.map(p => p.docs + '    ' + (p.wrapper ? '@' + p.wrapper + ' ' : '') + 'public var ' + p.key + ': ' + p.fieldType).join('\n');
  if (hasExtras) s += '\n    public var additionalProperties: [String: JSONValue]';
  s += '\n\n    public init(' + props.map(p => p.key + ': ' + p.fieldType + p.defaultValue).concat(hasExtras ? ['additionalProperties: [String: JSONValue] = [:]'] : []).join(',\n                ') + ') {\n';
  s += props.map(p => '        self.' + p.key + ' = ' + p.key).join('\n');
  if (hasExtras) s += '\n        self.additionalProperties = additionalProperties';
  s += '\n    }\n';
  if (props.length) s += '\n    enum CodingKeys: String, CodingKey {\n' + props.map(p => '        case ' + p.key + ' = ' + JSON.stringify(p.wire)).join('\n') + '\n    }\n';
  if (hasExtras) {
    s += '\n    public init(from decoder: Decoder) throws {\n        let c = try decoder.container(keyedBy: CodingKeys.self)\n';
    s += props.map(p => p.wrapperType ? '        ' + p.key + ' = try c.decode(' + p.wrapperType + '.self, forKey: .' + p.key + ').wrappedValue' :
      '        ' + p.key + ' = try c.' + (p.fieldType.endsWith('?') ? 'decodeIfPresent' : 'decode') + '(' + p.fieldType.replace(/\?$/, '') + '.self, forKey: .' + p.key + ')').join('\n');
    s += '\n        additionalProperties = try [String: JSONValue](from: decoder).filter { CodingKeys(rawValue: $0.key) == nil }\n    }\n';
    s += '\n    public func encode(to encoder: Encoder) throws {\n        var c = encoder.container(keyedBy: CodingKeys.self)\n';
    s += props.map(p => '        try c.' + (p.fieldType.endsWith('?') ? 'encodeIfPresent' : 'encode') + '(' + p.key + ', forKey: .' + p.key + ')').join('\n');
    s += '\n        var extra = encoder.container(keyedBy: APIKey.self)\n        for (key, value) in additionalProperties where CodingKeys(rawValue: key) == nil {\n            try extra.encode(value, forKey: APIKey(key))\n        }\n    }\n';
  }
  blocks.push(s + '}\n');
}
function renderAlias(name, node) {
  if (rendered.has(name)) return;
  rendered.add(name);
  if (ts.isUnionTypeNode(node.type) && node.type.types.every(n => ts.isLiteralTypeNode(n) && ts.isStringLiteral(n.literal))) {
    const vals = node.type.types.map(n => n.literal.text);
    blocks.push('/// Open string enum; preserves new server values.\npublic struct ' + name + ': RawRepresentable, Codable, Sendable, Hashable {\n' +
      '    public let rawValue: String\n    public init(rawValue: String) { self.rawValue = rawValue }\n' +
      '    public init(from decoder: Decoder) throws { rawValue = try decoder.singleValueContainer().decode(String.self) }\n' +
      '    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }\n' +
      vals.map(v => '    public static let `' + camel(v.replace(/[.-]([a-z])/g, (_, c) => c.toUpperCase())) + '` = Self(rawValue: ' + JSON.stringify(v) + ')').join('\n') + '\n}\n');
  } else blocks.push('public typealias ' + name + ' = ' + renderType(node.type, name, name) + '\n');
}
for (const group of [...groups, 'workspace-resources', 'runtime']) {
  blocks = [];
  const source = program.getSourceFile(path.join(root, 'types', group + '.d.ts'));
  for (const node of source.statements) {
    if (!node.name || manual.has(node.name.text)) continue;
    if (group === 'workspace-resources' && !extra.includes(node.name.text)) continue;
    if (group === 'runtime' && !runtimeTypes.includes(node.name.text)) continue;
    if (ts.isInterfaceDeclaration(node)) renderStruct(node.name.text, node);
    if (ts.isTypeAliasDeclaration(node)) renderAlias(node.name.text, node);
  }
  const filename = group === 'workspace-resources' ? 'AccountDomainModels' : group.split('-').map(upper).join('') + 'Models';
  fs.writeFileSync(path.join(outDir, filename + '.swift'), '// Models audited against oblien 2.4.0. Regenerate with scripts/generate-platform-models.cjs.\nimport Foundation\n\n' + blocks.join('\n'));
}
console.log('Generated ' + rendered.size + ' platform models with explicit wire keys.');
