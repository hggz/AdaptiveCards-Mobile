import Foundation

/// Represents a TableCell in an Adaptive Card.
/// This class now subclasses our updated Container.
class TableCell: Container {
    
    var isOrphaned: Bool = true
    
    /// Initializes a `TableCell` with default values.
    init() {
        // Call the designated initializer with CardElementType.tableCell.
        super.init(items: [], layouts: [], rtl: nil, cardElementType: .tableCell)
    }
    
    private enum CodingKeys: String, CodingKey {
        case items
        case rtl
        case style
    }
    
    // New helper to check for an explicit type field in JSON.
    private enum BaseCodingKeys: String, CodingKey {
        case type
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
    
    /// Updated initializer for Codable conformance.
    required init(from decoder: Decoder) throws {
        // Call super first
        try super.init(from: decoder)
        
        // Then decode our own style explicitly
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let styleString = try container.decodeIfPresent(String.self, forKey: .style) {
            // Force the style to be set after super.init
            self.style = ContainerStyle(rawValue: styleString.capitalized) ?? .none
            print("TableCell.init - Explicitly setting style to: \(styleString.capitalized)")
        }
    }
    /// Override to report .tableCell when not orphaned.
    override var elementTypeVal: CardElementType {
        return isOrphaned ? .unknown : .tableCell
    }
    /// Deserializes a `TableCell` from a JSON dictionary.
    static func deserialize(from json: [String: Any], context: ParseContext) throws -> TableCell {
        let idProperty = json[AdaptiveCardSchemaKey.id.rawValue] as? String ?? ""
        let internalId = InternalId.next()
        
        context.pushElement(idJsonProperty: idProperty, internalId: internalId)
        
        // Convert the JSON dictionary to Data.
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        let cell = try JSONDecoder().decode(TableCell.self, from: jsonData)
        
        // Explicitly set style if provided
        if let styleString = json["style"] as? String {
            cell.style = ContainerStyle(rawValue: styleString.capitalized) ?? .none
            print("TableCell.deserialize - Explicitly setting style to: \(styleString.capitalized)")
        }
        
        // Rest of your existing deserialization code...
        if let rtl = json[AdaptiveCardSchemaKey.rtl.rawValue] as? Bool {
            cell.setRtl(rtl)
        }
        
        cell.additionalProperties = nil
        context.popElement()
        return cell
    }
    
    /// Deserializes a `TableCell` from a JSON string.
    static func deserialize(from jsonString: String, context: ParseContext) throws -> TableCell {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(from: jsonDict, context: context)
    }
    
    // In TableCell
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        
        // Add items if present
        if !items.isEmpty {
            json["items"] = try items.map { try $0.serializeToJsonValue() }
        }
        
        // Add rtl if present
        if let rtl = self.rtl {
            json["rtl"] = rtl
        }
        
        // Add style with proper capitalization if not .none
        print("TableCell serializeToJsonValue - current style: \(style)")
        if style != .none {
            json["style"] = style.rawValue  // Use rawValue to get capitalized version
            print("TableCell serializeToJsonValue - set style to: \(style.rawValue)")
        }
        
        return json
    }
}
