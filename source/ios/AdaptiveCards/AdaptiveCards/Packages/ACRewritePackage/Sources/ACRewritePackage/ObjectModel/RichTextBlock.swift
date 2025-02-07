import Foundation

/// Represents a rich text block with inline elements.
struct RichTextBlock: Codable {
    var horizontalAlignment: HorizontalAlignment?
    var inlines: [Inline]

    init(horizontalAlignment: HorizontalAlignment? = nil, inlines: [Inline] = []) {
        self.horizontalAlignment = horizontalAlignment
        self.inlines = inlines
    }

    /// Serializes the RichTextBlock to a JSON object.
    func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]

        if let horizontalAlignment = horizontalAlignment {
            json["horizontalAlignment"] = horizontalAlignment.rawValue
        }

        json["inlines"] = inlines.map { $0.toJSON() }
        return json
    }
}

/// Parses a `RichTextBlock` from a JSON dictionary.
struct RichTextBlockParser {
    static func deserialize(from json: [String: Any]) throws -> RichTextBlock {
        guard let type = json["type"] as? String, type == "RichTextBlock" else {
            throw ParsingError.invalidType(expected: "RichTextBlock", found: json["type"] as? String ?? "Unknown")
        }

        let horizontalAlignment = (json["horizontalAlignment"] as? String).flatMap(HorizontalAlignment.init)
        let inlinesJSON = json["inlines"] as? [[String: Any]] ?? []
        let inlines = try inlinesJSON.map { try InlineParser.deserialize(from: $0) }

        return RichTextBlock(horizontalAlignment: horizontalAlignment, inlines: inlines)
    }
}

/// Enum representing horizontal alignment.
enum HorizontalAlignment: String, Codable {
    case left = "Left"
    case center = "Center"
    case right = "Right"
}

/// Error type for parsing failures.
enum ParsingError: Error {
    case invalidType(expected: String, found: String)
}
