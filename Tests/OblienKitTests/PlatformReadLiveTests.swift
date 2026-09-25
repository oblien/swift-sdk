import Foundation
import XCTest
@testable import OblienKit

/// Optional schema check against the signed-in account. This test only reads resources.
final class PlatformReadLiveTests: XCTestCase {
    func testPlatformReadSchemas() async throws {
        guard let file = ProcessInfo.processInfo.environment["OBLIEN_LIVE_TOKEN_FILE"] else {
            throw XCTSkip("Set OBLIEN_LIVE_TOKEN_FILE to check live platform response schemas.")
        }
        let token = try String(contentsOfFile: file, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
        let client = OblienClient(token: token)
        let reads: [(String, () async throws -> Void)] = [
            ("namespaces", { _ = try await client.namespaces.list() }),
            ("pages", { _ = try await client.pages.list() }),
            ("edge proxies", { _ = try await client.edgeProxy.list() }),
            ("edge verifications", { _ = try await client.edgeProxy.listVerifications() }),
            ("edge tunnels", { _ = try await client.edgeTunnel.list() }),
            ("webhooks", { _ = try await client.webhooks.list() }),
            ("webhook events", { _ = try await client.webhooks.events() }),
            ("domain routes", { _ = try await client.domain.routes() }),
            ("SSL certificates", { _ = try await client.domain.ssls() }),
            ("analytics", { _ = try await client.analytics.home() }),
            ("CDN files", { _ = try await client.cdn.list() }),
            ("CDN statistics", { _ = try await client.cdn.stats() }),
            ("CDN usage", { _ = try await client.cdn.usage() }),
            ("CDN namespace quotas", { _ = try await client.cdn.namespaces() }),
            ("CDN domains", { _ = try await client.cdn.domains.list() }),
            ("billing catalog", { _ = try await client.billing.catalog() }),
            ("notification tokens", { _ = try await client.notifications.listTokens() }),
            ("device registry", { _ = try await client.notifications.listDevices() }),
            ("image catalog", { _ = try await client.workspaces.images() }),
            ("workspace quota and resource pools", { _ = try await client.workspaces.getQuota() }),
            ("workspace credit estimate", { _ = try await client.workspaces.estimate(cpu: 1, ramMb: 2048, diskMb: 4096) }),
            ("archived workspaces", { _ = try await client.workspaces.archived() })
        ]
        for (name, read) in reads {
            do { try await read(); print("Live schema verified: \(name)") }
            catch let error as OblienError where [402, 403, 404].contains(error.status ?? 0) {
                print("Live capability unavailable: \(name) (HTTP \(error.status ?? 0))")
            } catch {
                XCTFail("\(name): \(error.localizedDescription)")
            }
        }
    }
}
