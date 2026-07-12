// Port of: drivers/wda (hierarchy parsing) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import SwiftMaestroDriver

/// Parses WebDriverAgent's XCTest page-source XML into the shared
/// `ViewHierarchy`. `Foundation.XMLParser` is unavailable in this Windows Swift
/// environment, so this is a small hand-rolled parser for WDA's well-formed
/// element/attribute tree (the same cross-platform strategy as Android).
public enum IOSHierarchyParser {
    public static func parse(xml: String) throws -> ViewHierarchy {
        let normalized = xml
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        var scanner = XMLScanner(normalized)
        guard let element = try scanner.parseTopElement() else {
            throw DriverError.toolFailure("empty or invalid WDA hierarchy XML")
        }
        return ViewHierarchy(root: map(element), platform: .ios)
    }

    // MARK: - Mapping (XCTest attributes -> ViewNode)

    private static func map(_ element: Element) -> ViewNode {
        let a = element.attributes
        let type = nonEmpty(a["type"]) ?? element.name
        let label = nonEmpty(a["label"])
        let value = nonEmpty(a["value"])
        let name = nonEmpty(a["name"])
        return ViewNode(
            text: label ?? value,
            resourceId: name,
            accessibilityId: name,
            className: type,
            bounds: parseBounds(a),
            enabled: parseBool(a["enabled"]),
            focused: parseBool(a["focused"]),
            selected: parseBool(a["selected"]),
            clickable: isClickable(type: type, attributes: a),
            visible: parseBool(a["visible"]),
            children: element.children.map(map)
        )
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }
        return value
    }

    private static func parseBool(_ value: String?) -> Bool? {
        switch value?.lowercased() {
        case "true", "1": return true
        case "false", "0": return false
        default: return nil
        }
    }

    private static func parseBounds(_ a: [String: String]) -> Bounds? {
        guard let x = number(a["x"]), let y = number(a["y"]),
              let width = number(a["width"]), let height = number(a["height"]) else {
            return nil
        }
        return Bounds(x: x, y: y, width: max(0, width), height: max(0, height))
    }

    private static func number(_ value: String?) -> Int? {
        guard let value, let number = Double(value) else { return nil }
        return Int(number.rounded())
    }

    private static func isClickable(type: String, attributes: [String: String]) -> Bool? {
        if parseBool(attributes["accessible"]) == true { return true }
        let clickableTypes = [
            "XCUIElementTypeButton", "XCUIElementTypeCell", "XCUIElementTypeLink",
            "XCUIElementTypeTextField", "XCUIElementTypeSecureTextField",
            "XCUIElementTypeSwitch", "XCUIElementTypeSlider", "XCUIElementTypeTab",
        ]
        return clickableTypes.contains(type) ? true : nil
    }

    // MARK: - Minimal XML scanner

    private struct Element {
        var name: String
        var attributes: [String: String]
        var children: [Element]
    }

    private struct XMLScanner {
        private let chars: [Character]
        private var position = 0

        init(_ string: String) { chars = Array(string) }

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
            advance()
            let name = readName()
            guard !name.isEmpty else { return nil }
            var attributes: [String: String] = [:]
            while true {
                skipWhitespace()
                guard let character = peek() else {
                    throw DriverError.toolFailure("unexpected end of WDA XML in <\(name)>")
                }
                if character == "/" || character == ">" { break }
                let (key, value) = try readAttribute(elementName: name)
                attributes[key] = value
            }
            if consume("/>") { return Element(name: name, attributes: attributes, children: []) }
            guard consume(">") else { throw DriverError.toolFailure("malformed WDA tag <\(name)>") }

            var children: [Element] = []
            while true {
                skipText()
                if consume("</") {
                    _ = readName()
                    skipWhitespace()
                    _ = consume(">")
                    break
                }
                guard peek() != nil else { break }
                if peek() == "<" {
                    if consume("<!--") { skipPast("-->"); continue }
                    if let child = try parseElement() { children.append(child) }
                } else {
                    advance()
                }
            }
            return Element(name: name, attributes: attributes, children: children)
        }

        private mutating func readAttribute(elementName: String) throws -> (String, String) {
            let name = readName()
            skipWhitespace()
            guard consume("=") else {
                throw DriverError.toolFailure("WDA attribute '\(name)' missing '=' in <\(elementName)>")
            }
            skipWhitespace()
            guard let quote = peek(), quote == "\"" || quote == "'" else {
                throw DriverError.toolFailure("WDA attribute '\(name)' is not quoted in <\(elementName)>")
            }
            advance()
            var value = ""
            while let character = peek(), character != quote {
                value.append(character)
                advance()
            }
            guard peek() == quote else {
                throw DriverError.toolFailure("unterminated WDA attribute '\(name)'")
            }
            advance()
            return (name, decodeEntities(value))
        }

        private mutating func readName() -> String {
            var name = ""
            while let character = peek(),
                  character.isLetter || character.isNumber || character == "-" ||
                  character == "_" || character == ":" || character == "." {
                name.append(character)
                advance()
            }
            return name
        }

        private mutating func skipWhitespace() {
            while let character = peek(),
                  character == " " || character == "\n" || character == "\r" || character == "\t" {
                advance()
            }
        }

        private mutating func skipText() {
            while let character = peek(), character != "<" { advance() }
        }

        private mutating func skipPast(_ marker: String) {
            let markerCharacters = Array(marker)
            while position < chars.count {
                if matches(position, markerCharacters) {
                    position += markerCharacters.count
                    return
                }
                position += 1
            }
        }

        private func matches(_ index: Int, _ marker: [Character]) -> Bool {
            guard index + marker.count <= chars.count else { return false }
            for offset in 0..<marker.count where chars[index + offset] != marker[offset] { return false }
            return true
        }

        private mutating func consume(_ string: String) -> Bool {
            let marker = Array(string)
            guard matches(position, marker) else { return false }
            position += marker.count
            return true
        }

        private func peek() -> Character? { position < chars.count ? chars[position] : nil }
        private mutating func advance() { position += 1 }

        private func decodeEntities(_ value: String) -> String {
            guard value.contains("&") else { return value }
            return value
                .replacingOccurrences(of: "&lt;", with: "<")
                .replacingOccurrences(of: "&gt;", with: ">")
                .replacingOccurrences(of: "&quot;", with: "\"")
                .replacingOccurrences(of: "&apos;", with: "'")
                .replacingOccurrences(of: "&amp;", with: "&")
        }
    }
}
