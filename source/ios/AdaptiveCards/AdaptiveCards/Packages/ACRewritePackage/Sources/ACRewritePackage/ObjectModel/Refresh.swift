import Foundation

/// Represents a refresh action in an adaptive card.
struct Refresh: Codable {
    var action: BaseActionElement?
    var userIds: [String]

    init(action: BaseActionElement? = nil, userIds: [String] = []) {
        self.action = action
        self.userIds = userIds
    }

    /// Serializes `Refresh` to a JSON dictionary.
    func serializeToJson() -> [String: Any] {
        var json: [String: Any] = [:]

        if let action = action {
            json["action"] = action.serializeToJson()
        }

        if !userIds.isEmpty {
            json["userIds"] = userIds
        }

        return json
    }

    /// Determines if serialization is needed (if non-default values are set).
    var shouldSerialize: Bool {
        return action != nil || !userIds.isEmpty
    }

    /// Deserializes a `Refresh` from JSON.
    static func deserialize(from json: [String: Any]) throws -> Refresh {
        let action: BaseActionElement? = try? BaseActionElement.deserialize(from: json["action"] as? [String: Any] ?? [:])
        let userIds = json["userIds"] as? [String] ?? []
        return Refresh(action: action, userIds: userIds)
    }

    /// Deserializes a `Refresh` from a JSON string.
    static func deserialize(from jsonString: String) throws -> Refresh {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try deserialize(from: jsonDict)
    }
}
