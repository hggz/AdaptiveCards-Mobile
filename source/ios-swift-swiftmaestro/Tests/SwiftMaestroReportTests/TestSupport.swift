import XCTest
import Foundation
@testable import SwiftMaestroReport

/// Golden-file support. On first run (or with RECORD_GOLDENS set) the expected
/// output is written next to this file and the assertion fails with a "recorded"
/// message; subsequent runs compare byte-for-byte (LF-normalized).
enum Goldens {
    static var directory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Goldens", isDirectory: true)
    }

    static func url(_ name: String) -> URL { directory.appendingPathComponent(name) }
}

func normalizeLF(_ s: String) -> String {
    s.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
}

func assertGolden(_ actual: String, _ name: String, file: StaticString = #filePath, line: UInt = #line) {
    let fm = FileManager.default
    let url = Goldens.url(name)
    let record = ProcessInfo.processInfo.environment["RECORD_GOLDENS"] != nil
    if record || !fm.fileExists(atPath: url.path) {
        try? fm.createDirectory(at: Goldens.directory, withIntermediateDirectories: true)
        try? normalizeLF(actual).write(to: url, atomically: true, encoding: .utf8)
        XCTFail("recorded golden '\(name)' — re-run to compare", file: file, line: line)
        return
    }
    let expected = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
    XCTAssertEqual(normalizeLF(actual), normalizeLF(expected), "golden mismatch: \(name)", file: file, line: line)
}

/// A fixed, deterministic report used by every golden test.
func sampleReport() -> TestReport {
    let login = FlowResult(
        name: "Login smoke",
        filePath: "flows/login.yaml",
        appId: "com.example.app",
        tags: ["smoke", "auth"],
        device: "emulator-5554",
        status: .passed,
        durationMs: 1234,
        steps: [
            StepResult(command: "launchApp", status: .passed, durationMs: 800),
            StepResult(command: "tapOn", label: "tap Login", status: .passed, durationMs: 200),
            StepResult(command: "assertVisible", status: .passed, durationMs: 234),
        ]
    )
    let checkout = FlowResult(
        name: "Checkout",
        filePath: "flows/checkout.yaml",
        appId: "com.example.app",
        tags: ["smoke"],
        device: "emulator-5554",
        status: .failed,
        durationMs: 560,
        message: "element not found: text=\"Pay\"",
        steps: [
            StepResult(command: "launchApp", status: .passed, durationMs: 300),
            StepResult(command: "tapOn", label: "tap Pay", status: .failed, durationMs: 260,
                       message: "element not found: text=\"Pay\""),
            StepResult(command: "assertVisible", status: .skipped, durationMs: 0),
        ]
    )
    // 1_700_000_000_000 ms == 2023-11-14T22:13:20Z.
    return TestReport(flows: [login, checkout], startedAtEpochMs: 1_700_000_000_000)
}
