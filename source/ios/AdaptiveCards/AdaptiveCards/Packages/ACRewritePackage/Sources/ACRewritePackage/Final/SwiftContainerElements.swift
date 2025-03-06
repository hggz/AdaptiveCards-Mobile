import Foundation

protocol SwiftCollectionCoreElement: SwiftBaseCardElement {
    // Remove 'mutating' since BaseCardElement is a class.
    func deserializeChildren(from json: [String: Any]) throws
    
    static func deserialize<T: SwiftCollectionCoreElement>(from json: [String: Any], context: SwiftParseContext) throws -> T
}

extension SwiftCollectionCoreElement {
    static func deserialize<T: SwiftCollectionCoreElement>(from json: [String: Any], context: SwiftParseContext) throws -> T {
        // Call the BaseCardElement deserializer without a context parameter.
        let collection = try SwiftBaseCardElement.deserialize(from: json) as! T
        
        let canFallbackToAncestor = context.canFallbackToAncestor
        context.canFallbackToAncestor = canFallbackToAncestor || (collection.fallbackType != SwiftFallbackType.none)
        collection.canFallbackToAncestor = canFallbackToAncestor
        
        try collection.deserializeChildren(from: json)
        
        context.canFallbackToAncestor = canFallbackToAncestor
        
        return collection
    }
    
    func getResourceInformation<T: SwiftBaseCardElement>(_ elements: [T]) -> [SwiftRemoteResourceInformation] {
        return elements.flatMap { $0.getResourceInformation() }
    }
}

extension SwiftBaseCardElement {
    func getResourceInformation() -> [SwiftRemoteResourceInformation] {
        return []
    }
}

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

/// Represents a TableCell in an Adaptive Card.
/// This class now subclasses our updated Container.
class SwiftTableCell: SwiftContainer {
    // MARK: - Properties
    
    var isOrphaned: Bool = true
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case items
        case rtl
        case style
    }
    
    /// Updated initializer for Codable conformance.
    required init(from decoder: Decoder) throws {
        // Call super first
        try super.init(from: decoder)
        
        // Then decode our own style explicitly
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let styleString = try container.decodeIfPresent(String.self, forKey: .style) {
            // Force the style to be set after super.init
            self.style = SwiftContainerStyle(rawValue: styleString.capitalized) ?? .none
        }
    }
    
    override func encode(to encoder: Encoder) throws {
        // First encode the Container properties
        try super.encode(to: encoder)
        
        // Then encode our local properties
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode non-empty items array
        if !items.isEmpty {
            try container.encode(items, forKey: .items)
        }
        
        // Encode RTL if present
        if let rtl = self.rtl {
            try container.encode(rtl, forKey: .rtl)
        }
        
        // Encode style with proper capitalization if not .none
        if style != .none {
            let styleString = style.rawValue  // Use rawValue directly to preserve case
            try container.encode(styleString, forKey: .style)
        }
    }
    
    // MARK: - Type Information
    
    /// Override to report .tableCell when not orphaned.
    override var elementTypeVal: SwiftCardElementType {
        return isOrphaned ? .unknown : .tableCell
    }
    
    // MARK: - Serialization to JSON
    
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
}

// MARK: - TableColumnDefinition

/// A Swift port of the C++ TableColumnDefinition.
/// This structure is Codable, uses value semantics, and enforces that
/// setting a relative width resets an explicit pixel width and vice versa.
struct SwiftTableColumnDefinition: Codable {
    // MARK: - Properties
    
    /// Optional horizontal alignment for cell content.
    /// Defaults to `.left` in the default initializer.
    var horizontalCellContentAlignment: SwiftHorizontalAlignment?
    
    /// Optional vertical alignment for cell content.
    /// Defaults to `.top` in the default initializer.
    var verticalCellContentAlignment: SwiftVerticalContentAlignment?
    
    /// The relative width (e.g. "2") of the column.
    /// Setting this will reset `pixelWidth`.
    var width: UInt? {
        didSet {
            if width != nil {
                pixelWidth = nil
            }
        }
    }
    
    /// The explicit pixel width (e.g. "100px") of the column.
    /// Setting this will reset `width`.
    var pixelWidth: UInt? {
        didSet {
            if pixelWidth != nil {
                width = nil
            }
        }
    }
    // MARK: - Codable Implementation
    
    /// Maps the property names to JSON keys.
    enum CodingKeys: String, CodingKey {
        case horizontalCellContentAlignment
        case verticalCellContentAlignment
        case width
    }
    
    /// Custom initializer for decoding.
    /// Handles the "width" field, which can be either an unsigned integer or a string with a "px" suffix.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode horizontal alignment with default
        if let horizontalString = try container.decodeIfPresent(String.self, forKey: .horizontalCellContentAlignment) {
            self.horizontalCellContentAlignment = SwiftHorizontalAlignment(rawValue: horizontalString.lowercased()) ?? .left
        } else {
            self.horizontalCellContentAlignment = .left
        }
        
        // Decode vertical alignment with default
        if let verticalString = try container.decodeIfPresent(String.self, forKey: .verticalCellContentAlignment) {
            self.verticalCellContentAlignment = SwiftVerticalContentAlignment(from: verticalString)
        } else {
            self.verticalCellContentAlignment = .top
        }
        
        // Decode the "width" field
        if container.contains(.width) {
            if let intValue = try? container.decode(UInt.self, forKey: .width) {
                self.width = intValue
                self.pixelWidth = nil
            } else if let stringValue = try? container.decode(String.self, forKey: .width) {
                if stringValue.hasSuffix("px") {
                    let numberPart = stringValue.dropLast(2)
                    if let pixelValue = UInt(numberPart) {
                        self.pixelWidth = pixelValue
                        self.width = nil
                    } else {
                        self.width = nil
                        self.pixelWidth = nil
                    }
                } else {
                    // When the unit is missing, do not set either width or pixelWidth.
                    self.width = nil
                    self.pixelWidth = nil
                }
            } else {
                throw DecodingError.dataCorruptedError(forKey: .width,
                                                      in: container,
                                                      debugDescription: "Invalid type for width")
            }
        } else {
            self.width = nil
            self.pixelWidth = nil
        }
    }
    
    /// Custom encoding to handle the "width" field.
    /// If `pixelWidth` is set, it takes precedence over `width` and is encoded as a string with a "px" suffix.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode the alignment values if present
        if let horizontal = horizontalCellContentAlignment {
            try container.encode(horizontal.rawValue, forKey: .horizontalCellContentAlignment)
        }
        
        if let vertical = verticalCellContentAlignment {
            try container.encode(vertical.rawValue, forKey: .verticalCellContentAlignment)
        }
        
        // Encode width or pixelWidth (prioritize pixelWidth)
        if let pixelWidth = pixelWidth {
            try container.encode("\(pixelWidth)px", forKey: .width)
        } else if let width = width {
            try container.encode(width, forKey: .width)
        }
    }
    
    // MARK: - Serialization to JSON
    
    /// Serializes the current instance to a JSON dictionary
    func serializeToJsonValue() throws -> [String: Any] {
        return try SwiftTableColumnDefinitionLegacySupport.serializeToJson(self)
    }
}
