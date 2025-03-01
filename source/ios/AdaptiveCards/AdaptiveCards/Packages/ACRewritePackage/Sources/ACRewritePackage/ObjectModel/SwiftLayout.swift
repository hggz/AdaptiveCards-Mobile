import Foundation

class SwiftLayout: Codable {
    var layoutContainerType: SwiftLayoutContainerType = .none
    var targetWidth: SwiftTargetWidthType = .default

    func shouldSerialize() -> Bool {
        return true
    }

    func meetsTargetWidthRequirement(hostWidth: SwiftHostWidth) -> Bool {
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

    static func deserialize(from json: Data) throws -> SwiftLayout {
        return try JSONDecoder().decode(SwiftLayout.self, from: json)
    }

    static func deserializeFromString(_ jsonString: String) throws -> SwiftLayout {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON string", code: -1, userInfo: nil)
        }
        return try deserialize(from: data)
    }

    func serialize() throws -> String {
        let jsonData = try JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }

    func serializeToJsonValue() -> [String: Any] {
        var json: [String: Any] = [:]

        if targetWidth != .default {
            json["targetWidth"] = targetWidth.rawValue
        }

        if layoutContainerType != .stack {
            json["layout"] = layoutContainerType.rawValue
        }

        return json
    }
    
    static func fromJSON(_ json: [String: Any]) -> SwiftLayout? {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return nil
        }
        return try? JSONDecoder().decode(SwiftLayout.self, from: data)
    }
    
    func toJSON() -> [String: Any] {
        return self.serializeToJsonValue()
    }
    
    init() {}
    
    convenience init(fromFlowLayout flow: SwiftFlowLayout) {
        self.init()
        self.layoutContainerType = .flow
        // Copy additional properties from flow if needed.
    }
    
    /// Conversion initializer to create a generic Layout from an AreaGridLayout.
    convenience init(fromAreaGridLayout areaGrid: SwiftAreaGridLayout) {
        self.init()
        self.layoutContainerType = .areaGrid
        // Copy additional properties from areaGrid if needed.
    }
}
