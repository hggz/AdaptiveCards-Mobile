import Foundation

/// Represents an icon element in an Adaptive Card.
class SwiftIcon: SwiftBaseCardElement {
    // MARK: - Properties
    let name: String?
    let foregroundColor: SwiftForegroundColor
    let iconSize: SwiftIconSize
    let iconStyle: SwiftIconStyle
    let selectAction: SwiftBaseActionElement?
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case name, foregroundColor, iconSize, iconStyle, selectAction
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        name = try container.decodeIfPresent(String.self, forKey: .name)
        foregroundColor = try container.decodeIfPresent(SwiftForegroundColor.self, forKey: .foregroundColor) ?? .default
        iconSize = try container.decodeIfPresent(SwiftIconSize.self, forKey: .iconSize) ?? .standard
        iconStyle = try container.decodeIfPresent(SwiftIconStyle.self, forKey: .iconStyle) ?? .regular
        
        // Decode selectAction if present
        if container.contains(.selectAction) {
            let actionDict = try container.decode([String: AnyCodable].self, forKey: .selectAction)
            let dict = actionDict.mapValues { $0.value }
            selectAction = try SwiftBaseActionElement.deserializeAction(from: dict)
        } else {
            selectAction = nil
        }
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(foregroundColor, forKey: .foregroundColor)
        try container.encode(iconSize, forKey: .iconSize)
        try container.encode(iconStyle, forKey: .iconStyle)
        
        if let action = selectAction {
            try container.encode(AnyCodable(try SwiftBaseCardElement.serializeSelectAction(action)), forKey: .selectAction)
        }
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
}
