import Foundation
import SwiftMaestroDriver

/// Loads recorded view-hierarchy fixtures relative to this source file.
enum Hierarchies {
    static var directory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures", isDirectory: true)
    }

    static func load(_ name: String) throws -> ViewHierarchy {
        let json = try String(contentsOf: directory.appendingPathComponent(name), encoding: .utf8)
        return try ViewHierarchy.decode(fromJSON: json)
    }
}
