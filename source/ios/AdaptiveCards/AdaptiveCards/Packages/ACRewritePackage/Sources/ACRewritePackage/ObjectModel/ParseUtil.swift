import Foundation

struct ParseUtil {
    
    static func jsonToString(_ json: [String: Any]) throws -> String {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }
    
    static func throwIfNotJsonObject(_ json: Any) throws {
        guard json is [String: Any] else {
            throw ParsingError.invalidType(expected: "JSON object", found: "\(type(of: json))")
        }
    }
    
    static func getTypeAsString(from json: [String: Any]) throws -> String {
        guard let type = json["type"] as? String else {
            throw AdaptiveCardParseException(statusCode: .requiredPropertyMissing, message: "type")
        }
        return type
    }
    
    static func tryGetTypeAsString(from json: [String: Any]) -> String {
        return (try? getTypeAsString(from: json)) ?? ""
    }
    
    static func getString(from json: [String: Any], key: String, isRequired: Bool = false) throws -> String {
        guard let value = json[key] as? String else {
            if isRequired {
                throw AdaptiveCardParseException(statusCode: .requiredPropertyMissing, message: key)
            }
            return ""
        }
        return value
    }
    
    static func getOptionalString(from json: [String: Any], key: String) -> String? {
        return json[key] as? String
    }
    
    static func getBool(from json: [String: Any], key: String, defaultValue: Bool, isRequired: Bool = false) throws -> Bool {
        guard let value = json[key] as? Bool else {
            if isRequired {
                throw AdaptiveCardParseException(statusCode: .requiredPropertyMissing, message: key)
            }
            return defaultValue
        }
        return value
    }
    
    static func getOptionalBool(from json: [String: Any], key: String) -> Bool? {
        return json[key] as? Bool
    }
    
    static func getInt(from json: [String: Any], key: String, defaultValue: Int, isRequired: Bool = false) throws -> Int {
        guard let value = json[key] as? Int else {
            if isRequired {
                throw AdaptiveCardParseException(statusCode: .requiredPropertyMissing, message: key)
            }
            return defaultValue
        }
        return value
    }
    
    static func getOptionalInt(from json: [String: Any], key: String) -> Int? {
        return json[key] as? Int
    }
    
    /// Returns an array of JSON dictionaries for the given key.
    static func getArray(from json: [String: Any], key: String, isRequired: Bool = false) throws -> [[String: Any]] {
        if let array = json[key] as? [[String: Any]] {
            return array
        }
        if isRequired {
            throw AdaptiveCardParseException(statusCode: .requiredPropertyMissing, message: key)
        }
        return []
    }
}
