import Foundation

// MARK: - Consolidated SwiftBackgroundImage Legacy Support

/// Unified legacy support for SwiftBackgroundImage parsing and serialization
enum SwiftBackgroundImageLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftBackgroundImage using Codable
    static func deserialize(from json: [String: Any]) throws -> SwiftBackgroundImage {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftBackgroundImage.self, from: data)
    }
    
    /// Deserializes string into a SwiftBackgroundImage
    static func deserialize(from jsonString: String) -> SwiftBackgroundImage? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(SwiftBackgroundImage.self, from: jsonData)
    }
    
    // MARK: - Serialization Functions
    
    /// Serializes a SwiftBackgroundImage to JSON string using Codable
    static func serialize(_ backgroundImage: SwiftBackgroundImage) -> String {
        let jsonData = try? JSONEncoder().encode(backgroundImage)
        return jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }
    
    /// Converts a SwiftBackgroundImage to JSON dictionary
    static func serializeToJson(_ backgroundImage: SwiftBackgroundImage) -> [String: Any] {
        guard let jsonData = try? JSONEncoder().encode(backgroundImage),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            return ["url": backgroundImage.url]
        }
        return json
    }
    
    /// Converts to JSON string with pretty printing
    static func serializeToJsonString(_ backgroundImage: SwiftBackgroundImage) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(backgroundImage)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw EncodingError.invalidValue(backgroundImage, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert to JSON string"))
        }
        return jsonString
    }
}

// MARK: - SwiftBackgroundImage Extension

extension SwiftBackgroundImage {
    // Validation methods
    func shouldSerialize() -> Bool {
        return !url.isEmpty
    }
    
    // Serialization helpers
    func serialize() -> String {
        return SwiftBackgroundImageLegacySupport.serialize(self)
    }
    
    func serializeToJsonValue() -> [String: Any] {
        return SwiftBackgroundImageLegacySupport.serializeToJson(self)
    }
    
    func toJSON() -> [String: Any] {
        return SwiftBackgroundImageLegacySupport.serializeToJson(self)
    }
    
    func toJSONString() throws -> String {
        return try SwiftBackgroundImageLegacySupport.serializeToJsonString(self)
    }
    
    // Static factory methods
    static func deserialize(from json: [String: Any]) throws -> SwiftBackgroundImage {
        return try SwiftBackgroundImageLegacySupport.deserialize(from: json)
    }
    
    static func deserialize(from jsonString: String) -> SwiftBackgroundImage? {
        return SwiftBackgroundImageLegacySupport.deserialize(from: jsonString)
    }
    
    static func fromJSON(_ json: [String: Any]) -> SwiftBackgroundImage? {
        return try? SwiftBackgroundImageLegacySupport.deserialize(from: json)
    }
    
    static func fromJSONString(_ jsonString: String) -> SwiftBackgroundImage? {
        return SwiftBackgroundImageLegacySupport.deserialize(from: jsonString)
    }
}

// MARK: - Consolidated SwiftCaptionSource Legacy Support

/// Unified legacy support for SwiftCaptionSource parsing and serialization
enum SwiftCaptionSourceLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftCaptionSource using Codable
    static func deserialize(from json: [String: Any]) throws -> SwiftCaptionSource {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftCaptionSource.self, from: jsonData)
    }
    
    /// Deserializes string into a SwiftCaptionSource
    static func deserialize(from jsonString: String) throws -> SwiftCaptionSource {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "CaptionSource", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        return try JSONDecoder().decode(SwiftCaptionSource.self, from: jsonData)
    }
    
    // MARK: - Serialization Functions
    
    /// Serializes a SwiftCaptionSource to JSON string using Codable
    static func serializeToJson(_ captionSource: SwiftCaptionSource) -> String? {
        guard let jsonData = try? JSONEncoder().encode(captionSource) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
    
    /// Converts to JSON dictionary
    static func toJsonDictionary(_ captionSource: SwiftCaptionSource) throws -> [String: Any] {
        guard let jsonData = try? JSONEncoder().encode(captionSource),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw EncodingError.invalidValue(captionSource, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert to JSON dictionary"))
        }
        return json
    }
    
    /// Converts to JSON string with pretty printing
    static func serializeToJsonString(_ captionSource: SwiftCaptionSource) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(captionSource)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw EncodingError.invalidValue(captionSource, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert to JSON string"))
        }
        return jsonString
    }
}

// MARK: - SwiftCaptionSource Extension

extension SwiftCaptionSource {
    // Validation methods
    func shouldSerialize() -> Bool {
        return mimeType != nil || url != nil || label != nil
    }
    
    // Serialization helpers
    func serializeToJson() -> String? {
        return SwiftCaptionSourceLegacySupport.serializeToJson(self)
    }
    
    func toJSON() throws -> [String: Any] {
        return try SwiftCaptionSourceLegacySupport.toJsonDictionary(self)
    }
    
    func toJSONString() throws -> String {
        return try SwiftCaptionSourceLegacySupport.serializeToJsonString(self)
    }
    
    // Static factory methods
    static func deserialize(from json: [String: Any]) throws -> SwiftCaptionSource {
        return try SwiftCaptionSourceLegacySupport.deserialize(from: json)
    }
    
    static func deserialize(from jsonString: String) throws -> SwiftCaptionSource {
        return try SwiftCaptionSourceLegacySupport.deserialize(from: jsonString)
    }
    
    static func fromJSON(_ json: [String: Any]) -> SwiftCaptionSource? {
        return try? SwiftCaptionSourceLegacySupport.deserialize(from: json)
    }
    
    static func fromJSONString(_ jsonString: String) -> SwiftCaptionSource? {
        return try? SwiftCaptionSourceLegacySupport.deserialize(from: jsonString)
    }
}

// MARK: - Consolidated SwiftChoiceInput Legacy Support

/// Unified legacy support for SwiftChoiceInput parsing and serialization
enum SwiftChoiceInputLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftChoiceInput using Codable
    static func deserialize(from json: [String: Any]) throws -> SwiftChoiceInput {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftChoiceInput.self, from: jsonData)
    }
    
    /// Deserializes string into a SwiftChoiceInput
    static func deserialize(from jsonString: String) throws -> SwiftChoiceInput {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "ChoiceInput", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        return try JSONDecoder().decode(SwiftChoiceInput.self, from: jsonData)
    }
    
    // MARK: - Serialization Functions
    
    /// Serializes a SwiftChoiceInput to JSON string using Codable
    static func serializeToJson(_ choiceInput: SwiftChoiceInput) -> String? {
        guard let jsonData = try? JSONEncoder().encode(choiceInput) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
    
    /// Converts to JSON dictionary
    static func toJsonDictionary(_ choiceInput: SwiftChoiceInput) throws -> [String: Any] {
        guard let jsonData = try? JSONEncoder().encode(choiceInput),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw EncodingError.invalidValue(choiceInput, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert to JSON dictionary"))
        }
        return json
    }
    
    /// Converts to JSON string with pretty printing
    static func serializeToJsonString(_ choiceInput: SwiftChoiceInput) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(choiceInput)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw EncodingError.invalidValue(choiceInput, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert to JSON string"))
        }
        return jsonString
    }
}

// MARK: - SwiftChoiceInput Extension

extension SwiftChoiceInput {
    // Validation methods
    func shouldSerialize() -> Bool {
        return !title.isEmpty || !value.isEmpty
    }
    
    // Serialization helpers
    func serializeToJson() -> String? {
        return SwiftChoiceInputLegacySupport.serializeToJson(self)
    }
    
    func toJSON() throws -> [String: Any] {
        return try SwiftChoiceInputLegacySupport.toJsonDictionary(self)
    }
    
    func toJSONString() throws -> String {
        return try SwiftChoiceInputLegacySupport.serializeToJsonString(self)
    }
    
    // Static factory methods
    static func deserialize(from json: [String: Any]) throws -> SwiftChoiceInput {
        return try SwiftChoiceInputLegacySupport.deserialize(from: json)
    }
    
    static func deserialize(from jsonString: String) throws -> SwiftChoiceInput {
        return try SwiftChoiceInputLegacySupport.deserialize(from: jsonString)
    }
    
    static func fromJSON(_ json: [String: Any]) -> SwiftChoiceInput? {
        return try? SwiftChoiceInputLegacySupport.deserialize(from: json)
    }
    
    static func fromJSONString(_ jsonString: String) -> SwiftChoiceInput? {
        return try? SwiftChoiceInputLegacySupport.deserialize(from: jsonString)
    }
}

// MARK: - Consolidated SwiftChoicesData Legacy Support

/// Unified legacy support for SwiftChoicesData parsing and serialization
enum SwiftChoicesDataLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftChoicesData using Codable
    static func deserialize(from json: [String: Any]) throws -> SwiftChoicesData {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftChoicesData.self, from: jsonData)
    }
    
    /// Deserializes string into a SwiftChoicesData
    static func deserialize(from jsonString: String) throws -> SwiftChoicesData {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "ChoicesData", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        return try JSONDecoder().decode(SwiftChoicesData.self, from: jsonData)
    }
    
    // MARK: - Serialization Functions
    
    /// Serializes a SwiftChoicesData to JSON string using Codable
    static func serializeToJson(_ choicesData: SwiftChoicesData) -> String? {
        guard let jsonData = try? JSONEncoder().encode(choicesData) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
    
    /// Converts to JSON dictionary
    static func toJsonDictionary(_ choicesData: SwiftChoicesData) throws -> [String: Any] {
        guard let jsonData = try? JSONEncoder().encode(choicesData),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw EncodingError.invalidValue(choicesData, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert to JSON dictionary"))
        }
        return json
    }
    
    /// Converts to JSON string with pretty printing
    static func serializeToJsonString(_ choicesData: SwiftChoicesData) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(choicesData)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw EncodingError.invalidValue(choicesData, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert to JSON string"))
        }
        return jsonString
    }
}

// MARK: - SwiftChoicesData Extension

extension SwiftChoicesData {
    // Validation methods
    func shouldSerialize() -> Bool {
        return choicesDataType != "Data.Query" && !dataset.isEmpty
    }
    
    // Serialization helpers
    func serializeToJson() -> String? {
        return SwiftChoicesDataLegacySupport.serializeToJson(self)
    }
    
    func toJSON() throws -> [String: Any] {
        return try SwiftChoicesDataLegacySupport.toJsonDictionary(self)
    }
    
    func toJSONString() throws -> String {
        return try SwiftChoicesDataLegacySupport.serializeToJsonString(self)
    }
    
    // Static factory methods
    static func deserialize(from json: [String: Any]) throws -> SwiftChoicesData {
        return try SwiftChoicesDataLegacySupport.deserialize(from: json)
    }
    
    static func deserialize(from jsonString: String) throws -> SwiftChoicesData {
        return try SwiftChoicesDataLegacySupport.deserialize(from: jsonString)
    }
    
    static func fromJSON(_ json: [String: Any]) -> SwiftChoicesData? {
        return try? SwiftChoicesDataLegacySupport.deserialize(from: json)
    }
    
    static func fromJSONString(_ jsonString: String) -> SwiftChoicesData? {
        return try? SwiftChoicesDataLegacySupport.deserialize(from: jsonString)
    }
}
