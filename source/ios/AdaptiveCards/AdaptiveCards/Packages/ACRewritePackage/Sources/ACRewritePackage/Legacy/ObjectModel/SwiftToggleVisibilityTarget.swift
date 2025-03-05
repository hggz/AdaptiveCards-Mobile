import Foundation

/// Enum representing visibility states for an element in Adaptive Cards.
enum SwiftIsVisible: String, Codable {
    case toggle = "toggle"
    case visible = "true"
    case hidden = "false"
}

/// Represents a target element for the `ToggleVisibilityAction`.
struct SwiftToggleVisibilityTarget: Codable {
    /// The ID of the target element whose visibility will be toggled.
    var elementId: String

    /// The visibility state of the target element.
    var isVisible: SwiftIsVisible

    /// Initializes a `ToggleVisibilityTarget` with default values.
    init(elementId: String = "", isVisible: SwiftIsVisible = .toggle) {
        self.elementId = elementId
        self.isVisible = isVisible
    }

    /// Decodes a `ToggleVisibilityTarget` from JSON.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let elementId = try? container.decode(String.self) {
            self.elementId = elementId
            self.isVisible = .toggle
        } else {
            let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.elementId = try keyedContainer.decode(String.self, forKey: .elementId)
            self.isVisible = try keyedContainer.decodeIfPresent(Bool.self, forKey: .isVisible) == true ? .visible : .hidden
        }
    }

    /// Encodes a `ToggleVisibilityTarget` to JSON.
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if isVisible == .toggle {
            try container.encode(elementId)
        } else {
            var keyedContainer = encoder.container(keyedBy: CodingKeys.self)
            try keyedContainer.encode(elementId, forKey: .elementId)
            try keyedContainer.encode(isVisible == .visible, forKey: .isVisible)
        }
    }

    /// Deserializes a `ToggleVisibilityTarget` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> SwiftToggleVisibilityTarget {
        if let elementId = json as? String {
            return SwiftToggleVisibilityTarget(elementId: elementId, isVisible: .toggle)
        }

        guard let elementId = json["elementId"] as? String else {
            throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        
        let isVisible: SwiftIsVisible = (json["isVisible"] as? Bool) == true ? .visible : .hidden
        return SwiftToggleVisibilityTarget(elementId: elementId, isVisible: isVisible)
    }

    /// Deserializes a `ToggleVisibilityTarget` from a JSON string.
    static func deserialize(from jsonString: String) throws -> SwiftToggleVisibilityTarget {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(from: jsonDict)
    }

    private enum CodingKeys: String, CodingKey {
        case elementId
        case isVisible
    }
}
