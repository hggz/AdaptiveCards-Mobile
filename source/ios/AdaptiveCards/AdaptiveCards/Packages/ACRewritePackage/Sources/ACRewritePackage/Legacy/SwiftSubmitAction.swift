import Foundation

/// Represents a Submit Action in an Adaptive Card.
class SwiftSubmitAction: SwiftBaseActionElement {
    // MARK: - Properties
    var dataJson: Any?
    var associatedInputs: SwiftAssociatedInputs
    var conditionallyEnabled: Bool
    
    // Known properties to filter out extra keys.
    static let knownProperties: Set<String> = [
        "data", "associatedInputs", "conditionallyEnabled",
        "title", "iconUrl", "style", "tooltip", "mode", "isEnabled", "role", "type", "id"
    ]
    
    /// Designated initializer.
    init(dataJson: Any? = nil,
         associatedInputs: SwiftAssociatedInputs = .auto,
         conditionallyEnabled: Bool = false,
         title: String? = nil,
         iconUrl: String? = nil,
         style: String? = "default",
         tooltip: String? = nil,
         mode: SwiftMode = .primary,
         isEnabled: Bool = true,
         role: SwiftActionRole? = nil,
         id: String? = nil) {
        self.dataJson = dataJson
        self.associatedInputs = associatedInputs
        self.conditionallyEnabled = conditionallyEnabled
        // Base properties such as title, iconUrl, etc. are assumed to be handled in SwiftBaseActionElement.
        super.init(type: .submit, id: id)
    }
    
    // MARK: - Codable Implementation
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SubmitActionCodingKeys.self)
        
        // Try decoding "data" as a String first; if that fails, try decoding as a dictionary.
        if let dataString = try? container.decode(String.self, forKey: .dataJson) {
            self.dataJson = dataString
        } else if let dataDict = try? container.decode([String: AnyCodable].self, forKey: .dataJson) {
            self.dataJson = dataDict.mapValues { $0.value }
        } else {
            self.dataJson = nil
        }
        
        self.associatedInputs = try container.decodeIfPresent(SwiftAssociatedInputs.self, forKey: .associatedInputs) ?? .auto
        self.conditionallyEnabled = try container.decodeIfPresent(Bool.self, forKey: .conditionallyEnabled) ?? false
        
        try super.init(from: decoder)
        
        // Filter out known keys from additionalProperties.
        if var additional = self.additionalProperties {
            additional = additional.filter { !Self.knownProperties.contains($0.key) }
            self.additionalProperties = additional.isEmpty ? nil : additional
        }
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: SubmitActionCodingKeys.self)
        
        // Encode dataJson based on its type.
        if let dataJson = self.dataJson {
            if let stringData = dataJson as? String {
                try container.encode(stringData, forKey: .dataJson)
            } else if let dictData = dataJson as? [String: Any] {
                let encodableDict = dictData.mapValues { AnyCodable($0) }
                try container.encode(encodableDict, forKey: .dataJson)
            }
        }
        
        if associatedInputs != .auto {
            try container.encode(associatedInputs, forKey: .associatedInputs)
        }
        try container.encode(conditionallyEnabled, forKey: .conditionallyEnabled)
    }
    
    enum SubmitActionCodingKeys: String, CodingKey {
        case dataJson = "data"
        case associatedInputs
        case conditionallyEnabled
    }
    
    /// Serializes the action into a JSON dictionary.
    override func serializeToJsonValue() throws -> [String: Any] {
        return try SwiftSubmitActionLegacySupport.serializeToJsonValue(self, superResult: super.serializeToJsonValue())
    }
}
