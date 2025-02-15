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
    
    /// Extracts an enum value from JSON.
    static func getEnumValue<T: RawRepresentable>(
        from json: [String: Any],
        key: String,
        defaultValue: T,
        converter: (String) -> T?
    ) throws -> T where T.RawValue == String {
        if let value = json[key] as? String, let enumValue = converter(value) {
            return enumValue
        }
        return defaultValue
    }
    
    /// Parses a JSON string into a dictionary.
    static func getJsonDictionary(from jsonString: String) throws -> [String: Any] {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        guard let dict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "JSON is not a dictionary")
        }
        return dict
    }
    
    /// Extend ParseUtil with the missing helper methods.
    static func getOptionalEnumValue<T: RawRepresentable>(
        from json: [String: Any],
        key: String,
        converter: (String) -> T?
    ) throws -> T? where T.RawValue == String {
        if let value = json[key] as? String {
            return converter(value)
        }
        return nil
    }
    
    static func getUInt(from json: [String: Any],
                        key: String,
                        defaultValue: UInt,
                        isRequired: Bool = false) throws -> UInt {
        if let number = json[key] as? NSNumber {
            return number.uintValue
        }
        if isRequired {
            throw AdaptiveCardParseException(statusCode: .requiredPropertyMissing, message: "\(key) is missing")
        }
        return defaultValue
    }
    
    /// Returns an array of BaseActionElement parsed from the JSON under the specified key.
    static func getActionCollection(from json: [String: Any], key: String) throws -> [BaseActionElement] {
        let array = try getArray(from: json, key: key, isRequired: false)
        // Assuming BaseActionElement has a static deserialize(from:) method.
        return try array.map { try BaseActionElement.deserialize(from: $0) }
    }
    
    static func getAction(from json: [String: Any], key: String, context: inout ParseContext) throws -> BaseActionElement? {
        guard let actionJson = json[key] as? [String: Any] else {
            return nil
        }
        // Assuming BaseActionElement has a static method `deserialize(from:context:)`
//        return try BaseActionElement.deserialize(from: actionJson, context: &context) // TODO
        return try BaseActionElement.deserialize(from: actionJson)
    }
    
    /// Returns an array of elements of a single type from the JSON dictionary,
    /// using the provided converter to deserialize each element.
    static func getElementCollectionOfSingleType<T>(
        from json: [String: Any],
        key: String,
        context: inout ParseContext,
        defaultValue: [T] = [],
        converter: (inout ParseContext, [String: Any]) throws -> T
    ) throws -> [T] {
        guard let array = json[key] as? [[String: Any]] else {
            return defaultValue
        }
        var results: [T] = []
        for item in array {
            let parsedItem = try converter(&context, item)
            results.append(parsedItem)
        }
        return results
    }
    
    // Added getElementCollection with the expected signature.
    static func getElementCollection(isTopToBottomContainer: Bool,
                                     context: inout ParseContext,
                                     json: [String: Any],
                                     key: String,
                                     isRequired: Bool) throws -> [BaseCardElement] {
        let array = try getArray(from: json, key: key, isRequired: isRequired)
        var elements: [BaseCardElement] = []
        for dict in array {
            let element = try BaseCardElement.deserialize(from: dict)
            elements.append(element)
        }
        return elements
    }
    
    // Added simple getValueAsString
    static func getValueAsString(from json: [String: Any], key: String) -> String {
        return json[key] as? String ?? ""
    }
    
    static func expectTypeString(_ json: [String: Any], expected: CardElementType) throws {
        let actual = try getTypeAsString(from: json)
        if actual != expected.rawValue {
            throw AdaptiveCardParseException(statusCode: .requiredPropertyMissing, message: "Expected type \(expected.rawValue) but found \(actual)")
        }
    }
}
