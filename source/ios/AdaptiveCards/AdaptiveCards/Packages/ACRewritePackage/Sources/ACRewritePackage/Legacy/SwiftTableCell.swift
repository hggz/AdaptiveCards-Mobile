import Foundation

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
