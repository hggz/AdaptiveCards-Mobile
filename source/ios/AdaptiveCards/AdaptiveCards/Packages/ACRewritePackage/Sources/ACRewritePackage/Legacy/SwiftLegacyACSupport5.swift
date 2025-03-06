import Foundation

enum SwiftToggleVisibilityTargetLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes a `SwiftToggleVisibilityTarget` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> SwiftToggleVisibilityTarget {
        // Legacy support: if the JSON is a single string, treat it as the elementId with a default toggle state.
        if let elementId = json as? String {
            return SwiftToggleVisibilityTarget(elementId: elementId, isVisible: .toggle)
        }
        
        // Expect a dictionary with an "elementId" key.
        guard let elementId = json["elementId"] as? String else {
            throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        
        // Legacy encoding stores isVisible as a Bool: true means .visible; false (or missing) means .hidden.
        let isVisible: SwiftIsVisible = (json["isVisible"] as? Bool) == true ? .visible : .hidden
        return SwiftToggleVisibilityTarget(elementId: elementId, isVisible: isVisible)
    }
    
    /// Deserializes a `SwiftToggleVisibilityTarget` from a JSON string.
    static func deserialize(from jsonString: String) throws -> SwiftToggleVisibilityTarget {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(from: jsonDict)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftToggleVisibilityTarget to a JSON dictionary with legacy formatting.
    static func serializeToJson(_ target: SwiftToggleVisibilityTarget, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        json["elementId"] = target.elementId
        
        // If the target is not in its default state (.toggle), include the "isVisible" key.
        if target.isVisible != .toggle {
            json["isVisible"] = (target.isVisible == .visible)
        }
        return json
    }
}

// MARK: - Extension for Legacy Serialization

internal extension SwiftToggleVisibilityTarget {
    /// Serializes this target to legacy JSON format.
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        return try SwiftToggleVisibilityTargetLegacySupport.serializeToJson(self, baseJson: superResult)
    }
    
    /// Deserializes a `ToggleVisibilityTarget` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> SwiftToggleVisibilityTarget {
        if let elementId = json as? String {
            return SwiftToggleVisibilityTarget(elementId: elementId, isVisible: .toggle)
        }

        guard let elementId = json["elementId"] as? String else {
            throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        
        let isVisible: SwiftIsVisible = (json["isVisible"] as? Bool) == true ? .visible : .hidden
        return SwiftToggleVisibilityTarget(elementId: elementId, isVisible: isVisible)
    }

    /// Deserializes a `ToggleVisibilityTarget` from a JSON string.
    static func deserialize(from jsonString: String) throws -> SwiftToggleVisibilityTarget {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(from: jsonDict)
    }

}

enum SwiftTokenExchangeResourceLegacySupport {
    // MARK: - Legacy Helpers
    
    /// Determines if serialization should occur based on whether any fields have been set.
    static func shouldSerialize(_ resource: SwiftTokenExchangeResource) -> Bool {
        return resource.id != nil || resource.uri != nil || resource.providerId != nil
    }
    
    /// Serializes the resource to a JSON string.
    static func serialize(_ resource: SwiftTokenExchangeResource) throws -> String {
        let jsonData = try JSONEncoder().encode(resource)
        return String(data: jsonData, encoding: .utf8) ?? ""
    }
    
    /// Serializes the resource into a JSON dictionary.
    static func serializeToJsonValue(_ resource: SwiftTokenExchangeResource) throws -> [String: Any] {
        let jsonData = try JSONEncoder().encode(resource)
        return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] ?? [:]
    }
    
    /// Deserializes a `SwiftTokenExchangeResource` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> SwiftTokenExchangeResource {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftTokenExchangeResource.self, from: jsonData)
    }
    
    /// Deserializes a `SwiftTokenExchangeResource` from a JSON string.
    static func deserialize(from jsonString: String) throws -> SwiftTokenExchangeResource {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftTokenExchangeResource.self, from: jsonData)
    }
}

// MARK: - Extension for Legacy Serialization

internal extension SwiftTokenExchangeResource {
    /// Serializes this resource to legacy JSON format by merging with an existing JSON dictionary.
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        var json = superResult
        let legacyJson = try SwiftTokenExchangeResourceLegacySupport.serializeToJsonValue(self)
        // Merge the legacy JSON values into the base dictionary.
        legacyJson.forEach { json[$0.key] = $0.value }
        return json
    }
    
    /// Determines if serialization should occur based on whether fields have been set.
    var shouldSerialize: Bool {
        return id != nil || uri != nil || providerId != nil
    }
    
    /// Serializes the resource to a JSON string.
    func serialize() throws -> String {
        let jsonData = try JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8) ?? ""
    }

    /// Serializes the resource into a JSON object.
    func serializeToJsonValue() throws -> [String: Any] {
        let jsonData = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] ?? [:]
    }

    /// Deserializes a `TokenExchangeResource` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> SwiftTokenExchangeResource {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftTokenExchangeResource.self, from: jsonData)
    }

    /// Deserializes a `TokenExchangeResource` from a JSON string.
    static func deserialize(from jsonString: String) throws -> SwiftTokenExchangeResource {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "")
        }
        return try JSONDecoder().decode(SwiftTokenExchangeResource.self, from: jsonData)
    }

}

enum SwiftBaseActionElementLegacySupport {
    /// Deserializes a BaseActionElement from a JSON string.
    /// This function is maintained for backward compatibility.
    static func deserializeAction(from jsonString: String) throws -> SwiftBaseActionElement {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }
        // Ensure the JSON contains a "type" key.
        guard let typeString = jsonDict["type"] as? String else {
            throw AdaptiveCardParseError.invalidType
        }
        
        // Prepare the JSON data for decoding.
        let data = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        let decoder = JSONDecoder()
        
        switch typeString {
        case SwiftActionType.openUrl.rawValue:
            return try decoder.decode(SwiftOpenUrlAction.self, from: data)
        case SwiftActionType.showCard.rawValue:
            return try decoder.decode(SwiftShowCardAction.self, from: data)
        case SwiftActionType.submit.rawValue:
            return try decoder.decode(SwiftSubmitAction.self, from: data)
        case SwiftActionType.toggleVisibility.rawValue:
            return try decoder.decode(SwiftToggleVisibilityAction.self, from: data)
        case SwiftActionType.execute.rawValue:
            return try decoder.decode(SwiftExecuteAction.self, from: data)
        default:
            // For any unknown type, decode as an UnknownAction.
            return try decoder.decode(SwiftUnknownAction.self, from: data)
        }
    }
    
    /// Deserializes a BaseActionElement from a JSON dictionary.
    static func deserializeAction(from originalJson: [String: Any]) throws -> SwiftBaseActionElement {
        let data = try JSONSerialization.data(withJSONObject: originalJson, options: [])
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw AdaptiveCardParseError.invalidJson
        }
        return try deserializeAction(from: jsonString)
    }
}

extension SwiftBaseActionElement {
    // MARK: - Deserialization Helpers
    
    /// Deserializes a BaseActionElement from a JSON string.
    /// This function is crucial and remains available for backward compatibility.
    class func deserializeAction(from jsonString: String) throws -> SwiftBaseActionElement {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }
        // Ensure the JSON contains a "type" key.
        guard let typeString = jsonDict["type"] as? String else {
            throw AdaptiveCardParseError.invalidType
        }
        
        // Prepare the JSON data for decoding.
        let data = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        let decoder = JSONDecoder()
        
        switch typeString {
        case SwiftActionType.openUrl.rawValue:
            return try decoder.decode(SwiftOpenUrlAction.self, from: data)
        case SwiftActionType.showCard.rawValue:
            return try decoder.decode(SwiftShowCardAction.self, from: data)
        case SwiftActionType.submit.rawValue:
            return try decoder.decode(SwiftSubmitAction.self, from: data)
        case SwiftActionType.toggleVisibility.rawValue:
            return try decoder.decode(SwiftToggleVisibilityAction.self, from: data)
        case SwiftActionType.execute.rawValue:
            return try decoder.decode(SwiftExecuteAction.self, from: data)
        default:
            // For any unknown or invalid type, decode as UnknownAction.
            return try decoder.decode(SwiftUnknownAction.self, from: data)
        }
    }
    
    /// Deserializes a BaseActionElement from a JSON dictionary.
    class func deserializeAction(from originalJson: [String: Any]) throws -> SwiftBaseActionElement {
        let data = try JSONSerialization.data(withJSONObject: originalJson, options: [])
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw AdaptiveCardParseError.invalidJson
        }
        return try deserializeAction(from: jsonString)
    }
}

enum SwiftExecuteActionLegacySupport {
    /// Sets the `dataJson` property from a JSON string.
    static func setDataJson(for action: SwiftExecuteAction, from jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            return
        }
        // Convert [String: Any] into [String: AnyCodable]
        action.dataJson = jsonDict.mapValues { AnyCodable($0) }
    }

    /// Serializes the action into a legacy JSON dictionary.
    static func serializeToJson(_ action: SwiftExecuteAction) -> [String: Any] {
        do {
            // Start with the base JSON from the superclass.
            var json = try action.serializeToJsonValue()
            
            if let dataJson = action.dataJson {
                // Convert [String: AnyCodable] to [String: Any] by extracting underlying values.
                json["data"] = dataJson.mapValues { $0.value }
            }
            if !action.verb.isEmpty {
                json["verb"] = action.verb
            }
            if action.associatedInputs != .auto {
                json["associatedInputs"] = action.associatedInputs.rawValue
            }
            json["conditionallyEnabled"] = action.conditionallyEnabled
            
            return json
        } catch {
            debugPrint("execute action error serializing to json")
            return [:]
        }
    }
}

final class SwiftExecuteActionParser: SwiftActionElementParser {
    func deserialize(context: SwiftParseContext, from json: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftExecuteAction.self, from: data)
    }

    func deserialize(fromString jsonString: String, context: SwiftParseContext) throws -> any SwiftAdaptiveCardElementProtocol {
        guard let jsonData = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(context: context, from: json)
    }
}

enum SwiftShowCardActionLegacySupport {
    /// Deserializes a `SwiftShowCardAction` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> SwiftShowCardAction {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftShowCardAction.self, from: data)
    }
    
    /// Deserializes a `SwiftShowCardAction` from a JSON string.
    static func deserialize(from jsonString: String) throws -> SwiftShowCardAction {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftShowCardAction.self, from: data)
    }
    
    /// Serializes `SwiftShowCardAction` to a legacy JSON dictionary.
    static func serializeToJson(_ action: SwiftShowCardAction) throws -> [String: Any] {
        var json = [String: Any]()
        if let card = action.card {
            var cardJson = try card.serializeToJsonValue()
            // Force fallback-related keys to non-nil defaults.
            cardJson[SwiftAdaptiveCardSchemaKey.fallbackText.rawValue] = card.fallbackText ?? ""
            cardJson[SwiftAdaptiveCardSchemaKey.speak.rawValue] = card.speak ?? ""
            // For language, if missing, force "en".
            cardJson["lang"] = card.language ?? "en"
            // Ensure the sub-card JSON contains a type.
            if cardJson["type"] == nil {
                cardJson["type"] = "AdaptiveCard"
            }
            json[SwiftAdaptiveCardSchemaKey.card.rawValue] = cardJson
        }
        return json
    }
    
    /// Serializes `SwiftShowCardAction` to a JSON string.
    static func serialize(_ action: SwiftShowCardAction) throws -> String {
        let json = try serializeToJson(action)
        return try SwiftParseUtil.jsonToString(json)
    }
}

enum SwiftOpenUrlActionLegacySupport {
    /// Deserializes a `SwiftOpenUrlAction` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> SwiftOpenUrlAction {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftOpenUrlAction.self, from: data)
    }
    
    /// Deserializes a `SwiftOpenUrlAction` from a JSON string.
    static func deserialize(from jsonString: String) throws -> SwiftOpenUrlAction {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftOpenUrlAction.self, from: data)
    }
}

struct OpenUrlActionParser: SwiftActionElementParser {
    func deserialize(context: SwiftParseContext, from json: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftOpenUrlActionLegacySupport.deserialize(from: json)
    }
    
    func deserialize(fromString jsonString: String, context: SwiftParseContext) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftOpenUrlActionLegacySupport.deserialize(from: jsonString)
    }
}

enum SwiftSubmitActionLegacySupport {
    /// Creates a SwiftSubmitAction from a JSON dictionary.
    static func make(from json: [String: Any]) throws -> SwiftSubmitAction {
        let dataJson: Any?
        if let data = json[SwiftAdaptiveCardSchemaKey.data.rawValue] {
            if let dataDict = data as? [String: Any] {
                dataJson = dataDict
            } else {
                dataJson = data
            }
        } else {
            dataJson = nil
        }
        
        let associatedInputsString = json[SwiftAdaptiveCardSchemaKey.associatedInputs.rawValue] as? String ?? "auto"
        let associatedInputs = SwiftAssociatedInputs(rawValue: associatedInputsString) ?? .auto
        let conditionallyEnabled = json[SwiftAdaptiveCardSchemaKey.conditionallyEnabled.rawValue] as? Bool ?? false
        
        let title = json["title"] as? String
        let iconUrl = json["iconUrl"] as? String
        let style = json["style"] as? String ?? "default"
        let tooltip = json["tooltip"] as? String
        let mode = (json["mode"] as? String).flatMap { SwiftMode(rawValue: $0) } ?? .primary
        let isEnabled = json["isEnabled"] as? Bool ?? true
        let id = json["id"] as? String
        
        let action = SwiftSubmitAction(
            dataJson: dataJson,
            associatedInputs: associatedInputs,
            conditionallyEnabled: conditionallyEnabled,
            title: title,
            iconUrl: iconUrl,
            style: style,
            tooltip: tooltip,
            mode: mode,
            isEnabled: isEnabled,
            id: id
        )
        
        // Set additional properties for any keys not in the known set.
        var additionalProps: [String: Any] = [:]
        for (key, value) in json {
            if !SwiftSubmitAction.knownProperties.contains(key) {
                additionalProps[key] = value
            }
        }
        if !additionalProps.isEmpty {
            action.additionalProperties = additionalProps.mapValues { AnyCodable($0) }
        }
        
        return action
    }
    
    /// Returns a legacy-formatted JSON dictionary for the given SubmitAction, merging with the provided base JSON.
    static func serializeToJsonValue(_ action: SwiftSubmitAction, superResult: [String: Any]) throws -> [String: Any] {
        var json = superResult
        
        json["type"] = "Action.Submit"
        
        // Include the data, preserving its original format.
        if let dataJson = action.dataJson {
            json[SwiftAdaptiveCardSchemaKey.data.rawValue] = dataJson
        }
        
        if action.associatedInputs != .auto {
            json[SwiftAdaptiveCardSchemaKey.associatedInputs.rawValue] = action.associatedInputs.rawValue
        }
        
        // Include title if present.
        if !action.title.isEmpty {
            json["title"] = action.title
        }
        
        // Merge in any additional properties.
        if let additionalProps = action.additionalProperties, !additionalProps.isEmpty {
            for (key, value) in additionalProps {
                json[key] = value.value
            }
        }
        
        return json
    }
}

class SubmitActionParser: SwiftActionElementParser {
    func deserialize(context: SwiftParseContext, from json: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftSubmitActionLegacySupport.make(from: json)
    }
    
    func deserialize(fromString jsonString: String, context: SwiftParseContext) throws -> any SwiftAdaptiveCardElementProtocol {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(context: context, from: jsonDict)
    }
}

extension SwiftSubmitAction {
    /// Creates a SubmitAction from a JSON dictionary.
    /// (Renamed from “deserialize(from:)” to avoid conflicting with BaseActionElement’s extension.)
    static func make(from json: [String: Any]) throws -> SwiftSubmitAction {
        let dataJson: Any?
        if let data = json[SwiftAdaptiveCardSchemaKey.data.rawValue] {
            if let dataDict = data as? [String: Any] {
                dataJson = dataDict
            } else {
                dataJson = data
            }
        } else {
            dataJson = nil
        }
        
        let associatedInputsString = json[SwiftAdaptiveCardSchemaKey.associatedInputs.rawValue] as? String ?? "auto"
        let associatedInputs = SwiftAssociatedInputs(rawValue: associatedInputsString) ?? .auto
        let conditionallyEnabled = json[SwiftAdaptiveCardSchemaKey.conditionallyEnabled.rawValue] as? Bool ?? false
        
        let title = json["title"] as? String
        let iconUrl = json["iconUrl"] as? String
        let style = json["style"] as? String ?? "default"
        let tooltip = json["tooltip"] as? String
        let mode = (json["mode"] as? String).flatMap { SwiftMode(rawValue: $0) } ?? .primary
        let isEnabled = json["isEnabled"] as? Bool ?? true
        let id = json["id"] as? String
        
        let action = SwiftSubmitAction(dataJson: dataJson,
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

enum SwiftToggleVisibilityActionLegacySupport {
    /// Deserializes a SwiftToggleVisibilityAction from a JSON dictionary.
    static func deserialize(from json: [String: Any], context: SwiftParseContext) throws -> SwiftToggleVisibilityAction {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftToggleVisibilityAction.self, from: data)
    }
    
    /// Deserializes a SwiftToggleVisibilityAction from a JSON string.
    static func deserialize(from jsonString: String, context: SwiftParseContext) throws -> SwiftToggleVisibilityAction {
        guard let data = jsonString.data(using: .utf8) else {
            throw AdaptiveCardParseError.invalidJson
        }
        return try JSONDecoder().decode(SwiftToggleVisibilityAction.self, from: data)
    }
}

class ToggleVisibilityActionParser: SwiftActionElementParser {
    func deserialize(context: SwiftParseContext, from json: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftToggleVisibilityActionLegacySupport.deserialize(from: json, context: context)
    }
    
    func deserialize(fromString jsonString: String, context: SwiftParseContext) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftToggleVisibilityActionLegacySupport.deserialize(from: jsonString, context: context)
    }
}

final class UnknownActionParser: SwiftActionElementParser {
    func deserialize(context: SwiftParseContext, from json: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        guard let typeString = json["type"] as? String else {
            throw AdaptiveCardParseError.invalidType
        }
        
        // Create an unknown action with the original type.
        let unknownAction = SwiftUnknownAction(type: typeString)
        // Store all JSON key–value pairs in additionalProperties.
        unknownAction.additionalProperties = json.mapValues { AnyCodable($0) }
        return unknownAction
    }
    
    func deserialize(fromString jsonString: String, context: SwiftParseContext) throws -> any SwiftAdaptiveCardElementProtocol {
        let json = try SwiftParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(context: context, from: json)
    }
}
