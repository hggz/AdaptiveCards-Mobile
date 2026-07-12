import Foundation

/// Locates the on-disk fixture tree relative to this source file. The local
/// gate runs from the source checkout, so `#filePath` resolves the fixtures
/// directory deterministically on every platform without resource bundling.
enum Fixtures {
    static var directory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures", isDirectory: true)
    }

    static func url(_ name: String) -> URL {
        directory.appendingPathComponent(name)
    }

    static func path(_ name: String) -> String {
        url(name).path
    }

    static func text(_ name: String) throws -> String {
        try String(contentsOf: url(name), encoding: .utf8)
    }
}
