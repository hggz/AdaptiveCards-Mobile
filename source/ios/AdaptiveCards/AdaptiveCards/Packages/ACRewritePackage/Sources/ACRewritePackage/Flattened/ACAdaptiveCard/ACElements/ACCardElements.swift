//
//  ACCardElements.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/18/24.
//

import Foundation


enum SwiftACCardElement: Codable, Hashable {
    
    // AC elements
    case textBlock(SwiftACTextBlock)
    case image(SwiftACImage)
    case media(SwiftACMedia)
    case richTextBlock(SwiftACRichTextBlock)
    case textRun(SwiftACTextRun)
    case icon(Icon)
    case ratingLabel(SwiftACRatingLabel)
    
    //containers
    case container(Container)
    case columnSet(SwiftACColumnSet)
    case column(SwiftACColumn)
    case factSet(SwiftACFactSet)
    case imageSet(ImageSet)
    case actionSet(SwiftACActionSet)

    //inputs
    case inputElement(SwiftACInputElement) // New case for InputElement

    
    enum CodingKeys: String, CodingKey {
        case type
    }

    enum CardElementType: String, Codable {
        case textBlock = "TextBlock"
        case image = "Image"
        case media = "Media"
        case richTextBlock = "RichTextBlock"
        case textRun = "TextRun"
        case icon = "Icon"
        case ratingLabel = "Rating"
        case container = "Container"
        case columnSet = "ColumnSet"
        case column = "Column"
        case factSet = "FactSet"
        case imageSet = "ImageSet"
        case actionSet = "ActionSet"
        case inputText = "Input.Text"
        case inputNumber = "Input.Number"
        case inputDate = "Input.Date"
        case inputTime = "Input.Time"
        case inputToggle = "Input.Toggle"
        case inputChoiceSet = "Input.ChoiceSet"
        
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CardElementType.self, forKey: .type)
        switch type {
        case .textBlock:
            self = .textBlock(try SwiftACTextBlock(from: decoder))
        case .image:
            self = .image(try SwiftACImage(from: decoder))
        case .media:
            self = .media(try SwiftACMedia(from: decoder))
        case .richTextBlock:
            self = .richTextBlock(try SwiftACRichTextBlock(from: decoder))
        case .icon:
            self = .icon(try Icon(from: decoder))
        case .ratingLabel:
            self = .ratingLabel(try SwiftACRatingLabel(from: decoder))
        case .textRun:
            self = .textRun(try SwiftACTextRun(from: decoder))
        case .container:
            self = .container(try Container(from: decoder))
        case .columnSet:
            self = .columnSet(try SwiftACColumnSet(from: decoder))
        case .column:
            self = .column(try SwiftACColumn(from: decoder))
        case .factSet:
            self = .factSet(try SwiftACFactSet(from: decoder))
        case .imageSet:
            self = .imageSet(try ImageSet(from: decoder))
        case .inputText, .inputNumber, .inputDate, .inputTime, .inputToggle, .inputChoiceSet:
            self = .inputElement(try SwiftACInputElement(from: decoder)) // Handle InputElement
        case .actionSet:
            self = .actionSet(try SwiftACActionSet(from: decoder))
       
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .textBlock(let value):
            try value.encode(to: encoder)
        case .image(let value):
            try value.encode(to: encoder)
        case .media(let value):
            try value.encode(to: encoder)
        case .richTextBlock(let value):
            try value.encode(to: encoder)
        case .icon(let value):
            try value.encode(to: encoder)
        case .ratingLabel(let value):
            try value.encode(to: encoder)
        case .textRun(let value):
            try value.encode(to: encoder)
        case .container(let value):
            try value.encode(to: encoder)
        case .columnSet(let value):
            try value.encode(to: encoder)
        case .column(let value):
            try value.encode(to: encoder)
        case .factSet(let value):
            try value.encode(to: encoder)
        case .imageSet(let value):
            try value.encode(to: encoder)
        case .actionSet(let value):
            try value.encode(to: encoder)
        case .inputElement(let value):
            try value.encode(to: encoder)
        
        }
    }
    
    static func == (lhs: SwiftACCardElement, rhs: SwiftACCardElement) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {}
}

class SwiftACTextBlock: SwiftACBaseCardElement {
    let text: String
    let color: SwiftACForegroundColor?
    let horizontalAlignment: SwiftACHorizontalAlignment?
    let isSubtle: Bool?
    let italic: Bool?
    let maxLines: Int?
    let size: SwiftACTextSize?
    let weight: SwiftACTextWeight?
    let wrap: Bool?
    let strikethrough: Bool?
    let style: SwiftACTextStyle?
    let fontType: SwiftACFontType?
    let highlight: Bool?
    let underline: Bool?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.color = try container.decodeIfPresent(SwiftACForegroundColor.self, forKey: .color)
        self.horizontalAlignment = try container.decodeIfPresent(SwiftACHorizontalAlignment.self, forKey: .horizontalAlignment)
        self.isSubtle = try container.decodeIfPresent(Bool.self, forKey: .isSubtle)
        self.italic = try container.decodeIfPresent(Bool.self, forKey: .italic)
        self.maxLines = try container.decodeIfPresent(Int.self, forKey: .maxLines)
        self.size = try container.decodeIfPresent(SwiftACTextSize.self, forKey: .size)
        self.weight = try container.decodeIfPresent(SwiftACTextWeight.self, forKey: .weight)
        self.wrap = try container.decodeIfPresent(Bool.self, forKey: .wrap)
        self.strikethrough = try container.decodeIfPresent(Bool.self, forKey: .strikethrough)
        self.style = try container.decodeIfPresent(SwiftACTextStyle.self, forKey: .style)
        self.fontType = try container.decodeIfPresent(SwiftACFontType.self, forKey: .fontType)
        self.highlight = try container.decodeIfPresent(Bool.self, forKey: .highlight)
        self.underline = try container.decodeIfPresent(Bool.self, forKey: .underline)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encodeIfPresent(horizontalAlignment, forKey: .horizontalAlignment)
        try container.encodeIfPresent(isSubtle, forKey: .isSubtle)
        try container.encodeIfPresent(italic, forKey: .italic)
        try container.encodeIfPresent(maxLines, forKey: .maxLines)
        try container.encodeIfPresent(size, forKey: .size)
        try container.encodeIfPresent(weight, forKey: .weight)
        try container.encodeIfPresent(wrap, forKey: .wrap)
        try container.encodeIfPresent(strikethrough, forKey: .strikethrough)
        try container.encodeIfPresent(style, forKey: .style)
        try container.encodeIfPresent(fontType, forKey: .fontType)
        try container.encodeIfPresent(highlight, forKey: .highlight)
        try container.encodeIfPresent(underline, forKey: .underline)
        try super.encode(to: encoder)
    }

    enum CodingKeys: String, CodingKey {
        case text
        case color
        case horizontalAlignment
        case isSubtle
        case italic
        case maxLines
        case size
        case weight
        case wrap
        case strikethrough
        case style
        case fontType
        case highlight
        case underline
    }

}

class SwiftACImage: SwiftACBaseCardElement, Hashable {
    static func == (lhs: SwiftACImage, rhs: SwiftACImage) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        
    }
    let url: String
    let altText: String?
    let horizontalAlignment: SwiftACHorizontalAlignment?
    let size: SwiftACImageSize?
    let style: SwiftACImageStyle?
 

    enum CodingKeys: String, CodingKey {
        case url
        case altText
        case horizontalAlignment
        case size
        case style
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        self.altText = try container.decodeIfPresent(String.self, forKey: .altText)
        self.horizontalAlignment = try container.decodeIfPresent(SwiftACHorizontalAlignment.self, forKey: .horizontalAlignment)
        self.size = try container.decodeIfPresent(SwiftACImageSize.self, forKey: .size)
        self.style = try container.decodeIfPresent(SwiftACImageStyle.self, forKey: .style)

        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encodeIfPresent(altText, forKey: .altText)
        try container.encodeIfPresent(horizontalAlignment, forKey: .horizontalAlignment)
        try container.encodeIfPresent(size, forKey: .size)
        try container.encodeIfPresent(style, forKey: .style)
       
        try super.encode(to: encoder)
    }
}

class SwiftACMedia: SwiftACBaseCardElement {
    let sources: [SwiftACMediaSource]

    enum CodingKeys: String, CodingKey {
        case sources
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sources = try container.decode([SwiftACMediaSource].self, forKey: .sources)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sources, forKey: .sources)
        try super.encode(to: encoder)
    }
}

struct SwiftACMediaSource: Codable {
    let mimeType: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case mimeType = "mimeType"
        case url = "url"
    }
}

class SwiftACRichTextBlock: SwiftACBaseCardElement {

    let inlines: [SwiftACTextRun]

    enum CodingKeys: String, CodingKey {
        case inlines
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.inlines = try container.decode([SwiftACTextRun].self, forKey: .inlines)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inlines, forKey: .inlines)
        try super.encode(to: encoder)
    }
}

struct SwiftACTextRun: Codable {
    let type: String
    let text: String
    let weight: SwiftACTextWeight?
    let highlight: Bool?
    let italic: Bool?
    let underline: Bool?
    let color: SwiftACForegroundColor?
    let size: SwiftACTextSize?
    let fontType: String?
}

class SwiftACActionSet: SwiftACBaseCardElement {
    let actions: [SwiftACActionElement]

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case actions
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.actions = try container.decode([SwiftACActionElement].self, forKey: .actions)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(actions, forKey: .actions)
        try super.encode(to: encoder)
    }
}

class Icon: SwiftACBaseCardElement {
    var foregroundColor: SwiftACForegroundColor
    var iconStyle: SwiftACIconStyle
    var iconSize: SwiftACIconSize
    var name: String
    var selectAction: SwiftACBaseActionElement?
    
    enum CodingKeys: String, CodingKey {
        case foregroundColor
        case iconStyle
        case iconSize
        case name
        case selectAction
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.foregroundColor = try container.decode(SwiftACForegroundColor.self, forKey: .foregroundColor)
        self.iconStyle = try container.decode(SwiftACIconStyle.self, forKey: .iconStyle)
        self.iconSize = try container.decode(SwiftACIconSize.self, forKey: .iconSize)
        self.name = try container.decode(String.self, forKey: .name)
        self.selectAction = try container.decodeIfPresent(SwiftACBaseActionElement.self, forKey: .selectAction)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(foregroundColor, forKey: .foregroundColor)
        try container.encode(iconStyle, forKey: .iconStyle)
        try container.encode(iconSize, forKey: .iconSize)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(selectAction, forKey: .selectAction)
        try super.encode(to: encoder)
    }
}


class SwiftACRatingLabel: SwiftACBaseCardElement {
    var max: Int?
    var count: Int?
    var color: String?
    var label: String?
    var value: Double?
    var errorMessage: String?
    var hAlignment: SwiftACHorizontalAlignment?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.max = try container.decodeIfPresent(Int.self, forKey: .max)
        self.count = try container.decodeIfPresent(Int.self, forKey: .count)
        self.hAlignment = try container.decodeIfPresent(SwiftACHorizontalAlignment.self, forKey: .hAlignment)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.color = try container.decodeIfPresent(String.self, forKey: .color)
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        self.value = try container.decodeIfPresent(Double.self, forKey: .value)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(max, forKey: .max)
        try container.encodeIfPresent(count, forKey: .count)
        try container.encodeIfPresent(hAlignment, forKey: .hAlignment)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encodeIfPresent(label, forKey: .label)
        try container.encodeIfPresent(errorMessage, forKey: .errorMessage)
        try container.encodeIfPresent(value, forKey: .value)
        try super.encode(to: encoder)
    }
    
    private enum CodingKeys: String, CodingKey {
        case max
        case count
        case hAlignment
        case color
        case label
        case errorMessage
        case value
    }
}
