import Foundation

/// Represents a Container element in an Adaptive Card.
class Container: StyledCollectionElement {
    var items: [BaseCardElement]
    var layouts: [Layout]
    var rtl: Bool?

    /// Designated initializer accepting a card element type.
    init(items: [BaseCardElement] = [],
             layouts: [Layout] = [],
             rtl: Bool? = nil,
         cardElementType: CardElementType = .container) {
        self.items = items
        self.layouts = layouts
        self.rtl = rtl
        // Initialize with restricted bleed
        super.init(
            type: cardElementType,
            style: .none,
            verticalContentAlignment: nil,
            bleedDirection: .bleedRestricted,  // Change from .bleedAll
            minHeight: 0,
            hasPadding: false,
            hasBleed: false,
            showBorder: false,
            roundedCorners: false,
            parentalId: nil,
            backgroundImage: nil,
            selectAction: nil
        )
    }

    /// Required initializer for Codable conformance (inherited from BaseCardElement).
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Initialize arrays before super.init
        self.items = []
        self.layouts = []
        self.rtl = nil

        // Call super.init to set up base properties including style
        try super.init(from: decoder)

        // Get the shared context
        let context = BaseElement.parseContext
        print("Container init - About to configure style, hasBleed: \(hasBleed)")
        
        // Configure our own style and bleed
        self.configForContainerStyle(context)
        
        // Then decode items with context and style configuration
        if let rawItems = try container.decodeIfPresent([[String: AnyCodable]].self, forKey: .items) {
            // Save our style as parent for children
            context.saveContextForStyledCollectionElement(self)
            print("Container saving style to context: \(self.style)")
            
            self.items = try rawItems.map { rawDict in
                let unwrapped = ParseUtil.unwrapAnyCodable(from: rawDict)
                guard let dict = unwrapped as? [String: Any] else {
                    throw AdaptiveCardParseError.invalidJson
                }
                let element = try BaseCardElement.deserialize(from: dict)
                
                if let styledElement = element as? StyledCollectionElement {
                    styledElement.configForContainerStyle(context)
                }
                
                return element
            }
            
            // Restore previous context
            context.restoreContextForStyledCollectionElement(self)
            print("Container restored previous style")
        }
        
        self.layouts = try container.decodeIfPresent([Layout].self, forKey: .layouts) ?? []
        self.rtl = try container.decodeIfPresent(Bool.self, forKey: .rtl)
    }
    
    override func configForContainerStyle(_ context: ParseContext) {
        print("Container.configForContainerStyle - Starting")
        super.configPadding(context)
        
        if canBleed {
            print("Container can bleed, configuring direction")
            if let parentId = context.paddingParentInternalId() {
                self.parentalId = parentId
                
                // Find parent Column
                if let parentColumn = findParentColumn() {
                    if let columnSet = findParentColumnSet(of: parentColumn) {
                        let columnIndex = columnSet.columns.firstIndex { $0.internalId == parentColumn.internalId } ?? 0
                        let isFirst = columnIndex == 0
                        let isLast = columnIndex == columnSet.columns.count - 1
                        
                        var direction: ContainerBleedDirection = .bleedDown
                        
                        // Add left/right based on position
                        if isFirst {
                            direction.insert(.bleedLeft)
                        }
                        if isLast {
                            direction.insert(.bleedRight)
                        }
                        
                        self.bleedDirection = direction
                    } else {
                        // Default container bleed if not in a ColumnSet
                        self.bleedDirection = [.bleedDown, .bleedLeft, .bleedRight]
                    }
                } else {
                    self.bleedDirection = [.bleedDown, .bleedLeft, .bleedRight]
                }
            } else {
                self.bleedDirection = .bleedRestricted
                self.parentalId = nil
            }
        } else {
            self.bleedDirection = .bleedRestricted
            self.parentalId = nil
        }
        
        print("Container.configForContainerStyle - Complete, direction: \(bleedDirection)")
    }
    
    private func findParentColumn() -> Column? {
        var current: BaseCardElement? = self
        while let parent = current?.parentalId {
            if let foundColumn = findElement(withId: parent) as? Column {
                return foundColumn
            }
            current = findElement(withId: parent)
        }
        return nil
    }
    
    private func findParentColumnSet(of column: Column) -> ColumnSet? {
        var current: BaseCardElement? = column
        while let parent = current?.parentalId {
            if let foundColumnSet = findElement(withId: parent) as? ColumnSet {
                return foundColumnSet
            }
            current = findElement(withId: parent)
        }
        return nil
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(items, forKey: .items)
        try container.encode(layouts, forKey: .layouts)
        try container.encodeIfPresent(rtl, forKey: .rtl)
        try super.encode(to: encoder)
    }

    private enum CodingKeys: String, CodingKey {
        case items, layouts, rtl
    }

    // Helper methods for other elements (e.g. TableCell) to use.
    func setRtl(_ rtl: Bool) {
        self.rtl = rtl
    }

    func setLayouts(_ layouts: [Layout]) {
        self.layouts = layouts
    }
    
    func deserializeChildren(from json: [String: Any]) throws {
        // Parse Items array
        if let itemsArray = json["items"] as? [[String: Any]] {
            self.items = try itemsArray.map { itemJson in
                var mutableJson = itemJson
                // Ensure type is set for items that don't specify it
                if mutableJson["type"] == nil {
                    mutableJson["type"] = "TextBlock" // Default type
                }
                return try BaseCardElement.deserialize(from: mutableJson)
            }
        }
    }
}

/// MARK: - Parser for Container

/// Parses a Container element from JSON.
struct ContainerParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        try ParseUtil.expectTypeString(value, expected: .container)
        
        print("ContainerParser deserialize - Starting")
        
        // Save current context
        let parentStyle = context.parentalContainerStyle
        print("ContainerParser - Parent style before: \(String(describing: parentStyle))")
        
        // Parse the container itself
        guard let container = try BaseCardElement.deserialize(from: value) as? Container else {
            throw AdaptiveCardParseError.invalidType
        }
        
        print("ContainerParser - Container style: \(container.style)")
        
        // Set new parent style for children
        context.setParentalContainerStyle(container.style)
        print("ContainerParser - Set new parent style: \(container.style)")
        
        // Configure container style
        container.configForContainerStyle(context)
        print("ContainerParser - Configured container style")
        
        // Parse children (items) if any
        if let itemsArray = value["items"] as? [[String: Any]] {
            print("ContainerParser - About to parse \(itemsArray.count) items")
            container.items = try itemsArray.map { itemJson in
                var mutableJson = itemJson
                if mutableJson["type"] == nil {
                    mutableJson["type"] = "TextBlock"
                }
                let element = try BaseCardElement.deserialize(from: mutableJson)
                if let styledElement = element as? StyledCollectionElement {
                    print("ContainerParser - Configuring style for child element")
                    styledElement.configForContainerStyle(context)
                }
                return element
            }
        }
        
        // Restore parent style
        if let parentStyle = parentStyle {
            context.setParentalContainerStyle(parentStyle)
            print("ContainerParser - Restored parent style: \(String(describing: parentStyle))")
        }
        
        print("ContainerParser deserialize - Complete")
        return container
    }

    func deserialize(fromString context: ParseContext, value: String) throws -> any AdaptiveCardElementProtocol {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
