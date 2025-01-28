import Foundation

class BaseCardElement: BaseElement {
    var type: CardElementType?
    var spacing: Spacing?
    var separator: Bool?
    var height: HeightType?
    var targetWidth: TargetWidthType?
    var isVisible: Bool?
    var areaGridName: String?
    var nonOptionalAreaGridName: String?

    enum CodingKeys: String, CodingKey {
        case type
        case spacing
        case separator
        case height
        case targetWidth
        case isVisible
        case areaGridName
        case nonOptionalAreaGridName
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(spacing, forKey: .spacing)
        try container.encodeIfPresent(separator, forKey: .separator)
        try container.encodeIfPresent(height, forKey: .height)
        try container.encodeIfPresent(targetWidth, forKey: .targetWidth)
        try container.encodeIfPresent(isVisible, forKey: .isVisible)
        try container.encodeIfPresent(areaGridName, forKey: .areaGridName)
        try container.encodeIfPresent(nonOptionalAreaGridName, forKey: .nonOptionalAreaGridName)
        
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(CardElementType.self, forKey: .type)
        spacing = try container.decodeIfPresent(Spacing.self, forKey: .spacing)
        separator = try container.decodeIfPresent(Bool.self, forKey: .separator)
        height = try container.decodeIfPresent(HeightType.self, forKey: .height)
        targetWidth = try container.decodeIfPresent(TargetWidthType.self, forKey: .targetWidth)
        isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible)
        areaGridName = try container.decodeIfPresent(String.self, forKey: .areaGridName)
        nonOptionalAreaGridName = try container.decodeIfPresent(String.self, forKey: .nonOptionalAreaGridName)
        try super.init(from: decoder)
    }

    func serialize() -> String {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            return String(data: jsonData, encoding: .utf8) ?? ""
        }
        return ""
    }

    func meetsTargetWidthRequirement(hostWidth: HostWidth) -> Bool {
        if targetWidth == .default || hostWidth == .default {
            return true
        }
        switch targetWidth {
        case .wide:
            return hostWidth == .wide
        case .standard:
            return hostWidth == .standard
        case .narrow:
            return hostWidth == .narrow
        case .veryNarrow:
            return hostWidth == .veryNarrow
        case .atLeastWide:
            return hostWidth >= .wide
        case .atLeastStandard:
            return hostWidth >= .standard
        case .atLeastNarrow:
            return hostWidth >= .narrow
        case .atLeastVeryNarrow:
            return hostWidth >= .veryNarrow
        case .atMostWide:
            return hostWidth <= .wide
        case .atMostStandard:
            return hostWidth <= .standard
        case .atMostNarrow:
            return hostWidth <= .narrow
        case .atMostVeryNarrow:
            return hostWidth <= .veryNarrow
        default:
            return true
        }
    }

    static func deserializeBaseProperties(from jsonString: String) -> BaseCardElement? {
        let decoder = JSONDecoder()
        if let jsonData = jsonString.data(using: .utf8) {
            return try? decoder.decode(BaseCardElement.self, from: jsonData)
        }
        return nil
    }

    static func deserializeBaseProperties(from json: [String: Any]) -> BaseCardElement? {
        let decoder = JSONDecoder()
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) {
            return try? decoder.decode(BaseCardElement.self, from: jsonData)
        }
        return nil
    }

    static func parseJsonObject(context: ParseContext, json: [String: Any]) -> BaseCardElement? {
        guard let typeString = json["type"] as? String else {
            return nil
        }
        guard let parser = context.elementParserRegistration.getParser(typeString) ?? context.elementParserRegistration.getParser("Unknown") else {
            return nil
        }
        return parser.deserialize(context: context, json: json)
    }
}



enum HostWidth: String, Codable, Comparable {
    case `default`
    case wide
    case standard
    case narrow
    case veryNarrow

    static func < (lhs: HostWidth, rhs: HostWidth) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

class ParseContext {
    var elementParserRegistration: ElementParserRegistration

    init(elementParserRegistration: ElementParserRegistration) {
        self.elementParserRegistration = elementParserRegistration
    }
}

class ElementParserRegistration {
    func getParser(_ type: String) -> ElementParser? {
        // Implement this method based on your specific requirements
        return nil
    }
}

protocol ElementParser {
    func deserialize(context: ParseContext, json: [String: Any]) -> BaseCardElement?
}
