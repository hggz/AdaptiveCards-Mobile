import Foundation

/// Represents a Table in an Adaptive Card.
class Table: BaseCardElement, CollectionCoreElement {
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

    /// Initializes a new `Table` with default values.
    init() {
        self.columnDefinitions = []
        self.rows = []
        self.showGridLines = true
        self.firstRowAsHeaders = true
        self.roundedCorners = false
        self.gridStyle = .none
        super.init(type: .table)
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
        try super.init(from: decoder)
    }

    /// Encodes a `Table` to JSON.
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(columnDefinitions, forKey: .columns)
        try container.encode(rows, forKey: .rows)
        try container.encode(showGridLines, forKey: .showGridLines)
        try container.encode(firstRowAsHeaders, forKey: .firstRowAsHeaders)
        try container.encode(roundedCorners, forKey: .roundedCorners)
        try container.encodeIfPresent(horizontalCellContentAlignment, forKey: .horizontalCellContentAlignment)
        try container.encodeIfPresent(verticalCellContentAlignment, forKey: .verticalCellContentAlignment)
        try container.encode(gridStyle, forKey: .gridStyle)
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
            from: json,
            key: CodingKeys.columns.rawValue,
            context: &context,
            defaultValue: [],
            converter: TableColumnDefinition.deserialize
        )
        
        table.rows = try ParseUtil.getElementCollectionOfSingleType(
            from: json,
            key: CodingKeys.rows.rawValue,
            context: &context,
            defaultValue: [TableRow](),
            converter: { (context: inout ParseContext, json: [String: Any]) throws -> TableRow in
                return try TableRow.deserialize(from: json, context: &context)
            }
        )
        table.showGridLines = try ParseUtil.getBool(
            from: json,
            key: CodingKeys.showGridLines.rawValue,
            defaultValue: true
        )
        table.firstRowAsHeaders = try ParseUtil.getBool(
            from: json,
            key: CodingKeys.firstRowAsHeaders.rawValue,
            defaultValue: true
        )
        table.roundedCorners = try ParseUtil.getBool(
            from: json,
            key: CodingKeys.roundedCorners.rawValue,
            defaultValue: false
        )
        table.horizontalCellContentAlignment = try ParseUtil.getOptionalEnumValue(
            from: json,
            key: CodingKeys.horizontalCellContentAlignment.rawValue,
            converter: { HorizontalAlignment(rawValue: $0) }
        )
        table.verticalCellContentAlignment = try ParseUtil.getOptionalEnumValue(
            from: json,
            key: CodingKeys.verticalCellContentAlignment.rawValue,
            converter: { VerticalContentAlignment(rawValue: $0) }
        )
        table.gridStyle = try ParseUtil.getEnumValue(
            from: json,
            key: CodingKeys.gridStyle.rawValue,
            defaultValue: .none,
            converter: { ContainerStyle(rawValue: $0) }
        )
        
        return table
    }

    /// Deserializes a `Table` from a JSON string.
    static func deserialize(from jsonString: String, context: inout ParseContext) throws -> Table {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON")
        }
        return try deserialize(from: jsonDict, context: &context)
    }
    
    func deserializeChildren(from json: [String: Any]) throws {
        // Table handles child deserialization within its custom `deserialize` method.
    }
}
