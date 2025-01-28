//
//  ACCardElements.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/18/24.
//

import Foundation


enum CardElement: Codable, Hashable {
    
    // AC elements
    case textBlock(TextBlock)
    case image(Image)
    case media(Media)
    case richTextBlock(RichTextBlock)
    case textRun(TextRun)
    case icon(Icon)
    case ratingLabel(RatingLabel)
    
    //containers
    case container(Container)
    case columnSet(ColumnSet)
    case column(Column)
    case factSet(FactSet)
    case imageSet(ImageSet)
    case actionSet(ActionSet)

    //inputs
    case inputElement(InputElement) // New case for InputElement

    
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
            self = .textBlock(try TextBlock(from: decoder))
        case .image:
            self = .image(try Image(from: decoder))
        case .media:
            self = .media(try Media(from: decoder))
        case .richTextBlock:
            self = .richTextBlock(try RichTextBlock(from: decoder))
        case .icon:
            self = .icon(try Icon(from: decoder))
        case .ratingLabel:
            self = .ratingLabel(try RatingLabel(from: decoder))
        case .textRun:
            self = .textRun(try TextRun(from: decoder))
        case .container:
            self = .container(try Container(from: decoder))
        case .columnSet:
            self = .columnSet(try ColumnSet(from: decoder))
        case .column:
            self = .column(try Column(from: decoder))
        case .factSet:
            self = .factSet(try FactSet(from: decoder))
        case .imageSet:
            self = .imageSet(try ImageSet(from: decoder))
        case .inputText, .inputNumber, .inputDate, .inputTime, .inputToggle, .inputChoiceSet:
            self = .inputElement(try InputElement(from: decoder)) // Handle InputElement
        case .actionSet:
            self = .actionSet(try ActionSet(from: decoder))
       
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
    
    static func == (lhs: CardElement, rhs: CardElement) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {}
}

class TextBlock: BaseCardElement {
    let text: String
    let color: ForegroundColor?
    let horizontalAlignment: HorizontalAlignment?
    let isSubtle: Bool?
    let italic: Bool?
    let maxLines: Int?
    let size: TextSize?
    let weight: TextWeight?
    let wrap: Bool?
    let strikethrough: Bool?
    let style: TextStyle?
    let fontType: FontType?
    let highlight: Bool?
    let underline: Bool?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.color = try container.decodeIfPresent(ForegroundColor.self, forKey: .color)
        self.horizontalAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .horizontalAlignment)
        self.isSubtle = try container.decodeIfPresent(Bool.self, forKey: .isSubtle)
        self.italic = try container.decodeIfPresent(Bool.self, forKey: .italic)
        self.maxLines = try container.decodeIfPresent(Int.self, forKey: .maxLines)
        self.size = try container.decodeIfPresent(TextSize.self, forKey: .size)
        self.weight = try container.decodeIfPresent(TextWeight.self, forKey: .weight)
        self.wrap = try container.decodeIfPresent(Bool.self, forKey: .wrap)
        self.strikethrough = try container.decodeIfPresent(Bool.self, forKey: .strikethrough)
        self.style = try container.decodeIfPresent(TextStyle.self, forKey: .style)
        self.fontType = try container.decodeIfPresent(FontType.self, forKey: .fontType)
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

class Image: BaseCardElement, Hashable {
    static func == (lhs: Image, rhs: Image) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        
    }
    let url: String
    let altText: String?
    let horizontalAlignment: HorizontalAlignment?
    let size: ImageSize?
    let style: ImageStyle?
 

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
        self.horizontalAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .horizontalAlignment)
        self.size = try container.decodeIfPresent(ImageSize.self, forKey: .size)
        self.style = try container.decodeIfPresent(ImageStyle.self, forKey: .style)

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

class Media: BaseCardElement {
    let sources: [MediaSource]

    enum CodingKeys: String, CodingKey {
        case sources
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sources = try container.decode([MediaSource].self, forKey: .sources)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sources, forKey: .sources)
        try super.encode(to: encoder)
    }
}

struct MediaSource: Codable {
    let mimeType: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case mimeType = "mimeType"
        case url = "url"
    }
}

class RichTextBlock: BaseCardElement {

    let inlines: [TextRun]

    enum CodingKeys: String, CodingKey {
        case inlines
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.inlines = try container.decode([TextRun].self, forKey: .inlines)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inlines, forKey: .inlines)
        try super.encode(to: encoder)
    }
}

struct TextRun: Codable {
    let type: String
    let text: String
    let weight: TextWeight?
    let highlight: Bool?
    let italic: Bool?
    let underline: Bool?
    let color: ForegroundColor?
    let size: TextSize?
    let fontType: String?
}

class ActionSet: BaseCardElement {
    let actions: [ActionElement]

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case actions
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.actions = try container.decode([ActionElement].self, forKey: .actions)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(actions, forKey: .actions)
        try super.encode(to: encoder)
    }
}

class Icon: BaseCardElement {
    var foregroundColor: ForegroundColor
    var iconStyle: IconStyle
    var iconSize: IconSize
    var name: String
    var selectAction: BaseActionElement?
    
    enum CodingKeys: String, CodingKey {
        case foregroundColor
        case iconStyle
        case iconSize
        case name
        case selectAction
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.foregroundColor = try container.decode(ForegroundColor.self, forKey: .foregroundColor)
        self.iconStyle = try container.decode(IconStyle.self, forKey: .iconStyle)
        self.iconSize = try container.decode(IconSize.self, forKey: .iconSize)
        self.name = try container.decode(String.self, forKey: .name)
        self.selectAction = try container.decodeIfPresent(BaseActionElement.self, forKey: .selectAction)
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


class RatingLabel: BaseCardElement {
    var max: Int?
    var count: Int?
    var color: String?
    var label: String?
    var value: Double?
    var errorMessage: String?
    var hAlignment: HorizontalAlignment?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.max = try container.decodeIfPresent(Int.self, forKey: .max)
        self.count = try container.decodeIfPresent(Int.self, forKey: .count)
        self.hAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .hAlignment)
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
