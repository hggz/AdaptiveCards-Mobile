import Foundation

/// Represents a rating input element in an Adaptive Card.
class SwiftRatingInput: SwiftBaseCardElement {
    var value: Double
    var max: Double
    var horizontalAlignment: SwiftHorizontalAlignment?
    var size: SwiftRatingSize
    var color: SwiftRatingColor

    /// Designated initializer.
    init(id: String? = nil,
         value: Double = 0,
         max: Double = 5,
         horizontalAlignment: SwiftHorizontalAlignment? = nil,
         size: SwiftRatingSize = .medium,
         color: SwiftRatingColor = .neutral,
         spacing: SwiftSpacing? = nil,
         height: SwiftHeightType? = nil,
         targetWidth: SwiftTargetWidthType? = nil,
         separator: Bool? = nil,
         isVisible: Bool = true,
         areaGridName: String? = nil) {
        
        self.value = value
        self.max = max
        self.horizontalAlignment = horizontalAlignment
        self.size = size
        self.color = color
        
        // Ensure CardElementType has a case for ratingInput.
        super.init(
            type: .ratingInput,
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
    
    private enum CodingKeys: String, CodingKey {
        case value, max, horizontalAlignment, size, color
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(Double.self, forKey: .value)
        self.max = try container.decode(Double.self, forKey: .max)
        self.horizontalAlignment = try container.decodeIfPresent(SwiftHorizontalAlignment.self, forKey: .horizontalAlignment)
        self.size = try container.decode(SwiftRatingSize.self, forKey: .size)
        self.color = try container.decode(SwiftRatingColor.self, forKey: .color)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(max, forKey: .max)
        try container.encodeIfPresent(horizontalAlignment, forKey: .horizontalAlignment)
        try container.encode(size, forKey: .size)
        try container.encode(color, forKey: .color)
        try super.encode(to: encoder)
    }
    
    // MARK: - JSON Serialization
    
    /// Converts the RatingInput object into a JSON dictionary.
    /// This builds upon the BaseCardElement JSON by adding RatingInput–specific keys.
    func serializeToJson() -> [String: Any] {
        var json = [String: Any]()
        if let baseJson = try? self.serializeToJsonValue() {
            json = baseJson
        }
        json["value"] = value
        json["max"] = max
        if let alignment = horizontalAlignment {
            json["horizontalAlignment"] = alignment.rawValue
        }
        // Only include non-default values
        if size != .medium {
            json["size"] = size.rawValue
        }
        if color != .neutral {
            json["color"] = color.rawValue
        }
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
    
    /// Creates a RatingInput object from a JSON dictionary.
    static func createFromJSON(_ json: [String: Any]) throws -> SwiftRatingInput {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftRatingInput.self, from: data)
    }
    
    /// Creates a RatingInput object from a JSON string.
    static func createFromJSONString(_ jsonString: String) throws -> SwiftRatingInput {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try JSONDecoder().decode(SwiftRatingInput.self, from: data)
    }
}

/// Parses RatingInput elements in an Adaptive Card.
class SwiftRatingInputParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftRatingInput.createFromJSON(value)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftRatingInput.createFromJSONString(value)
    }
}
