import Foundation

/// Represents a TableCell in an Adaptive Card.
class TableCell: Container {
    /// Initializes a `TableCell` with default values.
    override init() {
        super.init(cardElementType: .tableCell)
    }

    /// Deserializes a `TableCell` from a JSON dictionary.
    static func deserialize(from json: [String: Any], context: inout ParseContext) throws -> TableCell {
        let idProperty = json[AdaptiveCardSchemaKey.id.rawValue] as? String ?? ""
        let internalId = InternalId.next()
        
        context.pushElement(id: idProperty, internalId: internalId)
        
        let cell = try StyledCollectionElement.deserialize(type: TableCell.self, from: json, context: &context)
        
        if let rtl = json[AdaptiveCardSchemaKey.rtl.rawValue] as? Bool {
            cell.setRtl(rtl)
        }

        if let layoutArray = json[AdaptiveCardSchemaKey.layouts.rawValue] as? [[String: Any]], !layoutArray.isEmpty {
            var layouts: [Layout] = []
            
            for layoutJson in layoutArray {
                let layout = try Layout.deserialize(from: layoutJson)
                
                switch layout.layoutContainerType {
                case .flow:
                    layouts.append(try FlowLayout.deserialize(from: layoutJson))
                case .areaGrid:
                    let areaGridLayout = try AreaGridLayout.deserialize(from: layoutJson)
                    
                    if areaGridLayout.areas.isEmpty && areaGridLayout.columns.isEmpty {
                        let stackLayout = Layout()
                        stackLayout.layoutContainerType = .stack
                        layouts.append(stackLayout)
                    } else if areaGridLayout.areas.isEmpty {
                        let flowLayout = FlowLayout()
                        flowLayout.layoutContainerType = .flow
                        layouts.append(flowLayout)
                    } else {
                        layouts.append(areaGridLayout)
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
    static func deserialize(from jsonString: String, context: inout ParseContext) throws -> TableCell {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardError.invalidJson
        }
        return try deserialize(from: jsonDict, context: &context)
    }
}
