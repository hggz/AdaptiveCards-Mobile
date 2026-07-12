// Port of: pkg/uiautomator2 (hierarchy parsing) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// Parses the UIAutomator page-source XML into a normalized `ViewHierarchy`.
///
/// `Foundation.XMLParser` is unavailable on Windows swift-corelibs-foundation, so
/// this is a small hand-rolled recursive-descent parser for the well-formed
/// `<hierarchy>` / `<node .../>` subset the on-device server emits.
public enum AndroidHierarchyParser {

    public static func parse(xml: String) throws -> ViewHierarchy {
        // Normalize line endings first: Swift collapses "\r\n" into a SINGLE
        // Character (grapheme cluster), which a scalar-based scanner never matches
        // as whitespace — so a CRLF file (as read on Windows) would stall the
        // scanner. Same lesson as the flow parser.
        let normalized = xml
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        var scanner = Scanner(normalized)
        guard let root = try scanner.parseTopElement() else {
            throw DriverError.toolFailure("empty or invalid UI hierarchy XML")
        }
        let node: Element
        if root.name == "hierarchy" {
            guard let firstNode = root.children.first(where: { $0.name == "node" }) else {
                return ViewHierarchy(root: ViewNode(className: "hierarchy"), platform: .android)
            }
            node = firstNode
        } else {
            node = root
        }
        return ViewHierarchy(root: map(node), platform: .android)
    }

    // MARK: - Mapping (UIAutomator attributes -> ViewNode)

    struct Element {
        var name: String
        var attributes: [String: String]
        var children: [Element]
    }

    static func map(_ element: Element) -> ViewNode {
        let a = element.attributes
        return ViewNode(
            text: nonEmpty(a["text"]),
            resourceId: nonEmpty(a["resource-id"]),
            accessibilityId: nonEmpty(a["content-desc"]),
            className: nonEmpty(a["class"]),
            bounds: parseBounds(a["bounds"]),
            enabled: parseBool(a["enabled"]),
            checked: parseBool(a["checked"]),
            focused: parseBool(a["focused"]),
            selected: parseBool(a["selected"]),
            clickable: parseBool(a["clickable"]),
            children: element.children.filter { $0.name == "node" }.map(map)
        )
    }

    static func nonEmpty(_ s: String?) -> String? {
        guard let s, !s.isEmpty else { return nil }
        return s
    }

    static func parseBool(_ s: String?) -> Bool? {
        switch s {
        case "true": return true
        case "false": return false
        default: return nil
        }
    }

    /// `"[x1,y1][x2,y2]"` -> `Bounds(x1, y1, width, height)`.
    static func parseBounds(_ s: String?) -> Bounds? {
        guard let s else { return nil }
        let nums = s.split(whereSeparator: { !"-0123456789".contains($0) }).compactMap { Int($0) }
        guard nums.count == 4 else { return nil }
        return Bounds(x: nums[0], y: nums[1], width: max(0, nums[2] - nums[0]), height: max(0, nums[3] - nums[1]))
    }

    // MARK: - Minimal XML scanner

    struct Scanner {
        private let chars: [Character]
        private var pos = 0
        init(_ s: String) { chars = Array(s) }

        mutating func parseTopElement() throws -> Element? {
            skipMisc()
            return try parseElement()
        }

        private mutating func skipMisc() {
            while true {
                skipWhitespace()
                if consume("<?") { skipPast("?>") }
                else if consume("<!--") { skipPast("-->") }
                else if consume("<!") { skipPast(">") }
                else { break }
            }
        }

        private mutating func parseElement() throws -> Element? {
            skipWhitespace()
            guard peek() == "<" else { return nil }
            advance() // '<'
            let name = readName()
            var attributes: [String: String] = [:]
            while true {
                skipWhitespace()
                guard let c = peek() else { throw DriverError.toolFailure("unexpected end of XML in <\(name)>") }
                if c == "/" || c == ">" { break }
                let (key, value) = try readAttribute(elementName: name)
                attributes[key] = value
            }
            if consume("/>") {
                return Element(name: name, attributes: attributes, children: [])
            }
            guard consume(">") else { throw DriverError.toolFailure("malformed tag <\(name)>") }

            var children: [Element] = []
            while true {
                skipTextNoise()
                if consume("</") {
                    _ = readName()
                    skipWhitespace()
                    _ = consume(">")
                    break
                }
                guard peek() != nil else { break }
                if peek() == "<" {
                    if let child = try parseElement() { children.append(child) } else { break }
                } else {
                    advance()
                }
            }
            return Element(name: name, attributes: attributes, children: children)
        }

        private mutating func readAttribute(elementName: String) throws -> (String, String) {
            let name = readName()
            skipWhitespace()
            guard consume("=") else { throw DriverError.toolFailure("attribute '\(name)' missing '=' in <\(elementName)>") }
            skipWhitespace()
            guard let quote = peek(), quote == "\"" || quote == "'" else {
                throw DriverError.toolFailure("attribute '\(name)' value not quoted in <\(elementName)>")
            }
            advance()
            var value = ""
            while let c = peek(), c != quote {
                value.append(c)
                advance()
            }
            advance() // closing quote
            return (name, decodeEntities(value))
        }

        private mutating func readName() -> String {
            var name = ""
            while let c = peek(), c.isLetter || c.isNumber || c == "-" || c == "_" || c == ":" || c == "." {
                name.append(c)
                advance()
            }
            return name
        }

        private mutating func skipWhitespace() {
            while let c = peek(), c == " " || c == "\n" || c == "\r" || c == "\t" { advance() }
        }

        private mutating func skipTextNoise() {
            while let c = peek(), c != "<" { advance() }
        }

        private mutating func skipPast(_ marker: String) {
            let m = Array(marker)
            while pos < chars.count {
                if matchesAt(pos, m) { pos += m.count; return }
                pos += 1
            }
        }

        private func matchesAt(_ i: Int, _ m: [Character]) -> Bool {
            guard i + m.count <= chars.count else { return false }
            for k in 0..<m.count where chars[i + k] != m[k] { return false }
            return true
        }

        private mutating func consume(_ s: String) -> Bool {
            let m = Array(s)
            if matchesAt(pos, m) { pos += m.count; return true }
            return false
        }

        private func peek() -> Character? { pos < chars.count ? chars[pos] : nil }
        private mutating func advance() { pos += 1 }

        private func decodeEntities(_ s: String) -> String {
            guard s.contains("&") else { return s }
            return s
                .replacingOccurrences(of: "&lt;", with: "<")
                .replacingOccurrences(of: "&gt;", with: ">")
                .replacingOccurrences(of: "&quot;", with: "\"")
                .replacingOccurrences(of: "&apos;", with: "'")
                .replacingOccurrences(of: "&amp;", with: "&")
        }
    }
}
