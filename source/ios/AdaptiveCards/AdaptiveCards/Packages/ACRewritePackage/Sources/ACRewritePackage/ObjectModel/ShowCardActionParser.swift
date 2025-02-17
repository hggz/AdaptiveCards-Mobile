import Foundation

/// Parser for `ShowCardAction` elements.
class ShowCardActionParser: ActionElementParser {
    
    /// Deserializes a `ShowCardAction` from a JSON dictionary.
    func deserialize(context: ParseContext, from json: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        // EITHER manually build the object:
        // let showCardAction = ShowCardAction(...)
        // parse title, iconUrl, etc. from the dictionary
        
        // OR decode it with JSONDecoder:
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let showCardAction = try JSONDecoder().decode(ShowCardAction.self, from: data)
            
            // Now parse the sub-card if present
            if let cardObj = json[AdaptiveCardSchemaKey.card.rawValue] as? [String: Any] {
                let subCard = try AdaptiveCard.deserialize(from: cardObj)
                showCardAction.card = subCard
            }
            return showCardAction
        } catch {
            throw error
        }
    }

    /// Deserializes a `ShowCardAction` from a JSON string.
    func deserialize(fromString jsonString: String, context: ParseContext) throws -> any AdaptiveCardElementProtocol {
        let json = try ParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(context: context, from: json)
    }
}
