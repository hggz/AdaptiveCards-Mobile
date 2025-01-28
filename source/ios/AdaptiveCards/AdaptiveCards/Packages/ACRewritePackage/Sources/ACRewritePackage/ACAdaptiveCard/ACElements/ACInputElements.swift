//
//  ACInputElements.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/18/24.
//

import Foundation

enum InputElement: Codable {
    case text(InputText)
    case number(InputNumber)
    case date(InputDate)
    case time(InputTime)
    case toggle(InputToggle)
    case choiceSet(InputChoiceSet)
    case ratingInput(RatingInput)

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
            self = .text(try InputText(from: decoder))
        case .number:
            self = .number(try InputNumber(from: decoder))
        case .date:
            self = .date(try InputDate(from: decoder))
        case .time:
            self = .time(try InputTime(from: decoder))
        case .toggle:
            self = .toggle(try InputToggle(from: decoder))
        case .choiceSet:
            self = .choiceSet(try InputChoiceSet(from: decoder))
        case .ratingInput:
            self = .ratingInput(try RatingInput(from: decoder))
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

class InputText: BaseInputElement {

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

class InputNumber: BaseInputElement {
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

class InputDate: BaseInputElement {
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

class InputTime: BaseInputElement {
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
class InputToggle: BaseInputElement {
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
   
class InputChoiceSet: BaseInputElement {
    let isMultiSelect: Bool?
    let style: String?
    let value: String?
    let choices: [Choice]

    enum CodingKeys: String, CodingKey {
        case isMultiSelect, style, value, choices
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isMultiSelect = try container.decodeIfPresent(Bool.self, forKey: .isMultiSelect)
        self.style = try container.decodeIfPresent(String.self, forKey: .style)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.choices = try container.decode([Choice].self, forKey: .choices)
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

struct Choice: Codable, Hashable {
    let title: String
    let value: String
    
    static func ==(lhs: Choice, rhs: Choice) -> Bool {
        lhs.title == rhs.title
    }
    
    func hash(into hasher: inout Hasher) {
        
    }
}


class RatingInput: BaseInputElement {
    var horizontalAlignment: HorizontalAlignment?
    var value: Double
    var max: Double

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.horizontalAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .horizontalAlignment)
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
