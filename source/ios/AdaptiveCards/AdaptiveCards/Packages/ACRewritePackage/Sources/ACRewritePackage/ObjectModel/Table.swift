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
    
    var columns: [TableColumnDefinition] {
        return self.columnDefinitions
    }

    private enum CodingKeys: String, CodingKey {
        case columns
        case rows
        case showGridLines
        case roundedCorners
        case horizontalCellContentAlignment
        case verticalCellContentAlignment
        case gridStyle
        case firstRowAsHeaders
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
        // Do not encode firstRowAsHeaders if true (the default)
        if firstRowAsHeaders != true {
            // Uncomment if you need to output it when not default:
             try container.encode(firstRowAsHeaders, forKey: .firstRowAsHeaders)
        }
        try container.encode(roundedCorners, forKey: .roundedCorners)
        try container.encodeIfPresent(horizontalCellContentAlignment, forKey: .horizontalCellContentAlignment)
        try container.encodeIfPresent(verticalCellContentAlignment, forKey: .verticalCellContentAlignment)
        // When encoding gridStyle, output its capitalized raw value.
        try container.encode(gridStyle.rawValue.capitalized, forKey: .gridStyle)
    }
    /// Sets the collection of columns.
    func setColumns(_ value: [TableColumnDefinition]) {
        self.columnDefinitions = value
    }

    /// Sets the collection of rows.
    func setRows(_ value: [TableRow]) {
        self.rows = value
    }

    /// Conforms to CollectionCoreElement.
    func deserializeChildren(from json: [String: Any]) throws {
        // Table handles child deserialization within its custom logic.
    }
}

/// Parses Table elements in an Adaptive Card.
struct TableParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        // Verify that the type is correct.
        guard let typeString = value["type"] as? String,
              typeString == CardElementType.table.rawValue else {
            throw AdaptiveCardParseError.invalidType
        }
        // Use the global BaseCardElement deserialization and cast to Table.
        guard let table = try BaseCardElement.deserialize(from: value) as? Table else {
            throw AdaptiveCardParseError.invalidType
        }
        return table
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> any AdaptiveCardElementProtocol {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}

extension TableParser {
    func deserialize(from value: String, context: ParseContext) throws -> any AdaptiveCardElementProtocol {
        return try self.deserialize(fromString: context, value: value)
    }
}
