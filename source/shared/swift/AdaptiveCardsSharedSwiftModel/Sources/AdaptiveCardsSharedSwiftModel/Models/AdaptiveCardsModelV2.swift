import Foundation

// MARK: - AdaptiveCard
struct AdaptiveCard: Codable {
    let schema: String?
    let type: String
    let version: String?
    let body: [CardElement]? // Made optional
    let actions: [Action]? // Already optional

    enum CodingKeys: String, CodingKey {
        case schema = "$schema"
        case type
        case version
        case body
        case actions
    }
}

// MARK: - CardElement Enum
// Update CardElement enum
enum CardElement: Codable {
    case container(Container)
    case textBlock(TextBlock)
    case carousel(Carousel)
    case carouselPage(CarouselPage)
    case image(Image)
    case columnSet(ColumnSet)
    case column(Column)
    case imageSet(ImageSet)
    // New elements
    case icon(Icon)
    case actionSet(ActionSet)
    case compoundButton(CompoundButton)
    case media(Media)
    case table(TableComponent) // Added table case
    // Input elements
    case inputText(InputText)
    case inputDate(InputDate)
    case inputNumber(InputNumber)
    case inputTime(InputTime)
    case inputToggle(InputToggle)
    case inputChoiceSet(InputChoiceSet)

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
        case "Icon":
            self = .icon(try Icon(from: decoder))
        case "ActionSet":
            self = .actionSet(try ActionSet(from: decoder))
        case "CompoundButton":
            self = .compoundButton(try CompoundButton(from: decoder))
        case "Media":
            self = .media(try Media(from: decoder))
        case "Table":
            self = .table(try TableComponent(from: decoder)) // Handle table case
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

// MARK: - Media
struct Media: Codable {
    let type: String
    let poster: String?
    let altText: String?
    let sources: [MediaSource]
    let captionSources: [MediaCaptionSource]?

    enum CodingKeys: String, CodingKey {
        case type
        case poster
        case altText
        case sources
        case captionSources
    }
}

struct MediaSource: Codable {
    let mimeType: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case mimeType
        case url
    }
}

struct MediaCaptionSource: Codable {
    let mimeType: String
    let label: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case mimeType
        case label
        case url
    }
}

enum Action: Codable {
    case openUrl(ActionOpenUrl)
    case submit(ActionSubmit)
    case showCard(ActionShowCard)
    case execute(ActionExecute)
    // Add more action types as needed

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ActionCodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "Action.OpenUrl":
            self = .openUrl(try ActionOpenUrl(from: decoder))
        case "Action.Submit":
            self = .submit(try ActionSubmit(from: decoder))
        case "Action.ShowCard":
            self = .showCard(try ActionShowCard(from: decoder))
        case "Action.Execute":
            self = .execute(try ActionExecute(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type: \(type)")
        }
    }

    func encode(to encoder: Encoder) throws {
        // Implement encoding if needed
    }

    private enum ActionCodingKeys: String, CodingKey {
        case type
    }
}

struct Icon: Codable {
    let type: String
    let name: String
    let size: String?
    let style: String?
    let color: String?
    let selectAction: Action?

    enum CodingKeys: String, CodingKey {
        case type
        case name
        case size
        case style
        case color
        case selectAction
    }
}

struct ActionSet: Codable {
    let type: String
    let actions: [Action]

    enum CodingKeys: String, CodingKey {
        case type
        case actions
    }
}

struct CompoundButton: Codable {
    let type: String
    let title: String
    let icon: IconInfo?
    let description: String?
    let height: String?
    let badge: String?
    let selectAction: Action?
    let spacing: String?

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case icon
        case description
        case height
        case badge
        case selectAction
        case spacing
    }
}

struct IconInfo: Codable {
    let name: String
    let style: String?

    enum CodingKeys: String, CodingKey {
        case name
        case style
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
    let role: String?

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case associatedInputs
        case disabledUnlessAssociatedInputsChange
        case role
    }
}

struct ActionShowCard: Codable {
    let type: String
    let title: String?
    let card: AdaptiveCard

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case card
    }
}

struct ActionExecute: Codable {
    let type: String
    let title: String?
    let role: String?

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case role
    }
}

struct ActionOpenUrl: Codable {
    let type: String
    let title: String?
    let url: String?
    let iconUrl: String?
    let role: String?
    let tooltip: String?

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case url
        case iconUrl
        case role
        case tooltip
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

// MARK: - Table
struct TableComponent: Codable {
    let type: String
    let gridStyle: String?
    let firstRowAsHeaders: Bool?
    let showGridLines: Bool?
    let horizontalCellContentAlignment: String?
    let verticalCellContentAlignment: String?
    let columns: [TableColumnDefinition]
    let rows: [TableRowComponent]

    enum CodingKeys: String, CodingKey {
        case type
        case gridStyle
        case firstRowAsHeaders
        case showGridLines
        case horizontalCellContentAlignment
        case verticalCellContentAlignment
        case columns
        case rows
    }
}

// MARK: - TableColumnDefinition
struct TableColumnDefinition: Codable {
    let width: Double? // Assuming width can be a fractional value

    enum CodingKeys: String, CodingKey {
        case width
    }
}

// MARK: - TableRow
struct TableRowComponent: Codable {
    let type: String
    let cells: [TableCell]
    let style: String?
    let horizontalCellContentAlignment: String?
    let verticalCellContentAlignment: String?

    enum CodingKeys: String, CodingKey {
        case type
        case cells
        case style
        case horizontalCellContentAlignment
        case verticalCellContentAlignment
    }
}

// MARK: - TableCell
struct TableCell: Codable {
    let type: String
    let items: [CardElement]
    let style: String?
    let verticalContentAlignment: String?
    let horizontalContentAlignment: String?

    enum CodingKeys: String, CodingKey {
        case type
        case items
        case style
        case verticalContentAlignment
        case horizontalContentAlignment
    }
}

extension AdaptiveCard {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schema = try container.decodeIfPresent(String.self, forKey: .schema)
        type = try container.decode(String.self, forKey: .type)
        version = try container.decodeIfPresent(String.self, forKey: .version)
        body = try container.decodeIfPresent([CardElement].self, forKey: .body) ?? []
        actions = try container.decodeIfPresent([Action].self, forKey: .actions)
    }
}

extension Action {
    var title: String? {
        switch self {
        case .openUrl(let action):
            return action.title
        case .submit(let action):
            return action.title
        case .showCard(let action):
            return action.title
        case .execute(let action):
            return action.type
        }
    }
}
