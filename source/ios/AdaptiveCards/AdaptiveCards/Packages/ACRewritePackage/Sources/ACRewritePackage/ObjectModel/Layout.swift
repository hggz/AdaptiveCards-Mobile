import Foundation

enum LayoutContainerType: String, Codable {
    case none, stack
}

enum TargetWidthType: String, Codable {
    case `default`, wide, standard, narrow, veryNarrow
    case atLeastWide, atLeastStandard, atLeastNarrow, atLeastVeryNarrow
    case atMostWide, atMostStandard, atMostNarrow, atMostVeryNarrow
}

enum HostWidth: String, Comparable {
    case `default`, wide, standard, narrow, veryNarrow

    static func < (lhs: HostWidth, rhs: HostWidth) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

struct Layout: Codable {
    var layoutContainerType: LayoutContainerType = .none
    var targetWidth: TargetWidthType = .default

    func shouldSerialize() -> Bool {
        return true
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

    static func deserialize(from json: Data) throws -> Layout {
        return try JSONDecoder().decode(Layout.self, from: json)
    }

    static func deserializeFromString(_ jsonString: String) throws -> Layout {
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
}
