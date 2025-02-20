import Foundation

/// Represents a rich text block with inline elements.
class RichTextBlock: BaseCardElement {
    var horizontalAlignment: HorizontalAlignment?
    var inlines: [Any] // Changed to [Any] to support both TextRun and String
    
    init(id: String? = nil,
         horizontalAlignment: HorizontalAlignment? = nil,
         inlines: [Any] = [],
         spacing: Spacing? = nil,
         height: HeightType? = nil,
         separator: Bool? = nil,
         isVisible: Bool = true) {
        
        self.horizontalAlignment = horizontalAlignment
        self.inlines = inlines
        super.init(type: .richTextBlock,
                   spacing: spacing,
                   height: height,
                   separator: separator,
                   isVisible: isVisible,
                   id: id)
    }
    
    private enum CodingKeys: String, CodingKey {
        case horizontalAlignment
        case inlines
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode horizontalAlignment
        if let alignmentString = try container.decodeIfPresent(String.self, forKey: .horizontalAlignment) {
            self.horizontalAlignment = HorizontalAlignment(rawValue: alignmentString.lowercased())
        } else {
            self.horizontalAlignment = nil
        }
        
        // Decode inlines array
        var inlinesArray: [Any] = []
        var inlinesContainer = try container.nestedUnkeyedContainer(forKey: .inlines)
        
        while !inlinesContainer.isAtEnd {
            // Try to decode as a dictionary first (for TextRun)
            if let inlineDict = try? inlinesContainer.decode([String: AnyCodable].self) {
                let dict = inlineDict.mapValues { $0.value }
                if let typeString = dict["type"] as? String, typeString == "TextRun",
                   let textRun = try? TextRun.deserialize(from: dict) {
                    inlinesArray.append(textRun)
                }
            } else if let stringValue = try? inlinesContainer.decode(String.self) {
                // It's a plain string
                inlinesArray.append(stringValue)
            }
        }
        
        self.inlines = inlinesArray
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let alignment = horizontalAlignment {
            try container.encode(alignment.rawValue, forKey: .horizontalAlignment)
        }
        
        var inlinesContainer = container.nestedUnkeyedContainer(forKey: .inlines)
        for inline in inlines {
            if let textRun = inline as? TextRun {
                try inlinesContainer.encode(AnyCodable(textRun.serializeToJson()))
            } else if let stringValue = inline as? String {
                try inlinesContainer.encode(stringValue)
            }
        }
    }
    
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        json["type"] = "RichTextBlock"
        
        if let alignment = horizontalAlignment {
            json["horizontalAlignment"] = alignment.rawValue
        }
        
        // Change the map to return Any instead of [String: Any]
        json["inlines"] = inlines.map { inline -> Any in
            if let textRun = inline as? TextRun {
                return textRun.serializeToJson()
            } else if let stringValue = inline as? String {
                return stringValue
            }
            return [:]
        }
        
        return json
    }
}

struct RichTextBlockParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        let data = try JSONSerialization.data(withJSONObject: value)
        return try JSONDecoder().decode(RichTextBlock.self, from: data)
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> any AdaptiveCardElementProtocol {
        guard let data = value.data(using: .utf8) else {
            throw AdaptiveCardParseError.invalidJson
        }
        return try JSONDecoder().decode(RichTextBlock.self, from: data)
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
    }
}

/// Error type for parsing failures.
enum ParsingError: Error {
    case invalidType(expected: String, found: String)
}
