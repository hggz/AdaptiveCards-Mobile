import Foundation

/// Represents a Container element in an Adaptive Card.
class Container: BaseCardElement {
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
        self.items = try container.decode([BaseCardElement].self, forKey: .items)
        self.layouts = try container.decode([Layout].self, forKey: .layouts)
        self.rtl = try container.decodeIfPresent(Bool.self, forKey: .rtl)
        // Then decode properties of BaseCardElement.
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
    func deserialize(context: inout ParseContext, value: [String: Any]) throws -> BaseCardElement {
        // Use the BaseCardElement deserialization extension and then cast.
        guard let container = try BaseCardElement.deserialize(from: value) as? Container else {
            throw AdaptiveCardParseError.invalidType
        }
        return container
    }

    func deserialize(fromString context: inout ParseContext, value: String) throws -> BaseCardElement {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: &context, value: jsonDict)
    }
}
