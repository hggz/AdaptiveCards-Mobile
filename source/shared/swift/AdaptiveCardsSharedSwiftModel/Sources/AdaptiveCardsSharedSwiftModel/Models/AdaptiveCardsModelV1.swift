import Foundation

// MARK: - AdaptiveCardsSchema: 1.6
/*
public struct AdaptiveCardsPayload: Codable {
    public let schema: String
    public let id: String?
    public let definitions: Definitions
    public let anyOf: [AdaptiveCardsSchema]

    enum CodingKeys: String, CodingKey {
        case schema = "$schema"
        case id, definitions, anyOf
    }
}

// MARK: - AdaptiveCardsSchemaAnyOf
public struct AdaptiveCardsSchema: Codable {
    public let allOf: [AllOf]
}

// MARK: - AllOf
public struct AllOf: Codable {
    public let ref: String

    enum CodingKeys: String, CodingKey {
        case ref = "$ref"
    }
}

// MARK: - Definitions
public struct Definitions: Codable {
    public let actionExecute: ActionExecute
    public let actionOpenURL: ActionOpenURL
    public let actionShowCard, actionSubmit: ActionS
    public let actionToggleVisibility: ActionToggleVisibility
    public let targetElement: TargetElement
    public let adaptiveCard: AdaptiveCard
    public let actionSet: ActionSet
    public let captionSource: CaptionSource
    public let column: Column
    public let columnSet: ColumnSet
    public let container: Container
    public let fact: Fact
    public let factSet: Set
    public let image: Image
    public let imageSet: Set
    public let textRun: TextRun
    public let dataQuery: DataQuery
    public let inputChoice: Fact
    public let inputChoiceSet, inputDate, inputNumber, inputText: Input
    public let inputTime: Input
    public let inputToggle: InputToggle
    public let media: Media
    public let mediaSource: MediaSource
    public let richTextBlock: RichTextBlock
    public let table: Table
    public let tableCell: TableCell
    public let tableColumnDefinition: TableColumnDefinition
    public let tableRow: TableRow
    public let textBlock: TextBlock
    public let actionMode, actionStyle: ActionMode
    public let associatedInputs, blockElementHeight: BlockElementHeightClass
    public let choiceInputStyle: ChoiceInputStyle
    public let colors, containerStyle, fallbackOption, fontSize: BlockElementHeightClass
    public let fontType, fontWeight: BlockElementHeightClass
    public let horizontalAlignment: ChoiceInputStyle
    public let imageFillMode: BlockElementHeightClass
    public let imageSize, imageStyle, inputLabelPosition, inputStyle: ChoiceInputStyle
    public let spacing: ChoiceInputStyle
    public let textBlockStyle: ActionMode
    public let textInputStyle: ChoiceInputStyle
    public let verticalAlignment, verticalContentAlignment: BlockElementHeightClass
    public let authCardButton: AuthCardButton
    public let authentication: Authentication
    public let backgroundImage: BackgroundImage
    public let metadata: Metadata
    public let refresh: Refresh
    public let tokenExchangeResource: TokenExchangeResource
    public let implementationsOfAction, implementationsOfItem, implementationsOfISelectAction, implementationsOfElement: ImplementationsOf
    public let implementationsOfToggleableItem, implementationsOfInline, implementationsOfInput: ImplementationsOf
    public let extendableAction: ExtendableAction
    public let extendableElement: ExtendableElement
    public let extendableInput: ExtendableInput
    public let extendableItem: ExtendableItem
    public let extendabletoggleableItem: ExtendabletoggleableItem

    enum CodingKeys: String, CodingKey {
        case actionExecute = "Action.Execute"
        case actionOpenURL = "Action.OpenUrl"
        case actionShowCard = "Action.ShowCard"
        case actionSubmit = "Action.Submit"
        case actionToggleVisibility = "Action.ToggleVisibility"
        case targetElement = "TargetElement"
        case adaptiveCard = "AdaptiveCard"
        case actionSet = "ActionSet"
        case captionSource = "CaptionSource"
        case column = "Column"
        case columnSet = "ColumnSet"
        case container = "Container"
        case fact = "Fact"
        case factSet = "FactSet"
        case image = "Image"
        case imageSet = "ImageSet"
        case textRun = "TextRun"
        case dataQuery = "Data.Query"
        case inputChoice = "Input.Choice"
        case inputChoiceSet = "Input.ChoiceSet"
        case inputDate = "Input.Date"
        case inputNumber = "Input.Number"
        case inputText = "Input.Text"
        case inputTime = "Input.Time"
        case inputToggle = "Input.Toggle"
        case media = "Media"
        case mediaSource = "MediaSource"
        case richTextBlock = "RichTextBlock"
        case table = "Table"
        case tableCell = "TableCell"
        case tableColumnDefinition = "TableColumnDefinition"
        case tableRow = "TableRow"
        case textBlock = "TextBlock"
        case actionMode = "ActionMode"
        case actionStyle = "ActionStyle"
        case associatedInputs = "AssociatedInputs"
        case blockElementHeight = "BlockElementHeight"
        case choiceInputStyle = "ChoiceInputStyle"
        case colors = "Colors"
        case containerStyle = "ContainerStyle"
        case fallbackOption = "FallbackOption"
        case fontSize = "FontSize"
        case fontType = "FontType"
        case fontWeight = "FontWeight"
        case horizontalAlignment = "HorizontalAlignment"
        case imageFillMode = "ImageFillMode"
        case imageSize = "ImageSize"
        case imageStyle = "ImageStyle"
        case inputLabelPosition = "InputLabelPosition"
        case inputStyle = "InputStyle"
        case spacing = "Spacing"
        case textBlockStyle = "TextBlockStyle"
        case textInputStyle = "TextInputStyle"
        case verticalAlignment = "VerticalAlignment"
        case verticalContentAlignment = "VerticalContentAlignment"
        case authCardButton = "AuthCardButton"
        case authentication = "Authentication"
        case backgroundImage = "BackgroundImage"
        case metadata = "Metadata"
        case refresh = "Refresh"
        case tokenExchangeResource = "TokenExchangeResource"
        case implementationsOfAction = "ImplementationsOf.Action"
        case implementationsOfItem = "ImplementationsOf.Item"
        case implementationsOfISelectAction = "ImplementationsOf.ISelectAction"
        case implementationsOfElement = "ImplementationsOf.Element"
        case implementationsOfToggleableItem = "ImplementationsOf.ToggleableItem"
        case implementationsOfInline = "ImplementationsOf.Inline"
        case implementationsOfInput = "ImplementationsOf.Input"
        case extendableAction = "Extendable.Action"
        case extendableElement = "Extendable.Element"
        case extendableInput = "Extendable.Input"
        case extendableItem = "Extendable.Item"
        case extendabletoggleableItem = "Extendable.ToggleableItem"
    }
}

// MARK: - ActionExecute
public struct ActionExecute: Codable {
    public let description, version: String
    public let properties: ActionExecuteProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let allOf: [AllOf]
}

// MARK: - ActionExecuteProperties
public struct ActionExecuteProperties: Codable {
    public let type: TypeClass
    public let verb: Verb?
    public let data: DataClass?
    public let associatedInputs: AssociatedInputsClass?
    public let title, iconURL, id, style: IconURLClass
    public let fallback, tooltip, isEnabled, mode: IconURLClass
    public let requires: IconURLClass
    public let url: SchemaClass?
    public let card: Card?
    public let targetElements: TargetElements?

    enum CodingKeys: String, CodingKey {
        case type, verb, data, associatedInputs, title
        case iconURL = "iconUrl"
        case id, style, fallback, tooltip, isEnabled, mode, requires, url, card, targetElements
    }
}

// MARK: - AssociatedInputsClass
public struct AssociatedInputsClass: Codable {
    public let ref, description: String
    public let associatedInputsDefault, version: String?

    enum CodingKeys: String, CodingKey {
        case ref = "$ref"
        case description
        case associatedInputsDefault = "default"
        case version
    }
}

// MARK: - Card
public struct Card: Codable {
    public let ref: String
    public let description: String?

    enum CodingKeys: String, CodingKey {
        case ref = "$ref"
        case description
    }
}

// MARK: - DataClass
public struct DataClass: Codable {
    public let anyOf: [AdditionalProperties]
    public let description: String
}

// MARK: - AdditionalProperties
public struct AdditionalProperties: Codable {
    public let type: AdditionalPropertiesType
}

public enum AdditionalPropertiesType: String, Codable {
    case boolean = "boolean"
    case null = "null"
    case number = "number"
    case object = "object"
    case string = "string"
}

// MARK: - IconURLClass
public struct IconURLClass: Codable {
}

// MARK: - TargetElements
public struct TargetElements: Codable {
    public let type: TargetElementsType
    public let items: AllOf
    public let description: String
}

public enum TargetElementsType: String, Codable {
    case array = "array"
}

// MARK: - TypeClass
public struct TypeClass: Codable {
    public let typeEnum: [String]
    public let description: String

    enum CodingKeys: String, CodingKey {
        case typeEnum = "enum"
        case description
    }
}

// MARK: - SchemaClass
public struct SchemaClass: Codable {
    public let type: AdditionalPropertiesType
    public let format, description: String
}

// MARK: - Verb
public struct Verb: Codable {
    public let type: AdditionalPropertiesType
    public let description: String
}

// MARK: - ActionMode
public struct ActionMode: Codable {
    public let description: String?
    public let features: [Int]?
    public let version: String?
    public let anyOf: [ActionModeAnyOf]?
    public let type: AdditionalPropertiesType?
    public let examples: [String]?
    public let format: String?
    public let actionModeDefault: Bool?
    public let additionalProperties: AdditionalProperties?
    public let ref: String?

    enum CodingKeys: String, CodingKey {
        case description, features, version, anyOf, type, examples, format
        case actionModeDefault = "default"
        case additionalProperties
        case ref = "$ref"
    }
}

// MARK: - ActionModeAnyOf
public struct ActionModeAnyOf: Codable {
    public let anyOfEnum: [String]?
    public let pattern: String?

    enum CodingKeys: String, CodingKey {
        case anyOfEnum = "enum"
        case pattern
    }
}

// MARK: - ActionOpenURL
public struct ActionOpenURL: Codable {
    public let description: String
    public let properties: ActionExecuteProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let actionOpenURLRequired: [String]
    public let allOf: [AllOf]

    enum CodingKeys: String, CodingKey {
        case description, properties, type, additionalProperties
        case actionOpenURLRequired = "required"
        case allOf
    }
}

// MARK: - ActionSet
public struct ActionSet: Codable {
    public let description: String
    public let properties: ActionSetProperties
    public let version: String
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let actionSetRequired: [String]
    public let allOf: [AllOf]

    enum CodingKeys: String, CodingKey {
        case description, properties, version, type, additionalProperties
        case actionSetRequired = "required"
        case allOf
    }
}

// MARK: - ActionSetProperties
public struct ActionSetProperties: Codable {
    public let type: TypeClass
    public let actions: TargetElements?
    public let fallback, height, separator, spacing: IconURLClass
    public let id, isVisible, requires: IconURLClass
    public let facts, images: TargetElements?
    public let imageSize: AssociatedInputsClass?
    public let inlines: TargetElements?
    public let horizontalAlignment: HorizontalAlignment?
}

// MARK: - HorizontalAlignment
public struct HorizontalAlignment: Codable {
    public let anyOf: [HorizontalAlignmentAnyOf]
    public let description: String
}

// MARK: - HorizontalAlignmentAnyOf
public struct HorizontalAlignmentAnyOf: Codable {
    public let ref: String?
    public let type: AdditionalPropertiesType?

    enum CodingKeys: String, CodingKey {
        case ref = "$ref"
        case type
    }
}

// MARK: - ActionS
public struct ActionS: Codable {
    public let description: String
    public let properties: ActionExecuteProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let allOf: [AllOf]
}

// MARK: - ActionToggleVisibility
public struct ActionToggleVisibility: Codable {
    public let description, version: String
    public let properties: ActionExecuteProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let actionToggleVisibilityRequired: [String]
    public let allOf: [AllOf]

    enum CodingKeys: String, CodingKey {
        case description, version, properties, type, additionalProperties
        case actionToggleVisibilityRequired = "required"
        case allOf
    }
}

// MARK: - AdaptiveCard
public struct AdaptiveCard: Codable {
    public let description: String
    public let properties: AdaptiveCardProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
}

// MARK: - AdaptiveCardProperties
public struct AdaptiveCardProperties: Codable {
    public let type: TypeClass
    public let version: Lang
    public let refresh, authentication: AssociatedInputsClass
    public let body, actions: TargetElements
    public let selectAction: AssociatedInputsClass
    public let fallbackText: Verb
    public let backgroundImage: PurpleBackgroundImage
    public let metadata: AssociatedInputsClass
    public let minHeight: MinHeight
    public let rtl: RTL
    public let speak: Verb
    public let lang: Lang
    public let verticalContentAlignment: AssociatedInputsClass
    public let schema: SchemaClass

    enum CodingKeys: String, CodingKey {
        case type, version, refresh, authentication, body, actions, selectAction, fallbackText, backgroundImage, metadata, minHeight, rtl, speak, lang, verticalContentAlignment
        case schema = "$schema"
    }
}

// MARK: - PurpleBackgroundImage
public struct PurpleBackgroundImage: Codable {
    public let anyOf: [URLElement]
    public let description, version: String
}

// MARK: - URLElement
public struct URLElement: Codable {
    public let ref: String?
    public let type: AdditionalPropertiesType?
    public let format, description, version: String?

    enum CodingKeys: String, CodingKey {
        case ref = "$ref"
        case type, format, description, version
    }
}

// MARK: - Lang
public struct Lang: Codable {
    public let type: AdditionalPropertiesType
    public let description: String
    public let examples: [String]?
    public let version: String?
}

// MARK: - MinHeight
public struct MinHeight: Codable {
    public let type: AdditionalPropertiesType
    public let description: String
    public let examples: [String]?
    public let version: String?
    public let features: [Int]?
    public let example: String?
    public let minHeightDefault: Bool?
    public let additionalProperties: AdditionalProperties?

    enum CodingKeys: String, CodingKey {
        case type, description, examples, version, features, example
        case minHeightDefault = "default"
        case additionalProperties
    }
}

// MARK: - RTL
public struct RTL: Codable {
    public let anyOf: [AdditionalProperties]
    public let description, version: String
}

// MARK: - BlockElementHeightClass
public struct BlockElementHeightClass: Codable {
    public let anyOf: [ActionModeAnyOf]
}

// MARK: - AuthCardButton
public struct AuthCardButton: Codable {
    public let description, version: String
    public let properties: AuthCardButtonProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let authCardButtonRequired: [String]

    enum CodingKeys: String, CodingKey {
        case description, version, properties, type, additionalProperties
        case authCardButtonRequired = "required"
    }
}

// MARK: - AuthCardButtonProperties
public struct AuthCardButtonProperties: Codable {
    public let type, title, image, value: Verb
}

// MARK: - Authentication
public struct Authentication: Codable {
    public let description, version: String
    public let properties: AuthenticationProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
}

// MARK: - AuthenticationProperties
public struct AuthenticationProperties: Codable {
    public let type: TypeClass
    public let text, connectionName: Verb
    public let tokenExchangeResource: Card
    public let buttons: TargetElements
}

// MARK: - BackgroundImage
public struct BackgroundImage: Codable {
    public let description: String
    public let properties: BackgroundImageProperties
    public let version: String
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let backgroundImageRequired: [String]

    enum CodingKeys: String, CodingKey {
        case description, properties, version, type, additionalProperties
        case backgroundImageRequired = "required"
    }
}

// MARK: - BackgroundImageProperties
public struct BackgroundImageProperties: Codable {
    public let type: TypeClass
    public let url: SchemaClass
    public let fillMode, horizontalAlignment, verticalAlignment: Card
}

// MARK: - CaptionSource
public struct CaptionSource: Codable {
    public let description, version: String
    public let features: [Int]
    public let properties: CaptionSourceProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let captionSourceRequired: [String]

    enum CodingKeys: String, CodingKey {
        case description, version, features, properties, type, additionalProperties
        case captionSourceRequired = "required"
    }
}

// MARK: - CaptionSourceProperties
public struct CaptionSourceProperties: Codable {
    public let type: TypeClass
    public let mimeType: Verb
    public let url: SchemaClass
    public let label: Verb
}

// MARK: - ChoiceInputStyle
public struct ChoiceInputStyle: Codable {
    public let description: String
    public let anyOf: [ActionModeAnyOf]
}

// MARK: - Column
public struct Column: Codable {
    public let description: String
    public let properties: ColumnProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let allOf: [AllOf]
}

// MARK: - ColumnProperties
public struct ColumnProperties: Codable {
    public let type: TypeClass
    public let items: TargetElements
    public let backgroundImage: FluffyBackgroundImage
    public let bleed: ActionMode
    public let fallback: PurpleFallback
    public let minHeight: MinHeight
    public let rtl: RTL
    public let separator: Verb
    public let spacing: Card
    public let selectAction: AssociatedInputsClass
    public let style: HorizontalAlignment
    public let verticalContentAlignment: VerticalContentAlignment
    public let width: DataClass
    public let id, isVisible, requires: IconURLClass
}

// MARK: - FluffyBackgroundImage
public struct FluffyBackgroundImage: Codable {
    public let anyOf: [BackgroundImageAnyOf]
    public let description, version: String
}

// MARK: - BackgroundImageAnyOf
public struct BackgroundImageAnyOf: Codable {
    public let ref: String?
    public let type: AdditionalPropertiesType?
    public let format, description: String?

    enum CodingKeys: String, CodingKey {
        case ref = "$ref"
        case type, format, description
    }
}

// MARK: - PurpleFallback
public struct PurpleFallback: Codable {
    public let anyOf: [AllOf]
    public let description, version: String
}

// MARK: - VerticalContentAlignment
public struct VerticalContentAlignment: Codable {
    public let anyOf: [HorizontalAlignmentAnyOf]
    public let description, version: String
}

// MARK: - ColumnSet
public struct ColumnSet: Codable {
    public let description: String
    public let properties: ColumnSetProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let allOf: [AllOf]
}

// MARK: - ColumnSetProperties
public struct ColumnSetProperties: Codable {
    public let type: TypeClass
    public let columns: TargetElements
    public let selectAction: AssociatedInputsClass
    public let style: VerticalContentAlignment
    public let bleed, minHeight: MinHeight
    public let horizontalAlignment: HorizontalAlignment
    public let fallback, height, separator, spacing: IconURLClass
    public let id, isVisible, requires: IconURLClass
}

// MARK: - Container
public struct Container: Codable {
    public let description: String
    public let properties: ContainerProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let containerRequired: [String]
    public let allOf: [AllOf]

    enum CodingKeys: String, CodingKey {
        case description, properties, type, additionalProperties
        case containerRequired = "required"
        case allOf
    }
}

// MARK: - ContainerProperties
public struct ContainerProperties: Codable {
    public let type: TypeClass
    public let items: TargetElements
    public let selectAction: AssociatedInputsClass
    public let style: HorizontalAlignment
    public let verticalContentAlignment: VerticalContentAlignment
    public let bleed: MinHeight
    public let backgroundImage: FluffyBackgroundImage
    public let minHeight: ActionMode
    public let rtl: RTL
    public let fallback, height, separator, spacing: IconURLClass
    public let id, isVisible, requires: IconURLClass

    enum CodingKeys: String, CodingKey {
        case type, items, selectAction, style, verticalContentAlignment, bleed, backgroundImage, minHeight
        case rtl = "rtl?"
        case fallback, height, separator, spacing, id, isVisible, requires
    }
}

// MARK: - DataQuery
public struct DataQuery: Codable {
    public let description: String
    public let properties: DataQueryProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let dataQueryRequired: [String]

    enum CodingKeys: String, CodingKey {
        case description, properties, type, additionalProperties
        case dataQueryRequired = "required"
    }
}

// MARK: - DataQueryProperties
public struct DataQueryProperties: Codable {
    public let type: TypeClass
    public let dataset, count, skip: ActionMode
}

// MARK: - ExtendableAction
public struct ExtendableAction: Codable {
    public let properties: ExtendableActionProperties
    public let type: AdditionalPropertiesType
    public let allOf: [AllOf]
}

// MARK: - ExtendableActionProperties
public struct ExtendableActionProperties: Codable {
    public let title: Verb
    public let iconURL: ActionMode
    public let id: Verb
    public let style: AssociatedInputsClass
    public let fallback: PurpleFallback
    public let tooltip, isEnabled: ActionMode
    public let mode: AssociatedInputsClass
    public let requires: IconURLClass

    enum CodingKeys: String, CodingKey {
        case title
        case iconURL = "iconUrl"
        case id, style, fallback, tooltip, isEnabled, mode, requires
    }
}

// MARK: - ExtendableElement
public struct ExtendableElement: Codable {
    public let properties: ExtendableElementProperties
    public let type: AdditionalPropertiesType
    public let allOf: [AllOf]
}

// MARK: - ExtendableElementProperties
public struct ExtendableElementProperties: Codable {
    public let fallback: PurpleFallback
    public let height: AssociatedInputsClass
    public let separator: Verb
    public let spacing: Card
    public let id, isVisible, requires: IconURLClass
}

// MARK: - ExtendableInput
public struct ExtendableInput: Codable {
    public let description: String
    public let properties: ExtendableInputProperties
    public let type: AdditionalPropertiesType
    public let extendableInputRequired: [String]

    enum CodingKeys: String, CodingKey {
        case description, properties, type
        case extendableInputRequired = "required"
    }
}

// MARK: - ExtendableInputProperties
public struct ExtendableInputProperties: Codable {
    public let id: Verb
    public let errorMessage: MinHeight
    public let isRequired, label: ActionMode
    public let labelPosition: AssociatedInputsClass
    public let labelWidth: RTL
    public let inputStyle: AssociatedInputsClass
    public let fallback: PurpleFallback
    public let height: AssociatedInputsClass
    public let separator: Verb
    public let spacing: Card
    public let isVisible, requires: ActionMode
}

// MARK: - ExtendableItem
public struct ExtendableItem: Codable {
    public let properties: ExtendableItemProperties
    public let type: AdditionalPropertiesType
}

// MARK: - ExtendableItemProperties
public struct ExtendableItemProperties: Codable {
    public let requires: ActionMode
}

// MARK: - Extendabpublic letoggleableItem
public struct ExtendabletoggleableItem: Codable {
    public let properties: ExtendabletoggleableItemProperties
    public let type: AdditionalPropertiesType
    public let allOf: [AllOf]
}

// MARK: - Extendabpublic letoggleableItemProperties
public struct ExtendabletoggleableItemProperties: Codable {
    public let id: Verb
    public let isVisible: ActionMode
    public let requires: IconURLClass
}

// MARK: - Fact
public struct Fact: Codable {
    public let description: String
    public let properties: FactProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let factRequired: [String]

    enum CodingKeys: String, CodingKey {
        case description, properties, type, additionalProperties
        case factRequired = "required"
    }
}

// MARK: - FactProperties
public struct FactProperties: Codable {
    public let type: TypeClass
    public let title, value: Verb
}

// MARK: - Set
public struct Set: Codable {
    public let description: String
    public let properties: ActionSetProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let setRequired: [String]
    public let allOf: [AllOf]

    enum CodingKeys: String, CodingKey {
        case description, properties, type, additionalProperties
        case setRequired = "required"
        case allOf
    }
}

// MARK: - Image
public struct Image: Codable {
    public let description: String
    public let properties: ImageProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let imageRequired: [String]

    enum CodingKeys: String, CodingKey {
        case description, properties, type, additionalProperties
        case imageRequired = "required"
    }
}

// MARK: - ImageProperties
public struct ImageProperties: Codable {
    public let type: TypeClass
    public let url: URLElement
    public let altText: Verb
    public let backgroundColor: MinHeight
    public let height: Height
    public let horizontalAlignment: HorizontalAlignment
    public let selectAction: AssociatedInputsClass
    public let size, style: Card
    public let width: Lang
    public let fallback: PurpleFallback
    public let separator: Verb
    public let spacing: Card
    public let id: Verb
    public let isVisible, requires: MinHeight
}

// MARK: - Height
public struct Height: Codable {
    public let anyOf: [HorizontalAlignmentAnyOf]
    public let description: String
    public let examples: [String]
    public let heightDefault, version: String

    enum CodingKeys: String, CodingKey {
        case anyOf, description, examples
        case heightDefault = "default"
        case version
    }
}

// MARK: - ImplementationsOf
public struct ImplementationsOf: Codable {
    public let anyOf: [ImplementationsOfActionAnyOf]
}

// MARK: - ImplementationsOfActionAnyOf
public struct ImplementationsOfActionAnyOf: Codable {
    public let anyOfRequired: [Required]
    public let allOf: [AllOf]

    enum CodingKeys: String, CodingKey {
        case anyOfRequired = "required"
        case allOf
    }
}

public enum Required: String, Codable {
    case type = "type"
}

// MARK: - Input
public struct Input: Codable {
    public let description: String
    public let properties: InputChoiceSetProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let allOf: [AllOf]
}

// MARK: - InputChoiceSetProperties
public struct InputChoiceSetProperties: Codable {
    public let type: TypeClass
    public let choices: TargetElements?
    public let choicesData: AssociatedInputsClass?
    public let isMultiSelect: MinHeight?
    public let style: Card?
    public let value, placeholder: Verb
    public let wrap: Lang?
    public let id, errorMessage, isRequired, label: IconURLClass
    public let labelPosition, labelWidth, inputStyle, fallback: IconURLClass
    public let height, separator, spacing, isVisible: IconURLClass
    public let requires: IconURLClass
    public let max, min: Verb?
    public let isMultiline: ActionMode?
    public let maxLength: Verb?
    public let regex: MinHeight?
    public let inlineAction: AssociatedInputsClass?

    enum CodingKeys: String, CodingKey {
        case type, choices
        case choicesData = "choices.data"
        case isMultiSelect, style, value, placeholder, wrap, id, errorMessage, isRequired, label, labelPosition, labelWidth, inputStyle, fallback, height, separator, spacing, isVisible, requires, max, min, isMultiline, maxLength, regex, inlineAction
    }
}

// MARK: - InputToggle
public struct InputToggle: Codable {
    public let description: String
    public let properties: InputToggleProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let inputToggleRequired: [String]
    public let allOf: [AllOf]

    enum CodingKeys: String, CodingKey {
        case description, properties, type, additionalProperties
        case inputToggleRequired = "required"
        case allOf
    }
}

// MARK: - InputToggleProperties
public struct InputToggleProperties: Codable {
    public let type: TypeClass
    public let title: Verb
    public let value, valueOff, valueOn: Value
    public let wrap: MinHeight
    public let id, errorMessage, isRequired, label: IconURLClass
    public let labelPosition, labelWidth, inputStyle, fallback: IconURLClass
    public let height, separator, spacing, isVisible: IconURLClass
    public let requires: IconURLClass
}

// MARK: - Value
public struct Value: Codable {
    public let type: AdditionalPropertiesType
    public let description, valueDefault: String

    enum CodingKeys: String, CodingKey {
        case type, description
        case valueDefault = "default"
    }
}

// MARK: - Media
public struct Media: Codable {
    public let description, version: String
    public let features: [Int]
    public let properties: MediaProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let mediaRequired: [String]
    public let allOf: [AllOf]

    enum CodingKeys: String, CodingKey {
        case description, version, features, properties, type, additionalProperties
        case mediaRequired = "required"
        case allOf
    }
}

// MARK: - MediaProperties
public struct MediaProperties: Codable {
    public let type: TypeClass
    public let sources: TargetElements
    public let poster: URLElement
    public let altText: Verb
    public let captionSources: CaptionSources
    public let fallback, height, separator, spacing: IconURLClass
    public let id, isVisible, requires: IconURLClass
}

// MARK: - CaptionSources
public struct CaptionSources: Codable {
    public let type: TargetElementsType
    public let items: AllOf
    public let description: String
    public let captionSourcesRequired: Bool
    public let version: String

    enum CodingKeys: String, CodingKey {
        case type, items, description
        case captionSourcesRequired = "required"
        case version
    }
}

// MARK: - MediaSource
public struct MediaSource: Codable {
    public let description, version: String
    public let features: [Int]
    public let properties: MediaSourceProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let mediaSourceRequired: [String]

    enum CodingKeys: String, CodingKey {
        case description, version, features, properties, type, additionalProperties
        case mediaSourceRequired = "required"
    }
}

// MARK: - MediaSourceProperties
public struct MediaSourceProperties: Codable {
    public let type: TypeClass
    public let mimeType: MIMEType
    public let url: SchemaClass
}

// MARK: - MIMEType
public struct MIMEType: Codable {
    public let type: AdditionalPropertiesType
    public let description: String
    public let mimeTypeRequired: Bool

    enum CodingKeys: String, CodingKey {
        case type, description
        case mimeTypeRequired = "required"
    }
}

// MARK: - Metadata
public struct Metadata: Codable {
    public let description, version: String
    public let properties: MetadataProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
}

// MARK: - MetadataProperties
public struct MetadataProperties: Codable {
    public let type: TypeClass
    public let webURL: URLElement

    enum CodingKeys: String, CodingKey {
        case type
        case webURL = "webUrl"
    }
}

// MARK: - Refresh
public struct Refresh: Codable {
    public let description, version: String
    public let properties: RefreshProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
}

// MARK: - RefreshProperties
public struct RefreshProperties: Codable {
    public let type: TypeClass
    public let action: Card
    public let expires: MinHeight
    public let userIDS: UserIDS

    enum CodingKeys: String, CodingKey {
        case type, action, expires
        case userIDS = "userIds"
    }
}

// MARK: - UserIDS
public struct UserIDS: Codable {
    public let type: TargetElementsType
    public let items: AdditionalProperties
    public let description: String
}

// MARK: - RichTextBlock
public struct RichTextBlock: Codable {
    public let description, version: String
    public let features: [Int]
    public let properties: ActionSetProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let richTextBlockRequired: [String]
    public let allOf: [AllOf]

    enum CodingKeys: String, CodingKey {
        case description, version, features, properties, type, additionalProperties
        case richTextBlockRequired = "required"
        case allOf
    }
}

// MARK: - Table
public struct Table: Codable {
    public let description, version: String
    public let properties: TableProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let allOf: [AllOf]
}

// MARK: - TableProperties
public struct TableProperties: Codable {
    public let type: TypeClass
    public let columns, rows: TargetElements
    public let firstRowAsHeader: MinHeight
    public let showGridLines: ActionMode
    public let gridStyle: Style
    public let horizontalCellContentAlignment, verticalCellContentAlignment: HorizontalAlignment
    public let fallback, height, separator, spacing: IconURLClass
    public let id, isVisible, requires: IconURLClass
}

// MARK: - Style
public struct Style: Codable {
    public let anyOf: [HorizontalAlignmentAnyOf]
    public let description, styleDefault: String

    enum CodingKeys: String, CodingKey {
        case anyOf, description
        case styleDefault = "default"
    }
}

// MARK: - TableCell
public struct TableCell: Codable {
    public let description, version: String
    public let properties: TableCellProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let tableCellRequired: [String]

    enum CodingKeys: String, CodingKey {
        case description, version, properties, type, additionalProperties
        case tableCellRequired = "required"
    }
}

// MARK: - TableCellProperties
public struct TableCellProperties: Codable {
    public let type: TypeClass
    public let items: TargetElements
    public let selectAction: AssociatedInputsClass
    public let style: HorizontalAlignment
    public let verticalContentAlignment: VerticalContentAlignment
    public let bleed: ActionMode
    public let backgroundImage: FluffyBackgroundImage
    public let minHeight: ActionMode
    public let rtl: RTL

    enum CodingKeys: String, CodingKey {
        case type, items, selectAction, style, verticalContentAlignment, bleed, backgroundImage, minHeight
        case rtl = "rtl?"
    }
}

// MARK: - TableColumnDefinition
public struct TableColumnDefinition: Codable {
    public let description, version: String
    public let properties: TableColumnDefinitionProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
}

// MARK: - TableColumnDefinitionProperties
public struct TableColumnDefinitionProperties: Codable {
    public let type: TypeClass
    public let width: Width
    public let horizontalCellContentAlignment, verticalCellContentAlignment: HorizontalAlignment
}

// MARK: - Width
public struct Width: Codable {
    public let anyOf: [AdditionalProperties]
    public let description: String
    public let widthDefault: Int

    enum CodingKeys: String, CodingKey {
        case anyOf, description
        case widthDefault = "default"
    }
}

// MARK: - TableRow
public struct TableRow: Codable {
    public let description, version: String
    public let properties: TableRowProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
}

// MARK: - TableRowProperties
public struct TableRowProperties: Codable {
    public let type: TypeClass
    public let cells: TargetElements
    public let style, horizontalCellContentAlignment, verticalCellContentAlignment: HorizontalAlignment
}

// MARK: - TargetElement
public struct TargetElement: Codable {
    public let description: String
    public let anyOf: [TargetElementAnyOf]
}

// MARK: - TargetElementAnyOf
public struct TargetElementAnyOf: Codable {
    public let type: AdditionalPropertiesType
    public let description: String?
    public let properties: PurpleProperties?
    public let anyOfRequired: [String]?
    public let additionalProperties: Bool?

    enum CodingKeys: String, CodingKey {
        case type, description, properties
        case anyOfRequired = "required"
        case additionalProperties
    }
}

// MARK: - PurpleProperties
public struct PurpleProperties: Codable {
    public let type: TypeClass
    public let elementID: Verb
    public let isVisible: DataClass

    enum CodingKeys: String, CodingKey {
        case type
        case elementID = "elementId"
        case isVisible
    }
}

// MARK: - TextBlock
public struct TextBlock: Codable {
    public let description: String
    public let properties: TextBlockProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let textBlockRequired: [String]
    public let allOf: [AllOf]

    enum CodingKeys: String, CodingKey {
        case description, properties, type, additionalProperties
        case textBlockRequired = "required"
        case allOf
    }
}

// MARK: - TextBlockProperties
public struct TextBlockProperties: Codable {
    public let type: TypeClass
    public let text: Verb
    public let color: HorizontalAlignment
    public let fontType: VerticalContentAlignment
    public let horizontalAlignment: HorizontalAlignment
    public let isSubtle: IsSubtle
    public let maxLines: Verb
    public let size, weight: HorizontalAlignment
    public let wrap: ActionMode
    public let style: Style
    public let fallback, height, separator, spacing: IconURLClass
    public let id, isVisible, requires: IconURLClass
}

// MARK: - IsSubtle
public struct IsSubtle: Codable {
    public let anyOf: [AdditionalProperties]
    public let description: String
    public let isSubtleDefault: Bool

    enum CodingKeys: String, CodingKey {
        case anyOf, description
        case isSubtleDefault = "default"
    }
}

// MARK: - TextRun
public struct TextRun: Codable {
    public let description, version: String
    public let anyOf: [TextRunAnyOf]
}

// MARK: - TextRunAnyOf
public struct TextRunAnyOf: Codable {
    public let type: AdditionalPropertiesType
    public let description: String?
    public let properties: FluffyProperties?
    public let anyOfRequired: [String]?
    public let additionalProperties: Bool?

    enum CodingKeys: String, CodingKey {
        case type, description, properties
        case anyOfRequired = "required"
        case additionalProperties
    }
}

// MARK: - FluffyProperties
public struct FluffyProperties: Codable {
    public let type: TypeClass
    public let text: Verb
    public let color, fontType: HorizontalAlignment
    public let highlight: Verb
    public let isSubtle: IsSubtle
    public let italic: Verb
    public let selectAction: Card
    public let size: HorizontalAlignment
    public let strikethrough: Verb
    public let underline: Lang
    public let weight: HorizontalAlignment
}

// MARK: - TokenExchangeResource
public struct TokenExchangeResource: Codable {
    public let description, version: String
    public let properties: TokenExchangeResourceProperties
    public let type: AdditionalPropertiesType
    public let additionalProperties: Bool
    public let tokenExchangeResourceRequired: [String]

    enum CodingKeys: String, CodingKey {
        case description, version, properties, type, additionalProperties
        case tokenExchangeResourceRequired = "required"
    }
}

// MARK: - TokenExchangeResourceProperties
public struct TokenExchangeResourceProperties: Codable {
    public let type: TypeClass
    public let id, uri, providerID: Verb

    enum CodingKeys: String, CodingKey {
        case type, id, uri
        case providerID = "providerId"
    }
}
*/
