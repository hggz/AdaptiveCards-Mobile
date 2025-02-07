import Foundation

/// Represents a Table in an Adaptive Card.
class Table: CollectionCoreElement, Codable {
    /// Column definitions for the table.
    var columnDefinitions: [TableColumnDefinition]

    /// Rows in the table.
    var rows: [TableRow]

    /// Whether grid lines should be shown.
    var showGridLines: Bool

    /// Whether the first row should be used as headers.
    var firstRowAsHeaders: Bool

    /// Whether the table should have rounded corners.
    var roundedCorners: Bool

    /// The horizontal alignment of cell content.
    var horizontalCellContentAlignment: HorizontalAlignment?

    /// The vertical alignment of cell content.
    var verticalCellContentAlignment: VerticalContentAlignment?

    /// The grid style of the table.
    var gridStyle: ContainerStyle

    /// Initializes a new `Table` with default values.
    override init() {
        self.columnDefinitions = []
        self.rows = []
        self.showGridLines = true
        self.firstRowAsHeaders = true
        self.roundedCorners = false
        self.gridStyle = .none
        super.init(cardElementType: .table)
    }

    /// Decodes a `Table` from JSON.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.columnDefinitions = try container.decodeIfPresent([TableColumnDefinition].self, forKey: .columns) ?? []
        self.rows = try container.decodeIfPresent([TableRow].self, forKey: .rows) ?? []
        self.showGridLines = try container.decodeIfPresent(Bool.self, forKey: .showGridLines) ?? true
        self.firstRowAsHeaders = try container.decodeIfPresent(Bool.self, forKey: .firstRowAsHeaders) ?? true
        self.roundedCorners = try container.decodeIfPresent(Bool.self, forKey: .roundedCorners) ?? false
        self.horizontalCellContentAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .horizontalCellContentAlignment)
        self.verticalCellContentAlignment = try container.decodeIfPresent(VerticalContentAlignment.self, forKey: .verticalCellContentAlignment)
        self.gridStyle = try container.decodeIfPresent(ContainerStyle.self, forKey: .gridStyle) ?? .none
        super.init(cardElementType: .table)
    }

    /// Encodes a `Table` to JSON.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(columnDefinitions, forKey: .columns)
        try container.encodeIfPresent(rows, forKey: .rows)
        try container.encodeIfPresent(showGridLines, forKey: .showGridLines)
        try container.encodeIfPresent(firstRowAsHeaders, forKey: .firstRowAsHeaders)
        try container.encodeIfPresent(roundedCorners, forKey: .roundedCorners)
        try container.encodeIfPresent(horizontalCellContentAlignment, forKey: .horizontalCellContentAlignment)
        try container.encodeIfPresent(verticalCellContentAlignment, forKey: .verticalCellContentAlignment)
        try container.encodeIfPresent(gridStyle, forKey: .gridStyle)
    }

    /// Sets the collection of columns.
    func setColumns(_ value: [TableColumnDefinition]) {
        self.columnDefinitions = value
    }

    /// Sets the collection of rows.
    func setRows(_ value: [TableRow]) {
        self.rows = value
    }

    /// Deserializes a `Table` from a JSON dictionary.
    static func deserialize(from json: [String: Any], context: inout ParseContext) throws -> Table {
        let table = Table()
        
        table.columnDefinitions = try ParseUtil.getElementCollectionOfSingleType(
            json, key: .columns, context: &context, deserializer: TableColumnDefinition.deserialize
        )
        table.rows = try ParseUtil.getElementCollectionOfSingleType(
            json, key: .rows, context: &context, deserializer: TableRow.deserialize
        )
        
        table.showGridLines = try ParseUtil.getBool(json, key: .showGridLines, defaultValue: true)
        table.firstRowAsHeaders = try ParseUtil.getBool(json, key: .firstRowAsHeaders, defaultValue: true)
        table.roundedCorners = try ParseUtil.getBool(json, key: .roundedCorners, defaultValue: false)
        table.horizontalCellContentAlignment = try ParseUtil.getOptionalEnumValue(json, key: .horizontalCellContentAlignment, parser: HorizontalAlignment.fromString)
        table.verticalCellContentAlignment = try ParseUtil.getOptionalEnumValue(json, key: .verticalCellContentAlignment, parser: VerticalContentAlignment.fromString)
        table.gridStyle = try ParseUtil.getEnumValue(json, key: .gridStyle, defaultValue: .none, parser: ContainerStyle.fromString)

        return table
    }

    /// Deserializes a `Table` from a JSON string.
    static func deserialize(from jsonString: String, context: inout ParseContext) throws -> Table {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardError.invalidJson
        }
        return try deserialize(from: jsonDict, context: &context)
    }

    private enum CodingKeys: String, CodingKey {
        case columns
        case rows
        case showGridLines
        case firstRowAsHeaders
        case roundedCorners
        case horizontalCellContentAlignment
        case verticalCellContentAlignment
        case gridStyle
    }
}
