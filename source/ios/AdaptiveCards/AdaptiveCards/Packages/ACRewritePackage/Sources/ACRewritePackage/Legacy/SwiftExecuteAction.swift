import Foundation

/// Represents the execute action element.
final class SwiftExecuteAction: SwiftBaseActionElement {
    // MARK: - Properties
    var dataJson: [String: AnyCodable]?
    var verb: String
    var associatedInputs: SwiftAssociatedInputs
    var conditionallyEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case dataJson = "data"
        case verb
        case associatedInputs
        case conditionallyEnabled
    }

    // MARK: - Initializers

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dataJson = try container.decodeIfPresent([String: AnyCodable].self, forKey: .dataJson)
        self.verb = try container.decodeIfPresent(String.self, forKey: .verb) ?? ""
        self.associatedInputs = try container.decodeIfPresent(SwiftAssociatedInputs.self, forKey: .associatedInputs) ?? .auto
        self.conditionallyEnabled = try container.decodeIfPresent(Bool.self, forKey: .conditionallyEnabled) ?? false
        try super.init(from: decoder)
        
        // Filter additionalProperties to remove known keys.
        if var additional = self.additionalProperties {
            let knownKeys: Set<String> = [
                "data", "verb", "associatedInputs", "conditionallyEnabled",
                "title", "iconUrl", "style", "tooltip", "mode", "isEnabled", "role", "type", "id"
            ]
            additional = additional.filter { !knownKeys.contains($0.key) }
            self.additionalProperties = additional.isEmpty ? nil : additional
        }
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(dataJson, forKey: .dataJson)
        try container.encode(verb, forKey: .verb)
        try container.encode(associatedInputs, forKey: .associatedInputs)
        try container.encode(conditionallyEnabled, forKey: .conditionallyEnabled)
    }
}
