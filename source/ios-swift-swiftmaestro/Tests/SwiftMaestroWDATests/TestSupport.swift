import Foundation
import SwiftMaestroWDA

func wdaFixture(_ name: String = "wda-source.xml") throws -> String {
    let path = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("Fixtures")
        .appendingPathComponent(name)
        .path
    return try String(contentsOfFile: path, encoding: .utf8)
}

/// Recording host-tool mock for driver orchestration tests.
actor MockWDAHostTooling: WDAHostTooling {
    private(set) var actions: [String] = []

    func prepare() async throws { actions.append("prepare") }
    func installApp(_ path: String) async throws { actions.append("install(\(path))") }
    func addMedia(_ paths: [String]) async throws { actions.append("addMedia(\(paths.joined(separator: ",")))") }
    func tearDown() async { actions.append("tearDown") }
}
