import Foundation

class SwiftACBaseCardElement: SwiftACBaseElement {
    var type: SwiftACCardElementType?
    var spacing: SwiftACSpacing?
    var separator: Bool?
    var height: SwiftACHeightType?
    var targetWidth: SwiftACTargetWidthType?
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
        type = try container.decodeIfPresent(SwiftACCardElementType.self, forKey: .type)
        spacing = try container.decodeIfPresent(SwiftACSpacing.self, forKey: .spacing)
        separator = try container.decodeIfPresent(Bool.self, forKey: .separator)
        height = try container.decodeIfPresent(SwiftACHeightType.self, forKey: .height)
        targetWidth = try container.decodeIfPresent(SwiftACTargetWidthType.self, forKey: .targetWidth)
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

    func meetsTargetWidthRequirement(hostWidth: SwiftACHostWidth) -> Bool {
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

    static func deserializeBaseProperties(from jsonString: String) -> SwiftACBaseCardElement? {
        let decoder = JSONDecoder()
        if let jsonData = jsonString.data(using: .utf8) {
            return try? decoder.decode(SwiftACBaseCardElement.self, from: jsonData)
        }
        return nil
    }

    static func deserializeBaseProperties(from json: [String: Any]) -> SwiftACBaseCardElement? {
        let decoder = JSONDecoder()
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) {
            return try? decoder.decode(SwiftACBaseCardElement.self, from: jsonData)
        }
        return nil
    }

    static func parseJsonObject(context: SwiftACParseContext, json: [String: Any]) -> SwiftACBaseCardElement? {
        guard let typeString = json["type"] as? String else {
            return nil
        }
        guard let parser = context.elementParserRegistration.getParser(typeString) ?? context.elementParserRegistration.getParser("Unknown") else {
            return nil
        }
        return parser.deserialize(context: context, json: json)
    }
}



enum SwiftACHostWidth: String, Codable, Comparable {
    case `default`
    case wide
    case standard
    case narrow
    case veryNarrow

    static func < (lhs: SwiftACHostWidth, rhs: SwiftACHostWidth) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

class SwiftACParseContext {
    var elementParserRegistration: SwiftACElementParserRegistration

    init(elementParserRegistration: SwiftACElementParserRegistration) {
        self.elementParserRegistration = elementParserRegistration
    }
}

class SwiftACElementParserRegistration {
    func getParser(_ type: String) -> SwiftACElementParser? {
        // Implement this method based on your specific requirements
        return nil
    }
}

protocol SwiftACElementParser {
    func deserialize(context: SwiftACParseContext, json: [String: Any]) -> SwiftACBaseCardElement?
}
