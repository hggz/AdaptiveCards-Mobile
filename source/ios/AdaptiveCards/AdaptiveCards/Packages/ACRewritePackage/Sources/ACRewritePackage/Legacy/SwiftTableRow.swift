import Foundation

/// Represents a TableRow in an Adaptive Card.
class SwiftTableRow: SwiftBaseCardElement {
    // MARK: - Properties
    
    /// The style of the row.
    var style: SwiftContainerStyle
    
    /// The horizontal alignment of cell content.
    var horizontalCellContentAlignment: SwiftHorizontalAlignment?
    
    /// The vertical alignment of cell content.
    var verticalCellContentAlignment: SwiftVerticalContentAlignment?
    
    /// The collection of table cells in the row.
    var cells: [SwiftTableCell]
    
    /// Indicates if this row is not connected to a parent table.
    var isOrphaned: Bool = true
    
    override var elementTypeVal: SwiftCardElementType {
        return isOrphaned ? .unknown : .tableRow
    }
    
    // MARK: - Initializers
    
    /// Initializes a new `TableRow` with default values.
    init() {
        self.style = .none
        self.horizontalCellContentAlignment = .left
        self.verticalCellContentAlignment = .top
        self.cells = []
        super.init(type: .tableRow)
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case style
        case horizontalCellContentAlignment
        case verticalCellContentAlignment
        case cells
    }
    
    /// Decodes a `TableRow` from JSON.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode properties before super.init
        style = try container.decodeIfPresent(SwiftContainerStyle.self, forKey: .style) ?? .none
        horizontalCellContentAlignment = try container.decodeIfPresent(SwiftHorizontalAlignment.self, forKey: .horizontalCellContentAlignment)
        verticalCellContentAlignment = try container.decodeIfPresent(SwiftVerticalContentAlignment.self, forKey: .verticalCellContentAlignment)
        cells = try container.decodeIfPresent([SwiftTableCell].self, forKey: .cells) ?? []
        
        // Call super.init
        try super.init(from: decoder)
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
            try container.encode(style.rawValue, forKey: .style)
        }
        
        // Encode alignments if present
        if let horizontal = horizontalCellContentAlignment {
            try container.encode(horizontal.rawValue, forKey: .horizontalCellContentAlignment)
        }
        if let vertical = verticalCellContentAlignment {
            try container.encode(vertical.rawValue.capitalized, forKey: .verticalCellContentAlignment)
        }
    }
    
    // MARK: - Serialization to JSON
    
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
}
