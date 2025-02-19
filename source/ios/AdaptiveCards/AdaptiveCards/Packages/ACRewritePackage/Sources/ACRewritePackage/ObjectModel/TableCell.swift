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
            let styleString = style.rawValue.prefix(1).uppercased() + style.rawValue.dropFirst()
            try container.encode(styleString, forKey: .style)
        }
    }
    
    /// Updated initializer for Codable conformance.
    required init(from decoder: Decoder) throws {
        // (Our previous changes to check for an explicit "type" are still useful
        // for ensuring we call the correct initializer; see previous solution.)
        let baseContainer = try decoder.container(keyedBy: BaseCodingKeys.self)
        if !baseContainer.contains(.type) {
            // No explicit "type" → use the designated initializer.
            super.init(items: [], layouts: [], rtl: nil, cardElementType: .tableCell)
        } else {
            try super.init(from: decoder)
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let styleString = try container.decodeIfPresent(String.self, forKey: .style) {
            style = ContainerStyle(rawValue: styleString.lowercased()) ?? .none
        }
    }
    
    /// Override to report .tableCell when not orphaned.
    override var elementTypeVal: CardElementType {
        return isOrphaned ? .unknown : .tableCell
    }
    /// Deserializes a `TableCell` from a JSON dictionary.
    static func deserialize(from json: [String: Any], context: ParseContext) throws -> TableCell {
        // Retrieve the id property using the expected key.
        let idProperty = json[AdaptiveCardSchemaKey.id.rawValue] as? String ?? ""
        let internalId = InternalId.next()
        
        // Push the element into the parse context.
        context.pushElement(idJsonProperty: idProperty, internalId: internalId)
        
        // Convert the JSON dictionary to Data.
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        let cell = try JSONDecoder().decode(TableCell.self, from: jsonData)
        
        // Set RTL if provided (as before) …
        if let rtl = json[AdaptiveCardSchemaKey.rtl.rawValue] as? Bool {
            cell.setRtl(rtl)
        }
        
        // Set style if provided in the JSON
        if let styleString = json["style"] as? String {
            cell.style = ContainerStyle(rawValue: styleString.lowercased()) ?? .none
        }
        
        // Process layouts if provided.
        if let layoutArray = json[AdaptiveCardSchemaKey.layouts.rawValue] as? [[String: Any]], !layoutArray.isEmpty {
            var layouts: [Layout] = []
            
            for layoutJson in layoutArray {
                // Attempt to decode a generic Layout from the JSON.
                guard let layout = Layout.fromJSON(layoutJson) else {
                    continue
                }
                
                switch layout.layoutContainerType {
                case .flow:
                    // Use dictionary‑based deserialization for FlowLayout.
                    let flowLayout = try FlowLayout.deserialize(from: layoutJson)
                    layouts.append(Layout(fromFlowLayout: flowLayout))
                case .areaGrid:
                    // Dictionary‑based deserialization for AreaGridLayout.
                    let areaGridLayout = AreaGridLayout.deserialize(from: layoutJson)
                    if areaGridLayout.areas.isEmpty && areaGridLayout.columns.isEmpty {
                        var stackLayout = Layout(fromAreaGridLayout: areaGridLayout)
                        stackLayout.layoutContainerType = .stack
                        layouts.append(stackLayout)
                    } else if areaGridLayout.areas.isEmpty {
                        let flowLayout = try FlowLayout.deserialize(from: layoutJson)
                        layouts.append(Layout(fromFlowLayout: flowLayout))
                    } else {
                        layouts.append(Layout(fromAreaGridLayout: areaGridLayout))
                    }
                default:
                    layouts.append(layout)
                }
            }
            cell.setLayouts(layouts)
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
        if style != .none {
            json["style"] = style.rawValue.prefix(1).uppercased() + style.rawValue.dropFirst()
        }
        
        return json
    }
}
