import Foundation

enum ValueChangedActionType: String, Codable {
    case resetInputs = "ResetInputs"
    // Add other action types if necessary
}

struct ValueChangedAction: Codable {
    var targetInputIds: [String]
    var valueChangedActionType: ValueChangedActionType

    init(targetInputIds: [String] = [], valueChangedActionType: ValueChangedActionType = .resetInputs) {
        self.targetInputIds = targetInputIds
        self.valueChangedActionType = valueChangedActionType
    }

    var shouldSerialize: Bool {
        return !targetInputIds.isEmpty
    }

    func serializeToJson() -> [String: Any] {
        var json: [String: Any] = [:]
        if !targetInputIds.isEmpty {
            json["targetInputIds"] = targetInputIds
        }
        json["valueChangedActionType"] = valueChangedActionType.rawValue
        return json
    }

    func serialize() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: serializeToJson(), options: .prettyPrinted) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    static func deserialize(from json: [String: Any]) -> ValueChangedAction? {
        guard let targetInputIds = json["targetInputIds"] as? [String],
              let actionTypeString = json["valueChangedActionType"] as? String,
              let actionType = ValueChangedActionType(rawValue: actionTypeString) else {
            return nil
        }
        return ValueChangedAction(targetInputIds: targetInputIds, valueChangedActionType: actionType)
    }

    static func deserialize(from jsonString: String) -> ValueChangedAction? {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        return deserialize(from: jsonObject)
    }
}
