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

// MARK: - Consolidated SwiftCompoundButton Legacy Support

/// Unified legacy support for SwiftCompoundButton parsing and serialization
enum SwiftCompoundButtonLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftCompoundButton
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftCompoundButton {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftCompoundButton.self, from: data)
    }
    
    /// Deserializes string into a SwiftCompoundButton
    static func deserialize(from jsonString: String) throws -> SwiftCompoundButton {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftCompoundButton.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftCompoundButton to JSON dictionary with proper formatting
    static func serializeToJson(_ button: SwiftCompoundButton, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set type property
        json["type"] = "CompoundButton"
        
        // Add properties if present
        if let badge = button.badge {
            json["badge"] = badge
        }
        
        if let title = button.title {
            json["title"] = title
        }
        
        if let description = button.buttonDescription {
            json["description"] = description
        }
        
        if let icon = button.icon {
            json["icon"] = icon.toJSON()
        }
        
        // Add selectAction if present
        if let action = button.selectAction {
            json["selectAction"] = try SwiftBaseCardElement.serializeSelectAction(action)
        }
        
        return json
    }
}

// MARK: - Parser Implementation

/// Parses CompoundButton elements in an Adaptive Card
struct SwiftCompoundButtonParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.compoundButton)
        return try SwiftCompoundButtonLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftCompoundButtonLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftCompoundButtonLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftCompoundButton Extension

internal extension SwiftCompoundButton {
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        return try SwiftCompoundButtonLegacySupport.serializeToJson(self, baseJson: superResult)
    }
    
    // MARK: - Known Properties
    func populateKnownPropertiesSet() {
        self.knownProperties.insert("badge")
        self.knownProperties.insert("title")
        self.knownProperties.insert("description")
        self.knownProperties.insert("icon")
        self.knownProperties.insert("selectAction")
    }
}

// MARK: - Consolidated SwiftValueChangedAction Legacy Support

/// Unified legacy support for SwiftValueChangedAction parsing and serialization
enum SwiftValueChangedActionLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftValueChangedAction
    static func deserialize(from value: [String: Any]) throws -> SwiftValueChangedAction {
        // Convert dictionary to JSON data and let the decoder handle the validation
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftValueChangedAction.self, from: data)
    }
    /// Deserializes string into a SwiftValueChangedAction
    static func deserialize(from jsonString: String) throws -> SwiftValueChangedAction {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try deserialize(from: jsonObject)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftValueChangedAction to JSON dictionary with proper formatting
    static func serializeToJson(_ action: SwiftValueChangedAction) -> [String: Any] {
        var json: [String: Any] = [:]
        
        if !action.targetInputIds.isEmpty {
            json["targetInputIds"] = action.targetInputIds
        }
        
        json["valueChangedActionType"] = action.valueChangedActionType.rawValue
        
        return json
    }
    
    /// Determines whether this action has sufficient data to be serialized.
    static func shouldSerialize(_ action: SwiftValueChangedAction) -> Bool {
        return !action.targetInputIds.isEmpty
    }
}

// MARK: - SwiftValueChangedAction Extension

extension SwiftValueChangedAction {
    // MARK: - Serialization Helpers
    
    var shouldSerialize: Bool {
        return SwiftValueChangedActionLegacySupport.shouldSerialize(self)
    }
    
    // Static Methods for Serialization/Deserialization
    
    static func deserialize(from json: [String: Any]) -> SwiftValueChangedAction? {
        return try? SwiftValueChangedActionLegacySupport.deserialize(from: json)
    }
    
    static func deserialize(from jsonString: String) -> SwiftValueChangedAction? {
        return try? SwiftValueChangedActionLegacySupport.deserialize(from: jsonString)
    }
    
    static func serializeAction(_ action: SwiftValueChangedAction) throws -> [String: Any] {
        return SwiftValueChangedActionLegacySupport.serializeToJson(action)
    }
}

// MARK: - Consolidated SwiftBaseInputElement Legacy Support

/// Unified legacy support for SwiftBaseInputElement parsing and serialization
enum SwiftBaseInputElementLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftBaseInputElement
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftBaseInputElement {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftBaseInputElement.self, from: data)
    }
    
    /// Deserializes string into a SwiftBaseInputElement
    static func deserialize(from jsonString: String) throws -> SwiftBaseInputElement {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftBaseInputElement.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftBaseInputElement to JSON dictionary with proper formatting
    static func serializeToJson(_ inputElement: SwiftBaseInputElement, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Add label if present
        if let label = inputElement.label {
            json["label"] = label
        }
        
        // Only add non-default properties
        if inputElement.isRequired {
            json["isRequired"] = inputElement.isRequired
        }
        
        if let errorMessage = inputElement.errorMessage {
            json["errorMessage"] = errorMessage
        }
        
        // Add valueChangedAction if present
        if let action = inputElement.valueChangedAction {
            json["valueChangedAction"] = try SwiftValueChangedAction.serializeAction(action)
        }
        
        return json
    }
    
    /// Determines whether this element has sufficient data to be serialized.
    static func shouldSerialize(_ inputElement: SwiftBaseInputElement) -> Bool {
        // Assuming `id` is a property inherited from BaseElement (via BaseCardElement).
        let idNotEmpty = (inputElement.id ?? "").isEmpty == false
        let labelNotEmpty = !(inputElement.label?.isEmpty ?? true)
        let errorMessageNotEmpty = !(inputElement.errorMessage?.isEmpty ?? true)
        return idNotEmpty || inputElement.isRequired || labelNotEmpty || errorMessageNotEmpty
    }
}

// MARK: - SwiftBaseInputElement Extension

internal extension SwiftBaseInputElement {
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        return try SwiftBaseInputElementLegacySupport.serializeToJson(self, baseJson: superResult)
    }
    
    /// Determines whether this element has sufficient data to be serialized.
    func shouldSerialize() -> Bool {
        return SwiftBaseInputElementLegacySupport.shouldSerialize(self)
    }
}

// MARK: - Consolidated SwiftToggleInput Legacy Support

/// Unified legacy support for SwiftToggleInput parsing and serialization
enum SwiftToggleInputLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftToggleInput
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftToggleInput {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftToggleInput.self, from: data)
    }
    
    /// Deserializes string into a SwiftToggleInput
    static func deserialize(from jsonString: String) throws -> SwiftToggleInput {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftToggleInput.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftToggleInput to JSON dictionary with proper formatting
    static func serializeToJson(_ toggleInput: SwiftToggleInput, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set type property
        json["type"] = "Input.Toggle"
        
        // Add title if present (required in UI)
        if let title = toggleInput.title {
            json["title"] = title
        }
        
        // Add value if present
        if let value = toggleInput.value {
            json["value"] = value
        }
        
        // Only add non-default properties
        if toggleInput.valueOff != "false" {
            json["valueOff"] = toggleInput.valueOff
        }
        
        if toggleInput.valueOn != "true" {
            json["valueOn"] = toggleInput.valueOn
        }
        
        if toggleInput.wrap {
            json["wrap"] = toggleInput.wrap
        }
        
        return json
    }
}

// MARK: - Parser Implementation

/// Parses ToggleInput elements in an Adaptive Card
struct SwiftToggleInputParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.toggleInput)
        return try SwiftToggleInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftToggleInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftToggleInputLegacySupport.deserialize(from: value)
    }
}

// MARK: - Consolidated SwiftDateInput Legacy Support

/// Unified legacy support for SwiftDateInput parsing and serialization
enum SwiftDateInputLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftDateInput
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftDateInput {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftDateInput.self, from: data)
    }
    
    /// Deserializes string into a SwiftDateInput
    static func deserialize(from jsonString: String) throws -> SwiftDateInput {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftDateInput.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftDateInput to JSON dictionary with proper formatting
    static func serializeToJson(_ dateInput: SwiftDateInput, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set type property
        json["type"] = "Input.Date"
        
        // Add properties if present
        if let max = dateInput.max {
            json["max"] = max
        }
        
        if let min = dateInput.min {
            json["min"] = min
        }
        
        if let placeholder = dateInput.placeholder {
            json["placeholder"] = placeholder
        }
        
        if let value = dateInput.value {
            json["value"] = value
        }
        
        return json
    }
}

// MARK: - Parser Implementation

/// Parses DateInput elements in an Adaptive Card
struct SwiftDateInputParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.dateInput)
        return try SwiftDateInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftDateInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftDateInputLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftDateInput Extension

internal extension SwiftDateInput {
    // MARK: - Known Properties
    
    // MARK: - Static Factory Methods
    
    /// Creates a SwiftDateInput from a JSON dictionary
    static func createFromJSON(_ json: [String: Any]) throws -> SwiftDateInput {
        return try SwiftDateInputLegacySupport.deserialize(from: json)
    }
    
    /// Creates a SwiftDateInput from a JSON string
    static func createFromJSONString(_ jsonString: String) throws -> SwiftDateInput {
        return try SwiftDateInputLegacySupport.deserialize(from: jsonString)
    }
}

// MARK: - Consolidated SwiftNumberInput Legacy Support

/// Unified legacy support for SwiftNumberInput parsing and serialization
enum SwiftNumberInputLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftNumberInput
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftNumberInput {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftNumberInput.self, from: data)
    }
    
    /// Deserializes string into a SwiftNumberInput
    static func deserialize(from jsonString: String) throws -> SwiftNumberInput {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftNumberInput.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftNumberInput to JSON dictionary with proper formatting
    static func serializeToJson(_ numberInput: SwiftNumberInput, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set type property
        json["type"] = "Input.Number"
        
        // Add properties if present
        if let placeholder = numberInput.placeholder {
            json["placeholder"] = placeholder
        }
        
        if let value = numberInput.value {
            json["value"] = value
        }
        
        if let min = numberInput.min {
            json["min"] = min
        }
        
        if let max = numberInput.max {
            json["max"] = max
        }
        
        return json
    }
    
    /// Converts the NumberInput object into a JSON string
    static func toJSONString(_ numberInput: SwiftNumberInput) -> String {
        do {
            let json = try serializeToJson(numberInput, baseJson: [:])
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            return String(data: data, encoding: .utf8) ?? "{}"
        } catch {
            return "{}"
        }
    }
}

// MARK: - Parser Implementation

/// Parses NumberInput elements in an Adaptive Card
struct SwiftNumberInputParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.numberInput)
        return try SwiftNumberInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftNumberInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftNumberInputLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftNumberInput Extension

internal extension SwiftNumberInput {
    // MARK: - Known Properties
    
    // MARK: - Serialization Helpers
    
    /// Returns a JSON string representation
    func toJSONString() -> String {
        return SwiftNumberInputLegacySupport.toJSONString(self)
    }
    
    // MARK: - Static Factory Methods
    
    /// Creates a NumberInput object from a JSON dictionary
    static func createFromJSON(_ json: [String: Any]) throws -> SwiftNumberInput {
        return try SwiftNumberInputLegacySupport.deserialize(from: json)
    }
    
    /// Creates a NumberInput object from a JSON string
    static func createFromJSONString(_ jsonString: String) throws -> SwiftNumberInput {
        return try SwiftNumberInputLegacySupport.deserialize(from: jsonString)
    }
}

// MARK: - Consolidated SwiftTextInput Legacy Support

/// Unified legacy support for SwiftTextInput parsing and serialization
enum SwiftTextInputLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftTextInput
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftTextInput {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        let textInput = try decoder.decode(SwiftTextInput.self, from: data)
        
        // Validate style and multiline settings if context is provided
        if let context = context, textInput.isMultiline && textInput.style == .password {
            context.warnings.append(
                SwiftAdaptiveCardParseWarning(
                    statusCode: .invalidValue,
                    message: "Input.Text ignores isMultiline when using password style."
                )
            )
        }
        
        return textInput
    }
    
    /// Deserializes string into a SwiftTextInput
    static func deserialize(from jsonString: String) throws -> SwiftTextInput {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftTextInput.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftTextInput to JSON dictionary with proper formatting
    static func serializeToJson(_ textInput: SwiftTextInput, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set type property
        json["type"] = "Input.Text"
        
        // Add properties if present
        if let placeholder = textInput.placeholder, !placeholder.isEmpty {
            json["placeholder"] = placeholder
        }
        
        if let value = textInput.value, !value.isEmpty {
            json["value"] = value
        }
        
        // The test specifically wants to see "isMultiline": true
        // so always write out the actual value of isMultiline:
        json["isMultiline"] = textInput.isMultiline
        
        // Only add non-default properties
        if textInput.maxLength > 0 {
            json["maxLength"] = textInput.maxLength
        }
        
        if let style = textInput.style {
            json["style"] = style.rawValue
        }
        
        if let regex = textInput.regex {
            json["regex"] = regex
        }
        
        // Add inlineAction if present
        if let action = textInput.inlineAction {
            json["inlineAction"] = try action.serializeToJsonValue()
        }
        
        return json
    }
    
    /// Converts to JSON dictionary for legacy compatibility
    static func toJSON(_ textInput: SwiftTextInput) -> [String: Any] {
        do {
            // Start with the base element's JSON
            var json = textInput.toBaseJSON()
            
            // Add TextInput-specific fields
            if let placeholder = textInput.placeholder, !placeholder.isEmpty {
                json["placeholder"] = placeholder
            }
            
            if let value = textInput.value, !value.isEmpty {
                json["value"] = value
            }
            
            // Always include isMultiline
            json["isMultiline"] = textInput.isMultiline
            
            // Add style if present
            if let style = textInput.style {
                json["style"] = style.rawValue
            }
            
            // Add maxLength if non-zero
            if textInput.maxLength > 0 {
                json["maxLength"] = textInput.maxLength
            }
            
            // Add regex if present
            if let regex = textInput.regex, !regex.isEmpty {
                json["regex"] = regex
            }
            
            // Add inlineAction if present
            if let action = textInput.inlineAction {
                json["inlineAction"] = try action.serializeToJsonValue()
            }
            
            return json
        } catch {
            // Return minimal valid JSON if serialization fails
            return ["type": "Input.Text"]
        }
    }
}

// MARK: - Parser Implementation

/// Parses TextInput elements in an Adaptive Card
struct SwiftTextInputParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.textInput)
        return try SwiftTextInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftTextInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftTextInputLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftTextInput Extension

internal extension SwiftTextInput {
    // Helper for legacy serialization
    func toBaseJSON() -> [String: Any] {
        do {
            return try super.serializeToJsonValue()
        } catch {
            return ["type": "Input.Text"]
        }
    }
}
