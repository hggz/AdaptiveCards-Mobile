import Foundation

/// Represents a Table in an Adaptive Card.
class SwiftTable: SwiftBaseCardElement, SwiftCollectionCoreElement {
    /// Column definitions for the table.
    var columnDefinitions: [SwiftTableColumnDefinition]
    
    /// Rows in the table.
    var rows: [SwiftTableRow]
    
    /// Whether grid lines should be shown.
    var showGridLines: Bool
    
    /// Whether the first row should be used as headers.
    var firstRowAsHeaders: Bool
    
    /// Whether the table should have rounded corners.
    var roundedCorners: Bool
    
    /// The horizontal alignment of cell content.
    var horizontalCellContentAlignment: SwiftHorizontalAlignment?
    
    /// The vertical alignment of cell content.
    var verticalCellContentAlignment: SwiftVerticalContentAlignment?
    
    /// The grid style of the table.
    var gridStyle: SwiftContainerStyle
    
    var columns: [SwiftTableColumnDefinition] {
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
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.columnDefinitions = try container.decodeIfPresent([SwiftTableColumnDefinition].self, forKey: .columns) ?? []
        self.rows = try container.decodeIfPresent([SwiftTableRow].self, forKey: .rows) ?? []
        self.showGridLines = try container.decodeIfPresent(Bool.self, forKey: .showGridLines) ?? true
        self.firstRowAsHeaders = try container.decodeIfPresent(Bool.self, forKey: .firstRowAsHeaders) ?? true
        self.roundedCorners = try container.decodeIfPresent(Bool.self, forKey: .roundedCorners) ?? false
        self.horizontalCellContentAlignment = try container.decodeIfPresent(SwiftHorizontalAlignment.self, forKey: .horizontalCellContentAlignment)
        self.verticalCellContentAlignment = try container.decodeIfPresent(SwiftVerticalContentAlignment.self, forKey: .verticalCellContentAlignment)
        if let gridStyleString = try container.decodeIfPresent(String.self, forKey: .gridStyle) {
            self.gridStyle = SwiftContainerStyle.fromString(gridStyleString)
        } else {
            self.gridStyle = .none
        }
        
        try super.init(from: decoder)
        self.additionalProperties = nil
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
        
        // Mark all deserialized rows (and their cells) as non-orphaned.
        for row in self.rows {
            row.isOrphaned = false
            for cell in row.cells {
                cell.isOrphaned = false
            }
        }
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
            try container.encode(gridStyle, forKey: .gridStyle)  // Let enum handle it
        }
    }

    /// Sets the collection of columns.
    func setColumns(_ value: [SwiftTableColumnDefinition]) {
        self.columnDefinitions = value
    }

    /// Sets the collection of rows.
    func setRows(_ value: [SwiftTableRow]) {
        self.rows = value
    }
    
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        
        // Only include non-empty arrays
        if !columnDefinitions.isEmpty {
            json["columns"] = try columnDefinitions.map { try $0.serializeToJsonValue() }
        }
        
        if !rows.isEmpty {
            json["rows"] = try rows.map { try $0.serializeToJsonValue() }
        }
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
            json["gridStyle"] = SwiftContainerStyle.toString(gridStyle)  // Use toString
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
struct SwiftTableParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        // Verify that the type is correct, using case-insensitive comparison
        guard let typeString = value["type"] as? String,
              typeString.lowercased() == SwiftCardElementType.table.rawValue.lowercased() else {
            print("Type mismatch: got '\(value["type"] ?? "nil")', expected '\(SwiftCardElementType.table.rawValue)'")
            throw AdaptiveCardParseError.invalidType
        }
        
        // Use the global BaseCardElement deserialization and cast to Table.
        guard let table = try SwiftBaseCardElement.deserialize(from: value) as? SwiftTable else {
            print("Failed to cast deserialized element to Table")
            throw AdaptiveCardParseError.invalidType
        }
        return table
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        let jsonDict = try SwiftParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}

extension SwiftTableParser {
    func deserialize(from value: String, context: SwiftParseContext) throws -> any SwiftAdaptiveCardElementProtocol {
        return try self.deserialize(fromString: context, value: value)
    }
}
