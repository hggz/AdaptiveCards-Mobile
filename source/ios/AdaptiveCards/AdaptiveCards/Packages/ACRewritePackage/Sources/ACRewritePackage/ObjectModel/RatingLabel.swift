import Foundation

/// Represents a rating label element in an Adaptive Card.
class RatingLabel: BaseCardElement {
    var value: Double
    var max: Double
    var count: UInt?
    var horizontalAlignment: HorizontalAlignment?
    var size: RatingSize
    var color: RatingColor
    var style: RatingStyle

    /// Designated initializer.
    init(id: String? = nil,
         value: Double = 0,
         max: Double = 5,
         count: UInt? = nil,
         horizontalAlignment: HorizontalAlignment? = nil,
         size: RatingSize = .medium,
         color: RatingColor = .neutral,
         style: RatingStyle = .default,
         spacing: Spacing? = nil,
         height: HeightType? = nil,
         targetWidth: TargetWidthType? = nil,
         separator: Bool? = nil,
         isVisible: Bool = true,
         areaGridName: String? = nil) {
        
        self.value = value
        self.max = max
        self.count = count
        self.horizontalAlignment = horizontalAlignment
        self.size = size
        self.color = color
        self.style = style
        
        // Ensure CardElementType has a case for ratingLabel.
        super.init(
            type: .ratingLabel,
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
        case value, max, count, horizontalAlignment, size, color, style
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(Double.self, forKey: .value)
        self.max = try container.decode(Double.self, forKey: .max)
        self.count = try container.decodeIfPresent(UInt.self, forKey: .count)
        self.horizontalAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .horizontalAlignment)
        self.size = try container.decode(RatingSize.self, forKey: .size)
        self.color = try container.decode(RatingColor.self, forKey: .color)
        self.style = try container.decode(RatingStyle.self, forKey: .style)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(max, forKey: .max)
        try container.encodeIfPresent(count, forKey: .count)
        try container.encodeIfPresent(horizontalAlignment, forKey: .horizontalAlignment)
        try container.encode(size, forKey: .size)
        try container.encode(color, forKey: .color)
        try container.encode(style, forKey: .style)
        try super.encode(to: encoder)
    }
    
    // MARK: - JSON Serialization
    
    /// Converts the RatingLabel object into a JSON dictionary.
    /// It starts with the BaseCardElement JSON and adds RatingLabel–specific keys.
    func serializeToJson() -> [String: Any] {
        var json = [String: Any]()
        if let baseJson = try? self.serializeToJsonValue() {
            json = baseJson
        }
        
        json["value"] = value
        json["max"] = max
        
        if let count = count {
            json["count"] = count
        }
        
        if let alignment = horizontalAlignment {
            json["horizontalAlignment"] = alignment.rawValue
        }
        
        if size != .medium {
            json["size"] = size.rawValue
        }
        
        if color != .neutral {
            json["color"] = color.rawValue
        }
        
        if style != .default {
            json["style"] = style.rawValue
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
    
    /// Creates a RatingLabel object from a JSON dictionary.
    static func createFromJSON(_ json: [String: Any]) throws -> RatingLabel {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(RatingLabel.self, from: data)
    }
    
    /// Creates a RatingLabel object from a JSON string.
    static func createFromJSONString(_ jsonString: String) throws -> RatingLabel {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try JSONDecoder().decode(RatingLabel.self, from: data)
    }
}

/// Parses RatingLabel elements in an Adaptive Card.
class RatingLabelParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> BaseCardElement {
        return try RatingLabel.createFromJSON(value)
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> BaseCardElement {
        return try RatingLabel.createFromJSONString(value)
    }
}

/// Enumeration representing rating sizes.
enum RatingSize: String, Codable {
    case small
    case medium
    case large
}

/// Enumeration representing rating colors.
enum RatingColor: String, Codable {
    case neutral
    case positive
    case negative
}

/// Enumeration representing rating styles.
enum RatingStyle: String, Codable {
    case `default`
    case outlined
    case filled
}
