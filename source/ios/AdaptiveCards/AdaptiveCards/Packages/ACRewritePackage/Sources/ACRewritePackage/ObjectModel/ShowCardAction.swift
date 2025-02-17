import Foundation

/// Represents an action that displays a card when triggered.
class ShowCardAction: BaseActionElement {
    var card: AdaptiveCard?

    /// Default initializer
    init(card: AdaptiveCard? = nil) {
        self.card = card
        // Use the correct parameter name for the base initializer.
        super.init(type: .showCard)
    }

    /// Decodes a `ShowCardAction` from a JSON dictionary.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.card) {
            let cardDict = try container.decode([String: AnyCodable].self, forKey: .card)
            let dict = cardDict.mapValues { $0.value }
            // IMPORTANT: parse as an AdaptiveCard, not BaseCardElement
            self.card = try AdaptiveCard.deserialize(from: dict)
        }
        try super.init(from: decoder)
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
    static func deserializeShowCardAction(from json: [String: Any]) throws -> ShowCardAction {
        let showCardAction = ShowCardAction()
        if let cardJson = json[AdaptiveCardSchemaKey.card.rawValue] as? [String: Any] {
            showCardAction.card = try AdaptiveCard.deserialize(from: cardJson)
        }
        return showCardAction
    }

    /// Decodes a `ShowCardAction` from a JSON string.
    static func deserializeShowCardAction(from jsonString: String) throws -> ShowCardAction {
        let json = try ParseUtil.getJsonDictionary(from: jsonString)
        return try deserializeShowCardAction(from: json)
    }

    /// Encodes `ShowCardAction` to a JSON dictionary.
    override func serializeToJsonValue() -> [String: Any] {
        var json = [String: Any]()
        if let card = card {
            json[AdaptiveCardSchemaKey.card.rawValue] = card.serializeToJsonValue()
        }
        return json
    }

    /// Encodes `ShowCardAction` to a JSON string.
    func serialize() throws -> String {
        return try ParseUtil.jsonToString(serializeToJsonValue())
    }

    /// Coding keys for serialization.
    private enum CodingKeys: String, CodingKey {
        case card = "card"
    }
}
