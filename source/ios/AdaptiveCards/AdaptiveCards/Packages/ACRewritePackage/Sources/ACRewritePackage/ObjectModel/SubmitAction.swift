import Foundation

// MARK: - SubmitAction Implementation

/// Represents a Submit Action in an Adaptive Card.
class SubmitAction: BaseActionElement {
    var dataJson: [String: Any]?
    var associatedInputs: AssociatedInputs
    var conditionallyEnabled: Bool

    /// Designated initializer.
    init(dataJson: [String: Any]? = nil,
         associatedInputs: AssociatedInputs = .auto,
         conditionallyEnabled: Bool = false,
         title: String? = nil,
         iconUrl: String? = nil,
         style: String? = "default",
         tooltip: String? = nil,
         mode: Mode = .primary,
         isEnabled: Bool = true,
         role: ActionRole? = nil,
         id: String? = nil) {
        self.dataJson = dataJson
        self.associatedInputs = associatedInputs
        self.conditionallyEnabled = conditionallyEnabled
        // Call the designated initializer of BaseActionElement.
        super.init(type: .submit, title: title, iconUrl: iconUrl, style: style, tooltip: tooltip, mode: mode, isEnabled: isEnabled, role: role, id: id)
    }
    
    /// Required initializer for Codable.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SubmitActionCodingKeys.self)
        
        // Decode dataJson as a [String: AnyCodable] then convert.
        if let dataDict = try container.decodeIfPresent([String: AnyCodable].self, forKey: .dataJson) {
            self.dataJson = dataDict.mapValues { $0.value }
        } else {
            self.dataJson = nil
        }
        self.associatedInputs = try container.decodeIfPresent(AssociatedInputs.self, forKey: .associatedInputs) ?? .auto
        self.conditionallyEnabled = try container.decodeIfPresent(Bool.self, forKey: .conditionallyEnabled) ?? false
        
        try super.init(from: decoder)
    }
    
    /// Encodes this action to an Encoder.
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: SubmitActionCodingKeys.self)
        if let dataJson = self.dataJson {
            let encodableDict = dataJson.mapValues { AnyCodable($0) }
            try container.encode(encodableDict, forKey: .dataJson)
        }
        if associatedInputs != .auto {
            try container.encode(associatedInputs, forKey: .associatedInputs)
        }
        try container.encode(conditionallyEnabled, forKey: .conditionallyEnabled)
    }
    
    /// Coding keys for SubmitAction.
    enum SubmitActionCodingKeys: String, CodingKey {
        case dataJson = "data"
        case associatedInputs
        case conditionallyEnabled
    }
    
    /// Serializes the action into a JSON dictionary.
    func serializeToJson() -> [String: Any] {
        do {
            var json = try super.serializeToJsonValue()
            
            if let dataJson = self.dataJson {
                json[AdaptiveCardSchemaKey.data.rawValue] = dataJson
            }
            
            if associatedInputs != .auto {
                json[AdaptiveCardSchemaKey.associatedInputs.rawValue] = associatedInputs.rawValue
            }
            
            json[AdaptiveCardSchemaKey.conditionallyEnabled.rawValue] = conditionallyEnabled
            return json
        } catch {
            debugPrint("submit action error serializing to json")
            return [:]
        }
    }
    
    /// Converts the action into a JSON string.
    func serialize() throws -> String {
        let jsonData = try JSONSerialization.data(withJSONObject: serializeToJsonValue(), options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }
    
    /// Creates a SubmitAction from a JSON dictionary.
    /// (Renamed from “deserialize(from:)” to avoid conflicting with BaseActionElement’s extension.)
    static func make(from json: [String: Any]) throws -> SubmitAction {
        let dataJson = json[AdaptiveCardSchemaKey.data.rawValue] as? [String: Any]
        let associatedInputsString = json[AdaptiveCardSchemaKey.associatedInputs.rawValue] as? String ?? "auto"
        let associatedInputs = AssociatedInputs(rawValue: associatedInputsString) ?? .auto
        let conditionallyEnabled = json[AdaptiveCardSchemaKey.conditionallyEnabled.rawValue] as? Bool ?? false
        
        // Decode additional base action properties.
        let title = json["title"] as? String
        let iconUrl = json["iconUrl"] as? String
        let style = json["style"] as? String ?? "default"
        let tooltip = json["tooltip"] as? String
        let mode = (json["mode"] as? String).flatMap { Mode(rawValue: $0) } ?? .primary
        let isEnabled = json["isEnabled"] as? Bool ?? true
        let roleString = json["actionRole"] as? String
        let role: ActionRole = roleString.flatMap { ActionRole(rawValue: $0) } ?? .button
        let id = json["id"] as? String
        
        return SubmitAction(dataJson: dataJson,
                            associatedInputs: associatedInputs,
                            conditionallyEnabled: conditionallyEnabled,
                            title: title,
                            iconUrl: iconUrl,
                            style: style,
                            tooltip: tooltip,
                            mode: mode,
                            isEnabled: isEnabled,
                            role: role,
                            id: id)
    }
}

// MARK: - SubmitActionParser Implementation

/// Parses a SubmitAction from JSON.
class SubmitActionParser: ActionElementParser {
    func deserialize(context: inout ParseContext, from json: [String: Any]) throws -> BaseActionElement {
        return try SubmitAction.make(from: json)
    }
    
    func deserialize(fromString jsonString: String, context: inout ParseContext) throws -> BaseActionElement {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(context: &context, from: jsonDict)
    }
}
