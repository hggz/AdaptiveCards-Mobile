import Foundation

// MARK: - Image and ImageParser Implementation

/// Represents an image element in an Adaptive Card.
class Image: BaseCardElement {
    // MARK: - Properties
    var url: String
    var backgroundColor: String
    var imageStyle: ImageStyle
    var imageSize: ImageSize
    var pixelWidth: UInt
    var pixelHeight: UInt
    var altText: String
    var hAlignment: HorizontalAlignment?
    var selectAction: BaseActionElement?
    
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
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        
        // Decode backgroundColor and validate it.
        let rawColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor) ?? ""
        var dummyWarnings = [AdaptiveCardParseWarning]()
        self.backgroundColor = validateColor(rawColor, warnings: &dummyWarnings)
        
        // Decode style and size using our custom enum decoders.
        self.imageStyle = try container.decodeIfPresent(ImageStyle.self, forKey: .imageStyle) ?? .defaultImageStyle
        self.imageSize = try container.decodeIfPresent(ImageSize.self, forKey: .imageSize) ?? .none
        
        self.pixelWidth = try container.decodeIfPresent(UInt.self, forKey: .pixelWidth) ?? 0
        self.pixelHeight = try container.decodeIfPresent(UInt.self, forKey: .pixelHeight) ?? 0
        self.altText = try container.decodeIfPresent(String.self, forKey: .altText) ?? ""
        self.hAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .hAlignment)
        
        // Manually decode selectAction using your custom action parser.
        if container.contains(.selectAction) {
            let actionDict = try container.decode([String: AnyCodable].self, forKey: .selectAction)
            let dict = actionDict.mapValues { $0.value }
            self.selectAction = try BaseActionElement.deserializeAction(from: dict)
        } else {
            self.selectAction = nil
        }
        
        try super.init(from: decoder)
        
        // Ensure defaults if not provided.
        if self.height == nil {
            self.height = .auto
        }
        if self.spacing == nil {
            self.spacing = .none
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
            try container.encode(AnyCodable(try BaseCardElement.serializeSelectAction(action)), forKey: .selectAction)
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
            json["selectAction"] = try BaseCardElement.serializeSelectAction(action)
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
    
    func getImageStyle() -> ImageStyle {
        return imageStyle
    }
    
    func setImageStyle(_ value: ImageStyle) {
        self.imageStyle = value
    }
    
    func getImageSize() -> ImageSize {
        return imageSize
    }
    
    func setImageSize(_ value: ImageSize) {
        self.imageSize = value
    }
    
    func getAltText() -> String {
        return altText
    }
    
    func setAltText(_ value: String) {
        self.altText = value
    }
    
    func getHorizontalAlignment() -> HorizontalAlignment? {
        return hAlignment
    }
    
    func setHorizontalAlignment(_ value: HorizontalAlignment?) {
        self.hAlignment = value
    }
    
    func getSelectAction() -> BaseActionElement? {
        return selectAction
    }
    
    func setSelectAction(_ action: BaseActionElement?) {
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
    func getResourceInformation(_ resourceInfo: inout [RemoteResourceInformation]) {
        let info = RemoteResourceInformation(url: self.url, mimeType: "image")
        resourceInfo.append(info)
    }
}

/// Parses Image elements in an Adaptive Card.
struct ImageParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        // Ensure the type is Image.
        try ParseUtil.expectTypeString(value, expected: CardElementType.image)
        
        // Deserialize without checking type.
        return try deserializeWithoutCheckingType(context: context, value: value)
    }
    
    func deserializeWithoutCheckingType(context: ParseContext, value: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        // Use the generic deserialization helper to get an Image instance.
        let image: Image = try BaseCardElement.deserialize(from: value) as! Image
        
        // Populate properties.
        image.setUrl(try ParseUtil.getString(from: value, key: "url", required: true))
        image.setBackgroundColor(validateColor(try ParseUtil.getString(from: value, key: "backgroundColor"), warnings: &context.warnings))
        image.setImageStyle(try ParseUtil.getEnumValue(from: value, key: "style", defaultValue: .defaultImageStyle, converter: ImageStyle.fromString))
        image.setAltText(try ParseUtil.getString(from: value, key: "altText"))
        image.setHorizontalAlignment(try ParseUtil.getOptionalEnumValue(from: value, key: "horizontalAlignment", converter: HorizontalAlignment.fromString))
        
        let widthDimension = parseSizeForPixelSize(try ParseUtil.getString(from: value, key: "width"), warnings: &context.warnings)
        let heightDimension = parseSizeForPixelSize(try ParseUtil.getString(from: value, key: "height"), warnings: &context.warnings)
        
        if let widthDim = widthDimension, let heightDim = heightDimension {
            image.setPixelWidth(UInt(widthDim))
            image.setPixelHeight(UInt(heightDim))
        }
        else {
            image.setImageSize(try ParseUtil.getEnumValue(from: value, key: "size", defaultValue: .none, converter: ImageSize.fromString))
        }
        
        image.setSelectAction(try ParseUtil.getAction(from: value, key: "selectAction", context: context))
        
        return image
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> any AdaptiveCardElementProtocol {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
