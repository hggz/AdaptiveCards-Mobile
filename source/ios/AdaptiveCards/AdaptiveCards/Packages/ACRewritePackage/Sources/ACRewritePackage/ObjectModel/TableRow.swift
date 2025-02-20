import Foundation

/// Represents a TableRow in an Adaptive Card.
class TableRow: BaseCardElement {
    /// The style of the row.
    var style: ContainerStyle
    
    /// The horizontal alignment of cell content.
    var horizontalCellContentAlignment: HorizontalAlignment?
    
    /// The vertical alignment of cell content.
    var verticalCellContentAlignment: VerticalContentAlignment?
    
    /// The collection of table cells in the row.
    var cells: [TableCell]
    
    var isOrphaned: Bool = true
    
    override var elementTypeVal: CardElementType {
        return isOrphaned ? .unknown : .tableRow
    }
    
    /// Initializes a new `TableRow` with default values.
    init() {
        self.style = .none
        self.horizontalCellContentAlignment = .left
        self.verticalCellContentAlignment = .top
        self.cells = []
        super.init(type: .tableRow)
    }
    
    /// Decodes a `TableRow` from JSON.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.style = try container.decodeIfPresent(ContainerStyle.self, forKey: .style) ?? .none
        self.horizontalCellContentAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .horizontalCellContentAlignment)
        self.verticalCellContentAlignment = try container.decodeIfPresent(VerticalContentAlignment.self, forKey: .verticalCellContentAlignment)
        self.cells = try container.decodeIfPresent([TableCell].self, forKey: .cells) ?? []
        super.init(type: .tableRow)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Always encode cells if not empty
        if !cells.isEmpty {
            try container.encode(cells, forKey: .cells)
        }
        
        // Encode style with proper capitalization if not .none
        if style != .none {
            let styleString = style.rawValue  // Use rawValue directly to preserve case
            try container.encode(styleString, forKey: .style)
        }
        
        // Encode alignments if present
        if let horizontal = horizontalCellContentAlignment {
            try container.encode(horizontal.rawValue, forKey: .horizontalCellContentAlignment)
        }
        if let vertical = verticalCellContentAlignment {
            try container.encode(vertical.rawValue.capitalized, forKey: .verticalCellContentAlignment)
        }
    }
    
    /// Sets the collection of cells.
    func setCells(_ value: [TableCell]) {
        self.cells = value
    }
    
    /// Deserializes a `TableRow` from a JSON dictionary.
    static func deserialize(from json: [String: Any], context: ParseContext) throws -> TableRow {
        // Retrieve the id property using the expected key from AdaptiveCardSchemaKey.
        let idProperty = json[AdaptiveCardSchemaKey.id.rawValue] as? String ?? ""
        let internalId = InternalId.next()
        
        // Note: Adjust the parameter labels to match your ParseContext API.
        context.pushElement(idJsonProperty: idProperty, internalId: internalId)
        
        let tableRow = TableRow()
        tableRow.horizontalCellContentAlignment = try ParseUtil.getOptionalEnumValue(
            from: json,
            key: CodingKeys.horizontalCellContentAlignment.rawValue,
            converter: HorizontalAlignment.fromString
        )
        tableRow.verticalCellContentAlignment = try ParseUtil.getOptionalEnumValue(
            from: json,
            key: CodingKeys.verticalCellContentAlignment.rawValue,
            converter: VerticalContentAlignment.fromString
        )
        tableRow.style = try ParseUtil.getEnumValue(
            from: json,
            key: CodingKeys.style.rawValue,
            defaultValue: .none,
            converter: ContainerStyle.fromString
        )
        tableRow.cells = try ParseUtil.getElementCollectionOfSingleType(
            from: json,
            key: CodingKeys.cells.rawValue,
            context: context,
            defaultValue: [],
            converter: { (context: ParseContext, json: [String: Any]) throws -> TableCell in
                return try TableCell.deserialize(from: json, context: context)
            }
        )
        tableRow.additionalProperties = nil
        context.popElement()
        
        return tableRow
    }
    
    /// Deserializes a `TableRow` from a JSON string.
    static func deserialize(from jsonString: String, context: ParseContext) throws -> TableRow {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(from: jsonDict, context: context)
    }
    
    private enum CodingKeys: String, CodingKey {
        case style
        case horizontalCellContentAlignment
        case verticalCellContentAlignment
        case cells
    }
    
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        
        // Add cells if present
        if !cells.isEmpty {
            json["cells"] = try cells.map { try $0.serializeToJsonValue() }
        }
        
        // Add style if not default with proper capitalization
        if style != .none {
            json["style"] = style.rawValue  // Uses proper capitalization
        }
        
        // Add alignments if present
        if let horizontal = horizontalCellContentAlignment {
            json["horizontalCellContentAlignment"] = horizontal.rawValue
        }
        if let vertical = verticalCellContentAlignment {
            json["verticalCellContentAlignment"] = vertical.rawValue.capitalized
        }
        
        return json
    }
}
