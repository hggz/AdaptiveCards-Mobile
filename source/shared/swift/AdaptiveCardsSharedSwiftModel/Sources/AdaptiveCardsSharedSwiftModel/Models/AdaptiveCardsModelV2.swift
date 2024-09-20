import Foundation

// MARK: - AdaptiveCard
struct AdaptiveCard: Codable {
    let schema: String?
    let type: String
    let version: String
    let body: [CardElement]
    let actions: [CardElement]? // Adjusted to use CardElement for actions

    enum CodingKeys: String, CodingKey {
        case schema = "$schema"
        case type
        case version
        case body
        case actions
    }
}

// MARK: - CardElement Enum
enum CardElement: Codable {
    case container(Container)
    case textBlock(TextBlock)
    case carousel(Carousel)
    case carouselPage(CarouselPage)
    case image(Image)
    case columnSet(ColumnSet)
    case column(Column)
    case imageSet(ImageSet)
    // New input types
    case inputText(InputText)
    case inputDate(InputDate)
    case inputNumber(InputNumber)
    case inputTime(InputTime)
    case inputToggle(InputToggle)
    case inputChoiceSet(InputChoiceSet)
    // Actions (if needed)
    case actionSubmit(ActionSubmit)
    case actionOpenUrl(ActionOpenUrl)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "Container":
            self = .container(try Container(from: decoder))
        case "TextBlock":
            self = .textBlock(try TextBlock(from: decoder))
        case "Carousel":
            self = .carousel(try Carousel(from: decoder))
        case "CarouselPage":
            self = .carouselPage(try CarouselPage(from: decoder))
        case "Image":
            self = .image(try Image(from: decoder))
        case "ColumnSet":
            self = .columnSet(try ColumnSet(from: decoder))
        case "Column":
            self = .column(try Column(from: decoder))
        case "ImageSet":
            self = .imageSet(try ImageSet(from: decoder))
        // Handle new input types
        case "Input.Text":
            self = .inputText(try InputText(from: decoder))
        case "Input.Date":
            self = .inputDate(try InputDate(from: decoder))
        case "Input.Number":
            self = .inputNumber(try InputNumber(from: decoder))
        case "Input.Time":
            self = .inputTime(try InputTime(from: decoder))
        case "Input.Toggle":
            self = .inputToggle(try InputToggle(from: decoder))
        case "Input.ChoiceSet":
            self = .inputChoiceSet(try InputChoiceSet(from: decoder))
        // Handle actions if they appear in the body
        case "Action.Submit":
            self = .actionSubmit(try ActionSubmit(from: decoder))
        case "Action.OpenUrl":
            self = .actionOpenUrl(try ActionOpenUrl(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type: \(type)")
        }
    }

    func encode(to encoder: Encoder) throws {
        // Implement encoding if needed
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }
}

struct InputText: Codable {
    let type: String
    let id: String
    let value: String?
    let label: String?
    let labelPosition: String?
    let labelWidth: String?
    let inputStyle: String?

    enum CodingKeys: String, CodingKey {
        case type, id, value, label, labelPosition, labelWidth, inputStyle
    }

    // Custom initializer to handle labelWidth being a String or Number
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        id = try container.decode(String.self, forKey: .id)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        labelPosition = try container.decodeIfPresent(String.self, forKey: .labelPosition)
        inputStyle = try container.decodeIfPresent(String.self, forKey: .inputStyle)
        if let labelWidthNumber = try? container.decode(Double.self, forKey: .labelWidth) {
            labelWidth = String(labelWidthNumber)
        } else {
            labelWidth = try container.decodeIfPresent(String.self, forKey: .labelWidth)
        }
    }
}

struct InputDate: Codable {
    let type: String
    let id: String
    let value: String?
    let label: String?
    let labelPosition: String?
    let labelWidth: String?
    let inputStyle: String?

    enum CodingKeys: String, CodingKey {
        case type, id, value, label, labelPosition, labelWidth, inputStyle
    }

    // Custom initializer to handle labelWidth being a String or Number
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        id = try container.decode(String.self, forKey: .id)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        labelPosition = try container.decodeIfPresent(String.self, forKey: .labelPosition)
        inputStyle = try container.decodeIfPresent(String.self, forKey: .inputStyle)
        if let labelWidthNumber = try? container.decode(Double.self, forKey: .labelWidth) {
            labelWidth = String(labelWidthNumber)
        } else {
            labelWidth = try container.decodeIfPresent(String.self, forKey: .labelWidth)
        }
    }
}

struct InputTime: Codable {
    let type: String
    let id: String
    let value: String?
    let label: String?
    let labelPosition: String?
    let labelWidth: String?
    let inputStyle: String?

    enum CodingKeys: String, CodingKey {
        case type, id, value, label, labelPosition, labelWidth, inputStyle
    }

    // Custom initializer to handle labelWidth being a String or Number
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        id = try container.decode(String.self, forKey: .id)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        labelPosition = try container.decodeIfPresent(String.self, forKey: .labelPosition)
        inputStyle = try container.decodeIfPresent(String.self, forKey: .inputStyle)
        if let labelWidthNumber = try? container.decode(Double.self, forKey: .labelWidth) {
            labelWidth = String(labelWidthNumber)
        } else {
            labelWidth = try container.decodeIfPresent(String.self, forKey: .labelWidth)
        }
    }
}

struct InputNumber: Codable {
    let type: String
    let id: String
    let value: Double?
    let inputStyle: String?

    enum CodingKeys: String, CodingKey {
        case type, id, value, inputStyle
    }
}

struct InputToggle: Codable {
    let type: String
    let id: String
    let title: String?
    let value: String?
    let valueOn: String?
    let valueOff: String?
    let label: String?
    let labelPosition: String?

    enum CodingKeys: String, CodingKey {
        case type, id, title, value, valueOn, valueOff, label, labelPosition
    }
}

struct InputChoiceSet: Codable {
    let type: String
    let id: String
    let style: String?
    let labelPosition: String?
    let label: String?
    let isMultiSelect: Bool?
    let inputStyle: String?
    let value: String?
    let choices: [Choice]

    enum CodingKeys: String, CodingKey {
        case type, id, style, labelPosition, label, isMultiSelect, inputStyle, value, choices
    }
}

struct Choice: Codable {
    let title: String
    let value: String
}

struct ActionSubmit: Codable {
    let type: String
    let title: String?
    let associatedInputs: String?
    let disabledUnlessAssociatedInputsChange: Bool?

    enum CodingKeys: String, CodingKey {
        case type, title, associatedInputs, disabledUnlessAssociatedInputsChange
    }
}

struct ActionOpenUrl: Codable {
    let type: String
    let title: String?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case type, title, url
    }
}

// MARK: - Container
struct Container: Codable {
    let type: String
    let items: [CardElement]
    let style: String?

    enum CodingKeys: String, CodingKey {
        case type
        case items
        case style
    }
}

// MARK: - TextBlock
struct TextBlock: Codable {
    let type: String
    let text: String
    let size: String?
    let style: String?
    let horizontalAlignment: String?
    let wrap: Bool?
    let isSubtle: Bool?
    let weight: String?

    enum CodingKeys: String, CodingKey {
        case type
        case text
        case size
        case style
        case horizontalAlignment
        case wrap
        case isSubtle
        case weight
    }
}

// MARK: - Carousel
struct Carousel: Codable {
    let type: String
    let spacing: String?
    let pages: [CarouselPage]
    let rtl: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case spacing
        case pages
        case rtl
    }
}

// MARK: - CarouselPage
struct CarouselPage: Codable {
    let type: String
    let id: String
    let items: [CardElement]
    let rtl: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case id
        case items
        case rtl
    }
}

// MARK: - Image
struct Image: Codable {
    let type: String
    let url: String
    let altText: String?
    let size: String?
    let horizontalAlignment: String?

    enum CodingKeys: String, CodingKey {
        case type
        case url
        case altText
        case size
        case horizontalAlignment
    }
}

// MARK: - ColumnSet
struct ColumnSet: Codable {
    let type: String
    let columns: [Column]
    let style: String?

    enum CodingKeys: String, CodingKey {
        case type
        case columns
        case style
    }
}

// MARK: - Column
struct Column: Codable {
    let type: String
    let width: String?
    let items: [CardElement]?
    let backgroundImage: BackgroundImage?
    let verticalContentAlignment: String?
    let spacing: String?

    enum CodingKeys: String, CodingKey {
        case type
        case width
        case items
        case backgroundImage
        case verticalContentAlignment
        case spacing
    }
}

// MARK: - ImageSet
struct ImageSet: Codable {
    let type: String
    let style: String?
    let size: String?
    let offset: Int?
    let images: [Image]

    enum CodingKeys: String, CodingKey {
        case type
        case style
        case size
        case offset
        case images
    }
}

// MARK: - BackgroundImage
struct BackgroundImage: Codable {
    let url: String
    let verticalAlignment: String?
    let horizontalAlignment: String?
}
