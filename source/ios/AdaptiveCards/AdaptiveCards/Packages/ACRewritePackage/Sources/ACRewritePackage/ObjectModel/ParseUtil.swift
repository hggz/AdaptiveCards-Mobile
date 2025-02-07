import Foundation

/// Utility class for parsing JSON in AdaptiveCards.
struct ParseUtil {
    
    /// Converts a JSON dictionary to a string.
    static func jsonToString(_ json: [String: Any]) throws -> String {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }
    
    /// Throws an error if the provided JSON object is not valid.
    static func throwIfNotJsonObject(_ json: Any) throws {
        guard json is [String: Any] else {
            throw AdaptiveCardParseError.invalidJson("Expected JSON object.")
        }
    }
    
    /// Extracts the `type` property from JSON.
    static func getTypeAsString(from json: [String: Any]) throws -> String {
        guard let type = json["type"] as? String else {
            throw AdaptiveCardParseError.requiredPropertyMissing("The JSON element is missing the 'type' property.")
        }
        return type
    }
    
    /// Tries to extract the `type` property, returns empty string if missing.
    static func tryGetTypeAsString(from json: [String: Any]) -> String {
        return (try? getTypeAsString(from: json)) ?? ""
    }
    
    /// Extracts a required string property from JSON.
    static func getString(from json: [String: Any], key: String, isRequired: Bool = false) throws -> String {
        guard let value = json[key] as? String else {
            if isRequired {
                throw AdaptiveCardParseError.requiredPropertyMissing("Property \(key) is required but was missing.")
            }
            return ""
        }
        return value
    }
    
    /// Extracts an optional string property from JSON.
    static func getOptionalString(from json: [String: Any], key: String) -> String? {
        return json[key] as? String
    }
    
    /// Extracts a required boolean property from JSON.
    static func getBool(from json: [String: Any], key: String, defaultValue: Bool, isRequired: Bool = false) throws -> Bool {
        guard let value = json[key] as? Bool else {
            if isRequired {
                throw AdaptiveCardParseError.requiredPropertyMissing("Property \(key) is required but was missing.")
            }
            return defaultValue
        }
        return value
    }
    
    /// Extracts an optional boolean property from JSON.
    static func getOptionalBool(from json: [String: Any], key: String) -> Bool? {
        return json[key] as? Bool
    }
    
    /// Extracts a required integer property from JSON.
    static func getInt(from json: [String: Any], key: String, defaultValue: Int, isRequired: Bool = false) throws -> Int {
        guard let value = json[key] as? Int else {
            if isRequired {
                throw AdaptiveCardParseError.requiredPropertyMissing("Property \(key) is required but was missing.")
            }
            return defaultValue
        }
        return value
    }
    
    /// Extracts an optional integer property from JSON.
    static func getOptionalInt(from json: [String: Any], key: String) -> Int? {
        return json[key] as? Int
    }
    
    /// Extracts an array from JSON.
    static func getArray(from json: [String: Any], key: String, isRequired: Bool = false) throws -> [[String: Any]] {
        guard let value = json[key] as? [[String: Any]] else {
            if isRequired {
                throw AdaptiveCardParseError.requiredPropertyMissing("Property \(key) is required but was missing or not an array.")
            }
            return []
        }
        return value
    }
    
    /// Extracts an action collection from JSON.
    static func getActionCollection(from json: [String: Any], key: String, isRequired: Bool = false) throws -> [BaseActionElement] {
        let array = try getArray(from: json, key: key, isRequired: isRequired)
        return array.compactMap { try? BaseActionElement.deserialize(from: $0) }
    }
    
    /// Extracts and converts a lowercase string.
    static func toLowercase(_ value: String) -> String {
        return value.lowercased()
    }
}
