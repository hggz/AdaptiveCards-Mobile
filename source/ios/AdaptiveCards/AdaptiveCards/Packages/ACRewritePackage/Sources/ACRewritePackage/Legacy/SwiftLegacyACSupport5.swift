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
