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
    override func serializeToJsonValue() throws -> [String: Any] {
        // Get base properties
        var json = try super.serializeToJsonValue()
        
        // Ensure we use the correct type
        json["type"] = "Action.Submit"
        
        // Add SubmitAction-specific properties
        if let dataJson = self.dataJson {
            json[AdaptiveCardSchemaKey.data.rawValue] = dataJson
        }
        
        if associatedInputs != .auto {
            json[AdaptiveCardSchemaKey.associatedInputs.rawValue] = associatedInputs.rawValue
        }
        
        json[AdaptiveCardSchemaKey.conditionallyEnabled.rawValue] = conditionallyEnabled
        
        // Make sure title is included (this is from BaseActionElement)
        if let title = title {
            json["title"] = title
        }
        
        return json
    }

    // Remove or deprecate the old serializeToJson() method since we're using serializeToJsonValue now
    @available(*, deprecated, message: "Use serializeToJsonValue() instead")
    func serializeToJson() -> [String: Any] {
        do {
            return try serializeToJsonValue()
        } catch {
            debugPrint("submit action error serializing to json")
            return [:]
        }
    }

    // Update serialize() to use serializeToJsonValue
    func serialize() throws -> String {
        let json = try serializeToJsonValue()
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
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
    func deserialize(context: ParseContext, from json: [String: Any]) throws -> BaseActionElement {
        return try SubmitAction.make(from: json)
    }
    
    func deserialize(fromString jsonString: String, context: ParseContext) throws -> BaseActionElement {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(context: context, from: jsonDict)
    }
}
