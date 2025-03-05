//
//  ACInputElements.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/18/24.
//

import Foundation

enum SwiftACInputElement: Codable {
    case text(SwiftACInputText)
    case number(SwiftACInputNumber)
    case date(SwiftACInputDate)
    case time(SwiftACInputTime)
    case toggle(SwiftACInputToggle)
    case choiceSet(SwiftACInputChoiceSet)
    case ratingInput(SwiftACRatingInput)

    enum CodingKeys: String, CodingKey {
        case type
    }

    enum InputElementType: String, Codable {
        case text = "Input.Text"
        case number = "Input.Number"
        case date = "Input.Date"
        case time = "Input.Time"
        case toggle = "Input.Toggle"
        case choiceSet = "Input.ChoiceSet"
        case ratingInput = "Input.Rating"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(InputElementType.self, forKey: .type)
        switch type {
        case .text:
            self = .text(try SwiftACInputText(from: decoder))
        case .number:
            self = .number(try SwiftACInputNumber(from: decoder))
        case .date:
            self = .date(try SwiftACInputDate(from: decoder))
        case .time:
            self = .time(try SwiftACInputTime(from: decoder))
        case .toggle:
            self = .toggle(try SwiftACInputToggle(from: decoder))
        case .choiceSet:
            self = .choiceSet(try SwiftACInputChoiceSet(from: decoder))
        case .ratingInput:
            self = .ratingInput(try SwiftACRatingInput(from: decoder))
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let value):
            try value.encode(to: encoder)
        case .number(let value):
            try value.encode(to: encoder)
        case .date(let value):
            try value.encode(to: encoder)
        case .time(let value):
            try value.encode(to: encoder)
        case .toggle(let value):
            try value.encode(to: encoder)
        case .choiceSet(let value):
            try value.encode(to: encoder)
        case .ratingInput(let value):
            try value.encode(to: encoder)
        }
    }
}

class SwiftACInputText: SwiftACBaseInputElement {

    let isMultiline: Bool?
    let maxLength: Int?
    let placeholder: String?
    let style: String?
    let value: String?

    enum CodingKeys: String, CodingKey {
        case type, id, isMultiline, maxLength, placeholder, style, value
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isMultiline = try container.decodeIfPresent(Bool.self, forKey: .isMultiline)
        self.maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.style = try container.decodeIfPresent(String.self, forKey: .style)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(isMultiline, forKey: .isMultiline)
        try container.encodeIfPresent(maxLength, forKey: .maxLength)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(style, forKey: .style)
        try container.encodeIfPresent(value, forKey: .value)
    }
}

class SwiftACInputNumber: SwiftACBaseInputElement {
    let min: Double?
    let max: Double?
    let placeholder: String?
    let value: Double?

    enum CodingKeys: String, CodingKey {
        case min, max, placeholder, value
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.min = try container.decodeIfPresent(Double.self, forKey: .min)
        self.max = try container.decodeIfPresent(Double.self, forKey: .max)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.value = try container.decodeIfPresent(Double.self, forKey: .value)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(min, forKey: .min)
        try container.encodeIfPresent(max, forKey: .max)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(value, forKey: .value)
        try super.encode(to: encoder)
    }
}

class SwiftACInputDate: SwiftACBaseInputElement {
    let min: String?
    let max: String?
    let value: String?
    let placeholder: String?

    enum CodingKeys: String, CodingKey {
        case min, max, value, placeholder
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.min = try container.decodeIfPresent(String.self, forKey: .min)
        self.max = try container.decodeIfPresent(String.self, forKey: .max)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(min, forKey: .min)
        try container.encodeIfPresent(max, forKey: .max)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try super.encode(to: encoder)
    }
}

class SwiftACInputTime: SwiftACBaseInputElement {
    let min: String?
    let max: String?
    let value: String?
    let placeholder: String?

    enum CodingKeys: String, CodingKey {
        case min, max, value, placeholder
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.min = try container.decodeIfPresent(String.self, forKey: .min)
        self.max = try container.decodeIfPresent(String.self, forKey: .max)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(min, forKey: .min)
        try container.encodeIfPresent(max, forKey: .max)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try super.encode(to: encoder)
    }
}
class SwiftACInputToggle: SwiftACBaseInputElement {
    let title: String
    let value: String?
    let valueOn: String?
    let valueOff: String?
    let wrap: Bool?

    enum CodingKeys: String, CodingKey {
        case title, value, valueOn, valueOff, wrap
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.valueOn = try container.decodeIfPresent(String.self, forKey: .valueOn)
        self.valueOff = try container.decodeIfPresent(String.self, forKey: .valueOff)
        self.wrap = try container.decodeIfPresent(Bool.self, forKey: .wrap)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encodeIfPresent(valueOn, forKey: .valueOn)
        try container.encodeIfPresent(valueOff, forKey: .valueOff)
        try container.encodeIfPresent(wrap, forKey: .wrap)
        try super.encode(to: encoder)
    }
}
   
class SwiftACInputChoiceSet: SwiftACBaseInputElement {
    let isMultiSelect: Bool?
    let style: String?
    let value: String?
    let choices: [SwiftACChoice]

    enum CodingKeys: String, CodingKey {
        case isMultiSelect, style, value, choices
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isMultiSelect = try container.decodeIfPresent(Bool.self, forKey: .isMultiSelect)
        self.style = try container.decodeIfPresent(String.self, forKey: .style)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.choices = try container.decode([SwiftACChoice].self, forKey: .choices)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(isMultiSelect, forKey: .isMultiSelect)
        try container.encodeIfPresent(style, forKey: .style)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encode(choices, forKey: .choices)
        try super.encode(to: encoder)
    }
}

struct SwiftACChoice: Codable, Hashable {
    let title: String
    let value: String
    
    static func ==(lhs: SwiftACChoice, rhs: SwiftACChoice) -> Bool {
        lhs.title == rhs.title
    }
    
    func hash(into hasher: inout Hasher) {
        
    }
}


class SwiftACRatingInput: SwiftACBaseInputElement {
    var horizontalAlignment: SwiftACHorizontalAlignment?
    var value: Double
    var max: Double

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.horizontalAlignment = try container.decodeIfPresent(SwiftACHorizontalAlignment.self, forKey: .horizontalAlignment)
        self.value = try container.decode(Double.self, forKey: .value)
        self.max = try container.decode(Double.self, forKey: .max)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(horizontalAlignment, forKey: .horizontalAlignment)
        try container.encode(value, forKey: .value)
        try container.encode(max, forKey: .max)
        try super.encode(to: encoder)
    }

    private enum CodingKeys: String, CodingKey {
        case horizontalAlignment
        case value
        case max
    }
}
