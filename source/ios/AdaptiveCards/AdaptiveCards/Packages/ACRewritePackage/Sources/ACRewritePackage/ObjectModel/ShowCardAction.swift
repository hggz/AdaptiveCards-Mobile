import Foundation

/// Represents an action that displays a card when triggered.
class ShowCardAction: BaseActionElement, Codable {
    var card: AdaptiveCard?

    /// Default initializer
    init(card: AdaptiveCard? = nil) {
        self.card = card
        super.init(actionType: .showCard)
    }

    /// Decodes a `ShowCardAction` from a JSON dictionary.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.card = try container.decodeIfPresent(AdaptiveCard.self, forKey: .card)
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
        if card?.language.isEmpty ?? true {
            card?.language = language
        }
    }

    /// Populates the known properties set.
    override func populateKnownPropertiesSet() {
        knownProperties.insert(AdaptiveCardSchemaKey.card.rawValue)
    }

    /// Retrieves resource information from the card.
    override func getResourceInformation() -> [RemoteResourceInformation] {
        return card?.getResourceInformation() ?? []
    }

    /// Decodes a `ShowCardAction` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> ShowCardAction {
        let base = try BaseActionElement.deserialize(from: json) as ShowCardAction
        let cardJson = json[AdaptiveCardSchemaKey.card.rawValue] as? [String: Any]
        base.card = try cardJson.map { try AdaptiveCard.deserialize(from: $0) }
        return base
    }

    /// Decodes a `ShowCardAction` from a JSON string.
    static func deserialize(from jsonString: String) throws -> ShowCardAction {
        let json = try ParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(from: json)
    }

    /// Encodes `ShowCardAction` to a JSON dictionary.
    override func serializeToJsonValue() -> [String: Any] {
        var json = super.serializeToJsonValue()
        if let card = card {
            json[AdaptiveCardSchemaKey.card.rawValue] = card.serializeToJsonValue()
        }
        return json
    }

    /// Encodes `ShowCardAction` to a JSON string.
    override func serialize() throws -> String {
        return try ParseUtil.jsonToString(serializeToJsonValue())
    }

    /// Coding keys for serialization.
    private enum CodingKeys: String, CodingKey {
        case card = "card"
    }
}
