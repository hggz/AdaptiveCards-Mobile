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
