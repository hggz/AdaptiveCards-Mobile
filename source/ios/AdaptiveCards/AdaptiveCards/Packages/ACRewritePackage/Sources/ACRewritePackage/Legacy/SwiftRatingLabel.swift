import Foundation

/// Represents a rating label element in an Adaptive Card.
class SwiftRatingLabel: SwiftBaseCardElement {
    // MARK: - Properties
    let value: Double
    let max: Double
    let count: UInt?
    let horizontalAlignment: SwiftHorizontalAlignment?
    let size: SwiftRatingSize
    let color: SwiftRatingColor
    let style: SwiftRatingStyle
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case value, max, count, horizontalAlignment, size, color, style
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        value = try container.decode(Double.self, forKey: .value)
        max = try container.decode(Double.self, forKey: .max)
        count = try container.decodeIfPresent(UInt.self, forKey: .count)
        horizontalAlignment = try container.decodeIfPresent(SwiftHorizontalAlignment.self, forKey: .horizontalAlignment)
        size = try container.decodeIfPresent(SwiftRatingSize.self, forKey: .size) ?? .medium
        color = try container.decodeIfPresent(SwiftRatingColor.self, forKey: .color) ?? .neutral
        style = try container.decodeIfPresent(SwiftRatingStyle.self, forKey: .style) ?? .default
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
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
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
}
