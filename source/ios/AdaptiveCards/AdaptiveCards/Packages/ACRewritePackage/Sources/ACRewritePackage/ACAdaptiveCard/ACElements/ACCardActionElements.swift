//
//  ACCardActions.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/18/24.
//

import Foundation

enum SwiftACActionElement: Codable, Hashable {
    static func == (lhs: SwiftACActionElement, rhs: SwiftACActionElement) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    func hash(into hasher: inout Hasher) {
        
    }
    case submit(SwiftACActionSubmit)
    case openUrl(SwiftACActionOpenUrl)
    case showCard(SwiftACActionShowCard)
    case execute(SwiftACActionExecute)
    case toggleVisibility(SwiftACActionToggleVisibility)

    enum CodingKeys: String, CodingKey {
        case type
    }

    enum ActionType: String, Codable {
        case submit = "Action.Submit"
        case openUrl = "Action.OpenUrl"
        case showCard = "Action.ShowCard"
        case execute = "Action.Execute"
        case toggleVisibility = "Action.ToggleVisibility"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ActionType.self, forKey: .type)
        switch type {
        case .submit:
            self = .submit(try SwiftACActionSubmit(from: decoder))
        case .openUrl:
            self = .openUrl(try SwiftACActionOpenUrl(from: decoder))
        case .showCard:
            self = .showCard(try SwiftACActionShowCard(from: decoder))
        case .execute:
            self = .execute(try SwiftACActionExecute(from: decoder))
        case .toggleVisibility:
            self = .toggleVisibility(try SwiftACActionToggleVisibility(from: decoder))
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .submit(let value):
            try value.encode(to: encoder)
        case .openUrl(let value):
            try value.encode(to: encoder)
        case .showCard(let value):
            try value.encode(to: encoder)
        case .execute(let value):
            try value.encode(to: encoder)
        case .toggleVisibility(let value):
            try value.encode(to: encoder)
        }
    }
}

class SwiftACActionSubmit: SwiftACBaseActionElement {
    let data: [String: SwiftACAnyCodable]?

    enum CodingKeys: String, CodingKey {
        case data
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decodeIfPresent([String: SwiftACAnyCodable].self, forKey: .data)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(data, forKey: .data)
        try super.encode(to: encoder)
    }
}

class SwiftACActionOpenUrl: SwiftACBaseActionElement {
    let url: String

    enum CodingKeys: String, CodingKey {
        case url
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try super.encode(to: encoder)
    }
}

class SwiftACActionShowCard: SwiftACBaseActionElement {
    let card: SwiftACAdaptiveCard

    enum CodingKeys: String, CodingKey {
        case card
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.card = try container.decode(SwiftACAdaptiveCard.self, forKey: .card)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(card, forKey: .card)
        try super.encode(to: encoder)
    }
}

class SwiftACActionExecute: SwiftACBaseActionElement {
    let verb: String

    enum CodingKeys: String, CodingKey {
        case verb
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.verb = try container.decode(String.self, forKey: .verb)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(verb, forKey: .verb)
        try super.encode(to: encoder)
    }
}

class SwiftACActionToggleVisibility: SwiftACBaseActionElement {
    let targetElements: [SwiftACTargetElement]

    enum CodingKeys: String, CodingKey {
        case targetElements
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.targetElements = try container.decode([SwiftACTargetElement].self, forKey: .targetElements)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(targetElements, forKey: .targetElements)
        try super.encode(to: encoder)
    }
}

struct SwiftACTargetElement: Codable {
    let elementId: String
    let isVisible: Bool?

    enum CodingKeys: String, CodingKey {
        case elementId = "elementId"
        case isVisible = "isVisible"
    }
}


