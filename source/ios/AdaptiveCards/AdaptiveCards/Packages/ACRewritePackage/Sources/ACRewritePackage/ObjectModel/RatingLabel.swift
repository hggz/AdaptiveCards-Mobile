import Foundation

/// Represents a rating label element in an adaptive card.
struct RatingLabel: Codable {
    var value: Double
    var max: Double
    var count: UInt?
    var horizontalAlignment: HorizontalAlignment?
    var size: RatingSize
    var color: RatingColor
    var style: RatingStyle

    init(value: Double = 0, 
         max: Double = 5, 
         count: UInt? = nil, 
         horizontalAlignment: HorizontalAlignment? = nil, 
         size: RatingSize = .medium, 
         color: RatingColor = .neutral, 
         style: RatingStyle = .default) {
        self.value = value
        self.max = max
        self.count = count
        self.horizontalAlignment = horizontalAlignment
        self.size = size
        self.color = color
        self.style = style
    }

    /// Serializes `RatingLabel` to a JSON dictionary.
    func serializeToJson() -> [String: Any] {
        var json: [String: Any] = [
            "value": value,
            "max": max
        ]

        if let count = count {
            json["count"] = count
        }

        if let alignment = horizontalAlignment {
            json["horizontalAlignment"] = alignment.rawValue
        }
        
        if size != .medium {
            json["size"] = size.rawValue
        }
        
        if color != .neutral {
            json["color"] = color.rawValue
        }
        
        if style != .default {
            json["style"] = style.rawValue
        }

        return json
    }

    /// Deserializes a `RatingLabel` from JSON.
    static func deserialize(from json: [String: Any]) throws -> RatingLabel {
        let value = json["value"] as? Double ?? 0
        let max = json["max"] as? Double ?? 5
        let count = json["count"] as? UInt
        let alignment = (json["horizontalAlignment"] as? String).flatMap { HorizontalAlignment(rawValue: $0) }
        let size = (json["size"] as? String).flatMap { RatingSize(rawValue: $0) } ?? .medium
        let color = (json["color"] as? String).flatMap { RatingColor(rawValue: $0) } ?? .neutral
        let style = (json["style"] as? String).flatMap { RatingStyle(rawValue: $0) } ?? .default

        return RatingLabel(value: value, max: max, count: count, horizontalAlignment: alignment, size: size, color: color, style: style)
    }
}

/// Parses `RatingLabel` elements from JSON.
struct RatingLabelParser {
    /// Parses a `RatingLabel` object from JSON data.
    static func deserialize(from json: [String: Any]) throws -> RatingLabel {
        return try RatingLabel.deserialize(from: json)
    }

    /// Parses a `RatingLabel` object from a JSON string.
    static func deserialize(from jsonString: String) throws -> RatingLabel {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try deserialize(from: jsonDict)
    }
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

/// Enumeration representing rating styles.
enum RatingStyle: String, Codable {
    case `default`
    case outlined
    case filled
}
