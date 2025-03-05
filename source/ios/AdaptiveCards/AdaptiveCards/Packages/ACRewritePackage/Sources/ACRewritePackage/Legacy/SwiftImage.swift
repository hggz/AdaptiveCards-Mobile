import Foundation

/// Represents an image element in an Adaptive Card.
class SwiftImage: SwiftBaseCardElement {
    // MARK: - Properties
    let url: String
    let backgroundColor: String
    let imageStyle: SwiftImageStyle
    let imageSize: SwiftImageSize
    var pixelWidth: UInt
    let pixelHeight: UInt
    let altText: String
    let hAlignment: SwiftHorizontalAlignment?
    let selectAction: SwiftBaseActionElement?
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case url
        case backgroundColor
        case imageStyle = "style"
        case imageSize = "size"
        case pixelWidth, pixelHeight, altText
        case hAlignment = "horizontalAlignment"
        case selectAction
        case width
        case height
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode required properties
        url = try container.decode(String.self, forKey: .url)
        
        // Decode and validate background color
        let rawColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor) ?? ""
        var dummyWarnings = [SwiftAdaptiveCardParseWarning]()
        backgroundColor = validateColor(rawColor, warnings: &dummyWarnings)
        
        // Decode style and size
        imageStyle = try container.decodeIfPresent(SwiftImageStyle.self, forKey: .imageStyle) ?? .defaultImageStyle
        imageSize = try container.decodeIfPresent(SwiftImageSize.self, forKey: .imageSize) ?? .none
        
        // Decode altText and hAlignment
        altText = try container.decodeIfPresent(String.self, forKey: .altText) ?? ""
        hAlignment = try container.decodeIfPresent(SwiftHorizontalAlignment.self, forKey: .hAlignment)
        
        // Handle pixel dimensions including string parsing (before super.init)
        var tempPixelWidth = try container.decodeIfPresent(UInt.self, forKey: .pixelWidth) ?? 0
        var tempPixelHeight = try container.decodeIfPresent(UInt.self, forKey: .pixelHeight) ?? 0
        
        // Parse explicit width/height strings
        if let widthString = try? container.decode(String.self, forKey: .width) {
            var warnings = [SwiftAdaptiveCardParseWarning]()
            if let parsedWidth = parseSizeForPixelSize(widthString, warnings: &warnings) {
                tempPixelWidth = parsedWidth
            }
            SwiftWarningCollector.add(warnings)
        }
        
        if let heightString = try? container.decode(String.self, forKey: .height) {
            var warnings = [SwiftAdaptiveCardParseWarning]()
            if let parsedHeight = parseSizeForPixelSize(heightString, warnings: &warnings) {
                tempPixelHeight = parsedHeight
            }
            SwiftWarningCollector.add(warnings)
        }
        
        // Assign to let properties
        pixelWidth = tempPixelWidth
        pixelHeight = tempPixelHeight
        
        // Decode selectAction if present
        if container.contains(.selectAction) {
            let actionDict = try container.decode([String: AnyCodable].self, forKey: .selectAction)
            let dict = actionDict.mapValues { $0.value }
            selectAction = try SwiftBaseActionElement.deserializeAction(from: dict)
        } else {
            selectAction = nil
        }
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Default spacing and height if not set
        if self.height == nil {
            self.height = .auto
        }
        if self.spacing == nil {
            self.spacing = SwiftSpacing.none
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
    
    // MARK: - Serialization to JSON
    /// Serializes the Image to a JSON dictionary.
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
}
