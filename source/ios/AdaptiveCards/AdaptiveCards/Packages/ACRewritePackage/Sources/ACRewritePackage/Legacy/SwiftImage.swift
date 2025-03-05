import Foundation

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
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case url
        case backgroundColor
        case imageStyle = "style"            // maps JSON "style" to imageStyle
        case imageSize = "size"              // maps JSON "size" to imageSize
        case pixelWidth, pixelHeight, altText
        case hAlignment = "horizontalAlignment"  // maps JSON "horizontalAlignment" to hAlignment
        case selectAction
        case width
        case height
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        
        // Decode and validate background color.
        let rawColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor) ?? ""
        var dummyWarnings = [SwiftAdaptiveCardParseWarning]()
        self.backgroundColor = validateColor(rawColor, warnings: &dummyWarnings)
        
        // Decode style and size.
        self.imageStyle = try container.decodeIfPresent(SwiftImageStyle.self, forKey: .imageStyle) ?? .defaultImageStyle
        self.imageSize = try container.decodeIfPresent(SwiftImageSize.self, forKey: .imageSize) ?? .none
        
        // Decode explicit pixel dimensions if present, default to zero.
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
        
        // Default spacing and height if not set.
        if self.height == nil {
            self.height = .auto
        }
        if self.spacing == nil {
            self.spacing = SwiftSpacing.none
        }
        
        // Parse explicit width/height strings, overriding pixel dimensions if needed.
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
        
        self.populateKnownPropertiesSet()
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
    
    // MARK: - Serialization to JSON
    /// Serializes the Image to a JSON dictionary.
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
}
