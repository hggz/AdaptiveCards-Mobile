import Foundation

/// Parser for `ShowCardAction` elements.
class ShowCardActionParser: ActionElementParser {
    
    /// Deserializes a `ShowCardAction` from a JSON dictionary.
    func deserialize(context: inout ParseContext, from json: [String: Any]) throws -> BaseActionElement {
        let action = try ShowCardAction.deserializeAction(from: json)
        guard let showCardAction = action as? ShowCardAction else {
            debugPrint("unable to deserialize showcard action")
            return action
        }
        
        // Extract and parse the card
        if let cardJson = json[AdaptiveCardSchemaKey.card.rawValue] as? [String: Any] {
//            let parseResult = try AdaptiveCard.deserialize(from: cardJson, context: &context)
            let parseResult = try AdaptiveCard.deserialize(from: cardJson)

            // Append warnings from card parsing
//            context.warnings.append(contentsOf: parseResult.warnings) // TODO
            
            // Assign the parsed card to the action
            if let cardObj = json["card"] as? [String: Any] {
                let subCard = try AdaptiveCard.deserialize(from: cardObj)
                showCardAction.card = subCard
            }
        }
        
        return showCardAction
    }
    
    /// Deserializes a `ShowCardAction` from a JSON string.
    func deserialize(fromString jsonString: String, context: inout ParseContext) throws -> BaseActionElement {
        let json = try ParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(context: &context, from: json)
    }
}
