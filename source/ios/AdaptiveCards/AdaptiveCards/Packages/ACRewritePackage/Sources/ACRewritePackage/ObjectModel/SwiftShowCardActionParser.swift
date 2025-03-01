import Foundation

/// Parser for `ShowCardAction` elements.
class SwiftShowCardActionParser: SwiftActionElementParser {
    
    /// Deserializes a `ShowCardAction` from a JSON dictionary.
    func deserialize(context: SwiftParseContext, from json: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        // EITHER manually build the object:
        // let showCardAction = ShowCardAction(...)
        // parse title, iconUrl, etc. from the dictionary
        
        // OR decode it with JSONDecoder:
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let showCardAction = try JSONDecoder().decode(SwiftShowCardAction.self, from: data)
            
            // Now parse the sub-card if present
            if let cardObj = json[SwiftAdaptiveCardSchemaKey.card.rawValue] as? [String: Any] {
                let subCard = try SwiftAdaptiveCard.deserialize(from: cardObj)
                showCardAction.card = subCard
            }
            return showCardAction
        } catch {
            throw error
        }
    }

    /// Deserializes a `ShowCardAction` from a JSON string.
    func deserialize(fromString jsonString: String, context: SwiftParseContext) throws -> any SwiftAdaptiveCardElementProtocol {
        let json = try SwiftParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(context: context, from: json)
    }
}
