import Foundation

/// Represents a rating input element in an adaptive card.
struct RatingInput: Codable {
    var value: Double
    var max: Double
    var horizontalAlignment: HorizontalAlignment?
    var size: RatingSize
    var color: RatingColor

    init(value: Double = 0, max: Double = 5, horizontalAlignment: HorizontalAlignment? = nil, size: RatingSize = .medium, color: RatingColor = .neutral) {
        self.value = value
        self.max = max
        self.horizontalAlignment = horizontalAlignment
        self.size = size
        self.color = color
    }

    /// Serializes `RatingInput` to a JSON dictionary.
    func serializeToJson() -> [String: Any] {
        var json: [String: Any] = [
            "value": value,
            "max": max
        ]

        if let alignment = horizontalAlignment {
            json["horizontalAlignment"] = alignment.rawValue
        }
        
        if size != .medium {
            json["size"] = size.rawValue
        }
        
        if color != .neutral {
            json["color"] = color.rawValue
        }

        return json
    }

    /// Deserializes a `RatingInput` from JSON.
    static func deserialize(from json: [String: Any]) throws -> RatingInput {
        let value = json["value"] as? Double ?? 0
        let max = json["max"] as? Double ?? 5
        let alignment = (json["horizontalAlignment"] as? String).flatMap { HorizontalAlignment(rawValue: $0) }
        let size = (json["size"] as? String).flatMap { RatingSize(rawValue: $0) } ?? .medium
        let color = (json["color"] as? String).flatMap { RatingColor(rawValue: $0) } ?? .neutral

        return RatingInput(value: value, max: max, horizontalAlignment: alignment, size: size, color: color)
    }
}

/// Parses `RatingInput` elements from JSON.
struct RatingInputParser {
    /// Parses a `RatingInput` object from JSON data.
    static func deserialize(from json: [String: Any]) throws -> RatingInput {
        return try RatingInput.deserialize(from: json)
    }

    /// Parses a `RatingInput` object from a JSON string.
    static func deserialize(from jsonString: String) throws -> RatingInput {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try deserialize(from: jsonDict)
    }
}

/// Enumeration representing horizontal alignment.
enum HorizontalAlignment: String, Codable {
    case left
    case center
    case right
}

/// Enumeration representing rating sizes.
enum RatingSize: String, Codable {
    case small
    case medium
    case large
}

/// Enumeration representing rating colors.
enum RatingColor: String, Codable {
    case neutral
    case positive
    case negative
}
