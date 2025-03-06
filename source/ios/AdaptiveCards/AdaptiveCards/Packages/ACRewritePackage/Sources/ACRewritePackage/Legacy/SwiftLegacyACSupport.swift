import Foundation

// MARK: - Consolidated SwiftImage Legacy Support

/// Unified legacy support for SwiftImage parsing and serialization
enum SwiftImageLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftImage
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftImage {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftImage.self, from: data)
    }
    
    /// Deserializes string into a SwiftImage
    static func deserialize(from jsonString: String) throws -> SwiftImage {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftImage.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftImage to JSON dictionary with proper formatting
    static func serializeToJson(_ image: SwiftImage, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set required properties
        json["type"] = "Image"
        json["url"] = image.url
        
        // Format style properties
        json["style"] = image.imageStyle.rawValue
        json["size"] = image.imageSize.rawValue.lowercased()
        
        // Add optional properties
        if let alignment = image.hAlignment {
            json["horizontalAlignment"] = alignment.rawValue.lowercased()
        }
        
        // Only add non-empty strings
        if !image.backgroundColor.isEmpty {
            json["backgroundColor"] = image.backgroundColor
        }
        
        if !image.altText.isEmpty {
            json["altText"] = image.altText
        }
        
        // Add action if present
        if let action = image.selectAction {
            json["selectAction"] = try SwiftBaseCardElement.serializeSelectAction(action)
        }
        
        // Format layout properties
        if let spacing = image.spacing {
            json["spacing"] = spacing.rawValue.lowercased()
        }
        
        if let separator = image.separator {
            json["separator"] = separator
        }
        
        return json
    }
}

// MARK: - Parser Implementation

/// Parses Image elements in an Adaptive Card
struct SwiftImageParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.image)
        return try SwiftImageLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftImageLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftImageLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftImage Extension

internal extension SwiftImage {
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        return try SwiftImageLegacySupport.serializeToJson(self, baseJson: superResult)
    }
    
    // MARK: - Known Properties
    func populateKnownPropertiesSet() {
        self.knownProperties.insert("altText")
        self.knownProperties.insert("backgroundColor")
        self.knownProperties.insert("height")
        self.knownProperties.insert("horizontalAlignment")
        self.knownProperties.insert("selectAction")
        self.knownProperties.insert("size")
        self.knownProperties.insert("style")
        self.knownProperties.insert("url")
        self.knownProperties.insert("width")
    }
    
    // MARK: - Resource Information
    func getResourceInformation(_ resourceInfo: inout [SwiftRemoteResourceInformation]) {
        let info = SwiftRemoteResourceInformation(url: self.url, mimeType: "image")
        resourceInfo.append(info)
    }
}

// MARK: - Consolidated SwiftIcon Legacy Support

/// Unified legacy support for SwiftIcon parsing and serialization
enum SwiftIconLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftIcon
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftIcon {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftIcon.self, from: data)
    }
    
    /// Deserializes string into a SwiftIcon
    static func deserialize(from jsonString: String) throws -> SwiftIcon {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftIcon.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftIcon to JSON dictionary with proper formatting
    static func serializeToJson(_ icon: SwiftIcon, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set type property
        json["type"] = "Icon"
        
        // Add icon name if present
        if let name = icon.name {
            json["name"] = name
        }
        
        // Only add non-default properties
        if icon.foregroundColor != .default {
            json["color"] = icon.foregroundColor.rawValue
        }
        
        if icon.iconSize != .standard {
            json["size"] = icon.iconSize.rawValue
        }
        
        if icon.iconStyle != .regular {
            json["style"] = icon.iconStyle.rawValue
        }
        
        // Add selectAction if present
        if let action = icon.selectAction {
            json["selectAction"] = try SwiftBaseCardElement.serializeSelectAction(action)
        }
        
        return json
    }
}

// MARK: - Parser Implementation

/// Parses Icon elements in an Adaptive Card
struct SwiftIconParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.icon)
        return try SwiftIconLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftIconLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftIconLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftIcon Extension

internal extension SwiftIcon {
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        return try SwiftIconLegacySupport.serializeToJson(self, baseJson: superResult)
    }
    
    // MARK: - Known Properties
    func populateKnownPropertiesSet() {
        self.knownProperties.insert("name")
        self.knownProperties.insert("color")
        self.knownProperties.insert("size")
        self.knownProperties.insert("style")
        self.knownProperties.insert("selectAction")
    }
}

enum SwiftIconInfoLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftIconInfo
    static func deserialize(from value: [String: Any]) throws -> SwiftIconInfo {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftIconInfo.self, from: data)
    }
    
    /// Deserializes string into a SwiftIconInfo
    static func deserialize(from jsonString: String) throws -> SwiftIconInfo {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftIconInfo.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftIconInfo to JSON dictionary with proper formatting
    static func serializeToJson(_ iconInfo: SwiftIconInfo) throws -> [String: Any] {
        var json: [String: Any] = [:]
        
        // Only add non-default properties
        if iconInfo.iconSize != .standard {
            json["size"] = iconInfo.iconSize.rawValue
        }
        
        if iconInfo.iconStyle != .regular {
            json["style"] = iconInfo.iconStyle.rawValue
        }
        
        if iconInfo.foregroundColor != .default {
            json["color"] = iconInfo.foregroundColor.rawValue
        }
        
        if let name = iconInfo.name {
            json["name"] = name
        }
        
        return json
    }
    
    /// Converts to JSON string
    static func serializeToJsonString(_ iconInfo: SwiftIconInfo) throws -> String {
        let json = try serializeToJson(iconInfo)
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw EncodingError.invalidValue(json, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert JSON to string"))
        }
        return jsonString
    }
}

// MARK: - SwiftIconInfo Extension

extension SwiftIconInfo {
    // Serialization to JSON
    func toJSON() -> [String: Any] {
        (try? SwiftIconInfoLegacySupport.serializeToJson(self)) ?? [:]
    }
    
    func toJSONString() -> String {
        (try? SwiftIconInfoLegacySupport.serializeToJsonString(self)) ?? "{}"
    }
    
    // Static factory methods
    static func fromJSON(_ json: [String: Any]) -> SwiftIconInfo? {
        guard !json.isEmpty else { return nil }
        return try? SwiftIconInfoLegacySupport.deserialize(from: json)
    }
    
    static func fromJSONString(_ jsonString: String) -> SwiftIconInfo? {
        return try? SwiftIconInfoLegacySupport.deserialize(from: jsonString)
    }
}

// MARK: - Consolidated SwiftUnknownElement Legacy Support

/// Unified legacy support for SwiftUnknownElement parsing and serialization
enum SwiftUnknownElementLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftUnknownElement
    static func deserialize(from value: [String: Any]) throws -> SwiftUnknownElement {
        guard let typeString = value["type"] as? String else {
            throw AdaptiveCardParseError.invalidType
        }
        
        // Include all properties
        let properties = value.mapValues { AnyCodable($0) }
        
        return SwiftUnknownElement(elementType: typeString, additionalProperties: properties)
    }
    
    /// Deserializes string into a SwiftUnknownElement
    static func deserialize(from jsonString: String) throws -> SwiftUnknownElement {
        let json = try SwiftParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(from: json)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftUnknownElement to JSON dictionary
    static func serializeToJson(_ element: SwiftUnknownElement) throws -> [String: Any] {
        return element.additionalProperties?.mapValues { $0.value } ?? [:]
    }
    
    /// Converts to JSON string
    static func serializeToJsonString(_ element: SwiftUnknownElement) throws -> String {
        let json = try serializeToJson(element)
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw EncodingError.invalidValue(json, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert JSON to string"))
        }
        return jsonString
    }
}

// MARK: - Parser Implementation

/// Parses unknown elements in an Adaptive Card
struct SwiftUnknownElementParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftUnknownElementLegacySupport.deserialize(from: value)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftUnknownElementLegacySupport.deserialize(from: value)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftUnknownElementLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftUnknownElement Extension

extension SwiftUnknownElement {
    // Static factory methods
    static func createFromJSON(_ json: [String: Any]) throws -> SwiftUnknownElement {
        return try SwiftUnknownElementLegacySupport.deserialize(from: json)
    }
}

// MARK: - Consolidated SwiftAuthentication Legacy Support

/// Unified legacy support for SwiftAuthentication parsing and serialization
enum SwiftAuthenticationLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftAuthentication
    static func deserialize(from json: [String: Any]) throws -> SwiftAuthentication {
        return SwiftAuthentication(
            text: json["text"] as? String ?? "",
            connectionName: json["connectionName"] as? String ?? "",
            tokenExchangeResource: try (json["tokenExchangeResource"] as? [String: Any]).flatMap {
                try SwiftTokenExchangeResource.deserialize(from: $0)
            },
            buttons: (json["buttons"] as? [[String: Any]])?.compactMap {
                SwiftAuthCardButton.deserialize(from: $0)
            } ?? []
        )
    }
    
    /// Deserializes string into a SwiftAuthentication
    static func deserialize(from jsonString: String) -> SwiftAuthentication? {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            return nil
        }
        return try? deserialize(from: jsonDict)
    }
    
    // MARK: - Serialization Functions
    
    /// Serializes a SwiftAuthentication to JSON string
    static func serialize(_ authentication: SwiftAuthentication) -> String {
        let jsonData = try? JSONEncoder().encode(authentication)
        return jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }
    
    /// Converts a SwiftAuthentication to JSON dictionary
    static func serializeToJson(_ authentication: SwiftAuthentication) throws -> [String: Any] {
        return try authentication.serializeToJsonValue()
    }
    
    /// Converts to JSON string with pretty printing
    static func serializeToJsonString(_ authentication: SwiftAuthentication) throws -> String {
        let json = try serializeToJson(authentication)
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw EncodingError.invalidValue(json, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert JSON to string"))
        }
        return jsonString
    }
}

// MARK: - SwiftAuthentication Extension

extension SwiftAuthentication {
    // Serialization helpers
    func serialize() -> String {
        return SwiftAuthenticationLegacySupport.serialize(self)
    }
    
    func toJSON() throws -> [String: Any] {
        return try SwiftAuthenticationLegacySupport.serializeToJson(self)
    }
    
    func toJSONString() throws -> String {
        return try SwiftAuthenticationLegacySupport.serializeToJsonString(self)
    }
    
    // Static factory methods
    static func deserialize(from json: [String: Any]) throws -> SwiftAuthentication {
        return try SwiftAuthenticationLegacySupport.deserialize(from: json)
    }
    
    static func deserialize(from jsonString: String) -> SwiftAuthentication? {
        return SwiftAuthenticationLegacySupport.deserialize(from: jsonString)
    }
    
    static func fromJSON(_ json: [String: Any]) -> SwiftAuthentication? {
        return try? SwiftAuthenticationLegacySupport.deserialize(from: json)
    }
    
    static func fromJSONString(_ jsonString: String) -> SwiftAuthentication? {
        return SwiftAuthenticationLegacySupport.deserialize(from: jsonString)
    }
    
    func serializeToJsonValue() throws -> [String: Any] {
        var json: [String: Any] = [:]
        
        if !text.isEmpty {
            json["text"] = text
        }
        if !connectionName.isEmpty {
            json["connectionName"] = connectionName
        }
        if let tokenExchangeResource = tokenExchangeResource, tokenExchangeResource.shouldSerialize {
            json["tokenExchangeResource"] = try tokenExchangeResource.serializeToJsonValue()
        }
        if !buttons.isEmpty {
            json["buttons"] = buttons.map { $0.serializeToJsonValue() }
        }
        
        return json
    }
    
    func shouldSerialize() -> Bool {
        return !text.isEmpty ||
               !connectionName.isEmpty ||
               !buttons.isEmpty ||
               (tokenExchangeResource?.shouldSerialize ?? false)
    }
}

// MARK: - Consolidated SwiftAuthCardButton Legacy Support

/// Unified legacy support for SwiftAuthCardButton parsing and serialization
enum SwiftAuthCardButtonLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftAuthCardButton
    static func deserialize(from json: [String: Any]) -> SwiftAuthCardButton {
        return SwiftAuthCardButton(
            type: json["type"] as? String ?? "",
            title: json["title"] as? String ?? "",
            image: json["image"] as? String ?? "",
            value: json["value"] as? String ?? ""
        )
    }
    
    /// Deserializes string into a SwiftAuthCardButton
    static func deserialize(from jsonString: String) -> SwiftAuthCardButton? {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            return nil
        }
        return deserialize(from: jsonDict)
    }
    
    // MARK: - Serialization Functions
    
    /// Serializes a SwiftAuthCardButton to JSON string
    static func serialize(_ button: SwiftAuthCardButton) -> String {
        let jsonData = try? JSONEncoder().encode(button)
        return jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }
    
    /// Converts a SwiftAuthCardButton to JSON dictionary
    static func serializeToJson(_ button: SwiftAuthCardButton) -> [String: Any] {
        var json: [String: Any] = [:]
        
        if !button.type.isEmpty {
            json["type"] = button.type
        }
        if !button.title.isEmpty {
            json["title"] = button.title
        }
        if !button.image.isEmpty {
            json["image"] = button.image
        }
        if !button.value.isEmpty {
            json["value"] = button.value
        }
        
        return json
    }
    
    /// Converts to JSON string with pretty printing
    static func serializeToJsonString(_ button: SwiftAuthCardButton) throws -> String {
        let json = serializeToJson(button)
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw EncodingError.invalidValue(json, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert JSON to string"))
        }
        return jsonString
    }
}

// MARK: - SwiftAuthCardButton Extension

extension SwiftAuthCardButton {
    // Serialization helpers
    func serialize() -> String {
        return SwiftAuthCardButtonLegacySupport.serialize(self)
    }
    
    func serializeToJsonValue() -> [String: Any] {
        return SwiftAuthCardButtonLegacySupport.serializeToJson(self)
    }
    
    func toJSON() -> [String: Any] {
        return SwiftAuthCardButtonLegacySupport.serializeToJson(self)
    }
    
    func toJSONString() throws -> String {
        return try SwiftAuthCardButtonLegacySupport.serializeToJsonString(self)
    }
    
    // Validation
    func shouldSerialize() -> Bool {
        return !type.isEmpty || !title.isEmpty || !image.isEmpty || !value.isEmpty
    }
    
    // Static factory methods
    static func deserialize(from json: [String: Any]) -> SwiftAuthCardButton {
        return SwiftAuthCardButtonLegacySupport.deserialize(from: json)
    }
    
    static func deserialize(from jsonString: String) -> SwiftAuthCardButton? {
        return SwiftAuthCardButtonLegacySupport.deserialize(from: jsonString)
    }
    
    static func fromJSON(_ json: [String: Any]) -> SwiftAuthCardButton {
        return SwiftAuthCardButtonLegacySupport.deserialize(from: json)
    }
    
    static func fromJSONString(_ jsonString: String) -> SwiftAuthCardButton? {
        return SwiftAuthCardButtonLegacySupport.deserialize(from: jsonString)
    }
}

// MARK: - Consolidated SwiftLayout Legacy Support

/// Unified legacy support for SwiftLayout parsing and serialization
enum SwiftLayoutLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON data into a SwiftLayout
    static func deserialize(from json: Data) throws -> SwiftLayout {
        return try JSONDecoder().decode(SwiftLayout.self, from: json)
    }
    
    /// Deserializes JSON dictionary into a SwiftLayout
    static func deserialize(from json: [String: Any]) -> SwiftLayout? {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return nil
        }
        return try? deserialize(from: data)
    }
    
    /// Deserializes string into a SwiftLayout
    static func deserializeFromString(_ jsonString: String) throws -> SwiftLayout {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON string", code: -1, userInfo: nil)
        }
        return try deserialize(from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Serializes a SwiftLayout to JSON string
    static func serialize(_ layout: SwiftLayout) throws -> String {
        let jsonData = try JSONEncoder().encode(layout)
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }
    
    /// Converts a SwiftLayout to JSON dictionary
    static func serializeToJson(_ layout: SwiftLayout) -> [String: Any] {
        return layout.serializeToJsonValue()
    }
    
    /// Converts to JSON string with pretty printing
    static func serializeToJsonString(_ layout: SwiftLayout) throws -> String {
        let json = serializeToJson(layout)
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw EncodingError.invalidValue(json, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert JSON to string"))
        }
        return jsonString
    }
}

// MARK: - SwiftLayout Extension

extension SwiftLayout {
    // Static factory methods
    static func deserialize(from json: Data) throws -> SwiftLayout {
        return try SwiftLayoutLegacySupport.deserialize(from: json)
    }
    
    static func deserializeFromString(_ jsonString: String) throws -> SwiftLayout {
        return try SwiftLayoutLegacySupport.deserializeFromString(jsonString)
    }
    
    static func fromJSON(_ json: [String: Any]) -> SwiftLayout? {
        return SwiftLayoutLegacySupport.deserialize(from: json)
    }
    
    static func fromJSONString(_ jsonString: String) -> SwiftLayout? {
        return try? SwiftLayoutLegacySupport.deserializeFromString(jsonString)
    }
    
    // JSON conversion utilities
    func serialize() throws -> String {
        return try SwiftLayoutLegacySupport.serialize(self)
    }
    
    func toJSON() -> [String: Any] {
        return SwiftLayoutLegacySupport.serializeToJson(self)
    }
    
    func toJSONString() throws -> String {
        return try SwiftLayoutLegacySupport.serializeToJsonString(self)
    }
    
    // MARK: - Validation Methods
    /// Determines if this layout should be serialized
    func shouldSerialize() -> Bool {
        return true
    }
    
    /// Checks if the layout meets the target width requirement
    func meetsTargetWidthRequirement(hostWidth: SwiftHostWidth) -> Bool {
        if targetWidth == .default || hostWidth == .default {
            return true
        }

        switch targetWidth {
        case .wide:
            return hostWidth == .wide
        case .standard:
            return hostWidth == .standard
        case .narrow:
            return hostWidth == .narrow
        case .veryNarrow:
            return hostWidth == .veryNarrow
        case .atLeastWide:
            return hostWidth >= .wide
        case .atLeastStandard:
            return hostWidth >= .standard
        case .atLeastNarrow:
            return hostWidth >= .narrow
        case .atLeastVeryNarrow:
            return hostWidth >= .veryNarrow
        case .atMostWide:
            return hostWidth <= .wide
        case .atMostStandard:
            return hostWidth <= .standard
        case .atMostNarrow:
            return hostWidth <= .narrow
        case .atMostVeryNarrow:
            return hostWidth <= .veryNarrow
        default:
            return true
        }
    }
    
    // MARK: - Serialization to JSON
    /// Serializes to JSON dictionary
    func serializeToJsonValue() -> [String: Any] {
        var json: [String: Any] = [:]

        if targetWidth != .default {
            json["targetWidth"] = targetWidth.rawValue
        }

        if layoutContainerType != .stack {
            json["layout"] = layoutContainerType.rawValue
        }

        return json
    }
    
    convenience init(fromFlowLayout flow: SwiftFlowLayout) {
        self.init()
        self.layoutContainerType = .flow
        // Copy additional properties from flow if needed.
    }
    
    /// Conversion initializer to create a generic Layout from an AreaGridLayout.
    convenience init(fromAreaGridLayout areaGrid: SwiftAreaGridLayout) {
        self.init()
        self.layoutContainerType = .areaGrid
        // Copy additional properties from areaGrid if needed.
    }
}

// MARK: - Consolidated SwiftAreaGridLayout Legacy Support

/// Unified legacy support for SwiftAreaGridLayout parsing and serialization
enum SwiftAreaGridLayoutLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftAreaGridLayout
    static func deserialize(from json: [String: Any]) -> SwiftAreaGridLayout {
        let instance = SwiftAreaGridLayout()
        
        if let columnArray = json["columns"] as? [String] {
            instance.columns = columnArray
        }
        
        if let areaArray = json["areas"] as? [[String: Any]] {
            instance.areas = areaArray.map { SwiftGridArea.deserialize(from: $0) }
        }
        
        if let rowSpacingStr = json["rowSpacing"] as? String,
           let spacingEnum = SwiftSpacing(rawValue: rowSpacingStr) {
            instance.rowSpacing = spacingEnum
        }
        
        if let columnSpacingStr = json["columnSpacing"] as? String,
           let spacingEnum = SwiftSpacing(rawValue: columnSpacingStr) {
            instance.columnSpacing = spacingEnum
        }
        
        // Set the layout container type
        instance.layoutContainerType = .areaGrid
        
        // Handle parent class properties from the base class
        if let targetWidthStr = json["targetWidth"] as? String,
           let targetWidthEnum = SwiftTargetWidthType(rawValue: targetWidthStr) {
            instance.targetWidth = targetWidthEnum
        }
        
        return instance
    }
    
    /// Deserializes string into a SwiftAreaGridLayout
    static func deserialize(from jsonString: String) -> SwiftAreaGridLayout? {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            return nil
        }
        return deserialize(from: jsonDict)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftAreaGridLayout to JSON dictionary
    static func serializeToJson(_ layout: SwiftAreaGridLayout) -> [String: Any] {
        return layout.serializeToJson()
    }
    
    /// Converts to JSON string with pretty printing
    static func serializeToJsonString(_ layout: SwiftAreaGridLayout) throws -> String {
        let json = serializeToJson(layout)
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw EncodingError.invalidValue(json, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert JSON to string"))
        }
        return jsonString
    }
}

// MARK: - SwiftAreaGridLayout Extension

extension SwiftAreaGridLayout {
    // Static factory methods
    class func deserialize(from json: [String: Any]) -> SwiftAreaGridLayout {
        return SwiftAreaGridLayoutLegacySupport.deserialize(from: json)
    }
    
    static func deserialize(from jsonString: String) -> SwiftAreaGridLayout? {
        return SwiftAreaGridLayoutLegacySupport.deserialize(from: jsonString)
    }
    
    // MARK: - Serialization to JSON
    func serializeToJson() -> [String: Any] {
        var json = super.serializeToJsonValue()
        
        if !areas.isEmpty {
            json["areas"] = areas.map { $0.serializeToJson() }
        }
        if !columns.isEmpty {
            json["columns"] = columns
        }
        if rowSpacing != .default {
            json["rowSpacing"] = rowSpacing.rawValue
        }
        if columnSpacing != .default {
            json["columnSpacing"] = columnSpacing.rawValue
        }
        
        return json
    }
}
