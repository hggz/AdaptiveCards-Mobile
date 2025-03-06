import Foundation

// MARK: - Consolidated SwiftTimeInput Legacy Support

/// Unified legacy support for SwiftTimeInput parsing and serialization
enum SwiftTimeInputLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftTimeInput
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftTimeInput {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftTimeInput.self, from: data)
    }
    
    /// Deserializes string into a SwiftTimeInput
    static func deserialize(from jsonString: String) throws -> SwiftTimeInput {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftTimeInput.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftTimeInput to JSON dictionary with proper formatting
    static func serializeToJson(_ timeInput: SwiftTimeInput, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set type property
        json["type"] = "Input.Time"
        
        // Add properties if present
        if let max = timeInput.max {
            json["max"] = max
        }
        
        if let min = timeInput.min {
            json["min"] = min
        }
        
        if let placeholder = timeInput.placeholder {
            json["placeholder"] = placeholder
        }
        
        if let value = timeInput.value {
            json["value"] = value
        }
        
        return json
    }
}

// MARK: - Parser Implementation

/// Parses TimeInput elements in an Adaptive Card
struct SwiftTimeInputParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.timeInput)
        return try SwiftTimeInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftTimeInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftTimeInputLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftTimeInput Extension

internal extension SwiftTimeInput {
    // MARK: - Static Factory Methods
    
    /// Creates a SwiftTimeInput from a JSON dictionary
    static func createFromJSON(_ json: [String: Any]) throws -> SwiftTimeInput {
        return try SwiftTimeInputLegacySupport.deserialize(from: json)
    }
    
    /// Creates a SwiftTimeInput from a JSON string
    static func createFromJSONString(_ jsonString: String) throws -> SwiftTimeInput {
        return try SwiftTimeInputLegacySupport.deserialize(from: jsonString)
    }
}

// MARK: - Consolidated SwiftChoiceSetInput Legacy Support

/// Unified legacy support for SwiftChoiceSetInput parsing and serialization
enum SwiftChoiceSetInputLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftChoiceSetInput
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftChoiceSetInput {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftChoiceSetInput.self, from: data)
    }
    
    /// Deserializes string into a SwiftChoiceSetInput
    static func deserialize(from jsonString: String) throws -> SwiftChoiceSetInput {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftChoiceSetInput.self, from: data)
    }
    
    // MARK: - Serialization Functions
    static func serializeToJsonString(_ choiceSetInput: SwiftChoiceSetInput) -> String? {
        guard let jsonData = try? JSONEncoder().encode(choiceSetInput) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}

// MARK: - Parser Implementation

/// Parses ChoiceSetInput elements in an Adaptive Card
struct SwiftChoiceSetInputParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.choiceSetInput)
        return try SwiftChoiceSetInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftChoiceSetInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftChoiceSetInputLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftChoiceSetInput Extension

internal extension SwiftChoiceSetInput {
    // MARK: - Known Properties
    
    // MARK: - Serialization Helpers
    
    /// Serializes the instance to a JSON string.
    func serializeToJson() -> String? {
        return SwiftChoiceSetInputLegacySupport.serializeToJsonString(self)
    }
}

// MARK: - Consolidated SwiftFact Legacy Support

/// Unified legacy support for SwiftFact parsing and serialization
enum SwiftFactLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftFact
    static func deserialize(from json: [String: Any]) -> SwiftFact? {
        guard let title = json["title"] as? String,
              let value = json["value"] as? String else {
            return nil
        }
        
        let language = json["language"] as? String
        
        // Convert to JSON data and use Codable
        let jsonDict: [String: Any] = [
            "title": title,
            "value": value,
            "language": language as Any
        ].compactMapValues { $0 is NSNull ? nil : $0 }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
            return try JSONDecoder().decode(SwiftFact.self, from: data)
        } catch {
            return nil
        }
    }
    
    /// Deserializes string into a SwiftFact
    static func deserialize(from jsonString: String, context: SwiftParseContext? = nil) -> SwiftFact? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        do {
            return try JSONDecoder().decode(SwiftFact.self, from: data)
        } catch {
            return nil
        }
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftFact to JSON dictionary with proper formatting
    static func serializeToJson(_ fact: SwiftFact) -> [String: Any] {
        var dict: [String: Any] = [
            "title": fact.title,
            "value": fact.value
        ]
        
        if let language = fact.language {
            dict["language"] = language
        }
        
        return dict
    }
    
    /// Converts to JSON dictionary with type
    static func serializeWithType(_ fact: SwiftFact) -> [String: Any] {
        var dict = serializeToJson(fact)
        dict["type"] = "Fact"
        return dict
    }
    
    /// Converts to JSON string
    static func serialize(_ fact: SwiftFact) -> String {
        let dict = serializeToJson(fact)
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys])
        return (String(data: data ?? Data(), encoding: .utf8) ?? "{}") + "\n"
    }
}

// MARK: - SwiftFact Extension

extension SwiftFact {
    // MARK: - Initializer
    
    init(title: String = "", value: String = "", language: String? = nil) {
        self.title = title
        self.value = value
        self.language = language
    }
    
    // MARK: - Legacy Serialization Methods
    
    /// Serializes to a JSON string
    func serialize() -> String {
        return SwiftFactLegacySupport.serialize(self)
    }
    
    /// Serializes with type information
    func serializeWithType() -> [String: Any] {
        return SwiftFactLegacySupport.serializeWithType(self)
    }
    
    // MARK: - Static Deserialization Methods
    
    /// Deserializes from a JSON string
    static func deserialize(fromString jsonString: String, context: SwiftParseContext) -> SwiftFact? {
        return SwiftFactLegacySupport.deserialize(from: jsonString)
    }
    
    /// Deserializes from a JSON dictionary
    static func deserialize(from json: [String: Any]) -> SwiftFact? {
        return SwiftFactLegacySupport.deserialize(from: json)
    }
}

// MARK: - Consolidated SwiftFactSet Legacy Support

/// Unified legacy support for SwiftFactSet parsing and serialization
enum SwiftFactSetLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftFactSet
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftFactSet {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftFactSet.self, from: data)
    }
    
    /// Deserializes string into a SwiftFactSet
    static func deserialize(from jsonString: String) throws -> SwiftFactSet {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftFactSet.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftFactSet to JSON dictionary with proper formatting
    static func serializeToJson(_ factSet: SwiftFactSet, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set required properties
        json["type"] = "FactSet"
        
        // Add facts array if not empty
        if !factSet.facts.isEmpty {
            json["facts"] = factSet.facts.map { $0.serializeToJsonValue() }
        }
        
        return json
    }
}

// MARK: - Parser Implementation

/// Parses FactSet elements in an Adaptive Card
struct SwiftFactSetParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.factSet)
        return try SwiftFactSetLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftFactSetLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftFactSetLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftFactSet Extension

internal extension SwiftFactSet {
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        return try SwiftFactSetLegacySupport.serializeToJson(self, baseJson: superResult)
    }
    
    // MARK: - Known Properties
    func populateKnownPropertiesSet() {
        self.knownProperties.insert("facts")
    }
}

// MARK: - Consolidated SwiftGridArea Legacy Support

/// Unified legacy support for SwiftGridArea parsing and serialization
enum SwiftGridAreaLegacySupport {
    // MARK: - Legacy Array Support
    
    /// Converts an array of dictionaries to an array of SwiftGridArea objects
    static func deserializeArray(from arrayOfDicts: [[String: Any]]) -> [SwiftGridArea] {
        return arrayOfDicts.map { dict in
            do {
                return try deserialize(from: dict)
            } catch {
                // Return default grid area if deserialization fails
                return SwiftGridArea(name: "", row: 1, column: 1, rowSpan: 1, columnSpan: 1)
            }
        }
    }
    
    /// Serializes an array of SwiftGridArea objects to an array of dictionaries
    static func serializeArray(_ gridAreas: [SwiftGridArea]) -> [[String: Any]] {
        return gridAreas.map { serializeToJson($0) }
    }
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftGridArea
    static func deserialize(from value: [String: Any]) throws -> SwiftGridArea {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftGridArea.self, from: data)
    }
    
    /// Deserializes string into a SwiftGridArea
    static func deserialize(from jsonString: String) throws -> SwiftGridArea {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftGridArea.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftGridArea to JSON dictionary
    static func serializeToJson(_ gridArea: SwiftGridArea) -> [String: Any] {
        return [
            "name": gridArea.name,
            "row": gridArea.row,
            "column": gridArea.column,
            "rowSpan": gridArea.rowSpan,
            "columnSpan": gridArea.columnSpan
        ]
    }
    
    /// Converts a SwiftGridArea to JSON string
    static func serializeToString(_ gridArea: SwiftGridArea) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: serializeToJson(gridArea), options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            return "{}"
        }
    }
}

// MARK: - SwiftGridArea Extension

extension SwiftGridArea {
    // Static factory methods
    static func fromJSON(_ json: [String: Any]) -> SwiftGridArea? {
        guard !json.isEmpty else { return nil }
        return try? SwiftGridAreaLegacySupport.deserialize(from: json)
    }
    
    static func fromJSONString(_ jsonString: String) -> SwiftGridArea? {
        return try? SwiftGridAreaLegacySupport.deserialize(from: jsonString)
    }
    
    // Legacy compatibility methods - direct replacements for original code
    static func deserialize(from json: [String: Any]) -> SwiftGridArea {
        do {
            return try SwiftGridAreaLegacySupport.deserialize(from: json)
        } catch {
            // Replicate original fallback behavior
            return SwiftGridArea(name: "", row: 1, column: 1, rowSpan: 1, columnSpan: 1)
        }
    }
}
