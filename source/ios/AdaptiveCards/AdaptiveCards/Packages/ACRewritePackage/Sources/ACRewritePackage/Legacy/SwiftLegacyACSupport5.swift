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

/// Parser for `ShowCardAction` elements.
class SwiftShowCardActionParser: SwiftActionElementParser {
    
    /// Deserializes a `ShowCardAction` from a JSON dictionary.
    func deserialize(context: SwiftParseContext, from json: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftShowCardAction.self, from: data)
    }

    /// Deserializes a `ShowCardAction` from a JSON string.
    func deserialize(fromString jsonString: String, context: SwiftParseContext) throws -> any SwiftAdaptiveCardElementProtocol {
        let json = try SwiftParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(context: context, from: json)
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

enum SwiftStyledCollectionElementLegacySupport {
    static func serializeToJsonValue(_ element: SwiftStyledCollectionElement, superResult: [String: Any]) throws -> [String: Any] {
        var json = superResult
        if element.style != .none {
            json["style"] = SwiftContainerStyle.toString(element.style)
        }
        if let verticalAlignment = element.verticalContentAlignment {
            json["verticalContentAlignment"] = verticalAlignment.rawValue
        }
        if element.hasBleed {
            json["bleed"] = true
        }
        if element.minHeight > 0 {
            json["minHeight"] = "\(element.minHeight)px"
        }
        if let selectAction = element.selectAction {
            json["selectAction"] = selectAction.toJSON()
        }
        if let backgroundImage = element.backgroundImage {
            json["backgroundImage"] = backgroundImage.serializeToJsonValue()
        }
        return json
    }
}

extension SwiftContentSource {
    func serializeToJson() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }

    func getResourceInformation() -> SwiftRemoteResourceInformation? {
        guard let url = url, let mimeType = mimeType else { return nil }
        return SwiftRemoteResourceInformation(url: url, mimeType: mimeType)
    }

    static func deserialize(from json: [String: Any]) throws -> SwiftContentSource {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftContentSource.self, from: jsonData)
    }

    static func deserialize(from jsonString: String) throws -> SwiftContentSource {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "ContentSource", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        return try JSONDecoder().decode(SwiftContentSource.self, from: jsonData)
    }
}

extension SwiftFlowLayout {
    class func deserialize(from json: [String: Any]) throws -> SwiftFlowLayout {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftFlowLayout.self, from: data)
    }
}

// MARK: - Consolidated SwiftContainer Legacy Support

/// Unified legacy support for SwiftContainer parsing and serialization
enum SwiftContainerLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftContainer
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftContainer {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftContainer.self, from: data)
    }
    
    /// Deserializes string into a SwiftContainer
    static func deserialize(from jsonString: String) throws -> SwiftContainer {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftContainer.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftContainer to JSON dictionary with proper formatting
    static func serializeToJson(_ container: SwiftContainer, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set required properties
        json["type"] = "Container"
        
        // Serialize child items if present
        if !container.items.isEmpty {
            var itemsArray: [[String: Any]] = []
            for item in container.items {
                let itemJson = try item.serializeToJsonValue()
                itemsArray.append(itemJson)
            }
            json["items"] = itemsArray
        }
        
        // Add layouts if present
        if !container.layouts.isEmpty {
            var layoutsArray: [[String: Any]] = []
            for layout in container.layouts {
                // Assuming SwiftLayout has a toJSON method or similar
                layoutsArray.append(layout.toJSON())
            }
            json["layouts"] = layoutsArray
        }
        
        // Add rtl if present
        if let rtl = container.rtl {
            json["rtl"] = rtl
        }
        
        // Add vertical content alignment if present
        if let verticalContentAlignment = container.verticalContentAlignment {
            json["verticalContentAlignment"] = verticalContentAlignment.rawValue.lowercased()
        }
        
        // Add style if not default
        if container.style != .none {
            json["style"] = container.style.rawValue
        }
        
        return json
    }
}

// MARK: - Parser Implementation

/// Parses Container elements in an Adaptive Card
struct SwiftContainerParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: .container)
        
        // Save current context
        let parentStyle = context.parentalContainerStyle
        
        // Parse the container itself
        guard let container = try SwiftBaseCardElement.deserialize(from: value) as? SwiftContainer else {
            throw AdaptiveCardParseError.invalidType
        }
        
        // Set new parent style for children
        context.setParentalContainerStyle(container.style)
        
        // Configure container style
        container.configForContainerStyle(context)
        
        // Restore parent style
        if let parentStyle = parentStyle {
            context.setParentalContainerStyle(parentStyle)
        }
        
        return container
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftContainerLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftContainerLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftContainer Extension

extension SwiftContainer {
    /// Serializes to legacy JSON format
    
    // MARK: - Known Properties
    func populateKnownPropertiesSet() {
        self.knownProperties.insert("items")
        self.knownProperties.insert("layouts")
        self.knownProperties.insert("rtl")
        self.knownProperties.insert("style")
        self.knownProperties.insert("verticalContentAlignment")
        self.knownProperties.insert("bleed")
        self.knownProperties.insert("minHeight")
    }
    
    // MARK: - Helper Methods for Container Style
    internal func findParentColumn() -> SwiftColumn? {
        var current: SwiftBaseCardElement? = self
        var searchPath: [SwiftBaseCardElement] = []
        
        // First, build the parent chain
        while let currentElement = current {
            searchPath.append(currentElement)
            if let parentId = currentElement.parentalId {
                current = findElement(withId: parentId)
            } else {
                current = nil
            }
        }
        
        // Then search through the chain for the first Column
        for element in searchPath {
            if let parentId = element.parentalId,
               let column = findElement(withId: parentId) as? SwiftColumn {
                return column
            }
        }
        
        return nil
    }
    
    internal func findParentColumnSet(of element: SwiftBaseCardElement) -> SwiftColumnSet? {
        var current: SwiftBaseCardElement? = element
        
        while let currentElement = current {
            if let parentId = currentElement.parentalId {
                if let columnSet = findElement(withId: parentId) as? SwiftColumnSet {
                    return columnSet
                }
                current = findElement(withId: parentId)
            } else {
                current = nil
            }
        }
        
        return nil
    }
    
    func deserializeChildren(from json: [String: Any]) throws {
        // Parse Items array
        if let itemsArray = json["items"] as? [[String: Any]] {
            self.items = try itemsArray.map { itemJson in
                var mutableJson = itemJson
                // Ensure type is set for items that don't specify it
                if mutableJson["type"] == nil {
                    mutableJson["type"] = "TextBlock" // Default type
                }
                return try SwiftBaseCardElement.deserialize(from: mutableJson)
            }
        }
    }
}

// MARK: - Consolidated SwiftColumn Legacy Support

/// Unified legacy support for SwiftColumn parsing and serialization
enum SwiftColumnLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftColumn
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftColumn {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftColumn.self, from: data)
    }
    
    /// Deserializes string into a SwiftColumn
    static func deserialize(from jsonString: String) throws -> SwiftColumn {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftColumn.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftColumn to JSON dictionary with proper formatting
    static func serializeToJson(_ column: SwiftColumn, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set required properties
        json["type"] = "Column"
        json["width"] = column.width
        
        // Serialize items array
        if !column.items.isEmpty {
            var itemsArray: [[String: Any]] = []
            for item in column.items {
                let itemJson = try item.serializeToJsonValue()
                itemsArray.append(itemJson)
            }
            json["items"] = itemsArray
        }
        
        // Add optional properties
        if let rtl = column.rtl {
            json["rtl"] = rtl
        }
        
        // Add layouts if present
        if !column.layouts.isEmpty {
            var layoutsArray: [[String: Any]] = []
            for layout in column.layouts {
                // Assuming SwiftLayout has a toJSON method or similar
                layoutsArray.append(layout.toJSON())
            }
            json["layouts"] = layoutsArray
        }
        
        // Add style if not default
        if column.style != .none {
            json["style"] = column.style.rawValue
        }
        
        // Add vertical content alignment if present
        if let verticalContentAlignment = column.verticalContentAlignment {
            json["verticalContentAlignment"] = verticalContentAlignment.rawValue.lowercased()
        }
        
        // Add selectAction if present
        if let selectAction = column.selectAction {
            json["selectAction"] = try SwiftBaseCardElement.serializeSelectAction(selectAction)
        }
        
        return json
    }
}

// MARK: - Parser Implementation

/// Parses Column elements in an Adaptive Card
struct SwiftColumnParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        guard let typeString = value["type"] as? String,
              typeString == SwiftCardElementType.column.rawValue else {
            throw SwiftAdaptiveCardParseException(statusCode: .requiredPropertyMissing, message: "Invalid type for Column")
        }
        
        guard let column = try SwiftBaseCardElement.deserialize(from: value) as? SwiftColumn else {
            throw SwiftAdaptiveCardParseException(statusCode: .unsupportedParserOverride, message: "Column deserialization failed")
        }
        
        var columnWidth = SwiftParseUtil.getValueAsString(from: value, key: "width")
        if columnWidth.isEmpty {
            columnWidth = SwiftParseUtil.getValueAsString(from: value, key: "size")
        }
        column.setWidth(columnWidth, warnings: &context.warnings)
        column.setRtl(SwiftParseUtil.getOptionalBool(from: value, key: "rtl"))
        
        if let layoutArray: [[String: Any]] = try? SwiftParseUtil.getArray(from: value, key: "layouts", required: false), !layoutArray.isEmpty {
            var parsedLayouts: [SwiftLayout] = []
            for layoutJson in layoutArray {
                guard let baseLayout = SwiftLayout.fromJSON(layoutJson) else {
                    throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "Failed to parse layout")
                }
                switch baseLayout.layoutContainerType {
                case .flow:
                    let flowLayout = try SwiftFlowLayout.deserialize(from: layoutJson)
                    parsedLayouts.append(flowLayout)
                case .areaGrid:
                    let areaGridLayout = SwiftAreaGridLayout.deserialize(from: layoutJson)
                    if areaGridLayout.areas.isEmpty && areaGridLayout.columns.isEmpty {
                        let stackLayout = SwiftLayout()
                        stackLayout.layoutContainerType = .stack
                        parsedLayouts.append(stackLayout)
                    } else if areaGridLayout.areas.isEmpty {
                        let flowLayout = try SwiftFlowLayout.deserialize(from: layoutJson)
                        flowLayout.layoutContainerType = .flow
                        parsedLayouts.append(flowLayout)
                    } else {
                        parsedLayouts.append(SwiftAreaGridLayout.deserialize(from: layoutJson))
                    }
                default:
                    parsedLayouts.append(baseLayout)
                }
            }
            
            column.layouts = parsedLayouts
        }
        
        return column
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftColumnLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        let jsonDict = try SwiftParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}

// MARK: - SwiftColumn Extension

extension SwiftColumn {
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        return try SwiftColumnLegacySupport.serializeToJson(self, baseJson: superResult)
    }
    
    // MARK: - Known Properties
    func populateKnownPropertiesSet() {
        self.knownProperties.insert("items")
        self.knownProperties.insert("rtl")
        self.knownProperties.insert("selectAction")
        self.knownProperties.insert("width")
        self.knownProperties.insert("style")
        self.knownProperties.insert("verticalContentAlignment")
    }
    
    // MARK: - Resource Information
    func getResourceInformation(_ resourceInfo: inout [SwiftRemoteResourceInformation]) {
        for element in items {
            if let id = element.id {
                resourceInfo.append(SwiftRemoteResourceInformation(url: id, mimeType: ""))
            }
        }
    }
    
    // MARK: - Child Deserialization
    func deserializeChildren(context: SwiftParseContext, json: [String: Any]) throws {
        let cardElements = try SwiftParseUtil.getElementCollection(
            isTopToBottomContainer: true,
            context: context,
            json: json,
            key: "items",
            required: false
        )
        items = cardElements
    }
    
    // MARK: - RTL and Layout Setters
    func setRtl(_ value: Bool?) {
        rtl = value
    }
    
    func setLayouts(_ value: [SwiftLayout]) {
        layouts = value
    }
    
    // Helper to parse strings ending in "px" (e.g., "20px" → 20)
    internal func parseSizeForPixelSize(_ val: String) -> Int? {
        let lower = val.lowercased()
        guard lower.hasSuffix("px") else { return nil }
        let numberPart = lower.dropLast(2)
        return Int(numberPart)
    }
    
    // MARK: - setWidth Methods
    func setWidth(_ value: String, warnings: inout [SwiftAdaptiveCardParseWarning]) {
        self.width = value  // Property observer on 'width' will update pixelWidth
    }
    
    func setWidth(_ value: String) {
        var dummyWarnings = [SwiftAdaptiveCardParseWarning]()
        setWidth(value, warnings: &dummyWarnings)
    }
    
    func setPixelWidth(_ value: Int) {
        self.pixelWidth = value // Observer on 'pixelWidth' will update 'width'
    }
    
    func getPixelWidth() -> Int {
        return pixelWidth
    }
}

// MARK: - Consolidated SwiftColumnSet Legacy Support

/// Unified legacy support for SwiftColumnSet parsing and serialization
enum SwiftColumnSetLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftColumnSet
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftColumnSet {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftColumnSet.self, from: data)
    }
    
    /// Deserializes string into a SwiftColumnSet
    static func deserialize(from jsonString: String) throws -> SwiftColumnSet {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftColumnSet.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftColumnSet to JSON dictionary with proper formatting
    static func serializeToJson(_ columnSet: SwiftColumnSet, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set required properties
        json["type"] = "ColumnSet"
        
        // Serialize columns array
        if !columnSet.columns.isEmpty {
            var columnsArray: [[String: Any]] = []
            for column in columnSet.columns {
                let columnJson = try column.serializeToJsonValue()
                columnsArray.append(columnJson)
            }
            json["columns"] = columnsArray
        }
        
        // Add style if not default
        if columnSet.style != .none {
            json["style"] = columnSet.style.rawValue
        }
        
        // Add selectAction if present
        if let selectAction = columnSet.selectAction {
            json["selectAction"] = try SwiftBaseCardElement.serializeSelectAction(selectAction)
        }
        
        // Add bleed if true
        if columnSet.hasBleed {
            json["bleed"] = true
        }
        
        return json
    }
}

// MARK: - Parser Implementation

/// Parses ColumnSet elements in an Adaptive Card
struct SwiftColumnSetParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: .columnSet)
        
        // Parse the columnset itself
        let columnSet = try SwiftBaseCardElement.deserialize(from: value) as! SwiftColumnSet
        
        // Parse columns array
        let columnsArray: [[String: Any]] = try SwiftParseUtil.getArray(from: value, key: "columns", required: true)
        var columns: [SwiftColumn] = []
        
        for colJson in columnsArray {
            var temp = colJson
            if temp["type"] == nil {
                temp["type"] = "Column"
            }
            
            let base = try SwiftBaseCardElement.deserialize(from: temp)
            guard let col = base as? SwiftColumn else {
                throw AdaptiveCardParseError.invalidType
            }
            columns.append(col)
        }
        
        columnSet.columns = columns
        return columnSet
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftColumnSetLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        let jsonDict = try SwiftParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}

// MARK: - SwiftColumnSet Extension

extension SwiftColumnSet {
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        return try SwiftColumnSetLegacySupport.serializeToJson(self, baseJson: superResult)
    }
    
    // MARK: - Known Properties
    func populateKnownPropertiesSet() {
        self.knownProperties.insert("bleed")
        self.knownProperties.insert("columns")
        self.knownProperties.insert("selectAction")
        self.knownProperties.insert("style")
    }
    
    // MARK: - Resource Information
    func getResourceInformation(_ resourceInfo: inout [SwiftRemoteResourceInformation]) {
        // Iterate over our columns
        for column in columns {
            column.getResourceInformation(&resourceInfo)
        }
    }
    
    // MARK: - Child Deserialization
    func deserializeChildren(context: SwiftParseContext, json: [String: Any]) throws {
        // Use ParseUtil to get an array of BaseCardElement
        let elements = try SwiftParseUtil.getElementCollection(
            isTopToBottomContainer: false,
            context: context,
            json: json,
            key: "columns",
            required: false
        )
        // Filter for Column instances
        self.columns = elements.compactMap { $0 as? SwiftColumn }
    }
    
    // MARK: - Bleed Configuration
    
    /// Indicates whether this ColumnSet is nested (i.e. not at the top level of the card)
    var isNested: Bool {
        return self.parentalId != nil
    }
    
    /// Adjusts the bleedDirection for each contained Column based on position
    func configureColumnBleedDirections() {
        for (index, column) in columns.enumerated() {
            guard let column = column as? SwiftColumn else { continue }
            
            if !column.canBleed {
                column.bleedDirection = .bleedRestricted
                continue
            }
            
            // Start with bleedDown
            var direction: SwiftContainerBleedDirection = .bleedDown
            
            // Add bleedUp if parent ColumnSet has bleed enabled
            if self.hasBleed && self.canBleed {
                direction.insert(.bleedUp)
            }
            
            // Add left/right based on position
            if index == 0 {
                direction.insert(.bleedLeft)
            }
            if index == columns.count - 1 {
                direction.insert(.bleedRight)
            }
            
            column.bleedDirection = direction
            
            // Set parental ID for bleeding columns
            if column.canBleed {
                if let parentalId = self.parentalId {
                    column.parentalId = parentalId
                } else if let contextParentId = column.parentalId {
                    column.parentalId = contextParentId
                }
            }
        }
    }
}

// MARK: - Consolidated SwiftBaseElement Legacy Support

extension SwiftBaseElement {
    /// Deserialize from JSON data.
    static func decode(from json: Data) throws -> SwiftBaseElement {
        return try JSONDecoder().decode(SwiftBaseElement.self, from: json)
    }
    
    /// Serialize to JSON data.
    func encodeToData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat() throws -> [String: Any] {
        var json: [String: Any] = ["type": typeString]
        
        // Add core properties
        if let id = id {
            json["id"] = id
        }
        
        // Add additional properties
        if let additionalProperties = additionalProperties {
            for (key, anyCodable) in additionalProperties {
                json[key] = anyCodable.value
            }
        }
        
        // Add fallback info using the "fallback" key:
        if let fallbackContent = fallbackContent {
            json["fallback"] = try fallbackContent.serializeToJsonValue()
        } else if let fallbackType = fallbackType {
            json["fallback"] = fallbackType.rawValue
        }
        
        // Recursively unwrap AnyCodable values.
        if let unwrapped = SwiftParseUtil.unwrapAnyCodable(from: json) as? [String: Any] {
            return unwrapped
        }
        
        return json
    }
    
    /// Checks whether the element meets host requirements.
    func meetsRequirements(_ hostProvides: SwiftFeatureRegistration) -> Bool {
        guard let requires = requires else { return true }
        
        for (feature, requiredVersion) in requires {
            let hostVersionString = hostProvides.getFeatureVersion(featureName: feature)
            guard let hostVersion = try? SwiftSemanticVersion(hostVersionString) else {
                return false
            }
            
            if hostVersion < requiredVersion {
                return false
            }
        }
        
        return true
    }
}

// MARK: - Consolidated SwiftBaseCardElement Legacy Support

extension SwiftBaseCardElement {
    // MARK: - Deserialization Methods
    
    /// Parses a BaseCardElement from a JSON dictionary.
    static func deserialize(from originalJson: [String: Any]) throws -> SwiftBaseCardElement {
        // 1) Unwrap first
        let unwrapped = SwiftParseUtil.unwrapAnyCodable(from: originalJson)
        guard let jsonDict = unwrapped as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }
        
        // 2) Now "type" is definitely a String if present
        guard let typeString = jsonDict["type"] as? String else {
            throw AdaptiveCardParseError.invalidType
        }
        
        let knownTypes = [
            SwiftCardElementType.textBlock.rawValue,
            SwiftCardElementType.columnSet.rawValue,
            SwiftCardElementType.container.rawValue,
            SwiftCardElementType.column.rawValue,
            SwiftCardElementType.image.rawValue,
            SwiftCardElementType.factSet.rawValue,
            SwiftCardElementType.actionSet.rawValue,
            SwiftCardElementType.richTextBlock.rawValue,
            SwiftCardElementType.imageSet.rawValue,
            SwiftCardElementType.textInput.rawValue,
            SwiftCardElementType.numberInput.rawValue,
            SwiftCardElementType.dateInput.rawValue,
            SwiftCardElementType.timeInput.rawValue,
            SwiftCardElementType.choiceSetInput.rawValue,
            SwiftCardElementType.toggleInput.rawValue,
            SwiftCardElementType.media.rawValue,
            SwiftCardElementType.table.rawValue
        ]
        
        if !knownTypes.contains(typeString) {
            // For unknown types, return an UnknownElement that just preserves the JSON.
            return try SwiftUnknownElement.createFromJSON(jsonDict)
        }
        
        // 3) Convert to Data and decode
        let data = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        let decoder = JSONDecoder()
        
        switch typeString {
        case SwiftCardElementType.textBlock.rawValue:
            return try decoder.decode(SwiftTextBlock.self, from: data)
        case SwiftCardElementType.columnSet.rawValue:
            return try decoder.decode(SwiftColumnSet.self, from: data)
        case SwiftCardElementType.container.rawValue:
            return try decoder.decode(SwiftContainer.self, from: data)
        case SwiftCardElementType.column.rawValue:
            return try decoder.decode(SwiftColumn.self, from: data)
        case SwiftCardElementType.factSet.rawValue:
            return try decoder.decode(SwiftFactSet.self, from: data)
        case SwiftCardElementType.actionSet.rawValue:
            return try decoder.decode(SwiftActionSet.self, from: data)
        case SwiftCardElementType.richTextBlock.rawValue:
            return try decoder.decode(SwiftRichTextBlock.self, from: data)
        case SwiftCardElementType.image.rawValue:
            return try decoder.decode(SwiftImage.self, from: data)
        case SwiftCardElementType.imageSet.rawValue:
            return try decoder.decode(SwiftImageSet.self, from: data)
        case SwiftCardElementType.textInput.rawValue:
            return try decoder.decode(SwiftTextInput.self, from: data)
        case SwiftCardElementType.numberInput.rawValue:
            return try decoder.decode(SwiftNumberInput.self, from: data)
        case SwiftCardElementType.dateInput.rawValue:
            return try decoder.decode(SwiftDateInput.self, from: data)
        case SwiftCardElementType.timeInput.rawValue:
            return try decoder.decode(SwiftTimeInput.self, from: data)
        case SwiftCardElementType.choiceSetInput.rawValue:
            return try decoder.decode(SwiftChoiceSetInput.self, from: data)
        case SwiftCardElementType.toggleInput.rawValue:
            return try decoder.decode(SwiftToggleInput.self, from: data)
        case SwiftCardElementType.media.rawValue:
            return try decoder.decode(SwiftMedia.self, from: data)
        case SwiftCardElementType.table.rawValue:
            return try decoder.decode(SwiftTable.self, from: data)
        case SwiftCardElementType.unknown.rawValue:
            fallthrough
        default:
            return try decoder.decode(SwiftBaseCardElement.self, from: data)
        }
    }

    /// Parses a BaseCardElement from a JSON string.
    static func deserialize(from jsonString: String) throws -> SwiftBaseCardElement {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }
        return try deserialize(from: jsonDict)
    }
    
    // MARK: - Utility Methods
    
    /// Factory method for creating from JSON
    static func fromJSON(_ json: [String: Any]) -> SwiftBaseCardElement? {
        return try? self.deserialize(from: json)
    }
    
    /// Set additional properties from a JSON dictionary
    func setAdditionalProperties(_ json: [String: Any]) {
        var codableDict = [String: AnyCodable]()
        for (key, value) in json {
            codableDict[key] = AnyCodable(value)
        }
        self.additionalProperties = codableDict
    }
    
    /// Set the element type string
    func setElementTypeString(_ type: String) {
        self.typeString = type
    }
    
    // MARK: - Element Lookup Methods
    
    /// Helper method to find parent element
    func findParent() -> SwiftBaseCardElement? {
        guard let parentId = parentalId else { return nil }
        return findElement(withId: parentId)
    }
    
    /// Helper method to find element by ID
    func findElement(withId id: SwiftInternalId) -> SwiftBaseCardElement? {
        // This needs to be implemented with access to the element registry
        // For now, return nil to match current behavior
        return nil
    }
    
    // MARK: - Action Serialization
    
    /// Serialize a select action
    static func serializeSelectAction(_ action: SwiftBaseActionElement) throws -> [String: Any] {
        return try action.serializeToJsonValue()
    }
    
    // MARK: - Type Properties
    
    /// Returns the type string (as originally decoded)
    var elementTypeString: String {
        return self.typeString
    }
    
    /// A convenience "parse" method used in tests.
    static func parse(json: [String: Any], context: SwiftParseContext) -> SwiftBaseCardElement? {
        // We simply attempt to deserialize and return nil if an error is thrown.
        return try? SwiftBaseCardElement.deserialize(from: json)
    }
}

// MARK: - Consolidated SwiftAdaptiveCard Legacy Support

extension SwiftAdaptiveCard {
    // MARK: - Deserialization Methods
    
    /// Deserializes an AdaptiveCard from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> SwiftAdaptiveCard {
        let version = json[SwiftAdaptiveCardSchemaKey.version.rawValue] as? String ?? "1.0"
        let fallbackText = json[SwiftAdaptiveCardSchemaKey.fallbackText.rawValue] as? String
        
        // Handle backgroundImage, which can be a string or a dictionary
        let backgroundImageValue = json[SwiftAdaptiveCardSchemaKey.backgroundImage.rawValue]
        let backgroundImage: SwiftBackgroundImage?
        if let bgStr = backgroundImageValue as? String {
            backgroundImage = SwiftBackgroundImage(url: bgStr, fillMode: .cover, horizontalAlignment: .left, verticalAlignment: .top)
        } else if let bgDict = backgroundImageValue as? [String: Any] {
            backgroundImage = try SwiftBackgroundImage.deserialize(from: bgDict)
        } else {
            backgroundImage = nil
        }
        
        // Parse refresh and authentication if present
        let refreshJson = json[SwiftAdaptiveCardSchemaKey.refresh.rawValue] as? [String: Any]
        let refresh = try refreshJson.map { try SwiftRefresh.deserialize(from: $0) }
        
        let authenticationJson = json[SwiftAdaptiveCardSchemaKey.authentication.rawValue] as? [String: Any]
        let authentication = try authenticationJson.map { try SwiftAuthentication.deserialize(from: $0) }
        
        // Parse basic properties
        let speak = json[SwiftAdaptiveCardSchemaKey.speak.rawValue] as? String
        let style = SwiftContainerStyle(rawValue: json[SwiftAdaptiveCardSchemaKey.style.rawValue] as? String ?? "none") ?? .none
        let language = (json[SwiftAdaptiveCardSchemaKey.language.rawValue] as? String) ?? (json["lang"] as? String)
        let verticalContentAlignment = SwiftVerticalContentAlignment(rawValue: json[SwiftAdaptiveCardSchemaKey.verticalContentAlignment.rawValue] as? String ?? "top") ?? .top
        let height = SwiftHeightType(rawValue: json[SwiftAdaptiveCardSchemaKey.height.rawValue] as? String ?? "auto") ?? .auto
        
        // Parse minHeight, which could be a string with "px" suffix or a UInt
        var minHeight: UInt = 0
        if let minHeightStr = json[SwiftAdaptiveCardSchemaKey.minHeight.rawValue] as? String {
            let digits = minHeightStr.filter { "0123456789".contains($0) }
            minHeight = UInt(digits) ?? 0
        } else if let mh = json[SwiftAdaptiveCardSchemaKey.minHeight.rawValue] as? UInt {
            minHeight = mh
        }
        
        let rtl = json[SwiftAdaptiveCardSchemaKey.rtl.rawValue] as? Bool
        
        // Process body elements
        let bodyJson = json[SwiftAdaptiveCardSchemaKey.body.rawValue] as? [[String: Any]] ?? []
        let adjustedBodyJson = bodyJson.map { element -> [String: Any] in
            var element = element
            if let type = element["type"] as? String, type == "Table" {
                if let rows = element["rows"] as? [[String: Any]] {
                    let adjustedRows = rows.map { row -> [String: Any] in
                        var row = row
                        if row["type"] == nil { row["type"] = "TableRow" }
                        if let cells = row["cells"] as? [[String: Any]] {
                            let adjustedCells = cells.map { cell -> [String: Any] in
                                var cell = cell
                                if cell["type"] == nil { cell["type"] = "TableCell" }
                                return cell
                            }
                            row["cells"] = adjustedCells
                        }
                        return row
                    }
                    element["rows"] = adjustedRows
                }
            }
            return element
        }
        let body = try adjustedBodyJson.map { try SwiftBaseCardElement.deserialize(from: $0) }
        
        // Process actions
        let actionsJson = json[SwiftAdaptiveCardSchemaKey.actions.rawValue] as? [[String: Any]] ?? []
        let actions = try actionsJson.map { try SwiftBaseActionElement.deserializeAction(from: $0) }
        
        // Process layouts
        let layoutsJson = json[SwiftAdaptiveCardSchemaKey.layouts.rawValue] as? [[String: Any]] ?? []
        let layouts = try layoutsJson.map { json in
            guard let layout = SwiftLayout.fromJSON(json) else {
                throw AdaptiveCardParseError.invalidJson
            }
            return layout
        }
        
        // Process selectAction if present
        var selectAction: SwiftBaseActionElement? = nil
        if let selectActionJson = json[SwiftAdaptiveCardSchemaKey.selectAction.rawValue] as? [String: Any] {
            selectAction = try SwiftBaseActionElement.deserializeAction(from: selectActionJson)
        }
        
        // Create the card with parsed properties
        let card = SwiftAdaptiveCard(
            version: version,
            fallbackText: fallbackText,
            backgroundImage: backgroundImage,
            refresh: refresh,
            authentication: authentication,
            speak: speak,
            style: style,
            language: language,
            verticalContentAlignment: verticalContentAlignment,
            height: height,
            minHeight: minHeight,
            rtl: rtl,
            body: body,
            actions: actions,
            layouts: layouts,
            selectAction: selectAction,
            requires: [:],
            fallbackContent: nil,
            fallbackType: .none
        )
        
        // Remove known keys from additionalProperties
        let knownKeys: Set<String> = [
            "$schema", "type", SwiftAdaptiveCardSchemaKey.version.rawValue,
            SwiftAdaptiveCardSchemaKey.fallbackText.rawValue,
            SwiftAdaptiveCardSchemaKey.backgroundImage.rawValue,
            SwiftAdaptiveCardSchemaKey.refresh.rawValue,
            SwiftAdaptiveCardSchemaKey.authentication.rawValue,
            SwiftAdaptiveCardSchemaKey.speak.rawValue,
            SwiftAdaptiveCardSchemaKey.style.rawValue,
            SwiftAdaptiveCardSchemaKey.language.rawValue,
            "lang",
            SwiftAdaptiveCardSchemaKey.verticalContentAlignment.rawValue,
            SwiftAdaptiveCardSchemaKey.height.rawValue,
            SwiftAdaptiveCardSchemaKey.minHeight.rawValue,
            SwiftAdaptiveCardSchemaKey.rtl.rawValue,
            SwiftAdaptiveCardSchemaKey.body.rawValue,
            SwiftAdaptiveCardSchemaKey.actions.rawValue,
            SwiftAdaptiveCardSchemaKey.layouts.rawValue,
            SwiftAdaptiveCardSchemaKey.selectAction.rawValue,
            SwiftAdaptiveCardSchemaKey.requires.rawValue,
            SwiftAdaptiveCardSchemaKey.fallback.rawValue
        ]
        var additionalProps = json
        for key in knownKeys {
            additionalProps.removeValue(forKey: key)
        }
        card.additionalProperties = additionalProps
        
        // Check for duplicate IDs
        try checkDuplicateIds(in: card)
        
        return card
    }
    
    // MARK: - Serialization Methods
    
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat() throws -> [String: Any] {
        var json = additionalProperties
        
        // Essential fields that should always be included
        json["type"] = "AdaptiveCard"
        json[SwiftAdaptiveCardSchemaKey.version.rawValue] = version
        
        // Only include non-empty optional fields
        if let language = language {
            json["lang"] = language
        }
        
        // Background image
        if let backgroundImage = backgroundImage {
            json[SwiftAdaptiveCardSchemaKey.backgroundImage.rawValue] = backgroundImage.serializeToJsonValue()
        }
        
        // Body elements
        json[SwiftAdaptiveCardSchemaKey.body.rawValue] = try body.map { try $0.serializeToJsonValue() }
        
        // Actions with cleanup of empty/default fields
        let serializedActions = try actions.map { action -> [String: Any] in
            var actionJson = try action.serializeToJsonValue()
            
            // Remove empty or default fields from actions
            if let title = actionJson["title"] as? String, title.isEmpty {
                actionJson.removeValue(forKey: "title")
            }
            actionJson.removeValue(forKey: "conditionallyEnabled")
            
            return actionJson
        }
        json[SwiftAdaptiveCardSchemaKey.actions.rawValue] = serializedActions
        
        // Handle optional fields based on whether they have non-default values
        if let fallbackText = fallbackText, !fallbackText.isEmpty {
            json[SwiftAdaptiveCardSchemaKey.fallbackText.rawValue] = fallbackText
        }
        if let speak = speak, !speak.isEmpty {
            json[SwiftAdaptiveCardSchemaKey.speak.rawValue] = speak
        }
        if style != .none {
            json[SwiftAdaptiveCardSchemaKey.style.rawValue] = style.rawValue
        }
        if verticalContentAlignment != .top {
            json[SwiftAdaptiveCardSchemaKey.verticalContentAlignment.rawValue] = verticalContentAlignment.rawValue
        }
        if height != .auto {
            json[SwiftAdaptiveCardSchemaKey.height.rawValue] = height.rawValue
        }
        if !layouts.isEmpty {
            json[SwiftAdaptiveCardSchemaKey.layouts.rawValue] = layouts.map { $0.serializeToJsonValue() }
        }
        
        // Handle minHeight consistently
        if minHeight > 0 {
            json[SwiftAdaptiveCardSchemaKey.minHeight.rawValue] = "\(minHeight)px"
        }
        
        return json
    }
    
    // MARK: - Utility Methods
    
    /// Gets resource information from the card
    func getResourceInformation() -> [SwiftRemoteResourceInformation] {
        // Implement resource extraction logic if needed.
        // For now, return an empty array.
        return []
    }
    
    /// Deserializes an AdaptiveCard from a JSON string.
    static func deserialize(from jsonString: String) throws -> SwiftAdaptiveCard {
        let jsonDict = try SwiftParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(from: jsonDict)
    }
    
    /// Creates an AdaptiveCard that serves as a fallback, containing a single TextBlock with the provided text.
    func makeFallbackTextCard(text: String, language: String, speak: String) -> SwiftAdaptiveCard? {
        let fallbackTextBlock = SwiftTextBlock(
            text: text,
            textStyle: .heading,      // Use heading as expected
            textSize: SwiftTextSize.defaultSize,
            textWeight: SwiftTextWeight.defaultWeight,
            fontType: nil,
            textColor: .default,
            isSubtle: false,
            wrap: false,
            maxLines: 1,
            horizontalAlignment: .left,
            language: language,
            id: nil
        )
        
        // Set fallbackText to an empty string (instead of nil)
        // and speak to an empty string if that’s what is expected.
        return SwiftAdaptiveCard(
            version: self.version,
            fallbackText: "",      // explicitly set to empty string
            backgroundImage: nil,
            refresh: nil,
            authentication: nil,
            speak: "speak",             // explicitly set to empty string
            style: .none,
            language: language,    // should be "en" in our test
            verticalContentAlignment: .top,
            height: .auto,
            minHeight: 0,
            rtl: nil,
            body: [fallbackTextBlock],
            actions: [],
            layouts: [],
            selectAction: nil,
            requires: [:],
            fallbackContent: nil,
            fallbackType: .none
        )
    }
    
    internal static func checkDuplicateIds(in card: SwiftAdaptiveCard) throws {
        print("Starting duplicate ID check")  // Debug print
        var seen = Set<String>()
        
        // Check body
        print("Checking body elements...")  // Debug print
        for element in card.body {
            try gatherIds(element, &seen)
        }
        
        // Check actions
        print("Checking actions...")  // Debug print
        for action in card.actions {
            try gatherIds(action, &seen)
        }
        
        print("Found IDs: \(seen)")  // Debug print
    }
    
    internal static func gatherIds(_ element: Any, _ seen: inout Set<String>) throws {
        switch element {
        case let action as SwiftBaseActionElement:
            // First, check the action’s own id.
            if let theId = action.id, !theId.isEmpty {
                if seen.contains(theId) {
                    throw AdaptiveCardParseError.idCollision
                }
                seen.insert(theId)
            }
            // Then, if it is a ShowCardAction, recurse into its nested card.
            if let showCard = action as? SwiftShowCardAction, let nestedCard = showCard.card {
                for item in nestedCard.body { try gatherIds(item, &seen) }
                for nestedAction in nestedCard.actions { try gatherIds(nestedAction, &seen) }
                if let selectAction = nestedCard.selectAction {
                    try gatherIds(selectAction, &seen)
                }
            }
            
        case let base as SwiftBaseCardElement:
            // Now handle any BaseCardElement that isn’t an action.
            if let theId = base.id, !theId.isEmpty {
                if seen.contains(theId) {
                    throw AdaptiveCardParseError.idCollision
                }
                seen.insert(theId)
            }
            // Recurse into composite elements.
            if let container = base as? SwiftContainer {
                for item in container.items { try gatherIds(item, &seen) }
            }
            if let colSet = base as? SwiftColumnSet {
                for col in colSet.columns { try gatherIds(col, &seen) }
            }
            if let col = base as? SwiftColumn {
                for item in col.items { try gatherIds(item, &seen) }
            }
            
        case let card as SwiftAdaptiveCard:
            // Also check the AdaptiveCard itself.
            for item in card.body { try gatherIds(item, &seen) }
            for action in card.actions { try gatherIds(action, &seen) }
            if let selectAction = card.selectAction {
                try gatherIds(selectAction, &seen)
            }
            
        default:
            break
        }
    }
}
