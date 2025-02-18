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
                print("Found padding parent ID: \(parentId)")
                
                // First set parentalId from context
                self.parentalId = parentId
                
                // Then try to find parent Column
                if let parentColumn = findParentColumn() {
                    print("Found parent column with ID: \(parentColumn.internalId), style: \(parentColumn.style)")
                    
                    // Set our final parentalId to the column
                    self.parentalId = parentColumn.internalId
                    
                    if let parentColumnSet = findParentColumnSet(of: parentColumn) {
                        let columnIndex = parentColumnSet.columns.firstIndex { $0.internalId == parentColumn.internalId } ?? 0
                        let isFirst = columnIndex == 0
                        let isLast = columnIndex == parentColumnSet.columns.count - 1
                        print("Column position - index: \(columnIndex), total columns: \(parentColumnSet.columns.count)")
                        
                        // Set bleed direction based on position
                        var direction: ContainerBleedDirection = .bleedDown
                        if isFirst {
                            direction.insert(.bleedLeft)
                            print("Adding bleedLeft for first position")
                        }
                        if isLast {
                            direction.insert(.bleedRight)
                            print("Adding bleedRight for last position")
                        }
                        self.bleedDirection = direction
                        print("Set bleed direction to: \(direction)")
                    } else {
                        print("No parent ColumnSet found, using default container bleed")
                        self.bleedDirection = [.bleedDown, .bleedLeft, .bleedRight]
                    }
                } else {
                    print("No parent Column found")
                    self.bleedDirection = [.bleedDown, .bleedLeft, .bleedRight]
                }
            } else {
                print("No padding parent ID found, restricting bleed")
                self.bleedDirection = .bleedRestricted
                self.parentalId = nil
            }
        } else {
            print("Container cannot bleed, restricting")
            self.bleedDirection = .bleedRestricted
            self.parentalId = nil
        }
        
        print("Container.configForContainerStyle - Complete, parentalId: \(String(describing: parentalId)), direction: \(bleedDirection)")
    }
    
    private func findParentColumn() -> Column? {
        var current: BaseCardElement? = self
        var searchPath: [BaseCardElement] = []
        print("Finding parent column - starting search from container")
        print("Initial parentalId: \(String(describing: parentalId))")
        
        // First, build the parent chain
        while let currentElement = current {
            searchPath.append(currentElement)
            if let parentId = currentElement.parentalId {
                print("Found parent ID: \(parentId) for element type: \(Swift.type(of: currentElement))")
                current = findElement(withId: parentId)
            } else {
                current = nil
            }
        }
        
        print("Built search path with \(searchPath.count) elements")
        
        // Then search through the chain for the first Column
        for (index, element) in searchPath.enumerated() {
            if let parentId = element.parentalId,
               let column = findElement(withId: parentId) as? Column {
                print("Found Column at level \(index)")
                return column
            }
            if let parentId = element.parentalId,
               let parent = findElement(withId: parentId) {
                print("Found parent at level \(index): \(Swift.type(of: parent))")
            }
        }
        
        print("No Column found in search path")
        return nil
    }
    
    private func findParentColumnSet(of element: BaseCardElement) -> ColumnSet? {
        var current: BaseCardElement? = element
        print("Finding parent ColumnSet starting from: \(Swift.type(of: element))")
        
        while let currentElement = current {
            if let parentId = currentElement.parentalId {
                print("Checking parent ID: \(parentId)")
                if let columnSet = findElement(withId: parentId) as? ColumnSet {
                    print("Found parent ColumnSet")
                    return columnSet
                }
                current = findElement(withId: parentId)
            } else {
                current = nil
            }
        }
        
        print("No parent ColumnSet found")
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
