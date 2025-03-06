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

// MARK: - Consolidated SwiftMedia Legacy Support

/// Unified legacy support for SwiftMedia parsing and serialization
enum SwiftMediaLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftMedia
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftMedia {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftMedia.self, from: data)
    }
    
    /// Deserializes string into a SwiftMedia
    static func deserialize(from jsonString: String) throws -> SwiftMedia {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftMedia.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftMedia to JSON dictionary with proper formatting
    static func serializeToJson(_ media: SwiftMedia, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set required properties
        json["type"] = "Media"
        
        // Add optional properties
        if let poster = media.poster {
            json["poster"] = poster
        }
        
        if let altText = media.altText {
            json["altText"] = altText
        }
        
        // Add sources array
        json["sources"] = media.sources.map { $0.serializeToJson() }
        
        // Add caption sources if not empty
        if !media.captionSources.isEmpty {
            json["captionSources"] = media.captionSources.map { $0.serializeToJson() }
        }
        
        return json
    }
    
    /// Converts to JSON string
    static func serializeToJsonString(_ media: SwiftMedia) -> String {
        do {
            // Use the full serialization path for consistency
            let baseJson = try media.serializeToJsonValue()
            let jsonData = try JSONSerialization.data(withJSONObject: baseJson, options: .prettyPrinted)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw EncodingError.invalidValue(baseJson, EncodingError.Context(
                    codingPath: [], debugDescription: "Failed to convert JSON to string"))
            }
            return jsonString
        } catch {
            return "{}"
        }
    }
    
    // MARK: - Resource Information
    
    /// Retrieves resource information (from poster and media sources)
    static func getResourceInformation(_ media: SwiftMedia) -> [SwiftRemoteResourceInformation] {
        var resourceInfo: [SwiftRemoteResourceInformation] = []
        
        // Add poster if present
        if let poster = media.poster {
            resourceInfo.append(SwiftRemoteResourceInformation(url: poster, mimeType: "image"))
        }
        
        // Add sources
        for source in media.sources {
            resourceInfo.append(contentsOf: source.getResourceInformation())
        }
        
        return resourceInfo
    }
}

// MARK: - Parser Implementation

/// Parses Media elements in an Adaptive Card
struct SwiftMediaParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.media)
        return try SwiftMediaLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftMediaLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftMediaLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftMedia Extension

internal extension SwiftMedia {
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        return try SwiftMediaLegacySupport.serializeToJson(self, baseJson: superResult)
    }
    
    // MARK: - Known Properties
    func populateKnownPropertiesSet() {
        self.knownProperties.insert("poster")
        self.knownProperties.insert("altText")
        self.knownProperties.insert("sources")
        self.knownProperties.insert("captionSources")
    }
    
    // MARK: - Resource Information
    func mediaResourceInformation() -> [SwiftRemoteResourceInformation] {
        return SwiftMediaLegacySupport.getResourceInformation(self)
    }
    
    // Legacy compatibility methods
    func serializeToJson() -> [String: Any] {
        do {
            return try self.serializeToJsonValue()
        } catch {
            return [:]
        }
    }
    
    func toJSONString() -> String {
        return SwiftMediaLegacySupport.serializeToJsonString(self)
    }
}

// Legacy static methods for backward compatibility
extension SwiftMedia {
    static func createFromJSON(_ json: [String: Any]) throws -> SwiftMedia {
        return try SwiftMediaLegacySupport.deserialize(from: json)
    }
    
    static func createFromJSONString(_ jsonString: String) throws -> SwiftMedia {
        return try SwiftMediaLegacySupport.deserialize(from: jsonString)
    }
}

// MARK: - Consolidated SwiftMediaSource Legacy Support

/// Unified legacy support for SwiftMediaSource parsing and serialization
enum SwiftMediaSourceLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftMediaSource
    static func deserialize(from value: [String: Any]) throws -> SwiftMediaSource {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftMediaSource.self, from: data)
    }
    
    /// Deserializes string into a SwiftMediaSource
    static func deserialize(from jsonString: String) throws -> SwiftMediaSource {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftMediaSource.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftMediaSource to JSON dictionary
    static func serializeToJson(_ mediaSource: SwiftMediaSource) -> [String: Any] {
        var json: [String: Any] = ["url": mediaSource.url]
        if let mimeType = mediaSource.mimeType {
            json["mimeType"] = mimeType
        }
        return json
    }
    
    /// Converts to JSON string
    static func serializeToJsonString(_ mediaSource: SwiftMediaSource) -> String {
        do {
            let json = serializeToJson(mediaSource)
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw EncodingError.invalidValue(json, EncodingError.Context(
                    codingPath: [], debugDescription: "Failed to convert JSON to string"))
            }
            return jsonString
        } catch {
            return "{}"
        }
    }
    
    // MARK: - Resource Information
    
    /// Retrieves resource information
    static func getResourceInformation(_ mediaSource: SwiftMediaSource) -> [SwiftRemoteResourceInformation] {
        return [SwiftRemoteResourceInformation(url: mediaSource.url, mimeType: mediaSource.mimeType ?? "unknown")]
    }
}

// MARK: - SwiftMediaSource Extension

extension SwiftMediaSource {
    // Static factory methods for backward compatibility
    static func deserialize(from json: [String: Any]) throws -> SwiftMediaSource {
        return try SwiftMediaSourceLegacySupport.deserialize(from: json)
    }
    
    static func deserialize(from jsonString: String) throws -> SwiftMediaSource {
        return try SwiftMediaSourceLegacySupport.deserialize(from: jsonString)
    }
    
    // Additional utility methods
    static func fromJSON(_ json: [String: Any]) -> SwiftMediaSource? {
        guard !json.isEmpty else { return nil }
        return try? SwiftMediaSourceLegacySupport.deserialize(from: json)
    }
    
    static func fromJSONString(_ jsonString: String) -> SwiftMediaSource? {
        return try? SwiftMediaSourceLegacySupport.deserialize(from: jsonString)
    }
}

import Foundation

// MARK: - Consolidated SwiftRatingInput Legacy Support

/// Unified legacy support for SwiftRatingInput parsing and serialization
enum SwiftRatingInputLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftRatingInput
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftRatingInput {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftRatingInput.self, from: data)
    }
    
    /// Deserializes string into a SwiftRatingInput
    static func deserialize(from jsonString: String) throws -> SwiftRatingInput {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftRatingInput.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftRatingInput to JSON dictionary with proper formatting
    static func serializeToJson(_ ratingInput: SwiftRatingInput, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set required properties
        json["type"] = "RatingInput"
        json["value"] = ratingInput.value
        json["max"] = ratingInput.max
        
        // Add optional properties
        if let alignment = ratingInput.horizontalAlignment {
            json["horizontalAlignment"] = alignment.rawValue
        }
        
        // Only include non-default values
        if ratingInput.size != .medium {
            json["size"] = ratingInput.size.rawValue
        }
        
        if ratingInput.color != .neutral {
            json["color"] = ratingInput.color.rawValue
        }
        
        return json
    }
    
    /// Converts to JSON string
    static func serializeToJsonString(_ ratingInput: SwiftRatingInput) -> String {
        do {
            // Use the full serialization path for consistency
            let baseJson = try ratingInput.serializeToJsonValue()
            let jsonData = try JSONSerialization.data(withJSONObject: baseJson, options: .prettyPrinted)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw EncodingError.invalidValue(baseJson, EncodingError.Context(
                    codingPath: [], debugDescription: "Failed to convert JSON to string"))
            }
            return jsonString
        } catch {
            return "{}"
        }
    }
}

// MARK: - Parser Implementation

/// Parses RatingInput elements in an Adaptive Card
struct SwiftRatingInputParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.ratingInput)
        return try SwiftRatingInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftRatingInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftRatingInputLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftRatingInput Extension

internal extension SwiftRatingInput {
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        return try SwiftRatingInputLegacySupport.serializeToJson(self, baseJson: superResult)
    }
    
    // MARK: - Known Properties
    func populateKnownPropertiesSet() {
        self.knownProperties.insert("value")
        self.knownProperties.insert("max")
        self.knownProperties.insert("horizontalAlignment")
        self.knownProperties.insert("size")
        self.knownProperties.insert("color")
    }
    
    // Legacy compatibility methods
    func serializeToJson() -> [String: Any] {
        do {
            return try self.serializeToJsonValue()
        } catch {
            return [:]
        }
    }
    
    func toJSONString() -> String {
        return SwiftRatingInputLegacySupport.serializeToJsonString(self)
    }
}

// Legacy static methods for backward compatibility
extension SwiftRatingInput {
    static func createFromJSON(_ json: [String: Any]) throws -> SwiftRatingInput {
        return try SwiftRatingInputLegacySupport.deserialize(from: json)
    }
    
    static func createFromJSONString(_ jsonString: String) throws -> SwiftRatingInput {
        return try SwiftRatingInputLegacySupport.deserialize(from: jsonString)
    }
    
    /// Factory method for creating SwiftRatingInput instances
    static func create(id: String? = nil,
                       value: Double = 0,
                       max: Double = 5,
                       horizontalAlignment: SwiftHorizontalAlignment? = nil,
                       size: SwiftRatingSize = .medium,
                       color: SwiftRatingColor = .neutral,
                       spacing: SwiftSpacing? = nil,
                       height: SwiftHeightType? = nil,
                       targetWidth: SwiftTargetWidthType? = nil,
                       separator: Bool? = nil,
                       isVisible: Bool = true,
                       areaGridName: String? = nil) -> SwiftRatingInput {
        
        // Create a JSON dictionary with all properties
        var json: [String: Any] = [
            "type": "RatingInput",
            "value": value,
            "max": max,
            "size": size.rawValue,
            "color": color.rawValue,
            "isVisible": isVisible
        ]
        
        // Add optional properties
        if let id = id { json["id"] = id }
        if let horizontalAlignment = horizontalAlignment { json["horizontalAlignment"] = horizontalAlignment.rawValue }
        if let spacing = spacing { json["spacing"] = spacing.rawValue }
        if let height = height { json["height"] = height.rawValue }
        if let targetWidth = targetWidth { json["targetWidth"] = targetWidth.rawValue }
        if let separator = separator { json["separator"] = separator }
        if let areaGridName = areaGridName { json["areaGridName"] = areaGridName }
        
        // Use JSON deserialization to create the instance
        do {
            return try SwiftRatingInputLegacySupport.deserialize(from: json)
        } catch {
            // Create a minimal instance if deserialization fails
            var minimalJson: [String: Any] = [
                "type": "RatingInput",
                "value": 0.0,
                "max": 5.0,
                "size": "medium",
                "color": "neutral",
                "isVisible": true
            ]
            if let id = id { minimalJson["id"] = id }
            
            // This should almost never fail, but we need a fallback
            return try! SwiftRatingInputLegacySupport.deserialize(from: minimalJson)
        }
    }
}

// MARK: - Consolidated SwiftRatingLabel Legacy Support

/// Unified legacy support for SwiftRatingLabel parsing and serialization
enum SwiftRatingLabelLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftRatingLabel
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftRatingLabel {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftRatingLabel.self, from: data)
    }
    
    /// Deserializes string into a SwiftRatingLabel
    static func deserialize(from jsonString: String) throws -> SwiftRatingLabel {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftRatingLabel.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftRatingLabel to JSON dictionary with proper formatting
    static func serializeToJson(_ ratingLabel: SwiftRatingLabel, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set required properties
        json["type"] = "RatingLabel"
        json["value"] = ratingLabel.value
        json["max"] = ratingLabel.max
        
        // Add optional properties
        if let count = ratingLabel.count {
            json["count"] = count
        }
        
        if let alignment = ratingLabel.horizontalAlignment {
            json["horizontalAlignment"] = alignment.rawValue
        }
        
        // Only include non-default values
        if ratingLabel.size != .medium {
            json["size"] = ratingLabel.size.rawValue
        }
        
        if ratingLabel.color != .neutral {
            json["color"] = ratingLabel.color.rawValue
        }
        
        if ratingLabel.style != .default {
            json["style"] = ratingLabel.style.rawValue
        }
        
        return json
    }
    
    /// Converts to JSON string
    static func serializeToJsonString(_ ratingLabel: SwiftRatingLabel) -> String {
        do {
            // Use the full serialization path for consistency
            let baseJson = try ratingLabel.serializeToJsonValue()
            let jsonData = try JSONSerialization.data(withJSONObject: baseJson, options: .prettyPrinted)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw EncodingError.invalidValue(baseJson, EncodingError.Context(
                    codingPath: [], debugDescription: "Failed to convert JSON to string"))
            }
            return jsonString
        } catch {
            return "{}"
        }
    }
}

// MARK: - Parser Implementation

/// Parses RatingLabel elements in an Adaptive Card
struct SwiftRatingLabelParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.ratingLabel)
        return try SwiftRatingLabelLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftRatingLabelLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftRatingLabelLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftRatingLabel Extension

internal extension SwiftRatingLabel {
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        return try SwiftRatingLabelLegacySupport.serializeToJson(self, baseJson: superResult)
    }
    
    // MARK: - Known Properties
    func populateKnownPropertiesSet() {
        self.knownProperties.insert("value")
        self.knownProperties.insert("max")
        self.knownProperties.insert("count")
        self.knownProperties.insert("horizontalAlignment")
        self.knownProperties.insert("size")
        self.knownProperties.insert("color")
        self.knownProperties.insert("style")
    }
    
    // Legacy compatibility methods
    func serializeToJson() -> [String: Any] {
        do {
            return try self.serializeToJsonValue()
        } catch {
            return [:]
        }
    }
    
    func toJSONString() -> String {
        return SwiftRatingLabelLegacySupport.serializeToJsonString(self)
    }
}

// Legacy static methods for backward compatibility
extension SwiftRatingLabel {
    static func createFromJSON(_ json: [String: Any]) throws -> SwiftRatingLabel {
        return try SwiftRatingLabelLegacySupport.deserialize(from: json)
    }
    
    static func createFromJSONString(_ jsonString: String) throws -> SwiftRatingLabel {
        return try SwiftRatingLabelLegacySupport.deserialize(from: jsonString)
    }
    
    /// Factory method for creating SwiftRatingLabel instances
    static func create(id: String? = nil,
                       value: Double = 0,
                       max: Double = 5,
                       count: UInt? = nil,
                       horizontalAlignment: SwiftHorizontalAlignment? = nil,
                       size: SwiftRatingSize = .medium,
                       color: SwiftRatingColor = .neutral,
                       style: SwiftRatingStyle = .default,
                       spacing: SwiftSpacing? = nil,
                       height: SwiftHeightType? = nil,
                       targetWidth: SwiftTargetWidthType? = nil,
                       separator: Bool? = nil,
                       isVisible: Bool = true,
                       areaGridName: String? = nil) -> SwiftRatingLabel {
        
        // Create a JSON dictionary with all properties
        var json: [String: Any] = [
            "type": "RatingLabel",
            "value": value,
            "max": max,
            "size": size.rawValue,
            "color": color.rawValue,
            "style": style.rawValue,
            "isVisible": isVisible
        ]
        
        // Add optional properties
        if let id = id { json["id"] = id }
        if let count = count { json["count"] = count }
        if let horizontalAlignment = horizontalAlignment { json["horizontalAlignment"] = horizontalAlignment.rawValue }
        if let spacing = spacing { json["spacing"] = spacing.rawValue }
        if let height = height { json["height"] = height.rawValue }
        if let targetWidth = targetWidth { json["targetWidth"] = targetWidth.rawValue }
        if let separator = separator { json["separator"] = separator }
        if let areaGridName = areaGridName { json["areaGridName"] = areaGridName }
        
        // Use JSON deserialization to create the instance
        do {
            return try SwiftRatingLabelLegacySupport.deserialize(from: json)
        } catch {
            // Create a minimal instance if deserialization fails
            var minimalJson: [String: Any] = [
                "type": "RatingLabel",
                "value": 0.0,
                "max": 5.0,
                "size": "medium",
                "color": "neutral",
                "style": "default",
                "isVisible": true
            ]
            if let id = id { minimalJson["id"] = id }
            
            // This should almost never fail, but we need a fallback
            return try! SwiftRatingLabelLegacySupport.deserialize(from: minimalJson)
        }
    }
}

// MARK: - Consolidated SwiftRefresh Legacy Support

/// Unified legacy support for SwiftRefresh parsing and serialization
enum SwiftRefreshLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftRefresh
    static func deserialize(from value: [String: Any]) throws -> SwiftRefresh {
        let action: SwiftBaseActionElement? = try? SwiftBaseActionElement.deserializeAction(from: value["action"] as? [String: Any] ?? [:])
        let userIds = value["userIds"] as? [String] ?? []
        return SwiftRefresh(action: action, userIds: userIds)
    }
    
    /// Deserializes string into a SwiftRefresh
    static func deserialize(from jsonString: String) throws -> SwiftRefresh {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw SwiftJSONError.missingKey("Unable to parse JSON string")
        }
        
        return try deserialize(from: jsonDict)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftRefresh to JSON dictionary
    static func serializeToJson(_ refresh: SwiftRefresh) -> [String: Any] {
        var json: [String: Any] = [:]
        
        if let action = refresh.action {
            json["action"] = action.toJSON()
        }
        
        if !refresh.userIds.isEmpty {
            json["userIds"] = refresh.userIds
        }
        
        return json
    }
    
    /// Converts to JSON string
    static func serializeToJsonString(_ refresh: SwiftRefresh) -> String {
        do {
            let json = serializeToJson(refresh)
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw EncodingError.invalidValue(json, EncodingError.Context(
                    codingPath: [], debugDescription: "Failed to convert JSON to string"))
            }
            return jsonString
        } catch {
            return "{}"
        }
    }
}

// MARK: - SwiftRefresh Extension

extension SwiftRefresh {
    // Static factory methods for backward compatibility
    static func deserialize(from json: [String: Any]) throws -> SwiftRefresh {
        return try SwiftRefreshLegacySupport.deserialize(from: json)
    }
    
    static func deserialize(from jsonString: String) throws -> SwiftRefresh {
        return try SwiftRefreshLegacySupport.deserialize(from: jsonString)
    }
    
    // Additional utility methods
    static func fromJSON(_ json: [String: Any]) -> SwiftRefresh? {
        guard !json.isEmpty else { return nil }
        return try? SwiftRefreshLegacySupport.deserialize(from: json)
    }
    
    static func fromJSONString(_ jsonString: String) -> SwiftRefresh? {
        return try? SwiftRefreshLegacySupport.deserialize(from: jsonString)
    }
    
    // Serialization to string
    func toJSONString() -> String {
        return SwiftRefreshLegacySupport.serializeToJsonString(self)
    }
}

// MARK: - Consolidated SwiftRichTextBlock Legacy Support

/// Unified legacy support for SwiftRichTextBlock parsing and serialization
enum SwiftRichTextBlockLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftRichTextBlock
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftRichTextBlock {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftRichTextBlock.self, from: data)
    }
    
    /// Deserializes string into a SwiftRichTextBlock
    static func deserialize(from jsonString: String) throws -> SwiftRichTextBlock {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftRichTextBlock.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftRichTextBlock to JSON dictionary with proper formatting
    static func serializeToJson(_ richTextBlock: SwiftRichTextBlock, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set required properties
        json["type"] = "RichTextBlock"
        
        // Add optional properties
        if let alignment = richTextBlock.horizontalAlignment {
            json["horizontalAlignment"] = alignment.rawValue
        }
        
        // Process inlines
        json["inlines"] = richTextBlock.inlines.map { inline -> Any in
            if let textRun = inline as? SwiftTextRun {
                return textRun.serializeToJson()
            } else if let stringValue = inline as? String {
                return stringValue
            }
            return [:]
        }
        
        return json
    }
    
    /// Converts to JSON string
    static func serializeToJsonString(_ richTextBlock: SwiftRichTextBlock) -> String {
        do {
            // Use the full serialization path for consistency
            let baseJson = try richTextBlock.serializeToJsonValue()
            let jsonData = try JSONSerialization.data(withJSONObject: baseJson, options: .prettyPrinted)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw EncodingError.invalidValue(baseJson, EncodingError.Context(
                    codingPath: [], debugDescription: "Failed to convert JSON to string"))
            }
            return jsonString
        } catch {
            return "{}"
        }
    }
    
    /// Helper function to dispatch inline deserialization based on the "type" field.
    static func deserializeInline(from json: [String: Any]) throws -> SwiftInline {
        guard let typeString = json["type"] as? String,
              let type = SwiftInlineElementType(rawValue: typeString) else {
            throw ParsingError.invalidType(expected: "Inline", found: "Missing type")
        }
        
        switch type {
        case .textRun:
            guard let inline = try? SwiftTextRun.deserialize(from: json) else {
                throw ParsingError.invalidType(expected: "TextRun", found: "Invalid data")
            }
            return inline
        }
    }
}

// MARK: - Parser Implementation

/// Parses RichTextBlock elements in an Adaptive Card
struct SwiftRichTextBlockParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.richTextBlock)
        return try SwiftRichTextBlockLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftRichTextBlockLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftRichTextBlockLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftRichTextBlock Extension

internal extension SwiftRichTextBlock {
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        return try SwiftRichTextBlockLegacySupport.serializeToJson(self, baseJson: superResult)
    }
    
    // MARK: - Known Properties
    func populateKnownPropertiesSet() {
        self.knownProperties.insert("horizontalAlignment")
        self.knownProperties.insert("inlines")
    }
}

// Legacy static methods and factory method for backward compatibility
extension SwiftRichTextBlock {
    static func deserialize(fromString jsonString: String) throws -> SwiftRichTextBlock {
        return try SwiftRichTextBlockLegacySupport.deserialize(from: jsonString)
    }
    
    /// Factory method for creating SwiftRichTextBlock instances
    static func create(id: String? = nil,
                       horizontalAlignment: SwiftHorizontalAlignment? = nil,
                       inlines: [Any] = [],
                       spacing: SwiftSpacing? = nil,
                       height: SwiftHeightType? = nil,
                       separator: Bool? = nil,
                       isVisible: Bool = true) -> SwiftRichTextBlock {
        
        // Create a JSON dictionary with all properties
        var json: [String: Any] = [
            "type": "RichTextBlock",
            "isVisible": isVisible
        ]
        
        // Add optional properties
        if let id = id { json["id"] = id }
        if let horizontalAlignment = horizontalAlignment { json["horizontalAlignment"] = horizontalAlignment.rawValue }
        if let spacing = spacing { json["spacing"] = spacing.rawValue }
        if let height = height { json["height"] = height.rawValue }
        if let separator = separator { json["separator"] = separator }
        
        // Handle inlines - this is complex due to heterogeneous array
        var inlinesArray: [Any] = []
        for inline in inlines {
            if let textRun = inline as? SwiftTextRun {
                inlinesArray.append(textRun.serializeToJson())
            } else if let stringValue = inline as? String {
                inlinesArray.append(stringValue)
            }
        }
        json["inlines"] = inlinesArray
        
        // Use JSON deserialization to create the instance
        do {
            return try SwiftRichTextBlockLegacySupport.deserialize(from: json)
        } catch {
            // Create a minimal instance if deserialization fails
            var minimalJson: [String: Any] = [
                "type": "RichTextBlock",
                "inlines": [],
                "isVisible": true
            ]
            if let id = id { minimalJson["id"] = id }
            
            // This should almost never fail, but we need a fallback
            return try! SwiftRichTextBlockLegacySupport.deserialize(from: minimalJson)
        }
    }
}

// MARK: - Consolidated SwiftRichTextElementProperties Legacy Support

/// Unified legacy support for SwiftRichTextElementProperties parsing and serialization
enum SwiftRichTextElementPropertiesLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftRichTextElementProperties
    /// Deserializes JSON into a SwiftRichTextElementProperties
    static func deserialize(from value: [String: Any]) throws -> SwiftRichTextElementProperties {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        
        // Use the existing Codable implementation
        return try decoder.decode(SwiftRichTextElementProperties.self, from: data)
    }
    
    /// Deserializes string into a SwiftRichTextElementProperties
    static func deserialize(from jsonString: String) throws -> SwiftRichTextElementProperties {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw SwiftJSONError.missingKey("Unable to parse JSON string")
        }
        
        return try deserialize(from: jsonDict)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftRichTextElementProperties to JSON dictionary
    static func serializeToJson(_ properties: SwiftRichTextElementProperties) -> [String: Any] {
        var json: [String: Any] = [:]
        
        // Add non-nil optional properties
        if let textSize = properties.textSize {
            json["size"] = textSize.rawValue
        }
        if let textColor = properties.textColor {
            json["color"] = textColor.rawValue
        }
        if let textWeight = properties.textWeight {
            json["weight"] = textWeight.rawValue
        }
        if let fontType = properties.fontType {
            json["fontType"] = fontType.rawValue
        }
        if let isSubtle = properties.isSubtle {
            json["isSubtle"] = isSubtle
        }
        
        // Add required and default properties
        json["text"] = properties.text
        json["language"] = properties.language
        json["italic"] = properties.italic
        json["strikethrough"] = properties.strikethrough
        json["underline"] = properties.underline
        
        return json
    }
    
    /// Converts to JSON string
    static func serializeToJsonString(_ properties: SwiftRichTextElementProperties) -> String {
        do {
            let json = serializeToJson(properties)
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw EncodingError.invalidValue(json, EncodingError.Context(
                    codingPath: [], debugDescription: "Failed to convert JSON to string"))
            }
            return jsonString
        } catch {
            return "{}"
        }
    }
}

// MARK: - SwiftRichTextElementProperties Extension

extension SwiftRichTextElementProperties {
    // Static factory methods for backward compatibility
    static func fromJSON(_ json: [String: Any]) throws -> SwiftRichTextElementProperties {
        return try SwiftRichTextElementPropertiesLegacySupport.deserialize(from: json)
    }
    
    static func fromJSONString(_ jsonString: String) throws -> SwiftRichTextElementProperties? {
        return try SwiftRichTextElementPropertiesLegacySupport.deserialize(from: jsonString)
    }
    
    // Serialization to string
    func toJSONString() -> String {
        return SwiftRichTextElementPropertiesLegacySupport.serializeToJsonString(self)
    }
    
    // MARK: - Serialization to JSON
    func toJSON() -> [String: Any] {
        return SwiftRichTextElementPropertiesLegacySupport.serializeToJson(self)
    }
}
