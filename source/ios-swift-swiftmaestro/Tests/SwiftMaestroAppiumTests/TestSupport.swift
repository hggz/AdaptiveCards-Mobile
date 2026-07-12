import Foundation

func appiumFixture(_ name: String) throws -> String {
    let path = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("Fixtures")
        .appendingPathComponent(name)
        .path
    return try String(contentsOfFile: path, encoding: .utf8)
}
