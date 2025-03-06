import Foundation

/// Represents an action that displays a card when triggered.
class SwiftShowCardAction: SwiftBaseActionElement {
    // MARK: - Properties
    var card: SwiftAdaptiveCard?

    // MARK: - Initializers

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

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(card, forKey: .card)
        try super.encode(to: encoder)
    }
    // MARK: - Coding Keys

    private enum CodingKeys: String, CodingKey {
        case card = "card"
    }
}
