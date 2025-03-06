import Foundation

/// Represents a base action in an Adaptive Card.
/// This class is now decoupled from BaseCardElement.
class SwiftBaseActionElement: SwiftBaseElement, SwiftAdaptiveCardElementProtocol {
    // MARK: - Properties
    let title: String
    let iconUrl: String
    let style: String
    let tooltip: String
    let mode: SwiftMode
    let isEnabled: Bool
    let role: SwiftActionRole?
    
    override var typeString: String {
        get { super.typeString }
        set { super.typeString = newValue }
    }
    
    // MARK: - Initializer
    
    /// Initializes a BaseActionElement using an ActionType.
    /// Default property values are provided so that the synthesized Codable methods can work without additional custom initializers.
    init(type: SwiftActionType,
         id: String? = nil,
         title: String = "",
         iconUrl: String = "",
         style: String = "default",
         tooltip: String = "",
         mode: SwiftMode = .primary,
         isEnabled: Bool = true,
         role: SwiftActionRole? = nil) {
        
        // Compute role if not provided.
        let computedRole: SwiftActionRole? = role ?? (type == .openUrl ? .link : .button)
        self.title = title
        self.iconUrl = iconUrl
        self.style = style
        self.tooltip = tooltip
        self.mode = mode
        self.isEnabled = isEnabled
        self.role = computedRole
        super.init(typeString: type.rawValue, id: id)
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case title, iconUrl, style, tooltip, mode, isEnabled, role
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl) ?? ""
        self.style = try container.decodeIfPresent(String.self, forKey: .style) ?? "default"
        self.tooltip = try container.decodeIfPresent(String.self, forKey: .tooltip) ?? ""
        self.mode = try container.decodeIfPresent(SwiftMode.self, forKey: .mode) ?? .primary
        self.isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        self.role = try container.decodeIfPresent(SwiftActionRole.self, forKey: .role)
        try super.init(from: decoder)
        
        // Legacy support: Filter out keys already represented by properties.
        if var additional = self.additionalProperties {
            let knownKeys = Set(["title", "iconUrl", "style", "tooltip", "mode", "isEnabled", "role", "type", "id"])
            additional = additional.filter { !knownKeys.contains($0.key) }
            self.additionalProperties = additional.isEmpty ? nil : additional
        }
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(iconUrl, forKey: .iconUrl)
        try container.encode(style, forKey: .style)
        try container.encode(tooltip, forKey: .tooltip)
        try container.encode(mode, forKey: .mode)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(role, forKey: .role)
        try super.encode(to: encoder)
    }
    
    // MARK: - JSON Conversion
    
    /// Converts this action into a JSON dictionary.
    override func toJSON() -> [String: Any] {
        var json: [String: Any] = ["type": typeString]
        if let additionalProps = additionalProperties {
            for (key, value) in additionalProps {
                json[key] = value.value
            }
        }
        return json
    }
    
    /// Serializes the action into a JSON object.
    override func serializeToJsonValue() throws -> [String: Any] {
        return toJSON()
    }
}

// Utility extension for debugging (can remain here or be moved if desired).
extension Dictionary where Key == String, Value == Any {
    func debugPrint(label: String) {
        print("\n=== \(label) ===")
        for (key, value) in self {
            print("\(key): \(value)")
        }
        print("================")
    }
}
