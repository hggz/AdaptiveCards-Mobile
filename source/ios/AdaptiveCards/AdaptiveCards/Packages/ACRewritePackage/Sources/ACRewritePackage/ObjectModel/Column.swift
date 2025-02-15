import Foundation

// MARK: - Column & ColumnParser Implementation

/// Represents a column element in an Adaptive Card.
class Column: StyledCollectionElement {
    // MARK: - Properties
    var width: String
    var pixelWidth: Int
    var items: [BaseCardElement]
    var rtl: Bool?
    var layouts: [Layout]
    
    // MARK: - Initializer
    /// Designated initializer for Column.
    init(id: String? = nil) {
        self.width = "Auto"
        self.pixelWidth = 0
        self.items = []
        self.layouts = []
        // Call the superclass designated initializer with default style parameters.
        super.init(
            type: .column,
            style: .none,
            verticalContentAlignment: nil,
            bleedDirection: .bleedAll,
            minHeight: 0,
            hasPadding: false,
            hasBleed: false,
            showBorder: false,
            roundedCorners: false,
            parentalId: nil,
            backgroundImage: nil,
            selectAction: nil,
            id: id
        )
        self.populateKnownPropertiesSet()
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case width, pixelWidth, items, rtl, layouts
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.width = try container.decode(String.self, forKey: .width)
        self.pixelWidth = try container.decode(Int.self, forKey: .pixelWidth)
        self.items = try container.decode([BaseCardElement].self, forKey: .items)
        self.rtl = try container.decodeIfPresent(Bool.self, forKey: .rtl)
        self.layouts = try container.decodeIfPresent([Layout].self, forKey: .layouts) ?? []
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(width, forKey: .width)
        try container.encode(pixelWidth, forKey: .pixelWidth)
        try container.encode(items, forKey: .items)
        try container.encodeIfPresent(rtl, forKey: .rtl)
        try container.encode(layouts, forKey: .layouts)
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization
    /// Serializes the Column to a JSON string.
    func serialize() throws -> String {
        let jsonValue = try self.serializeToJsonVal()  // Calls our renamed method
        let data = try JSONSerialization.data(withJSONObject: jsonValue, options: [])
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw SerializationError.invalidData
        }
        return jsonString
    }
    
    /// Serializes the Column to a JSON dictionary.
    func serializeToJsonVal() throws -> [String: Any] {
        var root = try super.serializeToJsonValue()  // Calls the (renamed) method from BaseCardElement
        if !width.isEmpty {
            root["width"] = width
        }
        // Serialize items.
        root["items"] = try items.map { try $0.serializeToJsonValue() }
        if let rtl = rtl {
            root["rtl"] = rtl
        }
        return root
    }
    
    // MARK: - Width & Pixel Width
    func setWidth(_ value: String, warnings: inout [AdaptiveCardParseWarning]) {
        self.width = value.lowercased()
        self.pixelWidth = parseSizeForPixelSize(self.width, warnings: &warnings) ?? 0
    }

    func setWidth(_ value: String) {
        var warnings = [AdaptiveCardParseWarning]()
        self.setWidth(value, warnings: &warnings)
    }

    func getPixelWidth() -> Int {
        return pixelWidth
    }
    
    func setPixelWidth(_ value: Int) {
        self.pixelWidth = value
        self.width = "\(value)px"
    }
    
    // MARK: - Items, RTL, & Layouts
    func setRtl(_ value: Bool?) {
        self.rtl = value
    }
    
    func setLayouts(_ value: [Layout]) {
        self.layouts = value
    }
    
    /// Retrieves resource information from contained items.
    func getResourceInformation(_ resourceInfo: inout [RemoteResourceInformation]) {
        // For each item, assume its id is a URL and add a stub resource.
        for element in items {
            if let id = element.id {
                // Provide a mimeType as needed (here we use an empty string)
                resourceInfo.append(RemoteResourceInformation(url: id, mimeType: ""))
            }
        }
    }
    
    /// Parses children elements (items) from the provided JSON.
    func deserializeChildren(context: inout ParseContext, json: [String: Any]) throws {
        let cardElements = try ParseUtil.getElementCollection(
            isTopToBottomContainer: true,
            context: &context,
            json: json,
            key: "items",
            isRequired: false
        )
        self.items = cardElements
    }
    
    // MARK: - Known Properties
    private func populateKnownPropertiesSet() {
        self.knownProperties.insert("items")
        self.knownProperties.insert("rtl")
        self.knownProperties.insert("selectAction")
        self.knownProperties.insert("width")
        self.knownProperties.insert("style")
        self.knownProperties.insert("verticalContentAlignment")
    }
}

/// Parses Column elements in an Adaptive Card.
struct ColumnParser: BaseCardElementParser {
    func deserialize(context: inout ParseContext, value: [String: Any]) throws -> BaseCardElement {
        // Verify the type.
        guard let typeString = value["type"] as? String,
              typeString == CardElementType.column.rawValue else {
            throw AdaptiveCardParseException(statusCode: .requiredPropertyMissing, message: "Invalid type for Column")
        }
        
        // Deserialize the Column using the global helper.
        guard let column = try BaseCardElement.deserialize(from: value) as? Column else {
            throw AdaptiveCardParseException(statusCode: .unsupportedParserOverride, message: "Column deserialization failed")
        }
        
        // Retrieve the column width from the JSON.
        var columnWidth = ParseUtil.getValueAsString(from: value, key: "width")
        if columnWidth.isEmpty {
            // Fallback to "size" for older cards.
            columnWidth = ParseUtil.getValueAsString(from: value, key: "size")
        }
        column.setWidth(columnWidth, warnings: &context.warnings)
        
        // Set the RTL property.
        column.setRtl(ParseUtil.getOptionalBool(from: value, key: "rtl"))
        
        // Process layouts if available.
        if let layoutArray: [[String: Any]] = try? ParseUtil.getArray(from: value, key: "layouts", isRequired: false), !layoutArray.isEmpty {
            var parsedLayouts: [Layout] = []
            for layoutJson in layoutArray {
                guard let baseLayout = Layout.fromJSON(layoutJson) else {
                    throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Failed to parse layout")
                }
                switch baseLayout.layoutContainerType {
                case .flow:
                    let flowLayout = try FlowLayout.deserialize(from: layoutJson)
                    parsedLayouts.append(flowLayout)
                case .areaGrid:
                    let areaGridLayout = AreaGridLayout.deserialize(from: layoutJson)
                    if areaGridLayout.areas.isEmpty && areaGridLayout.columns.isEmpty {
                        let stackLayout = Layout()
                        stackLayout.layoutContainerType = .stack
                        parsedLayouts.append(stackLayout)
                    } else if areaGridLayout.areas.isEmpty {
                        let flowLayout = try FlowLayout.deserialize(from: layoutJson)
                        flowLayout.layoutContainerType = .flow
                        parsedLayouts.append(flowLayout)
                    } else {
                        parsedLayouts.append(AreaGridLayout.deserialize(from: layoutJson))
                    }
                default:
                    parsedLayouts.append(baseLayout)
                }
            }
            column.setLayouts(parsedLayouts)
        }
        
        return column
    }
    
    func deserialize(fromString context: inout ParseContext, value: String) throws -> BaseCardElement {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: &context, value: jsonDict)
    }
}
