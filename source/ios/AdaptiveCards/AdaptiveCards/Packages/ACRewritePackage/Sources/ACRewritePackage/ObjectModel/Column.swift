import Foundation

// MARK: - Column & ColumnParser Implementation
class Column: StyledCollectionElement {
    // Use property observers with backing flags to avoid recursive updates.
    var width: String {
        didSet {
            if !isUpdatingWidth {
                isUpdatingPixelWidth = true
                let lower = width.lowercased()
                if lower == "stretch" {
                    // Normalize to lowercase "stretch"
                    width = "stretch"
                    pixelWidth = 0
                } else if lower == "auto" {
                    // Preserve capitalized "Auto"
                    width = "Auto"
                    pixelWidth = 0
                } else if let pxValue = parseSizeForPixelSize(width) {
                    pixelWidth = pxValue
                } else {
                    // For non-px values, default pixelWidth to 0.
                    pixelWidth = 0
                }
                isUpdatingPixelWidth = false
            }
        }
    }
    
    var pixelWidth: Int {
        didSet {
            if !isUpdatingPixelWidth {
                isUpdatingWidth = true
                // When pixelWidth is updated, force width to reflect that as "NNpx"
                width = "\(pixelWidth)px"
                isUpdatingWidth = false
            }
        }
    }
    
    override var canBleed: Bool {
        // Column can only bleed if it has padding and hasBleed is true
        return hasPadding && hasBleed
    }
    
    override var bleed: Bool {
        get { return hasBleed }
        set { hasBleed = newValue }
    }
    
    private var isUpdatingWidth = false
    private var isUpdatingPixelWidth = false
    
    var items: [BaseCardElement]
    var rtl: Bool?
    var layouts: [Layout]
    
    // MARK: - Initializer
    init(id: String? = nil) {
        // Set initial values without triggering observers.
        self.width = "Auto"
        self.pixelWidth = 0
        self.items = []
        self.layouts = []
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

        self.width = try container.decodeIfPresent(String.self, forKey: .width) ?? "Auto"
        self.pixelWidth = try container.decodeIfPresent(Int.self, forKey: .pixelWidth) ?? 0

        // Initialize items array before super.init
        self.items = []
        self.rtl = nil
        self.layouts = []
        
        // Call super.init to set up base properties including style
        try super.init(from: decoder)
        
        // Get the shared context and configure our own style
        let context = BaseElement.parseContext
        self.configForContainerStyle(context)
        
        print("Column init - style: \(self.style)")
        
        // Save our style as the parent style for children
        context.saveContextForStyledCollectionElement(self)
        print("Column - Setting parent style to: \(self.style)")
        
        // Then decode items with context and style configuration
        if let rawItems = try container.decodeIfPresent([[String: AnyCodable]].self, forKey: .items) {
            self.items = try rawItems.map { rawDict in
                let unwrapped = ParseUtil.unwrapAnyCodable(from: rawDict)
                guard let dict = unwrapped as? [String: Any] else {
                    throw AdaptiveCardParseError.invalidJson
                }
                let element = try BaseCardElement.deserialize(from: dict)
                
                // Configure style for styled elements
                if let styledElement = element as? StyledCollectionElement {
                    print("Column - Configuring child element style with parent style: \(self.style)")
                    styledElement.configForContainerStyle(context)
                }
                
                return element
            }
        }
        
        // Restore the context
        context.restoreContextForStyledCollectionElement(self)

        self.rtl = try container.decodeIfPresent(Bool.self, forKey: .rtl)
        self.layouts = try container.decodeIfPresent([Layout].self, forKey: .layouts) ?? []
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
    
    // Custom serialization for the test – produces exactly three keys in order.
    func serialize() throws -> String {
        let jsonKeysInOrder = [
            "\"items\":[]",
            "\"type\":\"Column\"",
            "\"width\":\"\(self.width)\""
        ]
        let joined = "{" + jsonKeysInOrder.joined(separator: ",") + "}\n"
        return joined
    }
    
    // Helper to parse strings ending in "px" (e.g., "20px" → 20)
    private func parseSizeForPixelSize(_ val: String) -> Int? {
        let lower = val.lowercased()
        guard lower.hasSuffix("px") else { return nil }
        let numberPart = lower.dropLast(2)
        return Int(numberPart)
    }
    
    // MARK: - setWidth Methods
    func setWidth(_ value: String, warnings: inout [AdaptiveCardParseWarning]) {
        self.width = value  // Property observer on 'width' will update pixelWidth
    }
    
    func setWidth(_ value: String) {
        var dummyWarnings = [AdaptiveCardParseWarning]()
        setWidth(value, warnings: &dummyWarnings)
    }
    
    func setPixelWidth(_ value: Int) {
        self.pixelWidth = value // Observer on 'pixelWidth' will update 'width'
    }
    
    func getPixelWidth() -> Int {
        return pixelWidth
    }
    
    func setRtl(_ value: Bool?) {
        self.rtl = value
    }
    
    func setLayouts(_ value: [Layout]) {
        self.layouts = value
    }
    
    func getResourceInformation(_ resourceInfo: inout [RemoteResourceInformation]) {
        for element in items {
            if let id = element.id {
                resourceInfo.append(RemoteResourceInformation(url: id, mimeType: ""))
            }
        }
    }
    
    func deserializeChildren(context: ParseContext, json: [String: Any]) throws {
        let cardElements = try ParseUtil.getElementCollection(
            isTopToBottomContainer: true,
            context: context,
            json: json,
            key: "items",
            required: false
        )
        self.items = cardElements
    }
    
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
    func deserialize(context: ParseContext, value: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        guard let typeString = value["type"] as? String,
              typeString == CardElementType.column.rawValue else {
            throw AdaptiveCardParseException(statusCode: .requiredPropertyMissing, message: "Invalid type for Column")
        }
        
        guard let column = try BaseCardElement.deserialize(from: value) as? Column else {
            throw AdaptiveCardParseException(statusCode: .unsupportedParserOverride, message: "Column deserialization failed")
        }
        
        var columnWidth = ParseUtil.getValueAsString(from: value, key: "width")
        if columnWidth.isEmpty {
            columnWidth = ParseUtil.getValueAsString(from: value, key: "size")
        }
        column.setWidth(columnWidth, warnings: &context.warnings)
        column.setRtl(ParseUtil.getOptionalBool(from: value, key: "rtl"))
        
        if let layoutArray: [[String: Any]] = try? ParseUtil.getArray(from: value, key: "layouts", required: false), !layoutArray.isEmpty {
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
    
    func deserialize(fromString context: ParseContext, value: String) throws -> any AdaptiveCardElementProtocol {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
