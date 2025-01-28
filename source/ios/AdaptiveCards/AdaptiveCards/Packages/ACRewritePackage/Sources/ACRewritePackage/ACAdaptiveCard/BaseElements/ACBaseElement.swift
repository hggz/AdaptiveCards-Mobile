//
//  ACBaseElement.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation



class BaseElement: Codable {
    var id: String?
    var typeString: String?
    var additionalProperties: [String: AnyCodable]?
    var requires: [String: SemanticVersion]?
    var fallback: CardElement?
    var internalId: InternalId?
    var fallbackType: FallbackType?
    var canFallbackToAncestor: Bool?

    enum CodingKeys: String, CodingKey {
        case typeString
        case additionalProperties
        case requires
        case fallback
        case id
        case internalId
        case fallbackType
        case canFallbackToAncestor
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        typeString = try container.decodeIfPresent(String.self, forKey: .typeString)
        additionalProperties = try container.decodeIfPresent([String: AnyCodable].self, forKey: .additionalProperties)
        requires = try container.decodeIfPresent([String: SemanticVersion].self, forKey: .requires)
        fallback = try container.decodeIfPresent(CardElement.self, forKey: .fallback)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        internalId = try container.decodeIfPresent(InternalId.self, forKey: .internalId)
        fallbackType = try container.decodeIfPresent(FallbackType.self, forKey: .fallbackType)
        canFallbackToAncestor = try container.decodeIfPresent(Bool.self, forKey: .canFallbackToAncestor)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(typeString, forKey: .typeString)
        try container.encodeIfPresent(additionalProperties, forKey: .additionalProperties)
        try container.encodeIfPresent(requires, forKey: .requires)
        try container.encodeIfPresent(fallback, forKey: .fallback)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(internalId, forKey: .internalId)
        try container.encodeIfPresent(fallbackType, forKey: .fallbackType)
        try container.encodeIfPresent(canFallbackToAncestor, forKey: .canFallbackToAncestor)
    }

    init(typeString: String = "", additionalProperties: [String: AnyCodable] = [:], requires: [String: SemanticVersion] = [:], fallback: CardElement? = nil, id: String = "", internalId: InternalId = InternalId.next(), fallbackType: FallbackType = .none, canFallbackToAncestor: Bool = false) {
        self.typeString = typeString
        self.additionalProperties = additionalProperties
        self.requires = requires
        self.fallback = fallback
        self.id = id
        self.internalId = internalId
        self.fallbackType = fallbackType
        self.canFallbackToAncestor = canFallbackToAncestor
    }

}

// Supporting types
struct InternalId: Codable, Equatable {
    static var currentId: UInt = 1
    var id: UInt

    static func current() -> InternalId {
        return InternalId(id: currentId)
    }

    static func next() -> InternalId {
        currentId += 1
        return current()
    }
}

enum FallbackType: String, Codable {
    case none
    case content
}

struct SemanticVersion: Codable {
    var major: Int
    var minor: Int
    var patch: Int
}

// AnyCodable to handle additionalProperties dictionary
struct AnyCodable: Codable {
    var value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictionaryValue = try? container.decode([String: AnyCodable].self) {
            value = dictionaryValue.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else if let arrayValue = value as? [Any] {
            let anyCodableArray = arrayValue.map { AnyCodable($0) }
            try container.encode(anyCodableArray)
        } else if let dictionaryValue = value as? [String: Any] {
            let anyCodableDictionary = dictionaryValue.mapValues { AnyCodable($0) }
            try container.encode(anyCodableDictionary)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Unable to encode value"))
        }
    }
}
