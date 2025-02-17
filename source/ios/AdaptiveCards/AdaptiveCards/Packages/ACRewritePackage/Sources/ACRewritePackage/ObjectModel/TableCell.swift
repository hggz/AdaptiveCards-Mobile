import Foundation

/// Represents a TableCell in an Adaptive Card.
/// This class now subclasses our updated Container.
class TableCell: Container {
    
    /// Initializes a `TableCell` with default values.
    init() {
        // Call the designated initializer with CardElementType.tableCell.
        super.init(items: [], layouts: [], rtl: nil, cardElementType: .tableCell)
    }
    
    /// Required initializer for Codable conformance.
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
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
        
        // Set RTL if provided.
        if let rtl = json[AdaptiveCardSchemaKey.rtl.rawValue] as? Bool {
            cell.setRtl(rtl)
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
}
