import Foundation

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
