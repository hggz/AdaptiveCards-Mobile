import Foundation

/// Represents a semantic version with major, minor, build, and revision components.
struct SemanticVersion: Codable, Comparable, CustomStringConvertible {
    let major: UInt
    let minor: UInt
    let build: UInt
    let revision: UInt

    /// Initializes a `SemanticVersion` from a version string.
    /// - Throws: `SemanticVersionError.invalidVersion` if the version format is incorrect.
    init(_ version: String) throws {
        let pattern = #"^(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?$"#
        let regex = try NSRegularExpression(pattern: pattern)
        let nsVersion = version as NSString
        let matches = regex.matches(in: version, range: NSRange(location: 0, length: nsVersion.length))

        guard let match = matches.first else {
            throw SemanticVersionError.invalidVersion(version)
        }

        func extract(_ index: Int) -> UInt {
            guard index < match.numberOfRanges, let range = Range(match.range(at: index), in: version),
                  let value = UInt(version[range]) else { return 0 }
            return value
        }

        self.major = extract(1)
        self.minor = extract(2)
        self.build = extract(3)
        self.revision = extract(4)
    }

    var description: String {
        return "\(major).\(minor).\(build).\(revision)"
    }

    // MARK: - Comparable Implementation
    static func == (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return lhs.major == rhs.major &&
               lhs.minor == rhs.minor &&
               lhs.build == rhs.build &&
               lhs.revision == rhs.revision
    }

    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        if lhs.build != rhs.build { return lhs.build < rhs.build }
        return lhs.revision < rhs.revision
    }

    static func > (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return rhs < lhs
    }

    static func <= (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return !(lhs > rhs)
    }

    static func >= (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return !(lhs < rhs)
    }
}

/// Error cases for `SemanticVersion` parsing.
enum SemanticVersionError: Error {
    case invalidVersion(String)
}
