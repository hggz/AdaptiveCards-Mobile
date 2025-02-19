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
        self.knownProperties = Set([
            "columns",
            "rows",
            "showGridLines",
            "roundedCorners",
            "horizontalCellContentAlignment",
            "verticalCellContentAlignment",
            "gridStyle",
            "firstRowAsHeaders"
        ])
    }

    /// Decodes a `Table` from JSON.
    required init(from decoder: Decoder) throws {
        // First decode the Table-specific properties
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.columnDefinitions = try container.decodeIfPresent([TableColumnDefinition].self, forKey: .columns) ?? []
        self.rows = try container.decodeIfPresent([TableRow].self, forKey: .rows) ?? []
        self.showGridLines = try container.decodeIfPresent(Bool.self, forKey: .showGridLines) ?? true
        self.firstRowAsHeaders = try container.decodeIfPresent(Bool.self, forKey: .firstRowAsHeaders) ?? true
        self.roundedCorners = try container.decodeIfPresent(Bool.self, forKey: .roundedCorners) ?? false
        self.horizontalCellContentAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .horizontalCellContentAlignment)
        self.verticalCellContentAlignment = try container.decodeIfPresent(VerticalContentAlignment.self, forKey: .verticalCellContentAlignment)
        
        // Handle gridStyle with proper case handling
        if let gridStyleString = try container.decodeIfPresent(String.self, forKey: .gridStyle) {
            self.gridStyle = ContainerStyle(rawValue: gridStyleString.lowercased()) ?? .none
        } else {
            self.gridStyle = .none
        }
        
        // Initialize base class with .table type
        try super.init(from: decoder)
        
        // Clear any additional properties that might have been set during decoding
        self.additionalProperties = nil
        
        // Ensure knownProperties is set
        self.knownProperties = Set([
            "type",
            "id",
            "columns",
            "rows",
            "showGridLines",
            "roundedCorners",
            "horizontalCellContentAlignment",
            "verticalCellContentAlignment",
            "gridStyle",
            "firstRowAsHeaders"
        ])
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
        
        // Encode gridStyle with first letter capitalized
        if gridStyle != .none {
            let gridStyleString = gridStyle.rawValue.prefix(1).uppercased() + gridStyle.rawValue.dropFirst()
            try container.encode(gridStyleString, forKey: .gridStyle)
        }
    }

    /// Sets the collection of columns.
    func setColumns(_ value: [TableColumnDefinition]) {
        self.columnDefinitions = value
    }

    /// Sets the collection of rows.
    func setRows(_ value: [TableRow]) {
        self.rows = value
    }
    
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        
        // Add table-specific properties
        json["columns"] = try columnDefinitions.map { try $0.serializeToJsonValue() }
        json["rows"] = try rows.map { try $0.serializeToJsonValue() }
        
        if showGridLines != true {
            json["showGridLines"] = showGridLines
        }
        
        if roundedCorners {
            json["roundedCorners"] = roundedCorners
        }
        
        if let horizontalAlignment = horizontalCellContentAlignment {
            json["horizontalCellContentAlignment"] = horizontalAlignment.rawValue
        }
        
        if let verticalAlignment = verticalCellContentAlignment {
            json["verticalCellContentAlignment"] = verticalAlignment.rawValue
        }
        
        if gridStyle != .none {
            json["gridStyle"] = gridStyle.rawValue.prefix(1).uppercased() + gridStyle.rawValue.dropFirst()
        }
        
        // Only add properties that differ from defaults
        if !firstRowAsHeaders {
            json["firstRowAsHeaders"] = firstRowAsHeaders
        }
        
        // Clear any additional properties
        self.additionalProperties = nil
        
        return json
    }

    /// Conforms to CollectionCoreElement.
    func deserializeChildren(from json: [String: Any]) throws {
        // Table handles child deserialization within its custom logic.
    }
}

/// Parses Table elements in an Adaptive Card.
struct TableParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        // Verify that the type is correct, using case-insensitive comparison
        guard let typeString = value["type"] as? String,
              typeString.lowercased() == CardElementType.table.rawValue.lowercased() else {
            print("Type mismatch: got '\(value["type"] ?? "nil")', expected '\(CardElementType.table.rawValue)'")
            throw AdaptiveCardParseError.invalidType
        }
        
        // Use the global BaseCardElement deserialization and cast to Table.
        guard let table = try BaseCardElement.deserialize(from: value) as? Table else {
            print("Failed to cast deserialized element to Table")
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
