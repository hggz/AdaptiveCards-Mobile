import Foundation

// MARK: - SubmitAction Implementation

/// Represents a Submit Action in an Adaptive Card.
class SubmitAction: BaseActionElement {
    // Change type to Any? to handle both String and Dictionary
    var dataJson: Any?
    var associatedInputs: AssociatedInputs
    var conditionallyEnabled: Bool
    
    // Set of known properties to filter out
    private static let knownProperties: Set<String> = [
        "data", "associatedInputs", "conditionallyEnabled",
        "title", "iconUrl", "style", "tooltip", "mode", "isEnabled", "role", "type", "id"
    ]
    
    /// Designated initializer.
    init(dataJson: Any? = nil,
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
        super.init(type: .submit, id: id)
    }
    /// Required initializer for Codable.
    // In SubmitAction.swift, update the decoding logic:
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SubmitActionCodingKeys.self)
        
        if let dataString = try? container.decode(String.self, forKey: .dataJson) {
            self.dataJson = dataString
        } else if let dataDict = try? container.decode([String: AnyCodable].self, forKey: .dataJson) {
            self.dataJson = dataDict.mapValues { $0.value }
        } else {
            self.dataJson = nil
        }
        
        self.associatedInputs = try container.decodeIfPresent(AssociatedInputs.self, forKey: .associatedInputs) ?? .auto
        self.conditionallyEnabled = try container.decodeIfPresent(Bool.self, forKey: .conditionallyEnabled) ?? false
        
        try super.init(from: decoder)
        
        // Filter out known properties
        if var additional = self.additionalProperties {
            additional = additional.filter { !Self.knownProperties.contains($0.key) }
            self.additionalProperties = additional.isEmpty ? nil : additional
        }
    }
    
    /// Encodes this action to an Encoder.
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: SubmitActionCodingKeys.self)
        
        // Handle encoding based on type
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
    
    /// Coding keys for SubmitAction.
    enum SubmitActionCodingKeys: String, CodingKey {
        case dataJson = "data"
        case associatedInputs
        case conditionallyEnabled
    }
    
    /// Serializes the action into a JSON dictionary.
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        
        json["type"] = "Action.Submit"
        
        // Handle dataJson serialization to maintain exact format
        if let dataJson = self.dataJson {
            json[AdaptiveCardSchemaKey.data.rawValue] = dataJson
        }
        
        if associatedInputs != .auto {
            json[AdaptiveCardSchemaKey.associatedInputs.rawValue] = associatedInputs.rawValue
        }
        
        if !title.isEmpty {
            json["title"] = title
        }
        
        // Include only non-empty additional properties
        if let additionalProps = additionalProperties, !additionalProps.isEmpty {
            for (key, value) in additionalProps {
                json[key] = value.value
            }
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
        let dataJson: Any?
        if let data = json[AdaptiveCardSchemaKey.data.rawValue] {
            if let dataDict = data as? [String: Any] {
                dataJson = dataDict
            } else {
                dataJson = data
            }
        } else {
            dataJson = nil
        }
        
        let associatedInputsString = json[AdaptiveCardSchemaKey.associatedInputs.rawValue] as? String ?? "auto"
        let associatedInputs = AssociatedInputs(rawValue: associatedInputsString) ?? .auto
        let conditionallyEnabled = json[AdaptiveCardSchemaKey.conditionallyEnabled.rawValue] as? Bool ?? false
        
        let title = json["title"] as? String
        let iconUrl = json["iconUrl"] as? String
        let style = json["style"] as? String ?? "default"
        let tooltip = json["tooltip"] as? String
        let mode = (json["mode"] as? String).flatMap { Mode(rawValue: $0) } ?? .primary
        let isEnabled = json["isEnabled"] as? Bool ?? true
        let id = json["id"] as? String
        
        let action = SubmitAction(dataJson: dataJson,
                                  associatedInputs: associatedInputs,
                                  conditionallyEnabled: conditionallyEnabled,
                                  title: title,
                                  iconUrl: iconUrl,
                                  style: style,
                                  tooltip: tooltip,
                                  mode: mode,
                                  isEnabled: isEnabled,
                                  id: id)
        
        // Filter and set additional properties
        var additionalProps: [String: Any] = [:]
        for (key, value) in json {
            if !Self.knownProperties.contains(key) {
                additionalProps[key] = value
            }
        }
        if !additionalProps.isEmpty {
            action.additionalProperties = additionalProps.mapValues { AnyCodable($0) }
        }
        
        return action
    }
}

// MARK: - SubmitActionParser Implementation

/// Parses a SubmitAction from JSON.
class SubmitActionParser: ActionElementParser {
    func deserialize(context: ParseContext, from json: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        return try SubmitAction.make(from: json)
    }
    
    func deserialize(fromString jsonString: String, context: ParseContext) throws -> any AdaptiveCardElementProtocol {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(context: context, from: jsonDict)
    }
}
