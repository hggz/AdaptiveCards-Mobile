import Foundation

/// Parser for `ShowCardAction` elements.
class ShowCardActionParser: ActionElementParser {
    
    /// Deserializes a `ShowCardAction` from a JSON dictionary.
    func deserialize(context: inout ParseContext, from json: [String: Any]) throws -> BaseActionElement {
        let showCardAction = try ShowCardAction.deserializeAction(from: json)
        
        // Extract and parse the card
        if let cardJson = json[AdaptiveCardSchemaKey.card.rawValue] as? [String: Any] {
//            let parseResult = try AdaptiveCard.deserialize(from: cardJson, context: &context)
            let parseResult = try AdaptiveCard.deserialize(from: cardJson)

            // Append warnings from card parsing
//            context.warnings.append(contentsOf: parseResult.warnings) // TODO
            
            // Assign the parsed card to the action
//            showCardAction.card = parseResult.card
        }
        
        return showCardAction
    }
    
    /// Deserializes a `ShowCardAction` from a JSON string.
    func deserialize(fromString jsonString: String, context: inout ParseContext) throws -> BaseActionElement {
        let json = try ParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(context: &context, from: json)
    }
}
