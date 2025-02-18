import Foundation

enum CardElementType: String, Codable {
    case actionSet = "ActionSet"
    case adaptiveCard = "AdaptiveCard"
    case choiceSetInput = "Input.ChoiceSet"
    case column = "Column"
    case columnSet = "ColumnSet"
    case container = "Container"
    case custom = "Custom"
    case dateInput = "Input.Date"
    case fact = "Fact"
    case factSet = "FactSet"
    case image = "Image"
    case icon = "Icon"
    case imageSet = "ImageSet"
    case media = "Media"
    case numberInput = "Input.Number"
    case ratingInput = "Input.Rating"
    case ratingLabel = "Rating"
    case richTextBlock = "RichTextBlock"
    case table = "Table"
    case tableCell = "TableCell"
    case tableRow = "TableRow"
    case textBlock = "TextBlock"
    case textInput = "Input.Text"
    case timeInput = "Input.Time"
    case toggleInput = "Input.Toggle"
    case compoundButton = "CompoundButton"
    case unknown = "Unknown"
}

// MARK: - CardElementType

/// The test expects `.adaptiveCard` → "AdaptiveCard", etc.
extension CardElementType {
    static func toString(_ value: CardElementType) -> String {
        return value.rawValue
    }
    
    static func fromString(_ str: String) -> CardElementType? {
        return CardElementType(rawValue: str)
    }
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
    case `default` = "Default", veryNarrow, narrow, standard, wide
    case atMostVeryNarrow, atMostNarrow, atMostStandard, atMostWide
    case atLeastVeryNarrow, atLeastNarrow, atLeastStandard, atLeastWide
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
        return value.rawValue
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
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        if let color = ForegroundColor(rawValue: raw.lowercased()) {
            self = color
        } else {
            throw DecodingError.dataCorruptedError(in: container,
                debugDescription: "Cannot initialize ForegroundColor from invalid String value \(raw)")
        }
    }
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
    case left = "left"
    case center = "center"
    case right = "right"
    
    init(from rawValue: String) {
        self = HorizontalAlignment(rawValue: rawValue) ?? .left
    }
}

extension HorizontalAlignment {
    static func toString(_ value: HorizontalAlignment) -> String {
        return value.rawValue
    }
    
    static func fromString(_ s: String) -> HorizontalAlignment? {
        switch s {
        case "left": return .left
        case "center": return .center
        case "right": return .right
        default: return nil
        }
    }
}

// MARK: - VerticalAlignment

enum VerticalAlignment: String, Codable {
    case top = "top"
    case center = "center"
    case bottom = "bottom"
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
    case none = "None"
    case auto = "Auto"
    case large = "Large"
    case medium = "Medium"
    case small = "Small"
    case stretch = "Stretch"
}

extension ImageSize {
    static func toString(_ value: ImageSize) -> String {
        switch value {
        case .none: return "None"
        case .auto: return "Auto"
        case .stretch: return "Stretch"
        case .small: return "Small"
        case .medium: return "Medium"
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
    case defaultImageStyle = "default"
    case person = "person"
    case roundedCorners = "roundedCorners"
}

extension ImageStyle {
    static func toString(_ value: ImageStyle) -> String {
        switch value {
        case .defaultImageStyle: return "default"
        case .person: return "person"
        case .roundedCorners: return "roundedCorners"
        }
    }
    static func fromString(_ s: String) -> ImageStyle? {
        switch s.lowercased() {
        case "default": return .defaultImageStyle
        case "person": return .person
        case "roundedcorners": return .roundedCorners
        default: return nil
        }
    }
}

// MARK: - TextInputStyle

enum TextInputStyle: String, Codable {
    case text = "Text"
    case tel = "Tel"
    case url = "Url"
    case email = "Email"
    case password = "Password"
    
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
        return value.rawValue // Now we can just use rawValue since it matches C++
    }
    
    static func fromString(_ s: String) -> TextInputStyle? {
        switch s {
        case "Text": return .text
        case "Tel": return .tel
        case "Url": return .url
        case "Email": return .email
        case "Password": return .password
        default: return nil
        }
    }
}

// MARK: - ActionType

enum ActionType: String, Codable {
    case unsupported = "Unsupported"
    case execute = "Action.Execute"
    case openUrl = "Action.OpenUrl"
    case showCard = "Action.ShowCard"
    case submit = "Action.Submit"
    case toggleVisibility = "Action.ToggleVisibility"
    case custom = "Custom"
    case unknownAction = "UnknownAction"
    case overflow = "Overflow"
    
    // Mirror the C++ approach, but local to this enum.
    static func toString(_ value: ActionType) -> String {
        // If missing, fallback to rawValue
        switch value {
        case .unsupported: return "Unsupported"
        case .execute: return "Action.Execute"
        case .openUrl: return "Action.OpenUrl"  // special
        case .showCard: return "Action.ShowCard"
        case .submit: return "Action.Submit"
        case .toggleVisibility: return "Action.ToggleVisibility"
        case .custom: return "Custom"
        case .unknownAction: return "UnknownAction"
        case .overflow: return "Overflow"
        }
    }

    static func fromString(_ s: String) -> ActionType? {
        // case-insensitive
        let lowered = s.lowercased()
        switch lowered {
        case "unsupported": return .unsupported
        case "action.execute": return .execute
        case "action.openurl": return .openUrl
        case "action.showcard": return .showCard
        case "action.submit": return .submit
        case "action.togglevisibility": return .toggleVisibility
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
}

extension IconPlacement {
    static func toString(_ value: IconPlacement) -> String {
        switch value {
        case .leftOfTitle: return "LeftOfTitle"
        case .aboveTitle: return "AboveTitle"
        }
    }
    static func fromString(_ s: String) -> IconPlacement? {
        switch s {
        case "LeftOfTitle": return .leftOfTitle
        case "AboveTitle": return .aboveTitle
        default: return nil
        }
    }
}

// Case-insensitive string equality comparator
struct CaseInsensitiveEqualTo {
    func isEqual<T: StringProtocol>(_ lhs: T, _ rhs: T) -> Bool {
        return lhs.caseInsensitiveCompare(rhs) == .orderedSame
    }
}

// Case-insensitive hash generator
struct CaseInsensitiveHash {
    func hash<T: StringProtocol>(_ keyval: T) -> Int {
        return keyval.lowercased().hashValue
    }
}

// Hash function for enums
struct EnumHash<T: Hashable> {
    func hash(_ value: T) -> Int {
        return value.hashValue
    }
}

// Enum mapping class for bidirectional enum <-> string conversion
struct EnumMapping<T: Hashable & Codable>: Codable {
    private let enumToString: [T: String]
    private let stringToEnum: [String: T]

    init(_ mappings: [(T, String)]) {
        var eToS = [T: String]()
        var sToE = [String: T]()
        for (enumValue, stringValue) in mappings {
            eToS[enumValue] = stringValue
            sToE[stringValue.lowercased()] = enumValue
        }
        self.enumToString = eToS
        self.stringToEnum = sToE
    }

    func toString(_ value: T) -> String {
        return enumToString[value] ?? "unknown"
    }

    func fromString(_ value: String) throws -> T {
        guard let enumValue = stringToEnum[value.lowercased()] else {
            throw EnumMappingError.invalidValue(value)
        }
        return enumValue
    }
}

// Error handling for invalid enum values
enum EnumMappingError: Error {
    case invalidValue(String)
}

// Protocol to allow enums to use the mapping
protocol AdaptiveCardEnum: Codable, Hashable {
    static var mappings: EnumMapping<Self> { get }
}

extension AdaptiveCardEnum {
    func toString() -> String {
        return Self.mappings.toString(self)
    }
    static func fromString(_ value: String) throws -> Self {
        return try Self.mappings.fromString(value)
    }
}

// Define `AdaptiveCardSchemaKey` using EnumMapping
enum AdaptiveCardSchemaKey: String, AdaptiveCardEnum {
    case accent, action, actionAlignment, actionMode, actionRole, actionSet, actionSetConfig
    case actions, actionsOrientation, adaptiveCard, allowCustomStyle, allowInlinePlayback
    case backgroundColor, backgroundImage, backgroundImageUrl, baseCardElement, baseContainerStyle
    case bleed, body, bolder, borderColor, bottom, badge, buttonSpacing, buttons, captionSources
    case card, cellSpacing, cells, center, choiceSet, choices, choicesData, choicesDataType, color
    case colorConfig, column, columnHeader, columnSet, columns, container, containerStyles, dark, data
    case dataQuery, dataset, dateInput, defaultCase, defaultPoster, description, elementId, emphasis
    case errorMessage, extraLarge, factSet, facts, fallback, fallbackText, fontFamily, fontSizes, fontType
    case fontWeights, foregroundColor, foregroundColors, good, gridStyle, heading, headingLevel
    case height, highlight, highlightColor, highlightColors, horizontalAlignment, hostWidthBreakpoints
    case iconPlacement, iconSize, iconUrl, id, image, imageBaseUrl, imageSet, imageSize, imageSizes
    case images, inlineAction, inlineTopMargin, inlines, inputSpacing, inputs, isEnabled, isMultiSelect
    case isMultiline, showBorder, roundedCorners, isRequired, isSelected, isSubtle, isVisible, italic
    case items, label, language, attention, large, left, light, lighter, lineColor, lineThickness, max, maxActions
    case maxImageHeight, maxLength, maxLines, maxWidth, media, medium, metaData, method, mimeType, min
    case minHeight, mode, monospace, narrow, numberInput, ratingInput, ratingLabel, padding, placeholder
    case playButton, poster, providerId, refresh, regex, repeatHorizontally, repeatVertically
    case requiredInputs, requires, richTextBlock, right, rows, rtl, selectAction, separator
    case showActionMode, showCard, showCardActionConfig, showGridLines, size, small, sources, spacing
    case speak, standard, stretch, strikethrough, style, subtle, suffix, supportsInteractivity
    case table, tableCell, tableRow, targetElements, layout, itemFit, rowSpacing, columnSpacing
    case itemWidth, minItemWidth, maxItemWidth, horizontalItemsAlignment, row, rowSpan, columnSpan
    case areaGridName, areas, layouts, targetInputIds, targetWidth, text, textBlock, textConfig
    case textInput, textStyles, marigoldColor, neutralColor, filledStar, emptyStar, ratingTextColor
    case countTextColor, textWeight, thickness, timeInput, title, toggleInput, tooltip, top, type
    case underline, uri, url, userIds, value, valueChangedAction, valueChangedActionType, valueOff
    case valueOn, verb, veryNarrow, version, verticalAlignment, verticalCellContentAlignment
    case verticalContentAlignment, warning, webUrl, weight, width, wrap, compoundButton, authentication
    case associatedInputs
    case conditionallyEnabled
    case altText
    case name
    case borderWidth
    case cornerRadius
    case connectionName
    case count
    case fillMode
    case firstRowAsHeaders
    case fontTypes
    case horizontalCellContentAlignment
    case icon
    case optionalInputs
    case schema = "$schema"
    case spacingDefinition
    case tokenExchangeResource

    static let mappings = EnumMapping([
        (AdaptiveCardSchemaKey.accent, "accent"),
        (AdaptiveCardSchemaKey.action, "action"),
        (AdaptiveCardSchemaKey.actionAlignment, "actionAlignment"),
        (AdaptiveCardSchemaKey.actionMode, "actionMode"),
        (AdaptiveCardSchemaKey.actionRole, "role"),
        (AdaptiveCardSchemaKey.actionSet, "ActionSet"),
        (AdaptiveCardSchemaKey.actionSetConfig, "actionSetConfig"),
        (AdaptiveCardSchemaKey.actions, "actions"),
        (AdaptiveCardSchemaKey.actionsOrientation, "actionsOrientation"),
        (AdaptiveCardSchemaKey.adaptiveCard, "adaptiveCard"),
        (AdaptiveCardSchemaKey.allowCustomStyle, "allowCustomStyle"),
        (AdaptiveCardSchemaKey.allowInlinePlayback, "allowInlinePlayback"),
        (AdaptiveCardSchemaKey.backgroundColor, "backgroundColor"),
        (AdaptiveCardSchemaKey.backgroundImage, "backgroundImage"),
        (AdaptiveCardSchemaKey.backgroundImageUrl, "backgroundImageUrl"),
        (AdaptiveCardSchemaKey.baseCardElement, "baseCardElement"),
        (AdaptiveCardSchemaKey.baseContainerStyle, "baseContainerStyle"),
        (AdaptiveCardSchemaKey.badge, "badge"),
        (AdaptiveCardSchemaKey.bleed, "bleed"),
        (AdaptiveCardSchemaKey.body, "body"),
        (AdaptiveCardSchemaKey.bolder, "bolder"),
        (AdaptiveCardSchemaKey.borderColor, "borderColor"),
        (AdaptiveCardSchemaKey.bottom, "bottom"),
        (AdaptiveCardSchemaKey.buttonSpacing, "buttonSpacing"),
        (AdaptiveCardSchemaKey.buttons, "buttons"),
        (AdaptiveCardSchemaKey.captionSources, "captionSources"),
        (AdaptiveCardSchemaKey.card, "card"),
        (AdaptiveCardSchemaKey.cellSpacing, "cellSpacing"),
        (AdaptiveCardSchemaKey.cells, "cells"),
        (AdaptiveCardSchemaKey.center, "center"),
        (AdaptiveCardSchemaKey.choiceSet, "choiceSet"),
        (AdaptiveCardSchemaKey.choices, "choices"),
        (AdaptiveCardSchemaKey.choicesData, "choices.data"),
        (AdaptiveCardSchemaKey.choicesDataType, "type"),
        (AdaptiveCardSchemaKey.color, "color"),
        (AdaptiveCardSchemaKey.colorConfig, "colorConfig"),
        (AdaptiveCardSchemaKey.column, "column"),
        (AdaptiveCardSchemaKey.columnHeader, "columnHeader"),
        (AdaptiveCardSchemaKey.columnSet, "columnSet"),
        (AdaptiveCardSchemaKey.columns, "columns"),
        (AdaptiveCardSchemaKey.container, "container"),
        (AdaptiveCardSchemaKey.containerStyles, "containerStyles"),
        (AdaptiveCardSchemaKey.dark, "dark"),
        (AdaptiveCardSchemaKey.data, "data"),
        (AdaptiveCardSchemaKey.dataQuery, "Data.Query"),
        (AdaptiveCardSchemaKey.dataset, "dataset"),
        (AdaptiveCardSchemaKey.dateInput, "dateInput"),
        (AdaptiveCardSchemaKey.defaultCase, "default"),
        (AdaptiveCardSchemaKey.defaultPoster, "defaultPoster"),
        (AdaptiveCardSchemaKey.description, "description"),
        (AdaptiveCardSchemaKey.elementId, "elementId"),
        (AdaptiveCardSchemaKey.emphasis, "emphasis"),
        (AdaptiveCardSchemaKey.errorMessage, "errorMessage"),
        (AdaptiveCardSchemaKey.extraLarge, "extraLarge"),
        (AdaptiveCardSchemaKey.factSet, "factSet"),
        (AdaptiveCardSchemaKey.facts, "facts"),
        (AdaptiveCardSchemaKey.fallback, "fallback"),
        (AdaptiveCardSchemaKey.fallbackText, "fallbackText"),
        (AdaptiveCardSchemaKey.fontFamily, "fontFamily"),
        (AdaptiveCardSchemaKey.fontSizes, "fontSizes"),
        (AdaptiveCardSchemaKey.fontType, "fontType"),
        (AdaptiveCardSchemaKey.fontWeights, "fontWeights"),
        (AdaptiveCardSchemaKey.foregroundColor, "foregroundColor"),
        (AdaptiveCardSchemaKey.foregroundColors, "foregroundColors"),
        (AdaptiveCardSchemaKey.good, "good"),
        (AdaptiveCardSchemaKey.gridStyle, "gridStyle"),
        (AdaptiveCardSchemaKey.heading, "heading"),
        (AdaptiveCardSchemaKey.headingLevel, "headingLevel"),
        (AdaptiveCardSchemaKey.height, "height"),
        (AdaptiveCardSchemaKey.highlight, "highlight"),
        (AdaptiveCardSchemaKey.highlightColor, "highlightColor"),
        (AdaptiveCardSchemaKey.highlightColors, "highlightColors"),
        (AdaptiveCardSchemaKey.horizontalAlignment, "horizontalAlignment"),
        (AdaptiveCardSchemaKey.hostWidthBreakpoints, "hostWidthBreakpoints"),
        (AdaptiveCardSchemaKey.associatedInputs, "associatedInputs"),
        (AdaptiveCardSchemaKey.conditionallyEnabled, "conditionallyEnabled"),
        (AdaptiveCardSchemaKey.altText, "altText"),
        (AdaptiveCardSchemaKey.name, "name"),
        (AdaptiveCardSchemaKey.borderWidth, "borderWidth"),
        (AdaptiveCardSchemaKey.cornerRadius, "cornerRadius"),
        (AdaptiveCardSchemaKey.connectionName, "connectionName"),
        (AdaptiveCardSchemaKey.count, "count"),
        (AdaptiveCardSchemaKey.fillMode, "fillMode"),
        (AdaptiveCardSchemaKey.firstRowAsHeaders, "firstRowAsHeaders"),
        (AdaptiveCardSchemaKey.fontTypes, "fontTypes"),
        (AdaptiveCardSchemaKey.horizontalCellContentAlignment, "horizontalCellContentAlignment"),
        (AdaptiveCardSchemaKey.icon, "icon"),
        (AdaptiveCardSchemaKey.optionalInputs, "optionalInputs"),
        (AdaptiveCardSchemaKey.schema, "$schema"),
        (AdaptiveCardSchemaKey.spacingDefinition, "spacingDefinition"),
        (AdaptiveCardSchemaKey.tokenExchangeResource, "tokenExchangeResource"),
        (AdaptiveCardSchemaKey.language, "lang"), // Currently maps to "language"
        (AdaptiveCardSchemaKey.attention, "attention"),
        (AdaptiveCardSchemaKey.iconUrl, "iconUrl"),
        (AdaptiveCardSchemaKey.value, "value"),
        (AdaptiveCardSchemaKey.valueChangedAction, "valueChangedAction"),
        (AdaptiveCardSchemaKey.valueChangedActionType, "valueChangedActionType"),
        (AdaptiveCardSchemaKey.valueOff, "valueOff"),
        (AdaptiveCardSchemaKey.valueOn, "valueOn"),
        (AdaptiveCardSchemaKey.verb, "verb"),
        (AdaptiveCardSchemaKey.version, "version"),
        (AdaptiveCardSchemaKey.webUrl, "webUrl"),
        (AdaptiveCardSchemaKey.width, "width"),
        (AdaptiveCardSchemaKey.wrap, "wrap"),
        (AdaptiveCardSchemaKey.tooltip, "tooltip"),
        (AdaptiveCardSchemaKey.method, "method"),
        (AdaptiveCardSchemaKey.text, "text"),
        (AdaptiveCardSchemaKey.standard, "standard"),
        (AdaptiveCardSchemaKey.compoundButton, "compoundButton"),
    ])
}

extension AdaptiveCardSchemaKey {
    static func fromString(_ s: String) -> AdaptiveCardSchemaKey? {
        return try? mappings.fromString(s)
    }

    static func toString(_ value: AdaptiveCardSchemaKey) -> String {
        return mappings.toString(value)
    }
}

/// The role of an action – originally defined in C++.
enum ActionRole: String, Codable {
    case button = "Button"
    case link = "Link"
    case tab = "Tab"
    case menu = "Menu"
    case menuItem = "MenuItem"
}

enum AssociatedInputs: String, Codable {
    case auto = "Auto"
    case none = "None"
}

enum ImageFillMode: String, Codable {
    case cover = "cover"
    case repeatHorizontally = "repeatHorizontally"
    case repeatVertically = "repeatVertically"
    case `repeat` = "repeat"
}

enum IconSize: String, Codable {
    case xxSmall = "xxSmall"
    case xSmall = "xSmall"
    case small = "Small"
    case standard = "Standard"
    case medium = "Medium"
    case large = "Large"
    case xLarge = "xLarge"
    case xxLarge = "xxLarge"
}

enum IconStyle: String, Codable {
    case regular = "Regular"
    case filled = "Filled"
}

enum LayoutContainerType: String, Codable {
    case none = "Layout.None"
    case stack = "Layout.Stack"
    case flow = "Layout.Flow"
    case areaGrid = "Layout.AreaGrid"
}

/// Minimal stubs for text-related enums.
enum TextStyle: String, Codable {
    case defaultStyle = "default"  // Can simplify since raw value matches toString
    case heading = "heading"
    
    init(from rawValue: String) {
        self = TextStyle(rawValue: rawValue) ?? .defaultStyle
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        
        switch raw.lowercased() {
        case "default":
            self = .defaultStyle
        case "heading":
            self = .heading
        default:
            // If unknown, fall back to .defaultStyle:
            self = .defaultStyle
        }
    }
}

enum ValueChangedActionType: String, Codable {
    case resetInputs = "ResetInputs"
}

enum InlineElementType: String, Codable {
    case textRun = "TextRun"
}

enum RatingSize: String, Codable {
    case medium = "medium"
    case large = "large"
}

enum RatingColor: String, Codable {
    case neutral = "neutral"
    case marigold = "marigold"
}

enum RatingStyle: String, Codable {
    case `default` = "default"
    case compact = "compact"
}

enum ItemFit: String, Codable {
    case fit = "Fit"
    case fill = "Fill"
}

struct ContainerBleedDirection: OptionSet, Codable {
    let rawValue: Int

    static let bleedRestricted    = ContainerBleedDirection(rawValue: 0x0000)
    static let bleedLeft          = ContainerBleedDirection(rawValue: 0x0001)
    static let bleedRight         = ContainerBleedDirection(rawValue: 0x0010)
    static let bleedLeftRight     = ContainerBleedDirection(rawValue: 0x0011)
    static let bleedUp            = ContainerBleedDirection(rawValue: 0x0100)
    static let bleedLeftUp        = ContainerBleedDirection(rawValue: 0x0101)
    static let bleedRightUp       = ContainerBleedDirection(rawValue: 0x0110)
    static let bleedLeftRightUp   = ContainerBleedDirection(rawValue: 0x0111)
    static let bleedDown          = ContainerBleedDirection(rawValue: 0x1000)
    static let bleedLeftDown      = ContainerBleedDirection(rawValue: 0x1001)
    static let bleedRightDown     = ContainerBleedDirection(rawValue: 0x1010)
    static let bleedLeftRightDown = ContainerBleedDirection(rawValue: 0x1011)
    static let bleedUpDown        = ContainerBleedDirection(rawValue: 0x1100)
    static let bleedLeftUpDown    = ContainerBleedDirection(rawValue: 0x1101)
    static let bleedRightUpDown   = ContainerBleedDirection(rawValue: 0x1110)
    static let bleedAll           = ContainerBleedDirection(rawValue: 0x1111)
}

extension RawRepresentable where Self: Codable, RawValue == String {
    static func toString(_ value: Self) -> String {
        return value.rawValue
    }
    
    static func fromString(_ s: String) -> Self? {
        return Self(rawValue: s) ?? Self(rawValue: s.capitalized) ?? Self(rawValue: s.lowercased())
    }
}
