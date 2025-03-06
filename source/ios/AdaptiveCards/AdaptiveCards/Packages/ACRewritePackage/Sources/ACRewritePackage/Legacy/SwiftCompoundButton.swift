import Foundation

/// Represents a compound button element in an Adaptive Card.
class SwiftCompoundButton: SwiftBaseCardElement {
    // MARK: - Properties
    let badge: String?
    let title: String?           // Inherited name "title" is now unique since we subclass BaseCardElement.
    let buttonDescription: String?  // Renamed from "description" to avoid conflict with Swift's 'description'.
    let icon: SwiftIconInfo?
    let selectAction: SwiftBaseActionElement?

    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case badge, title, buttonDescription = "description", icon, selectAction
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        badge = try container.decodeIfPresent(String.self, forKey: .badge)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        buttonDescription = try container.decodeIfPresent(String.self, forKey: .buttonDescription)
        icon = try container.decodeIfPresent(SwiftIconInfo.self, forKey: .icon)
        
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
        try container.encodeIfPresent(badge, forKey: .badge)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(buttonDescription, forKey: .buttonDescription)
        try container.encodeIfPresent(icon, forKey: .icon)
        
        if let action = selectAction {
            try container.encode(AnyCodable(try SwiftBaseCardElement.serializeSelectAction(action)), forKey: .selectAction)
        }
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    /// Serializes the CompoundButton to a JSON dictionary.
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
}
