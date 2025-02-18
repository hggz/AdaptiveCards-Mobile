import Foundation

/// Represents a column set element in an Adaptive Card.
/// Inherits from StyledCollectionElement.
class ColumnSet: StyledCollectionElement {
    // MARK: - Properties
    var columns: [Column] = []
    
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
        let context = BaseElement.parseContext
        
        // Call super.init to set up base properties
        try super.init(from: decoder)
        
        // Configure our own style
        self.configForContainerStyle(context)
        
        // Save our context for children
        context.saveContextForStyledCollectionElement(self)
        
        // Process columns
        for raw in rawColumns {
            var dict = raw.mapValues { $0.value }
            if dict["type"] == nil {
                dict["type"] = "Column"
            }
            
            let base = try BaseCardElement.deserialize(from: dict)
            guard let col = base as? Column else {
                throw AdaptiveCardParseError.invalidType
            }
            
            // Configure the column's style
            col.configForContainerStyle(context)
            
            self.columns.append(col)
        }
        
        // Restore previous context
        context.restoreContextForStyledCollectionElement(self)
        
        // Configure bleed directions after all columns are processed
        self.configureColumnBleedDirections()
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
    func deserializeChildren(context: ParseContext, json: [String: Any]) throws {
        // Use ParseUtil to get an array of BaseCardElement.
        let elements = try ParseUtil.getElementCollection(
            isTopToBottomContainer: false,
            context: context,
            json: json,
            key: "columns",
            required: false
        )
        // Filter for Column instances.
        self.columns = elements.compactMap { $0 as? Column }
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
    func getResourceInformation(_ resourceInfo: inout [RemoteResourceInformation]) {
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
        let count = columns.count
        
        for (index, column) in columns.enumerated() {
            var direction: ContainerBleedDirection = []
            
            // Handle single column case
            if count == 1 {
                direction = [.bleedDown, .bleedUp]
            }
            // Handle multi-column case
            else {
                if index == 0 {  // First column
                    direction = [.bleedDown, .bleedLeft, .bleedUp]
                } else if index == count - 1 {  // Last column
                    direction = [.bleedDown, .bleedRight, .bleedUp]
                } else {  // Middle columns
                    direction = [.bleedDown, .bleedUp]
                }
            }
            
            // Only set the direction if the column can bleed
            if column.canBleed {
                column.bleedDirection = direction
            } else {
                column.bleedDirection = .bleedRestricted
            }
            
            // Clear parentalId for all columns in top-level ColumnSet
            column.parentalId = nil
        }
    }
}

/// Parses ColumnSet elements in an Adaptive Card.
struct ColumnSetParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        try ParseUtil.expectTypeString(value, expected: .columnSet)
        let columnSet = try BaseCardElement.deserialize(from: value) as! ColumnSet
        
        let columnsArray: [[String: Any]] = try ParseUtil.getArray(from: value, key: "columns", required: true)
        var columns: [Column] = []
        for colJson in columnsArray {
            var temp = colJson
            if temp["type"] == nil {
                temp["type"] = "Column"
            }
            
            let base = try BaseCardElement.deserialize(from: temp)
            guard let col = base as? Column else {
                throw AdaptiveCardParseError.invalidType
            }
            columns.append(col)
        }
        columnSet.columns = columns
        return columnSet
    }

    func deserialize(fromString context: ParseContext, value: String) throws -> any AdaptiveCardElementProtocol {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
