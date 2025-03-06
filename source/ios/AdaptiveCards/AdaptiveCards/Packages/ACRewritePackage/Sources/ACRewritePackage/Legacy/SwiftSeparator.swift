import Foundation

/// Represents a separator with color and thickness attributes.
struct SwiftSeparator: Codable {
    // MARK: - Properties
    let thickness: SwiftSeparatorThickness
    let color: SwiftForegroundColor
    
    // MARK: - Initializers
    
    init(thickness: SwiftSeparatorThickness = .defaultThickness, color: SwiftForegroundColor = .default) {
        self.thickness = thickness
        self.color = color
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case thickness, color
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode properties with defaults if not present
        thickness = try container.decodeIfPresent(SwiftSeparatorThickness.self, forKey: .thickness) ?? .defaultThickness
        color = try container.decodeIfPresent(SwiftForegroundColor.self, forKey: .color) ?? .default
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(thickness, forKey: .thickness)
        try container.encode(color, forKey: .color)
    }
    
    // MARK: - Serialization to JSON
    
    /// Serializes the Separator to a JSON dictionary.
    func serializeToJsonValue() -> [String: Any] {
        return SwiftSeparatorLegacySupport.serializeToJson(self)
    }
}
