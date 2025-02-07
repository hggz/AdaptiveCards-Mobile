import Foundation

/// Represents a TableRow in an Adaptive Card.
class TableRow: BaseCardElement, Codable {
    /// The style of the row.
    var style: ContainerStyle

    /// The horizontal alignment of cell content.
    var horizontalCellContentAlignment: HorizontalAlignment?

    /// The vertical alignment of cell content.
    var verticalCellContentAlignment: VerticalContentAlignment?

    /// The collection of table cells in the row.
    var cells: [TableCell]

    /// Initializes a new `TableRow` with default values.
    override init() {
        self.style = .none
        self.horizontalCellContentAlignment = .left
        self.verticalCellContentAlignment = .top
        self.cells = []
        super.init(cardElementType: .tableRow)
    }

    /// Decodes a `TableRow` from JSON.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.style = try container.decodeIfPresent(ContainerStyle.self, forKey: .style) ?? .none
        self.horizontalCellContentAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .horizontalCellContentAlignment)
        self.verticalCellContentAlignment = try container.decodeIfPresent(VerticalContentAlignment.self, forKey: .verticalCellContentAlignment)
        self.cells = try container.decodeIfPresent([TableCell].self, forKey: .cells) ?? []
        super.init(cardElementType: .tableRow)
    }

    /// Encodes a `TableRow` to JSON.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(style, forKey: .style)
        try container.encodeIfPresent(horizontalCellContentAlignment, forKey: .horizontalCellContentAlignment)
        try container.encodeIfPresent(verticalCellContentAlignment, forKey: .verticalCellContentAlignment)
        try container.encodeIfPresent(cells, forKey: .cells)
    }

    /// Sets the collection of cells.
    func setCells(_ value: [TableCell]) {
        self.cells = value
    }

    /// Deserializes a `TableRow` from a JSON dictionary.
    static func deserialize(from json: [String: Any], context: inout ParseContext) throws -> TableRow {
        let idProperty = json[AdaptiveCardSchemaKey.id.rawValue] as? String ?? ""
        let internalId = InternalId.next()
        
        context.pushElement(id: idProperty, internalId: internalId)
        
        let tableRow = TableRow()
        tableRow.horizontalCellContentAlignment = try ParseUtil.getOptionalEnumValue(json, key: .horizontalCellContentAlignment, parser: HorizontalAlignment.fromString)
        tableRow.verticalCellContentAlignment = try ParseUtil.getOptionalEnumValue(json, key: .verticalCellContentAlignment, parser: VerticalContentAlignment.fromString)
        tableRow.style = try ParseUtil.getEnumValue(json, key: .style, defaultValue: .none, parser: ContainerStyle.fromString)
        tableRow.cells = try ParseUtil.getElementCollectionOfSingleType(json, key: .cells, context: &context, deserializer: TableCell.deserialize)

        context.popElement()
        
        return tableRow
    }

    /// Deserializes a `TableRow` from a JSON string.
    static func deserialize(from jsonString: String, context: inout ParseContext) throws -> TableRow {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardError.invalidJson
        }
        return try deserialize(from: jsonDict, context: &context)
    }

    private enum CodingKeys: String, CodingKey {
        case style
        case horizontalCellContentAlignment
        case verticalCellContentAlignment
        case cells
    }
}
