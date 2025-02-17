import Foundation

/// Represents a compound button element in an Adaptive Card.
class CompoundButton: BaseCardElement {
    // MARK: - Properties
    var badge: String?
    var title: String?           // Inherited name "title" is now unique since we subclass BaseCardElement.
    var buttonDescription: String?  // Renamed from "description" to avoid conflict with Swift's 'description'.
    var icon: IconInfo?
    var selectAction: BaseActionElement?

    private enum CodingKeys: String, CodingKey {
        case badge, title, buttonDescription = "description", icon, selectAction
    }

    // MARK: - Initializers

    /// Designated initializer.
    init(
        badge: String? = nil,
        title: String? = nil,
        buttonDescription: String? = nil,
        icon: IconInfo? = nil,
        selectAction: BaseActionElement? = nil,
        id: String? = nil
    ) {
        self.badge = badge
        self.title = title
        self.buttonDescription = buttonDescription
        self.icon = icon
        self.selectAction = selectAction
        // Use the appropriate CardElementType (assuming .compoundButton exists in CardElementType).
        super.init(type: .compoundButton, id: id)
    }

    /// Required initializer for decoding.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.badge = try container.decodeIfPresent(String.self, forKey: .badge)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.buttonDescription = try container.decodeIfPresent(String.self, forKey: .buttonDescription)
        self.icon = try container.decodeIfPresent(IconInfo.self, forKey: .icon)
        self.selectAction = try container.decodeIfPresent(BaseActionElement.self, forKey: .selectAction)
        try super.init(from: decoder)
    }

    /// Encodes this CompoundButton to JSON.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(badge, forKey: .badge)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(buttonDescription, forKey: .buttonDescription)
        try container.encodeIfPresent(icon, forKey: .icon)
        try container.encodeIfPresent(selectAction, forKey: .selectAction)
        try super.encode(to: encoder)
    }
}

/// Parses CompoundButton elements in an Adaptive Card.
struct CompoundButtonParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        // Verify that the type in the JSON matches CompoundButton.
        guard let typeString = value["type"] as? String,
              typeString == CardElementType.compoundButton.rawValue else {
            throw AdaptiveCardParseError.invalidType
        }
        // Use the global BaseCardElement deserialization helper and cast to CompoundButton.
        guard let compoundButton = try BaseCardElement.deserialize(from: value) as? CompoundButton else {
            throw AdaptiveCardParseError.invalidType
        }
        return compoundButton
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> any AdaptiveCardElementProtocol {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
