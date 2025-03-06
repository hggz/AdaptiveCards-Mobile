import Foundation

/// Represents a Table in an Adaptive Card.
class SwiftTable: SwiftBaseCardElement, SwiftCollectionCoreElement {
    // MARK: - Properties
    
    /// Column definitions for the table.
    let columnDefinitions: [SwiftTableColumnDefinition]
    
    /// Rows in the table.
    let rows: [SwiftTableRow]
    
    /// Whether grid lines should be shown.
    let showGridLines: Bool
    
    /// Whether the first row should be used as headers.
    let firstRowAsHeaders: Bool
    
    /// Whether the table should have rounded corners.
    let roundedCorners: Bool
    
    /// The horizontal alignment of cell content.
    let horizontalCellContentAlignment: SwiftHorizontalAlignment?
    
    /// The vertical alignment of cell content.
    let verticalCellContentAlignment: SwiftVerticalContentAlignment?
    
    /// The grid style of the table.
    let gridStyle: SwiftContainerStyle
    
    var columns: [SwiftTableColumnDefinition] {
        return self.columnDefinitions
    }
    
    // MARK: - Codable Implementation
    
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
    
    // MARK: - Initializers
    
    /// Decodes a `Table` from JSON.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        columnDefinitions = try container.decodeIfPresent([SwiftTableColumnDefinition].self, forKey: .columns) ?? []
        rows = try container.decodeIfPresent([SwiftTableRow].self, forKey: .rows) ?? []
        showGridLines = try container.decodeIfPresent(Bool.self, forKey: .showGridLines) ?? true
        firstRowAsHeaders = try container.decodeIfPresent(Bool.self, forKey: .firstRowAsHeaders) ?? true
        roundedCorners = try container.decodeIfPresent(Bool.self, forKey: .roundedCorners) ?? false
        horizontalCellContentAlignment = try container.decodeIfPresent(SwiftHorizontalAlignment.self, forKey: .horizontalCellContentAlignment)
        verticalCellContentAlignment = try container.decodeIfPresent(SwiftVerticalContentAlignment.self, forKey: .verticalCellContentAlignment)
        
        // Handle grid style
        if let gridStyleString = try container.decodeIfPresent(String.self, forKey: .gridStyle) {
            gridStyle = SwiftContainerStyle.fromString(gridStyleString)
        } else {
            gridStyle = .none
        }
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Clear additional properties and set known properties
        self.additionalProperties = nil
        populateKnownPropertiesSet()
        
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
    
    // MARK: - Serialization to JSON
    
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
    
    // MARK: - SwiftCollectionCoreElement Implementation
    
    /// Conforms to CollectionCoreElement.
    func deserializeChildren(from json: [String: Any]) throws {
        // Table handles child deserialization within its custom logic.
    }
}
