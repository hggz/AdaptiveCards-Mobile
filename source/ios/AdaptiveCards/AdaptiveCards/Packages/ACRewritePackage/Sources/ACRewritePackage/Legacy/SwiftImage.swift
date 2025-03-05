import Foundation

// MARK: - Image and ImageParser Implementation

/// Represents an image element in an Adaptive Card.
class SwiftImage: SwiftBaseCardElement {
    // MARK: - Properties
    var url: String
    var backgroundColor: String
    var imageStyle: SwiftImageStyle
    var imageSize: SwiftImageSize
    var pixelWidth: UInt
    var pixelHeight: UInt
    var altText: String
    var hAlignment: SwiftHorizontalAlignment?
    var selectAction: SwiftBaseActionElement?
    
    // MARK: - Initializer
    /// Default initializer.
    init(id: String? = nil) {
        self.url = ""
        self.backgroundColor = ""
        self.imageStyle = .defaultImageStyle
        self.imageSize = .none
        self.pixelWidth = 0
        self.pixelHeight = 0
        self.altText = ""
        self.hAlignment = nil
        self.selectAction = nil
        // Set default spacing to .none and height to .auto.
        super.init(
            type: .image,
            spacing: .none,
            height: .auto,
            targetWidth: nil,
            separator: nil,
            isVisible: true,
            areaGridName: nil,
            id: id
        )
        self.populateKnownPropertiesSet()
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case url
        case backgroundColor
        case imageStyle = "style"        // maps JSON "style" to imageStyle
        case imageSize = "size"            // maps JSON "size" to imageSize
        case pixelWidth, pixelHeight, altText
        case hAlignment = "horizontalAlignment" // maps JSON "horizontalAlignment" to hAlignment
        case selectAction
        case width    // new key for explicit width string
        case height   // new key for explicit height string
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        
        // Decode backgroundColor and validate it.
        let rawColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor) ?? ""
        var dummyWarnings = [SwiftAdaptiveCardParseWarning]()
        self.backgroundColor = validateColor(rawColor, warnings: &dummyWarnings)
        
        // Decode style and size.
        self.imageStyle = try container.decodeIfPresent(SwiftImageStyle.self, forKey: .imageStyle) ?? .defaultImageStyle
        self.imageSize = try container.decodeIfPresent(SwiftImageSize.self, forKey: .imageSize) ?? .none
        
        // These keys might not be present in our JSON so we default to zero.
        self.pixelWidth = try container.decodeIfPresent(UInt.self, forKey: .pixelWidth) ?? 0
        self.pixelHeight = try container.decodeIfPresent(UInt.self, forKey: .pixelHeight) ?? 0
        self.altText = try container.decodeIfPresent(String.self, forKey: .altText) ?? ""
        self.hAlignment = try container.decodeIfPresent(SwiftHorizontalAlignment.self, forKey: .hAlignment)
        
        // Decode selectAction if present.
        if container.contains(.selectAction) {
            let actionDict = try container.decode([String: AnyCodable].self, forKey: .selectAction)
            let dict = actionDict.mapValues { $0.value }
            self.selectAction = try SwiftBaseActionElement.deserializeAction(from: dict)
        } else {
            self.selectAction = nil
        }
        
        try super.init(from: decoder)
        
        if self.height == nil {
            self.height = .auto
        }
        if self.spacing == nil {
            self.spacing = .none
        }
        
        // Parse explicit dimension strings and collect warnings
        if let widthString = try? container.decode(String.self, forKey: .width) {
            var warnings = [SwiftAdaptiveCardParseWarning]()
            if let parsedWidth = parseSizeForPixelSize(widthString, warnings: &warnings) {
                self.pixelWidth = parsedWidth
            }
            SwiftWarningCollector.add(warnings)
        }
        if let heightString = try? container.decode(String.self, forKey: .height) {
            var warnings = [SwiftAdaptiveCardParseWarning]()
            if let parsedHeight = parseSizeForPixelSize(heightString, warnings: &warnings) {
                self.pixelHeight = parsedHeight
            }
            SwiftWarningCollector.add(warnings)
        }
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try container.encode(imageStyle, forKey: .imageStyle)
        try container.encode(imageSize, forKey: .imageSize)
        try container.encode(pixelWidth, forKey: .pixelWidth)
        try container.encode(pixelHeight, forKey: .pixelHeight)
        try container.encode(altText, forKey: .altText)
        try container.encodeIfPresent(hAlignment, forKey: .hAlignment)
        
        if let action = selectAction {
            try container.encode(AnyCodable(try SwiftBaseCardElement.serializeSelectAction(action)), forKey: .selectAction)
        }
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization
    /// Serializes the Image to a JSON dictionary.
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        json["type"] = "Image"
        json["url"] = url
        
        // Use "style" for imageStyle.
        json["style"] = imageStyle.rawValue
        // Use "size" for imageSize (converted to lowercase).
        json["size"] = imageSize.rawValue.lowercased()
        
        if let alignment = hAlignment {
            json["horizontalAlignment"] = alignment.rawValue.lowercased()
        }
        
        if !backgroundColor.isEmpty {
            json["backgroundColor"] = backgroundColor
        }
        
        if !altText.isEmpty {
            json["altText"] = altText
        }
        
        if let action = selectAction {
            json["selectAction"] = try SwiftBaseCardElement.serializeSelectAction(action)
        }
        
        if let spacing = spacing {
            json["spacing"] = spacing.rawValue.lowercased()
        }
        
        if let separator = separator {
            json["separator"] = separator
        }
        
        return json
    }
    
    // MARK: - Getters and Setters (if needed)
    func getUrl() -> String {
        return url
    }
    
    func setUrl(_ value: String) {
        self.url = value
    }
    
    func getBackgroundColor() -> String {
        return backgroundColor
    }
    
    func setBackgroundColor(_ value: String) {
        self.backgroundColor = value
    }
    
    func getImageStyle() -> SwiftImageStyle {
        return imageStyle
    }
    
    func setImageStyle(_ value: SwiftImageStyle) {
        self.imageStyle = value
    }
    
    func getImageSize() -> SwiftImageSize {
        return imageSize
    }
    
    func setImageSize(_ value: SwiftImageSize) {
        self.imageSize = value
    }
    
    func getAltText() -> String {
        return altText
    }
    
    func setAltText(_ value: String) {
        self.altText = value
    }
    
    func getHorizontalAlignment() -> SwiftHorizontalAlignment? {
        return hAlignment
    }
    
    func setHorizontalAlignment(_ value: SwiftHorizontalAlignment?) {
        self.hAlignment = value
    }
    
    func getSelectAction() -> SwiftBaseActionElement? {
        return selectAction
    }
    
    func setSelectAction(_ action: SwiftBaseActionElement?) {
        self.selectAction = action
    }
    
    func getPixelWidth() -> UInt {
        return pixelWidth
    }
    
    func setPixelWidth(_ value: UInt) {
        self.pixelWidth = value
    }
    
    func getPixelHeight() -> UInt {
        return pixelHeight
    }
    
    func setPixelHeight(_ value: UInt) {
        self.pixelHeight = value
    }
    
    // MARK: - Known Properties
    private func populateKnownPropertiesSet() {
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

/// Parses Image elements in an Adaptive Card.
struct SwiftImageParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        // Ensure the type is Image.
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.image)
        
        // Deserialize without checking type.
        return try deserializeWithoutCheckingType(context: context, value: value)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        // Use the generic deserialization helper to get an Image instance.
        let image: SwiftImage = try SwiftBaseCardElement.deserialize(from: value) as! SwiftImage
        
        // Populate properties.
        image.setUrl(try SwiftParseUtil.getString(from: value, key: "url", required: true))
        image.setBackgroundColor(validateColor(try SwiftParseUtil.getString(from: value, key: "backgroundColor"), warnings: &context.warnings))
        image.setImageStyle(try SwiftParseUtil.getEnumValue(from: value, key: "style", defaultValue: .defaultImageStyle, converter: SwiftImageStyle.fromString))
        image.setAltText(try SwiftParseUtil.getString(from: value, key: "altText"))
        image.setHorizontalAlignment(try SwiftParseUtil.getOptionalEnumValue(from: value, key: "horizontalAlignment", converter: SwiftHorizontalAlignment.fromString))
        
        // Parse width independently using the raw JSON dictionary.
        if let widthStr = value["width"] as? String {
            if let widthDim = parseSizeForPixelSize(widthStr, warnings: &context.warnings) {
                image.setPixelWidth(widthDim)
            }
        }
        // Parse height independently using the raw JSON dictionary.
        if let heightStr = value["height"] as? String {
            if let heightDim = parseSizeForPixelSize(heightStr, warnings: &context.warnings) {
                image.setPixelHeight(heightDim)
            }
        }
        // Only if neither valid width nor height was provided do we fallback to using the "size" enum.
        if image.getPixelWidth() == 0 && image.getPixelHeight() == 0 {
            image.setImageSize(try SwiftParseUtil.getEnumValue(from: value, key: "size", defaultValue: .none, converter: SwiftImageSize.fromString))
        }
        
        image.setSelectAction(try SwiftParseUtil.getAction(from: value, key: "selectAction", context: context))
        
        return image
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        let jsonDict = try SwiftParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
