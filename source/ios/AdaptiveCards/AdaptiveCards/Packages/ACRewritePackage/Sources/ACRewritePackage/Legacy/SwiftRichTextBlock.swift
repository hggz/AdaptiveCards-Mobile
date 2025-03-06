import Foundation

/// Represents a rich text block with inline elements.
class SwiftRichTextBlock: SwiftBaseCardElement {
    // MARK: - Properties
    let horizontalAlignment: SwiftHorizontalAlignment?
    let inlines: [Any] // Supports both TextRun and String
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case horizontalAlignment
        case inlines
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode horizontalAlignment
        if let alignmentString = try container.decodeIfPresent(String.self, forKey: .horizontalAlignment) {
            horizontalAlignment = SwiftHorizontalAlignment(rawValue: alignmentString.lowercased())
        } else {
            horizontalAlignment = nil
        }
        
        // Decode inlines array
        var inlinesArray: [Any] = []
        var inlinesContainer = try container.nestedUnkeyedContainer(forKey: .inlines)
        
        while !inlinesContainer.isAtEnd {
            // Try to decode as a dictionary first (for TextRun)
            if let inlineDict = try? inlinesContainer.decode([String: AnyCodable].self) {
                let dict = inlineDict.mapValues { $0.value }
                if let typeString = dict["type"] as? String, typeString == "TextRun",
                   let textRun = try? SwiftTextRun.deserialize(from: dict) {
                    inlinesArray.append(textRun)
                }
            } else if let stringValue = try? inlinesContainer.decode(String.self) {
                // It's a plain string
                inlinesArray.append(stringValue)
            }
        }
        
        inlines = inlinesArray
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let alignment = horizontalAlignment {
            try container.encode(alignment.rawValue, forKey: .horizontalAlignment)
        }
        
        var inlinesContainer = container.nestedUnkeyedContainer(forKey: .inlines)
        for inline in inlines {
            if let textRun = inline as? SwiftTextRun {
                try inlinesContainer.encode(AnyCodable(textRun.serializeToJson()))
            } else if let stringValue = inline as? String {
                try inlinesContainer.encode(stringValue)
            }
        }
    }
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
}
