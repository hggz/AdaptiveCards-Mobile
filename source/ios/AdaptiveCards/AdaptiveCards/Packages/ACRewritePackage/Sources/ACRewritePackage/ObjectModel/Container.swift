import Foundation

/// Represents a Container element in an Adaptive Card.
class Container: StyledCollectionElement {
    var items: [BaseCardElement]
    var layouts: [Layout]
    var rtl: Bool?

    /// Designated initializer accepting a card element type.
    init(items: [BaseCardElement] = [],
         layouts: [Layout] = [],
         rtl: Bool? = nil,
         cardElementType: CardElementType = .container) {
        self.items = items
        self.layouts = layouts
        self.rtl = rtl
        // Call BaseCardElement initializer (adjust parameters as needed).
        super.init(type: cardElementType)
    }

    /// Required initializer for Codable conformance (inherited from BaseCardElement).
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode "items" polymorphically
        if let rawItems = try container.decodeIfPresent([[String: AnyCodable]].self, forKey: .items) {
            self.items = try rawItems.map { rawDict in
                let unwrapped = ParseUtil.unwrapAnyCodable(from: rawDict)
                guard let dict = unwrapped as? [String: Any] else {
                    throw AdaptiveCardParseError.invalidJson
                }
                return try BaseCardElement.deserialize(from: dict)
            }
        } else {
            self.items = []
        }
        
        // Same for layouts if you want them to be dynamic.
        // (But your Layout is likely a single type, so you can keep it as is or do the same approach.)
        self.layouts = try container.decodeIfPresent([Layout].self, forKey: .layouts) ?? []

        self.rtl = try container.decodeIfPresent(Bool.self, forKey: .rtl)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(items, forKey: .items)
        try container.encode(layouts, forKey: .layouts)
        try container.encodeIfPresent(rtl, forKey: .rtl)
        try super.encode(to: encoder)
    }

    private enum CodingKeys: String, CodingKey {
        case items, layouts, rtl
    }

    // Helper methods for other elements (e.g. TableCell) to use.
    func setRtl(_ rtl: Bool) {
        self.rtl = rtl
    }

    func setLayouts(_ layouts: [Layout]) {
        self.layouts = layouts
    }
}

/// MARK: - Parser for Container

/// Parses a Container element from JSON.
struct ContainerParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        // Use the BaseCardElement deserialization extension and then cast.
        guard let container = try BaseCardElement.deserialize(from: value) as? Container else {
            throw AdaptiveCardParseError.invalidType
        }
        return container
    }

    func deserialize(fromString context: ParseContext, value: String) throws -> any AdaptiveCardElementProtocol {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
