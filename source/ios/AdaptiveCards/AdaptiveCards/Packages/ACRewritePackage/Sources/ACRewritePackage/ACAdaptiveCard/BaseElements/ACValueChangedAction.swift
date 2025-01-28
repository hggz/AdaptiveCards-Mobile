//
//  ACValueChangedAction.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/19/24.
//


import Foundation

class ValueChangedAction: Codable {
    var targetInputIds: [String]
    var valueChangedActionType: ValueChangedActionType

    enum CodingKeys: String, CodingKey {
        case targetInputIds
        case valueChangedActionType
    }

    init(targetInputIds: [String] = [], valueChangedActionType: ValueChangedActionType = .resetInputs) {
        self.targetInputIds = targetInputIds
        self.valueChangedActionType = valueChangedActionType
    }

    func getTargetInputIds() -> [String] {
        return targetInputIds
    }

    func setTargetInputIds(_ targetInputIds: [String]) {
        self.targetInputIds = targetInputIds
    }

    func getValueChangedActionType() -> ValueChangedActionType {
        return valueChangedActionType
    }

    func setValueChangedActionType(_ valueChangedActionType: ValueChangedActionType) {
        self.valueChangedActionType = valueChangedActionType
    }

    func shouldSerialize() -> Bool {
        return !targetInputIds.isEmpty
    }

    func serialize() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }

    static func deserialize(from jsonString: String) -> ValueChangedAction? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(ValueChangedAction.self, from: jsonData)
    }
}
