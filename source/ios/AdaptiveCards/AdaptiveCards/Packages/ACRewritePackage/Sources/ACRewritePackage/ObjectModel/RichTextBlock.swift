import Foundation

/// Represents a rich text block with inline elements.
class RichTextBlock: BaseCardElement {
    var horizontalAlignment: HorizontalAlignment?
    var inlines: [Inline]
    
    /// Designated initializer.
    init(id: String? = nil,
         horizontalAlignment: HorizontalAlignment? = nil,
         inlines: [Inline] = [],
         spacing: Spacing? = nil,
         height: HeightType? = nil,
         targetWidth: TargetWidthType? = nil,
         separator: Bool? = nil,
         isVisible: Bool = true,
         areaGridName: String? = nil) {
        
        self.horizontalAlignment = horizontalAlignment
        self.inlines = inlines
        // Pass the appropriate element type to the base initializer.
        super.init(
            type: .richTextBlock,
            spacing: spacing,
            height: height,
            targetWidth: targetWidth,
            separator: separator,
            isVisible: isVisible,
            areaGridName: areaGridName,
            id: id
        )
    }
    
    // MARK: - Codable
    
    private enum RichTextBlockCodingKeys: String, CodingKey {
        case horizontalAlignment
        case inlines
    }
    
    required init(from decoder: Decoder) throws {
        // Initialize subclass properties with default values before calling super.init.
        self.inlines = []
        self.horizontalAlignment = nil
        
        try super.init(from: decoder)
        
        let container = try decoder.container(keyedBy: RichTextBlockCodingKeys.self)
        
        // Decode horizontalAlignment (stored as its raw string value)
        if let alignmentRaw = try container.decodeIfPresent(String.self, forKey: .horizontalAlignment) {
            self.horizontalAlignment = HorizontalAlignment(rawValue: alignmentRaw)
        }
        
        // Decode inlines: inlines are stored as a JSON string.
        let inlinesJSONString = try container.decode(String.self, forKey: .inlines)
        guard let data = inlinesJSONString.data(using: .utf8),
              let inlinesJSONArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            throw DecodingError.dataCorruptedError(forKey: .inlines,
                                                   in: container,
                                                   debugDescription: "Invalid inlines JSON")
        }
        self.inlines = try inlinesJSONArray.map { try deserializeInline(from: $0) }
    }
    
    override func encode(to encoder: Encoder) throws {
        // First, let the BaseCardElement encode its own properties.
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: RichTextBlockCodingKeys.self)
        
        // Encode horizontalAlignment as its raw value.
        if let horizontalAlignment = horizontalAlignment {
            try container.encode(horizontalAlignment.rawValue, forKey: .horizontalAlignment)
        }
        
        // For inlines, convert each inline into a JSON dictionary and then into a JSON string.
        let inlinesJSONArray = inlines.map { $0.serializeToJson() }
        let data = try JSONSerialization.data(withJSONObject: inlinesJSONArray, options: [])
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw EncodingError.invalidValue(inlinesJSONArray,
                                             EncodingError.Context(codingPath: container.codingPath,
                                                                   debugDescription: "Unable to encode inlines as JSON string"))
        }
        try container.encode(jsonString, forKey: .inlines)
    }
    
    // MARK: - JSON Serialization Helpers
    
    /// Converts the RichTextBlock object into a JSON dictionary.
    func serializeToJson() -> [String: Any] {
        var json = [String: Any]()
        // Start with BaseCardElement’s JSON.
        if let baseJson = try? self.serializeToJsonValue() {
            json = baseJson
        }
        // Add RichTextBlock–specific keys.
        if let horizontalAlignment = horizontalAlignment {
            json["horizontalAlignment"] = horizontalAlignment.rawValue
        }
        let inlinesJSONArray = inlines.map { $0.serializeToJson() }
        json["inlines"] = inlinesJSONArray
        // Ensure the type is explicitly set.
        json["type"] = "RichTextBlock"
        return json
    }
    
    /// Returns a JSON string representation.
    func toJSONString() -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: serializeToJson(), options: .prettyPrinted)
            return String(data: data, encoding: .utf8) ?? "{}"
        } catch {
            return "{}"
        }
    }
    
    // MARK: - Utility Deserialization
    
    /// Creates a RichTextBlock object from a JSON dictionary.
    static func createFromJSON(_ json: [String: Any]) throws -> RichTextBlock {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(RichTextBlock.self, from: data)
    }
    
    /// Creates a RichTextBlock object from a JSON string.
    static func createFromJSONString(_ jsonString: String) throws -> RichTextBlock {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try JSONDecoder().decode(RichTextBlock.self, from: data)
    }
}

/// Parses RichTextBlock elements in an Adaptive Card.
class RichTextBlockParser: BaseCardElementParser {
    func deserialize(context: inout ParseContext, value: [String: Any]) throws -> BaseCardElement {
        return try RichTextBlock.createFromJSON(value)
    }
    
    func deserialize(fromString context: inout ParseContext, value: String) throws -> BaseCardElement {
        return try RichTextBlock.createFromJSONString(value)
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
