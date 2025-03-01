import Foundation

/// Represents a column set element in an Adaptive Card.
/// Inherits from StyledCollectionElement.
class SwiftColumnSet: SwiftStyledCollectionElement {
    // MARK: - Properties
    var columns: [SwiftColumn] = []
    
    // MARK: - Initializer
    /// Designated initializer for ColumnSet.
    init(id: String? = nil) {
        // Call the superclass initializer, setting type to .columnSet.
        // (Assuming your CardElementType has a case .columnSet)
        super.init(
            type: .columnSet,
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
        populateKnownPropertiesSet()
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case columns
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Initialize columns before super.init
        self.columns = []
        
        // Decode the raw columns
        let rawColumns = try container.decodeIfPresent([[String: AnyCodable]].self, forKey: .columns) ?? []
        
        // Get the shared context
        let context = SwiftBaseElement.parseContext
        
        // Call super.init to set up base properties
        try super.init(from: decoder)
        
        // Configure our own style first
        self.configForContainerStyle(context)
        
        // Save our context for children
        context.saveContextForStyledCollectionElement(self)
        
        // Process columns
        for raw in rawColumns {
            var dict = raw.mapValues { $0.value }
            if dict["type"] == nil {
                dict["type"] = "Column"
            }
            
            let base = try SwiftBaseCardElement.deserialize(from: dict)
            guard let col = base as? SwiftColumn else {
                throw AdaptiveCardParseError.invalidType
            }
            
            // Configure the column's style
            col.configForContainerStyle(context)
            
            self.columns.append(col)
        }
        
        // Restore previous context
        context.restoreContextForStyledCollectionElement(self)
        
        // Configure bleed directions after all columns are processed and their styles are set
        print("ColumnSet.init - About to configure column bleed directions")
        configureColumnBleedDirections()
    }
    
    override func configForContainerStyle(_ context: SwiftParseContext) {
        print("ColumnSet.configForContainerStyle - Starting")
        // Call super but don't configure bleed directions here
        super.configForContainerStyle(context)
        print("ColumnSet.configForContainerStyle - Complete")
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(columns, forKey: .columns)
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization
    /// Serializes the ColumnSet to a JSON dictionary.
    /// This method calls the superclass’s serialization and then adds the columns array.
    func serializeToJsonVal() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        // Use "columns" as the JSON key.
        json["columns"] = try columns.map { try $0.serializeToJsonValue() }
        return json
    }
    
    // MARK: - Deserialization of Children
    /// Parses the children elements (columns) from the provided JSON.
    func deserializeChildren(context: SwiftParseContext, json: [String: Any]) throws {
        // Use ParseUtil to get an array of BaseCardElement.
        let elements = try SwiftParseUtil.getElementCollection(
            isTopToBottomContainer: false,
            context: context,
            json: json,
            key: "columns",
            required: false
        )
        // Filter for Column instances.
        self.columns = elements.compactMap { $0 as? SwiftColumn }
    }
    
    // MARK: - Known Properties
    /// Populates the set of known properties for a ColumnSet.
    private func populateKnownPropertiesSet() {
        self.knownProperties.insert("bleed")
        self.knownProperties.insert("columns")
        self.knownProperties.insert("selectAction")
        self.knownProperties.insert("style")
    }
    
    // MARK: - Resource Information
    /// Retrieves resource information from contained columns.
    func getResourceInformation(_ resourceInfo: inout [SwiftRemoteResourceInformation]) {
        // Assume a helper method exists on StyledCollectionElement that accepts a collection of elements.
        // Here we simply iterate over our columns.
        for column in columns {
            column.getResourceInformation(&resourceInfo)
        }
    }
    
    /// Indicates whether this ColumnSet is nested (i.e. not at the top level of the card).
    var isNested: Bool {
        // For our purposes, if its parentalId is non‑nil, we consider it nested.
        return self.parentalId != nil
    }
    
    /// Adjusts the bleedDirection for each contained Column based on whether this ColumnSet
    /// is nested or top‑level.
    ///
    /// For a top‑level ColumnSet (isNested == false) we want:
    ///   • Leftmost column: bleedDirection = BleedDown ∪ BleedLeft ∪ BleedRight (i.e. 4096+1+16 = 4113)
    ///   • Middle column(s): bleedDirection = BleedDown ∪ BleedUp (i.e. 4096+256 = 4352)
    ///   • Rightmost column: bleedDirection = BleedDown ∪ BleedUp ∪ BleedRight (i.e. 4096+256+16 = 4368)
    ///
    /// For a nested ColumnSet (isNested == true) we want:
    ///   • Leftmost: bleedDirection = BleedDown ∪ BleedLeft (4096+1 = 4097)
    ///   • Middle: bleedDirection = BleedDown (4096)
    ///   • Rightmost: bleedDirection = BleedDown ∪ BleedRight (4096+16 = 4112)
    func configureColumnBleedDirections() {
        print("ColumnSet.configureColumnBleedDirections - Starting")
        
        for (index, column) in columns.enumerated() {
            guard let column = column as? SwiftColumn else { continue }
            
            print("Configuring column \(index) of \(columns.count - 1), canBleed: \(column.canBleed)")
            
            if !column.canBleed {
                print("Column \(index) cannot bleed, restricting")
                column.bleedDirection = .bleedRestricted
                continue
            }
            
            // Start with bleedDown
            var direction: SwiftContainerBleedDirection = .bleedDown
            print("Initial direction for column \(index): \(direction)")
            
            // Add bleedUp if parent ColumnSet has bleed enabled
            if self.hasBleed && self.canBleed {
                direction.insert(.bleedUp)
            }
            
            // Add left/right based on position
            if index == 0 {
                direction.insert(.bleedLeft)
            }
            if index == columns.count - 1 {
                direction.insert(.bleedRight)
            }
            
            column.bleedDirection = direction
            print("Setting final direction for column \(index) to: \(direction)")
            
            // Set parental ID for bleeding columns
            if column.canBleed {
                if let parentalId = self.parentalId {
                    column.parentalId = parentalId
                } else if let contextParentId = column.parentalId {
                    column.parentalId = contextParentId
                }
            }
        }
    }
}

/// Parses ColumnSet elements in an Adaptive Card.
struct SwiftColumnSetParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: .columnSet)
        let columnSet = try SwiftBaseCardElement.deserialize(from: value) as! SwiftColumnSet
        
        let columnsArray: [[String: Any]] = try SwiftParseUtil.getArray(from: value, key: "columns", required: true)
        var columns: [SwiftColumn] = []
        for colJson in columnsArray {
            var temp = colJson
            if temp["type"] == nil {
                temp["type"] = "Column"
            }
            
            let base = try SwiftBaseCardElement.deserialize(from: temp)
            guard let col = base as? SwiftColumn else {
                throw AdaptiveCardParseError.invalidType
            }
            columns.append(col)
        }
        columnSet.columns = columns
        return columnSet
    }

    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        let jsonDict = try SwiftParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
