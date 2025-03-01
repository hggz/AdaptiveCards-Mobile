import Foundation

/// Represents an action that displays a card when triggered.
class SwiftShowCardAction: SwiftBaseActionElement {
    var card: SwiftAdaptiveCard?

    /// Default initializer
    init(card: SwiftAdaptiveCard? = nil) {
        self.card = card
        // Use the correct parameter name for the base initializer.
        super.init(type: .showCard)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.card = try container.decodeIfPresent(SwiftAdaptiveCard.self, forKey: .card)
        try super.init(from: decoder)
        
        // Filter out known keys so that additionalProperties becomes empty if no extra keys were provided.
        if var additional = self.additionalProperties {
            let knownKeys: Set<String> = [
                "card",
                "title", "iconUrl", "style", "tooltip", "mode", "isEnabled", "role", "type", "id"
            ]
            additional = additional.filter { !knownKeys.contains($0.key) }
            self.additionalProperties = additional.isEmpty ? nil : additional
        }
    }

    /// Encodes `ShowCardAction` to a JSON dictionary.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(card, forKey: .card)
        try super.encode(to: encoder)
    }

    /// Sets the language for the card if it does not already specify a language.
    func setLanguage(_ language: String) {
        // If card?.language is nil, treat it as empty.
        if (card?.language ?? "").isEmpty {
            card?.language = language
        }
    }

    /// Decodes a `ShowCardAction` from a JSON dictionary.
    /// (Renamed to avoid conflict with BaseActionElement’s deserialize(from:) defined in an extension.)
    static func deserializeShowCardAction(from json: [String: Any]) throws -> SwiftShowCardAction {
        let showCardAction = SwiftShowCardAction()
        if let cardJson = json[SwiftAdaptiveCardSchemaKey.card.rawValue] as? [String: Any] {
            showCardAction.card = try SwiftAdaptiveCard.deserialize(from: cardJson)
        }
        return showCardAction
    }

    /// Decodes a `ShowCardAction` from a JSON string.
    static func deserializeShowCardAction(from jsonString: String) throws -> SwiftShowCardAction {
        let json = try SwiftParseUtil.getJsonDictionary(from: jsonString)
        return try deserializeShowCardAction(from: json)
    }

    /// Encodes `ShowCardAction` to a JSON dictionary.
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = [String: Any]()
        if let card = card {
            // Get the card's JSON
            var cardJson = try card.serializeToJsonValue()
            // Force fallback-related keys to non-nil defaults
            cardJson[SwiftAdaptiveCardSchemaKey.fallbackText.rawValue] = card.fallbackText ?? ""
            cardJson[SwiftAdaptiveCardSchemaKey.speak.rawValue] = card.speak ?? ""
            // For language, if missing, force "en"
            cardJson["lang"] = card.language ?? "en"
            // Ensure the sub-card JSON contains a type
            if cardJson["type"] == nil {
                cardJson["type"] = "AdaptiveCard"
            }
            json[SwiftAdaptiveCardSchemaKey.card.rawValue] = cardJson
        }
        return json
    }

    /// Encodes `ShowCardAction` to a JSON string.
    func serialize() throws -> String {
        return try SwiftParseUtil.jsonToString(serializeToJsonValue())
    }

    /// Coding keys for serialization.
    private enum CodingKeys: String, CodingKey {
        case card = "card"
    }
}
