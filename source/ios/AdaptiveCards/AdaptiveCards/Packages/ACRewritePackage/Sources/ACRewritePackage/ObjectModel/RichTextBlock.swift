import Foundation

// MARK: - RichTextBlock and Parser

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
        // Include the type so that the parser can verify this element.
        json["type"] = "RichTextBlock"
        if let horizontalAlignment = horizontalAlignment {
            json["horizontalAlignment"] = horizontalAlignment.rawValue
        }
        json["inlines"] = inlines.map { $0.serializeToJson() }
        return json
    }
    
    // MARK: - Codable Conformance
    /// Custom encoding that encodes the object as a JSON string.
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let json = self.toJSON()
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw EncodingError.invalidValue(json, EncodingError.Context(codingPath: encoder.codingPath,
                                                                          debugDescription: "Unable to encode RichTextBlock as JSON string"))
        }
        try container.encode(jsonString)
    }
    
    /// Custom decoding that expects the JSON to be stored as a string.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let jsonString = try container.decode(String.self)
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw DecodingError.dataCorruptedError(in: container,
                                                    debugDescription: "Unable to decode RichTextBlock from JSON string")
        }
        let block = try RichTextBlockParser.deserialize(from: jsonObject)
        self = block
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
        let inlines: [Inline] = try inlinesJSON.map { try deserializeInline(from: $0) }
        return RichTextBlock(horizontalAlignment: horizontalAlignment, inlines: inlines)
    }
}

/// Helper function to dispatch inline deserialization based on the "type" field.
func deserializeInline(from json: [String: Any]) throws -> Inline {
    guard let typeString = json["type"] as? String,
          let type = InlineElementType(rawValue: typeString) else {
        throw ParsingError.invalidType(expected: "Inline", found: "Missing type")
    }
    
    switch type {
    case .textRun:
        guard let inline = try? TextRun.deserialize(from: json) else {
            throw ParsingError.invalidType(expected: "TextRun", found: "Invalid data")
        }
        return inline
    case .unknown:
        throw ParsingError.invalidType(expected: "Inline", found: "Unknown inline type")
    }
}

/// Error type for parsing failures.
enum ParsingError: Error {
    case invalidType(expected: String, found: String)
}
