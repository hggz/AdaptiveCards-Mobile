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
        
        // We decode an array of raw dictionaries, then enforce "type = Column" if missing.
        let rawColumns = try container.decodeIfPresent([[String: AnyCodable]].self, forKey: .columns) ?? []
        var builtColumns = [Column]()
        for raw in rawColumns {
            var dict = raw.mapValues { $0.value }
            if dict["type"] == nil {
                dict["type"] = "Column"
            }
            let base = try BaseCardElement.deserialize(from: dict)
            guard let col = base as? Column else {
                throw AdaptiveCardParseError.invalidType
            }
            builtColumns.append(col)
        }
        self.columns = builtColumns
        
        // Finally call super
        try super.init(from: decoder)
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
