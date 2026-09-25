import Foundation
import XCTest
@testable import OblienKit

final class LogReconciliationTests: XCTestCase {
    private func entry(_ text: String, second: Int) -> LogEntry {
        LogEntry(line: text, timestamp: String(format: "2026-09-25T00:00:%02dZ", second), stream: "stdout")
    }
    func testRetainedAndLiveFormatsMatchWithoutChangingWhitespace() throws {
        let retained = try LogBatch.decode(Data(#"{"logs":"[2026-09-25T00:00:01Z] stdout:   value  \n"}"#.utf8))
        let live = try LogBatch.decode(Data(#"{"type":"log","line":"  value  ","stream":"stdout","timestamp":"2026-09-25T00:00:01.123456Z"}"#.utf8))
        XCTAssertEqual(retained.entries.count, 1)
        XCTAssertEqual(retained.entries[0].line, "  value  ")
        XCTAssertEqual(LogFollowBuffer.join(history: retained.entries, live: live.entries).count, 1)
    }
    func testSnapshotAndSubscriptionReconcileEvenIfParserDeliveryIsLate() async throws {
        let (stream, continuation) = AsyncThrowingStream<LogBatch, Error>.makeStream()
        let buffer = LogFollowBuffer(continuation: continuation)
        try await buffer.receive(.init(entries: [entry("during read", second: 2)]))
        try await buffer.seed(.init(entries: [entry("older", second: 1), entry("during read", second: 2), entry("late delivery", second: 3)]))
        try await buffer.receive(.init(entries: [entry("late delivery", second: 3), entry("new", second: 4)]))
        try await buffer.receive(.init(entries: [entry("new", second: 4)]))
        continuation.finish()
        var batches: [LogBatch] = []
        for try await batch in stream { batches.append(batch) }
        XCTAssertTrue(batches[0].cleared)
        XCTAssertEqual(batches.flatMap(\.entries).map(\.line), ["older", "during read", "late delivery", "new", "new"])
    }
    func testLiveClearDuringSnapshotDoesNotResurrectDeletedOutput() async throws {
        let (stream, continuation) = AsyncThrowingStream<LogBatch, Error>.makeStream()
        let buffer = LogFollowBuffer(continuation: continuation)
        try await buffer.receive(.init(entries: [entry("old live", second: 2)]))
        try await buffer.receive(.init(entries: [entry("after clear", second: 3)], cleared: true))
        try await buffer.seed(.init(entries: [entry("old snapshot", second: 1)]))
        continuation.finish()
        var entries: [LogEntry] = []
        for try await batch in stream { entries += batch.entries }
        XCTAssertEqual(entries.map(\.line), ["after clear"])
    }
}
