import Foundation

struct SwiftValueChangedAction: Codable {
    var targetInputIds: [String]
    var valueChangedActionType: SwiftValueChangedActionType

    init(targetInputIds: [String] = [], valueChangedActionType: SwiftValueChangedActionType = .resetInputs) {
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

    static func deserialize(from json: [String: Any]) -> SwiftValueChangedAction? {
        guard let targetInputIds = json["targetInputIds"] as? [String],
              let actionTypeString = json["valueChangedActionType"] as? String,
              let actionType = SwiftValueChangedActionType(rawValue: actionTypeString) else {
            return nil
        }
        return SwiftValueChangedAction(targetInputIds: targetInputIds, valueChangedActionType: actionType)
    }

    static func deserialize(from jsonString: String) -> SwiftValueChangedAction? {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        return deserialize(from: jsonObject)
    }
}
