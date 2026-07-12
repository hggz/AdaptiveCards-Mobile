import XCTest
import Foundation
@testable import SwiftMaestroRunner
import SwiftMaestroDriver
import SwiftMaestroReport
import SwiftMaestroFlow

final class ParallelTests: XCTestCase {

    /// Write `count` single-step flow files into a fresh temp dir; return its path.
    private func makeFlowDir(count: Int) throws -> String {
        let dir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("swiftmaestro-parallel-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        for i in 0..<count {
            let yaml = "appId: com.flow\(i)\nname: Flow \(i)\n---\n- launchApp: com.flow\(i)\n"
            try yaml.write(to: dir.appendingPathComponent("flow\(i).yaml"), atomically: false, encoding: .utf8)
        }
        return dir.path
    }

    func testPoolRunsEveryFlowExactlyOnce() async throws {
        let dir = try makeFlowDir(count: 6)
        defer { try? FileManager.default.removeItem(atPath: dir) }

        let drivers: [any Driver] = (0..<3).map { _ -> any Driver in MockDriver() }
        let report = try await TestRunner().run(path: dir, drivers: drivers, deviceLabels: ["A", "B", "C"])

        XCTAssertEqual(report.total, 6)
        XCTAssertEqual(report.passed, 6)
        let names = Set(report.flows.map { $0.name })
        XCTAssertEqual(names.count, 6, "each flow should run exactly once: \(report.flows.map { $0.name })")
        // Every result carries one of the pool's device labels.
        XCTAssertTrue(report.flows.allSatisfy { ["A", "B", "C"].contains($0.device ?? "") })
    }

    func testPoolActuallyRunsConcurrently() async throws {
        let dir = try makeFlowDir(count: 3)
        defer { try? FileManager.default.removeItem(atPath: dir) }

        let gate = ConcurrencyGate()
        let drivers: [any Driver] = (0..<3).map { _ -> any Driver in
            MockDriver(onLaunch: {
                await gate.enter()
                try? await Task.sleep(nanoseconds: 80_000_000) // 80ms overlap window
                await gate.leave()
            })
        }

        let report = try await TestRunner().run(path: dir, drivers: drivers)
        XCTAssertEqual(report.total, 3)
        let peak = await gate.peak
        XCTAssertGreaterThanOrEqual(peak, 2, "expected the pool to run flows concurrently (peak=\(peak))")
    }

    func testSingleDriverPathStaysSequential() async throws {
        let dir = try makeFlowDir(count: 4)
        defer { try? FileManager.default.removeItem(atPath: dir) }

        let driver = MockDriver()
        let report = try await TestRunner().run(path: dir, driver: driver)
        XCTAssertEqual(report.total, 4)

        let actions = await driver.actions
        XCTAssertEqual(actions.first, "setUp")
        XCTAssertEqual(actions.last, "tearDown")
    }
}

/// Records the peak number of flows executing at the same time.
actor ConcurrencyGate {
    private var current = 0
    private(set) var peak = 0
    func enter() { current += 1; peak = max(peak, current) }
    func leave() { current -= 1 }
}
