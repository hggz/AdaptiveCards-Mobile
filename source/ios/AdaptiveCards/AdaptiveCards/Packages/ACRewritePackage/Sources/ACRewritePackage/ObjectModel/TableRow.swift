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
        // Assuming ContainerStyle conforms to Codable; otherwise, decode as a String and convert.
        self.style = try container.decodeIfPresent(ContainerStyle.self, forKey: .style) ?? .none
        self.horizontalCellContentAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .horizontalCellContentAlignment)
        self.verticalCellContentAlignment = try container.decodeIfPresent(VerticalContentAlignment.self, forKey: .verticalCellContentAlignment)
        self.cells = try container.decodeIfPresent([TableCell].self, forKey: .cells) ?? []
        super.init(type: .tableRow)
    }

    /// Encodes a `TableRow` to JSON.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(style, forKey: .style)
        try container.encodeIfPresent(horizontalCellContentAlignment, forKey: .horizontalCellContentAlignment)
        try container.encodeIfPresent(verticalCellContentAlignment, forKey: .verticalCellContentAlignment)
        try container.encode(cells, forKey: .cells)
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
}
