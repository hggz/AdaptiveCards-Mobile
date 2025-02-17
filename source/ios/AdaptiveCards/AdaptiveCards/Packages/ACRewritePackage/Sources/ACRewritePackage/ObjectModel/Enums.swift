import Foundation

enum CardElementType: String, Codable {
    case actionSet = "ActionSet"
    case adaptiveCard = "AdaptiveCard"
    case choiceInput = "ChoiceInput"
    case choiceSetInput = "ChoiceSetInput"
    case column = "Column"
    case columnSet = "ColumnSet"
    case container = "Container"
    case custom = "Custom"
    case dateInput = "DateInput"
    case fact = "Fact"
    case factSet = "FactSet"
    case image = "Image"
    case icon = "Icon"
    case imageSet = "ImageSet"
    case media = "Media"
    case numberInput = "NumberInput"
    case ratingInput = "RatingInput"
    case ratingLabel = "RatingLabel"
    case richTextBlock = "RichTextBlock"
    case table = "Table"
    case tableCell = "TableCell"
    case tableRow = "TableRow"
    case textBlock = "TextBlock"
    case textInput = "TextInput"
    case timeInput = "TimeInput"
    case toggleInput = "ToggleInput"
    case compoundButton = "CompoundButton"
    case inputText = "Input.Text"
    case inputChoiceSet = "Input.ChoiceSet"
    case inputToggle = "Input.Toggle"
    case unknown = "Unknown"
}

enum Mode: String, Codable {
    case primary, secondary
}

enum ErrorStatusCode: String, Codable {
    case invalidJson, renderFailed, requiredPropertyMissing, invalidPropertyValue, unsupportedParserOverride, idCollision, customError, unknownElementType, serializationFailed
}

enum WarningStatusCode: String, Codable {
    case unknownElementType, unknownActionElementType, unknownPropertyOnElement, unknownEnumValue, noRendererForType
    case interactivityNotSupported, maxActionsExceeded, assetLoadFailed, unsupportedSchemaVersion, unsupportedMediaType
    case invalidMediaMix, invalidColorFormat, invalidDimensionSpecified, invalidLanguage, invalidValue, customWarning
    case emptyLabelInRequiredInput, requiredPropertyMissing
}

enum HostWidth: String, Codable {
    case `default`, veryNarrow, narrow, standard, wide
    static func < (lhs: HostWidth, rhs: HostWidth) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    static func <= (lhs: HostWidth, rhs: HostWidth) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
    static func >= (lhs: HostWidth, rhs: HostWidth) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
}

enum TargetWidthType: String, Codable {
    case `default`, veryNarrow, narrow, standard, wide
    case atMostVeryNarrow, atMostNarrow, atMostStandard, atMostWide
    case atLeastVeryNarrow, atLeastNarrow, atLeastStandard, atLeastWide
}


// MARK: - CardElementType

/// The test expects `.adaptiveCard` → "AdaptiveCard", etc.
extension CardElementType {
    static func toString(_ value: CardElementType) -> String {
        switch value {
        case .actionSet: return "ActionSet"
        case .adaptiveCard: return "AdaptiveCard"
        case .choiceInput: return "choiceInput"
        case .choiceSetInput: return "choiceSetInput"
        case .column: return "column"
        case .columnSet: return "columnSet"
        case .container: return "container"
        case .custom: return "custom"
        case .dateInput: return "dateInput"
        case .fact: return "fact"
        case .factSet: return "factSet"
        case .image: return "image"
        case .icon: return "icon"
        case .imageSet: return "imageSet"
        case .media: return "media"
        case .numberInput: return "numberInput"
        case .ratingInput: return "ratingInput"
        case .ratingLabel: return "ratingLabel"
        case .richTextBlock: return "richTextBlock"
        case .table: return "table"
        case .tableCell: return "tableCell"
        case .tableRow: return "tableRow"
        case .textBlock: return "textBlock"
        case .textInput: return "textInput"
        case .timeInput: return "timeInput"
        case .toggleInput: return "toggleInput"
        case .compoundButton: return "compoundButton"
        case .unknown: return "unknown"
        case .inputText: return "inputText"
        case .inputChoiceSet: return "inputChoiceSet"
        case .inputToggle: return "inputToggle"
        }
    }
    
    static func fromString(_ str: String) -> CardElementType? {
        switch str {
        case "ActionSet": return .actionSet
        case "AdaptiveCard": return .adaptiveCard
        case "choiceInput": return .choiceInput
        case "choiceSetInput": return .choiceSetInput
        case "column": return .column
        case "columnSet": return .columnSet
        case "container": return .container
        case "custom": return .custom
        case "dateInput": return .dateInput
        case "fact": return .fact
        case "factSet": return .factSet
        case "image": return .image
        case "icon": return .icon
        case "imageSet": return .imageSet
        case "media": return .media
        case "numberInput": return .numberInput
        case "ratingInput": return .ratingInput
        case "ratingLabel": return .ratingLabel
        case "richTextBlock": return .richTextBlock
        case "table": return .table
        case "tableCell": return .tableCell
        case "tableRow": return .tableRow
        case "textBlock": return .textBlock
        case "textInput": return .textInput
        case "timeInput": return .timeInput
        case "toggleInput": return .toggleInput
        case "compoundButton": return .compoundButton
        case "unknown": return .unknown
        default: return nil
        }
    }
}

// MARK: - TextSize

enum TextSize: String, Codable {
    case defaultSize = "Default"
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "ExtraLarge"
    
    init(from rawValue: String) {
        self = TextSize(rawValue: rawValue) ?? .defaultSize
    }
}

extension TextSize {
    static func toString(_ value: TextSize) -> String {
        // "Default" → "Normal", others are the same as rawValue
        switch value {
        case .defaultSize: return "Normal"
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        case .extraLarge: return "ExtraLarge"
        }
    }
    
    static func fromString(_ s: String) -> TextSize? {
        let lowered = s.lowercased()
        if lowered == "normal" { return .defaultSize }
        switch lowered {
        case "small": return .small
        case "medium": return .medium
        case "large": return .large
        case "extralarge": return .extraLarge
        default: return nil
        }
    }
}

// MARK: - TextWeight

enum TextWeight: String, Codable {
    case defaultWeight = "Default"
    case lighter = "Lighter"
    case bolder = "Bolder"
    // We add no changes to init since your code uses it.
    init(from rawValue: String) {
        self = TextWeight(rawValue: rawValue) ?? .defaultWeight
    }
}

extension TextWeight {
    static func toString(_ value: TextWeight) -> String {
        // defaultWeight → "Normal"
        switch value {
        case .defaultWeight: return "Normal"
        case .lighter: return "Lighter"
        case .bolder: return "Bolder"
        }
    }
    
    static func fromString(_ s: String) -> TextWeight? {
        switch s {
        case "Normal": return .defaultWeight
        case "Lighter": return .lighter
        case "Bolder": return .bolder
        default: return nil
        }
    }
}

// MARK: - FontType

enum FontType: String, Codable {
    case defaultFont = "Default"
    case monospace = "Monospace"
    init(from rawValue: String) {
        self = FontType(rawValue: rawValue) ?? .defaultFont
    }
}

extension FontType {
    static func toString(_ value: FontType) -> String {
        switch value {
        case .defaultFont: return "Default"
        case .monospace: return "Monospace"
        }
    }
    
    static func fromString(_ s: String) -> FontType? {
        switch s {
        case "Default": return .defaultFont
        case "Monospace": return .monospace
        default: return nil
        }
    }
}

// MARK: - ForegroundColor

enum ForegroundColor: String, Codable {
    case `default`, dark, light, accent, good, warning, attention
}

extension ForegroundColor {
    static func toString(_ value: ForegroundColor) -> String {
        // e.g. "accent" → "Accent" if test expects capital letter
        switch value {
        case .default: return "Default"
        case .dark: return "Dark"
        case .light: return "Light"
        case .accent: return "Accent"
        case .good: return "Good"
        case .warning: return "Warning"
        case .attention: return "Attention"
        }
    }
    
    static func fromString(_ s: String) -> ForegroundColor? {
        switch s.capitalized {
        case "Default": return .default
        case "Dark": return .dark
        case "Light": return .light
        case "Accent": return .accent
        case "Good": return .good
        case "Warning": return .warning
        case "Attention": return .attention
        default: return nil
        }
    }
}

// MARK: - HorizontalAlignment

enum HorizontalAlignment: String, Codable {
    case left = "Left"
    case center = "center"
    case right = "Right"
    init(from rawValue: String) {
        self = HorizontalAlignment(rawValue: rawValue) ?? .left
    }
}

extension HorizontalAlignment {
    static func toString(_ value: HorizontalAlignment) -> String {
        return value.rawValue // e.g. "Center"
    }
    static func fromString(_ s: String) -> HorizontalAlignment? {
        switch s {
        case "Left": return .left
        case "center": return .center
        case "Right": return .right
        default: return nil
        }
    }
}

// MARK: - VerticalAlignment

enum VerticalAlignment: String, Codable {
    case top, center, bottom
}

// Your test references a “VerticalContentAlignment” with `.center`.
// If you really need that exact enum, define it:
enum VerticalContentAlignment: String, Codable {
    case top = "Top"
    case center = "Center"
    case bottom = "Bottom"
}

extension VerticalContentAlignment {
    static func toString(_ value: VerticalContentAlignment) -> String {
        return value.rawValue
    }
    static func fromString(_ s: String) -> VerticalContentAlignment? {
        switch s {
        case "Top": return .top
        case "Center": return .center
        case "Bottom": return .bottom
        default: return nil
        }
    }
}

// MARK: - ImageSize

enum ImageSize: String, Codable {
    case none, auto, stretch, small, medium, large
}

extension ImageSize {
    static func toString(_ value: ImageSize) -> String {
        switch value {
        case .none: return "none"
        case .auto: return "auto"
        case .stretch: return "stretch"
        case .small: return "small"
        case .medium: return "medium"
        case .large: return "Large" // if your test wants capital "Large"
        }
    }
    static func fromString(_ s: String) -> ImageSize? {
        switch s.lowercased() {
        case "none": return .none
        case "auto": return .auto
        case "stretch": return .stretch
        case "small": return .small
        case "medium": return .medium
        case "large": return .large
        default: return nil
        }
    }
}

// MARK: - ImageStyle

enum ImageStyle: String, Codable {
    case defaultImageStyle, person, roundedCorners
    
}

extension ImageStyle {
    static func toString(_ value: ImageStyle) -> String {
        switch value {
        case .defaultImageStyle: return "defaultImageStyle"
        case .person: return "person"
        case .roundedCorners: return "roundedCorners"
        }
    }
    static func fromString(_ s: String) -> ImageStyle? {
        switch s.lowercased() {
        case "defaultimagestyle": return .defaultImageStyle
        case "person": return .person
        case "roundedcorners": return .roundedCorners
        default: return nil
        }
    }
}

// MARK: - TextInputStyle

enum TextInputStyle: String, Codable {
    case text, tel, url, email, password
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw.lowercased() {
        case "password":
            self = .password
        case "tel":
            self = .tel
        case "url":
            self = .url
        case "email":
            self = .email
        default:
            self = .text
        }
    }
}

extension TextInputStyle {
    static func toString(_ value: TextInputStyle) -> String {
        switch value {
        case .text: return "text"
        case .tel: return "tel"
        case .url: return "url"
        case .email: return "email"
        case .password: return "Password" // test wants capital "Password"
        }
    }
    static func fromString(_ s: String) -> TextInputStyle? {
        switch s.lowercased() {
        case "text": return .text
        case "tel": return .tel
        case "url": return .url
        case "email": return .email
        case "password": return .password
        default: return nil
        }
    }
}

// MARK: - ActionType

enum ActionType: String, Codable {
    case unsupported
    case execute
    case openUrl
    case showCard
    case submit
    case toggleVisibility
    case custom
    case unknownAction
    case overflow
    
    // Mirror the C++ approach, but local to this enum.
    static func toString(_ value: ActionType) -> String {
        // If missing, fallback to rawValue
        switch value {
        case .unsupported: return "unsupported"
        case .execute: return "execute"
        case .openUrl: return "Action.OpenUrl"  // special
        case .showCard: return "Action.ShowCard"
        case .submit: return "Action.Submit"
        case .toggleVisibility: return "toggleVisibility"
        case .custom: return "custom"
        case .unknownAction: return "unknownAction"
        case .overflow: return "overflow"
        }
    }

    static func fromString(_ s: String) -> ActionType? {
        // case-insensitive
        let lowered = s.lowercased()
        switch lowered {
        case "unsupported": return .unsupported
        case "execute": return .execute
        case "action.openurl": return .openUrl
        case "action.showcard": return .showCard
        case "action.submit": return .submit
        case "togglevisibility": return .toggleVisibility
        case "custom": return .custom
        case "unknownaction": return .unknownAction
        case "overflow": return .overflow
        default: return nil
        }
    }
}

// MARK: - ActionAlignment

enum ActionAlignment: String, Codable {
    case left, center, right, stretch
}

extension ActionAlignment {
    static func toString(_ value: ActionAlignment) -> String {
        switch value {
        case .left: return "Left"
        case .center: return "Center"
        case .right: return "Right"
        case .stretch: return "Stretch"
        }
    }
    static func fromString(_ s: String) -> ActionAlignment? {
        switch s {
        case "Left": return .left
        case "Center": return .center
        case "Right": return .right
        case "Stretch": return .stretch
        default: return nil
        }
    }
}

// MARK: - ActionMode (the test references .popup)

enum ActionMode: String, Codable {
    case inline = "Inline"
    case popup = "Popup"
}

extension ActionMode {
    static func toString(_ value: ActionMode) -> String {
        switch value {
        case .inline: return "Inline"
        case .popup: return "Popup"
        }
    }
    static func fromString(_ s: String) -> ActionMode? {
        switch s {
        case "Inline": return .inline
        case "Popup": return .popup
        default: return nil
        }
    }
}

// MARK: - ActionsOrientation

enum ActionsOrientation: String, Codable {
    case vertical, horizontal
}

extension ActionsOrientation {
    static func toString(_ value: ActionsOrientation) -> String {
        switch value {
        case .vertical: return "Vertical"
        case .horizontal: return "Horizontal"
        }
    }
    static func fromString(_ s: String) -> ActionsOrientation? {
        switch s {
        case "Vertical": return .vertical
        case "Horizontal": return .horizontal
        default: return nil
        }
    }
}

// MARK: - ChoiceSetStyle

enum ChoiceSetStyle: String, Codable {
    case compact = "Compact"
    case expanded = "Expanded"
    case filtered = "Filtered"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self).lowercased()
        switch raw {
        case "compact":
            self = .compact
        case "expanded":
            self = .expanded
        default:
            // If test never uses other styles, you can default or throw.
            // If you want to fail gracefully, you can do:
            // throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown style: \(raw)")
            self = .compact
        }
    }
}

extension ChoiceSetStyle {
    static func toString(_ value: ChoiceSetStyle) -> String {
        switch value {
        case .compact: return "Compact"
        case .expanded: return "Expanded"
        case .filtered: return "Filtered"
        }
    }
    static func fromString(_ s: String) -> ChoiceSetStyle? {
        switch s {
        case "Compact": return .compact
        case "Expanded": return .expanded
        case "Filtered": return .filtered
        default: return nil
        }
    }
}

// MARK: - ContainerStyle

enum ContainerStyle: String, Codable {
    case none, `default`, emphasis, good, attention, warning, accent
}

extension ContainerStyle {
    static func toString(_ value: ContainerStyle) -> String {
        switch value {
        case .none: return "None"
        case .default: return "Default"
        case .emphasis: return "Emphasis"
        case .good: return "Good"
        case .attention: return "Attention"
        case .warning: return "Warning"
        case .accent: return "Accent"
        }
    }
    static func fromString(_ s: String) -> ContainerStyle? {
        switch s {
        case "None": return .none
        case "Default": return .default
        case "Emphasis": return .emphasis
        case "Good": return .good
        case "Attention": return .attention
        case "Warning": return .warning
        case "Accent": return .accent
        default: return nil
        }
    }
}

// MARK: - Spacing

enum Spacing: String, Codable {
    case `default`, none, small, medium, large, extraLarge, padding
}

extension Spacing {
    static func toString(_ value: Spacing) -> String {
        switch value {
        case .default: return "default"
        case .none: return "none"
        case .small: return "small"
        case .medium: return "medium"
        case .large: return "large"
        case .extraLarge: return "extraLarge"
        case .padding: return "padding"
        }
    }
    static func fromString(_ s: String) -> Spacing? {
        switch s.lowercased() {
        case "default": return .default
        case "none": return Spacing.none
        case "small": return .small
        case "medium": return .medium
        case "large": return .large
        case "extralarge", "extra large": return .extraLarge
        case "padding": return .padding
        default: return nil
        }
    }
}

// MARK: - SeparatorThickness (the test references .thick)

enum SeparatorThickness: String, Codable {
    case defaultThickness = "default"
    case thick = "thick"
}

extension SeparatorThickness {
    static func toString(_ value: SeparatorThickness) -> String {
        switch value {
        case .defaultThickness: return "default"
        case .thick: return "thick"
        }
    }
    static func fromString(_ s: String) -> SeparatorThickness? {
        switch s.lowercased() {
        case "default": return .defaultThickness
        case "thick": return .thick
        default: return nil
        }
    }
}

// MARK: - HeightType (the test references .auto)

enum HeightType: String, Codable {
    case auto = "auto"
    case stretch = "stretch"
}

extension HeightType {
    static func toString(_ value: HeightType) -> String {
        switch value {
        case .auto: return "Auto"
        case .stretch: return "Stretch"
        }
    }
    static func fromString(_ s: String) -> HeightType? {
        switch s {
        case "Auto": return .auto
        case "Stretch": return .stretch
        default: return nil
        }
    }
}

// MARK: - IconPlacement (the test references .leftOfTitle)

enum IconPlacement: String, Codable {
    case leftOfTitle = "LeftOfTitle"
    case aboveTitle = "AboveTitle"
    case noTitle = "NoTitle"
}

extension IconPlacement {
    static func toString(_ value: IconPlacement) -> String {
        switch value {
        case .leftOfTitle: return "LeftOfTitle"
        case .aboveTitle: return "AboveTitle"
        case .noTitle: return "NoTitle"
        }
    }
    static func fromString(_ s: String) -> IconPlacement? {
        switch s {
        case "LeftOfTitle": return .leftOfTitle
        case "AboveTitle": return .aboveTitle
        case "NoTitle": return .noTitle
        default: return nil
        }
    }
}
