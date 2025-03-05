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
