import Foundation

// MARK: - JSON Helper

enum JSONError: Error {
    case missingKey(String)
    case invalidType(key: String, expected: String, actual: String)
}

extension Dictionary where Key == String {
    /// Returns the value for a key or the supplied default.
    func value<T>(forKey key: String, default defaultValue: T) -> T {
        return self[key] as? T ?? defaultValue
    }
    
    /// Returns a nested dictionary for a key (or an empty dictionary if missing)
    func nestedDictionary(forKey key: String) -> [String: Any] {
        return self[key] as? [String: Any] ?? [:]
    }
}

// MARK: - Enums

extension TextSize {
    var defaultFontSize: UInt {
        switch self {
        case .small: return 10
        case .defaultSize: return 12
        case .medium: return 14
        case .large: return 17
        case .extraLarge: return 20
        }
    }
}

extension TextWeight {
    var defaultFontWeight: UInt {
        switch self {
        case .lighter: return 200
        case .defaultWeight: return 400
        case .bolder: return 800
        }
    }
}

enum ActionMode: String, Codable {
    case inline
}

enum IconPlacement: String, Codable {
    case aboveTitle, leftOfTitle
}

// MARK: - Configuration Structures

// 1. FontSizesConfig
struct FontSizesConfig: Codable {
    var small: UInt?
    var `default`: UInt?
    var medium: UInt?
    var large: UInt?
    var extraLarge: UInt?
    
    static func deserialize(from json: [String: Any], defaultValue: FontSizesConfig) -> FontSizesConfig {
        return FontSizesConfig(
            small: json["small"] as? UInt ?? defaultValue.small,
            default: json["default"] as? UInt ?? defaultValue.default,
            medium: json["medium"] as? UInt ?? defaultValue.medium,
            large: json["large"] as? UInt ?? defaultValue.large,
            extraLarge: json["extraLarge"] as? UInt ?? defaultValue.extraLarge
        )
    }
    
    func getFontSize(for size: TextSize) -> UInt {
        switch size {
        case .small:      return small ?? size.defaultFontSize
        case .medium:     return medium ?? size.defaultFontSize
        case .large:      return large ?? size.defaultFontSize
        case .extraLarge: return extraLarge ?? size.defaultFontSize
        case .defaultSize:    return self.default ?? size.defaultFontSize
        }
    }
    
    static func getDefaultFontSize(for size: TextSize) -> UInt {
        return size.defaultFontSize
    }
}

// 2. FontWeightsConfig
struct FontWeightsConfig: Codable {
    var lighter: UInt?
    var `default`: UInt?
    var bolder: UInt?
    
    static func deserialize(from json: [String: Any], defaultValue: FontWeightsConfig) -> FontWeightsConfig {
        return FontWeightsConfig(
            lighter: json["lighter"] as? UInt ?? defaultValue.lighter,
            default: json["default"] as? UInt ?? defaultValue.default,
            bolder: json["bolder"] as? UInt ?? defaultValue.bolder
        )
    }
    
    func getFontWeight(for weight: TextWeight) -> UInt {
        switch weight {
        case .lighter:  return lighter ?? weight.defaultFontWeight
        case .bolder:   return bolder ?? weight.defaultFontWeight
        case .defaultWeight:  return self.default ?? weight.defaultFontWeight
        }
    }
    
    static func getDefaultFontWeight(for weight: TextWeight) -> UInt {
        return weight.defaultFontWeight
    }
}

// 3. FontTypeDefinition
struct FontTypeDefinition: Codable {
    var fontFamily: String
    var fontSizes: FontSizesConfig
    var fontWeights: FontWeightsConfig
    
    static func deserialize(from json: [String: Any], defaultValue: FontTypeDefinition) -> FontTypeDefinition {
        let fontFamilyValue = (json["fontFamily"] as? String) ?? ""
        let finalFontFamily = fontFamilyValue.isEmpty ? defaultValue.fontFamily : fontFamilyValue
        let sizes = FontSizesConfig.deserialize(from: json.nestedDictionary(forKey: "fontSizes"), defaultValue: defaultValue.fontSizes)
        let weights = FontWeightsConfig.deserialize(from: json.nestedDictionary(forKey: "fontWeights"), defaultValue: defaultValue.fontWeights)
        return FontTypeDefinition(fontFamily: finalFontFamily, fontSizes: sizes, fontWeights: weights)
    }
}

// 4. FontTypesDefinition
struct FontTypesDefinition: Codable {
    var defaultFontType: FontTypeDefinition
    var monospaceFontType: FontTypeDefinition
    
    static func deserialize(from json: [String: Any], defaultValue: FontTypesDefinition) -> FontTypesDefinition {
        let defaultFont = FontTypeDefinition.deserialize(from: json.nestedDictionary(forKey: "default"), defaultValue: defaultValue.defaultFontType)
        let monospaceFont = FontTypeDefinition.deserialize(from: json.nestedDictionary(forKey: "monospace"), defaultValue: defaultValue.monospaceFontType)
        return FontTypesDefinition(defaultFontType: defaultFont, monospaceFontType: monospaceFont)
    }
}

// 5. HighlightColorConfig
struct HighlightColorConfig: Codable {
    var defaultColor: String
    var subtleColor: String
    
    static func deserialize(from json: [String: Any], defaultValue: HighlightColorConfig) -> HighlightColorConfig {
        let defColor = (json["default"] as? String) ?? ""
        let finalDefault = defColor.isEmpty ? defaultValue.defaultColor : defColor
        let subColor = (json["subtle"] as? String) ?? ""
        let finalSubtle = subColor.isEmpty ? defaultValue.subtleColor : subColor
        return HighlightColorConfig(defaultColor: finalDefault, subtleColor: finalSubtle)
    }
}

// 6. ColorConfig
struct ColorConfig: Codable {
    var defaultColor: String
    var subtleColor: String
    var highlightColors: HighlightColorConfig
    
    static func deserialize(from json: [String: Any], defaultValue: ColorConfig) -> ColorConfig {
        let defColor = (json["default"] as? String) ?? ""
        let finalDefault = defColor.isEmpty ? defaultValue.defaultColor : defColor
        let subColor = (json["subtle"] as? String) ?? ""
        let finalSubtle = subColor.isEmpty ? defaultValue.subtleColor : subColor
        let highlight = HighlightColorConfig.deserialize(from: json.nestedDictionary(forKey: "highlightColors"), defaultValue: defaultValue.highlightColors)
        return ColorConfig(defaultColor: finalDefault, subtleColor: finalSubtle, highlightColors: highlight)
    }
}

// 7. ColorsConfig
struct ColorsConfig: Codable {
    var `default`: ColorConfig
    var accent: ColorConfig
    var dark: ColorConfig
    var light: ColorConfig
    var good: ColorConfig
    var warning: ColorConfig
    var attention: ColorConfig
    
    static func deserialize(from json: [String: Any], defaultValue: ColorsConfig) -> ColorsConfig {
        return ColorsConfig(
            default: ColorConfig.deserialize(from: json.nestedDictionary(forKey: "default"), defaultValue: defaultValue.default),
            accent: ColorConfig.deserialize(from: json.nestedDictionary(forKey: "accent"), defaultValue: defaultValue.accent),
            dark: ColorConfig.deserialize(from: json.nestedDictionary(forKey: "dark"), defaultValue: defaultValue.dark),
            light: ColorConfig.deserialize(from: json.nestedDictionary(forKey: "light"), defaultValue: defaultValue.light),
            good: ColorConfig.deserialize(from: json.nestedDictionary(forKey: "good"), defaultValue: defaultValue.good),
            warning: ColorConfig.deserialize(from: json.nestedDictionary(forKey: "warning"), defaultValue: defaultValue.warning),
            attention: ColorConfig.deserialize(from: json.nestedDictionary(forKey: "attention"), defaultValue: defaultValue.attention)
        )
    }
}

// 8. TextStyleConfig
struct TextStyleConfig: Codable {
    var weight: TextWeight
    var size: TextSize
    var isSubtle: Bool
    var color: ForegroundColor
    var fontType: FontType
    
    static func deserialize(from json: [String: Any], defaultValue: TextStyleConfig) -> TextStyleConfig {
        let weightStr = json["weight"] as? String ?? defaultValue.weight.rawValue
        let weight = TextWeight(rawValue: weightStr) ?? defaultValue.weight
        let sizeStr = json["size"] as? String ?? defaultValue.size.rawValue
        let size = TextSize(rawValue: sizeStr) ?? defaultValue.size
        let isSubtle = json["isSubtle"] as? Bool ?? defaultValue.isSubtle
        let colorStr = json["color"] as? String ?? defaultValue.color.rawValue
        let color = ForegroundColor(rawValue: colorStr) ?? defaultValue.color
        let fontTypeStr = json["fontType"] as? String ?? defaultValue.fontType.rawValue
        let fontType = FontType(rawValue: fontTypeStr) ?? defaultValue.fontType
        return TextStyleConfig(weight: weight, size: size, isSubtle: isSubtle, color: color, fontType: fontType)
    }
}

// 9. FactSetTextConfig
struct FactSetTextConfig: Codable {
    var weight: TextWeight
    var size: TextSize
    var isSubtle: Bool
    var color: ForegroundColor
    var fontType: FontType
    var wrap: Bool
    var maxWidth: UInt
    
    static func deserialize(from json: [String: Any], defaultValue: FactSetTextConfig) -> FactSetTextConfig {
        let base = TextStyleConfig.deserialize(from: json, defaultValue: TextStyleConfig(weight: defaultValue.weight, size: defaultValue.size, isSubtle: defaultValue.isSubtle, color: defaultValue.color, fontType: defaultValue.fontType))
        let wrap = json["wrap"] as? Bool ?? defaultValue.wrap
        let maxWidth = json["maxWidth"] as? UInt ?? defaultValue.maxWidth
        return FactSetTextConfig(weight: base.weight, size: base.size, isSubtle: base.isSubtle, color: base.color, fontType: base.fontType, wrap: wrap, maxWidth: maxWidth)
    }
}

// 10. RatingStarCofig
struct RatingStarCofig: Codable {
    var marigoldColor: String
    var neutralColor: String
    
    static func deserialize(from json: [String: Any], defaultValue: RatingStarCofig) -> RatingStarCofig {
        let marigold = json["marigoldColor"] as? String ?? defaultValue.marigoldColor
        let neutral = json["neutralColor"] as? String ?? defaultValue.neutralColor
        return RatingStarCofig(marigoldColor: marigold, neutralColor: neutral)
    }
}

// 11. RatingElementConfig
struct RatingElementConfig: Codable {
    var filledStar: RatingStarCofig
    var emptyStar: RatingStarCofig
    var ratingTextColor: String
    var countTextColor: String
    
    static func deserialize(from json: [String: Any], defaultValue: RatingElementConfig) -> RatingElementConfig {
        let filled = RatingStarCofig.deserialize(from: json.nestedDictionary(forKey: "filledStar"), defaultValue: defaultValue.filledStar)
        let empty = RatingStarCofig.deserialize(from: json.nestedDictionary(forKey: "emptyStar"), defaultValue: defaultValue.emptyStar)
        let ratingTextColor = json["ratingTextColor"] as? String ?? defaultValue.ratingTextColor
        let countTextColor = json["countTextColor"] as? String ?? defaultValue.countTextColor
        return RatingElementConfig(filledStar: filled, emptyStar: empty, ratingTextColor: ratingTextColor, countTextColor: countTextColor)
    }
}

// 12. TextStylesConfig
struct TextStylesConfig: Codable {
    var heading: TextStyleConfig
    var columnHeader: TextStyleConfig
    
    static func deserialize(from json: [String: Any], defaultValue: TextStylesConfig) -> TextStylesConfig {
        let heading = TextStyleConfig.deserialize(from: json.nestedDictionary(forKey: "heading"), defaultValue: defaultValue.heading)
        let columnHeader = TextStyleConfig.deserialize(from: json.nestedDictionary(forKey: "columnHeader"), defaultValue: defaultValue.columnHeader)
        return TextStylesConfig(heading: heading, columnHeader: columnHeader)
    }
}

// 13. SpacingConfig
struct SpacingConfig: Codable {
    var smallSpacing: UInt
    var defaultSpacing: UInt
    var mediumSpacing: UInt
    var largeSpacing: UInt
    var extraLargeSpacing: UInt
    var paddingSpacing: UInt
    
    static func deserialize(from json: [String: Any], defaultValue: SpacingConfig) -> SpacingConfig {
        return SpacingConfig(
            smallSpacing: json["smallSpacing"] as? UInt ?? defaultValue.smallSpacing,
            defaultSpacing: json["defaultSpacing"] as? UInt ?? defaultValue.defaultSpacing,
            mediumSpacing: json["mediumSpacing"] as? UInt ?? defaultValue.mediumSpacing,
            largeSpacing: json["largeSpacing"] as? UInt ?? defaultValue.largeSpacing,
            extraLargeSpacing: json["extraLargeSpacing"] as? UInt ?? defaultValue.extraLargeSpacing,
            paddingSpacing: json["paddingSpacing"] as? UInt ?? defaultValue.paddingSpacing
        )
    }
}

// 14. SeparatorConfig
struct SeparatorConfig: Codable {
    var lineThickness: UInt
    var lineColor: String
    
    static func deserialize(from json: [String: Any], defaultValue: SeparatorConfig) -> SeparatorConfig {
        let thickness = json["lineThickness"] as? UInt ?? defaultValue.lineThickness
        let color = (json["lineColor"] as? String).flatMap { !$0.isEmpty ? $0 : defaultValue.lineColor } ?? defaultValue.lineColor
        return SeparatorConfig(lineThickness: thickness, lineColor: color)
    }
}

// 15. ImageSizesConfig
struct ImageSizesConfig: Codable {
    var smallSize: UInt
    var mediumSize: UInt
    var largeSize: UInt
    
    static func deserialize(from json: [String: Any], defaultValue: ImageSizesConfig) -> ImageSizesConfig {
        return ImageSizesConfig(
            smallSize: json["smallSize"] as? UInt ?? defaultValue.smallSize,
            mediumSize: json["mediumSize"] as? UInt ?? defaultValue.mediumSize,
            largeSize: json["largeSize"] as? UInt ?? defaultValue.largeSize
        )
    }
}

// 16. ImageSetConfig
struct ImageSetConfig: Codable {
    var imageSize: ImageSize
    var maxImageHeight: UInt
    
    static func deserialize(from json: [String: Any], defaultValue: ImageSetConfig) -> ImageSetConfig {
        let imageSizeStr = json["imageSize"] as? String ?? defaultValue.imageSize.rawValue
        let imageSize = ImageSize(rawValue: imageSizeStr) ?? defaultValue.imageSize
        let maxHeight = json["maxImageHeight"] as? UInt ?? defaultValue.maxImageHeight
        return ImageSetConfig(imageSize: imageSize, maxImageHeight: maxHeight)
    }
}

// 17. ImageConfig
struct ImageConfig: Codable {
    var imageSize: ImageSize
    
    static func deserialize(from json: [String: Any], defaultValue: ImageConfig) -> ImageConfig {
        let imageSizeStr = json["imageSize"] as? String ?? defaultValue.imageSize.rawValue
        let imageSize = ImageSize(rawValue: imageSizeStr) ?? defaultValue.imageSize
        return ImageConfig(imageSize: imageSize)
    }
}

// 18. AdaptiveCardConfig
struct AdaptiveCardConfig: Codable {
    var allowCustomStyle: Bool
    
    static func deserialize(from json: [String: Any], defaultValue: AdaptiveCardConfig) -> AdaptiveCardConfig {
        let allowStyle = json["allowCustomStyle"] as? Bool ?? defaultValue.allowCustomStyle
        return AdaptiveCardConfig(allowCustomStyle: allowStyle)
    }
}

// 19. FactSetConfig
struct FactSetConfig: Codable {
    var title: FactSetTextConfig
    var value: FactSetTextConfig
    var spacing: UInt
    
    static func deserialize(from json: [String: Any], defaultValue: FactSetConfig) -> FactSetConfig {
        let spacing = json["spacing"] as? UInt ?? defaultValue.spacing
        let title = FactSetTextConfig.deserialize(from: json.nestedDictionary(forKey: "title"), defaultValue: defaultValue.title)
        var valueConfig = FactSetTextConfig.deserialize(from: json.nestedDictionary(forKey: "value"), defaultValue: defaultValue.value)
        // As in C++ the value’s maxWidth is reset to default.
        valueConfig.maxWidth = defaultValue.value.maxWidth
        return FactSetConfig(title: title, value: valueConfig, spacing: spacing)
    }
}

// 20. ContainerStyleDefinition
struct ContainerStyleDefinition: Codable {
    var backgroundColor: String
    var borderColor: String
    var foregroundColors: ColorsConfig
    
    static func deserialize(from json: [String: Any], defaultValue: ContainerStyleDefinition) -> ContainerStyleDefinition {
        let bg = (json["backgroundColor"] as? String).flatMap { !$0.isEmpty ? $0 : defaultValue.backgroundColor } ?? defaultValue.backgroundColor
        let border = (json["borderColor"] as? String).flatMap { !$0.isEmpty ? $0 : defaultValue.borderColor } ?? defaultValue.borderColor
        let foreground = ColorsConfig.deserialize(from: json.nestedDictionary(forKey: "foregroundColors"), defaultValue: defaultValue.foregroundColors)
        return ContainerStyleDefinition(backgroundColor: bg, borderColor: border, foregroundColors: foreground)
    }
}

// 21. ContainerStylesDefinition
struct ContainerStylesDefinition: Codable {
    var defaultPalette: ContainerStyleDefinition
    var emphasisPalette: ContainerStyleDefinition
    var goodPalette: ContainerStyleDefinition
    var attentionPalette: ContainerStyleDefinition
    var warningPalette: ContainerStyleDefinition
    var accentPalette: ContainerStyleDefinition
    
    static func deserialize(from json: [String: Any], defaultValue: ContainerStylesDefinition) -> ContainerStylesDefinition {
        return ContainerStylesDefinition(
            defaultPalette: ContainerStyleDefinition.deserialize(from: json.nestedDictionary(forKey: "default"), defaultValue: defaultValue.defaultPalette),
            emphasisPalette: ContainerStyleDefinition.deserialize(from: json.nestedDictionary(forKey: "emphasis"), defaultValue: defaultValue.emphasisPalette),
            goodPalette: ContainerStyleDefinition.deserialize(from: json.nestedDictionary(forKey: "good"), defaultValue: defaultValue.goodPalette),
            attentionPalette: ContainerStyleDefinition.deserialize(from: json.nestedDictionary(forKey: "attention"), defaultValue: defaultValue.attentionPalette),
            warningPalette: ContainerStyleDefinition.deserialize(from: json.nestedDictionary(forKey: "warning"), defaultValue: defaultValue.warningPalette),
            accentPalette: ContainerStyleDefinition.deserialize(from: json.nestedDictionary(forKey: "accent"), defaultValue: defaultValue.accentPalette)
        )
    }
}

// 22. ShowCardActionConfig
struct ShowCardActionConfig: Codable {
    var actionMode: ActionMode
    var style: ContainerStyle
    var inlineTopMargin: UInt
    
    static func deserialize(from json: [String: Any], defaultValue: ShowCardActionConfig) -> ShowCardActionConfig {
        let modeStr = json["actionMode"] as? String ?? defaultValue.actionMode.rawValue
        let mode = ActionMode(rawValue: modeStr) ?? defaultValue.actionMode
        let styleStr = json["style"] as? String ?? defaultValue.style.rawValue
        let style = ContainerStyle(rawValue: styleStr) ?? defaultValue.style
        let margin = json["inlineTopMargin"] as? UInt ?? defaultValue.inlineTopMargin
        return ShowCardActionConfig(actionMode: mode, style: style, inlineTopMargin: margin)
    }
}

// 23. ActionsConfig
struct ActionsConfig: Codable {
    var showCard: ShowCardActionConfig
    var actionsOrientation: ActionsOrientation
    var actionAlignment: ActionAlignment
    var buttonSpacing: UInt
    var maxActions: UInt
    var spacing: Spacing
    var iconPlacement: IconPlacement
    var iconSize: UInt
    
    static func deserialize(from json: [String: Any], defaultValue: ActionsConfig) -> ActionsConfig {
        let orientationStr = json["actionsOrientation"] as? String ?? defaultValue.actionsOrientation.rawValue
        let orientation = ActionsOrientation(rawValue: orientationStr) ?? defaultValue.actionsOrientation
        let alignmentStr = json["actionAlignment"] as? String ?? defaultValue.actionAlignment.rawValue
        let alignment = ActionAlignment(rawValue: alignmentStr) ?? defaultValue.actionAlignment
        let buttonSpacing = json["buttonSpacing"] as? UInt ?? defaultValue.buttonSpacing
        let maxActions = json["maxActions"] as? UInt ?? defaultValue.maxActions
        let spacingStr = json["spacing"] as? String ?? defaultValue.spacing.rawValue
        let spacing = Spacing(rawValue: spacingStr) ?? defaultValue.spacing
        let iconPlacementStr = json["iconPlacement"] as? String ?? defaultValue.iconPlacement.rawValue
        let iconPlacement = IconPlacement(rawValue: iconPlacementStr) ?? defaultValue.iconPlacement
        let iconSize = json["iconSize"] as? UInt ?? defaultValue.iconSize
        let showCard = ShowCardActionConfig.deserialize(from: json.nestedDictionary(forKey: "showCard"), defaultValue: defaultValue.showCard)
        return ActionsConfig(showCard: showCard, actionsOrientation: orientation, actionAlignment: alignment, buttonSpacing: buttonSpacing, maxActions: maxActions, spacing: spacing, iconPlacement: iconPlacement, iconSize: iconSize)
    }
}

// 24. InputLabelConfig
struct InputLabelConfig: Codable {
    var color: ForegroundColor
    var isSubtle: Bool
    var size: TextSize
    var suffix: String
    var weight: TextWeight
    
    static func deserialize(from json: [String: Any], defaultValue: InputLabelConfig) -> InputLabelConfig {
        let colorStr = json["color"] as? String ?? defaultValue.color.rawValue
        let color = ForegroundColor(rawValue: colorStr) ?? defaultValue.color
        let isSubtle = json["isSubtle"] as? Bool ?? defaultValue.isSubtle
        let sizeStr = json["size"] as? String ?? defaultValue.size.rawValue
        let size = TextSize(rawValue: sizeStr) ?? defaultValue.size
        let suffix = json["suffix"] as? String ?? defaultValue.suffix
        let weightStr = json["weight"] as? String ?? defaultValue.weight.rawValue
        let weight = TextWeight(rawValue: weightStr) ?? defaultValue.weight
        return InputLabelConfig(color: color, isSubtle: isSubtle, size: size, suffix: suffix, weight: weight)
    }
}

// 25. LabelConfig
struct LabelConfig: Codable {
    var inputSpacing: Spacing
    var requiredInputs: InputLabelConfig
    var optionalInputs: InputLabelConfig
    
    static func deserialize(from json: [String: Any], defaultValue: LabelConfig) -> LabelConfig {
        let spacingStr = json["inputSpacing"] as? String ?? defaultValue.inputSpacing.rawValue
        let spacing = Spacing(rawValue: spacingStr) ?? defaultValue.inputSpacing
        let required = InputLabelConfig.deserialize(from: json.nestedDictionary(forKey: "requiredInputs"), defaultValue: defaultValue.requiredInputs)
        let optional = InputLabelConfig.deserialize(from: json.nestedDictionary(forKey: "optionalInputs"), defaultValue: defaultValue.optionalInputs)
        return LabelConfig(inputSpacing: spacing, requiredInputs: required, optionalInputs: optional)
    }
}

// 26. ErrorMessageConfig
struct ErrorMessageConfig: Codable {
    var size: TextSize
    var spacing: Spacing
    var weight: TextWeight
    
    static func deserialize(from json: [String: Any], defaultValue: ErrorMessageConfig) -> ErrorMessageConfig {
        let sizeStr = json["size"] as? String ?? defaultValue.size.rawValue
        let size = TextSize(rawValue: sizeStr) ?? defaultValue.size
        let spacingStr = json["spacing"] as? String ?? defaultValue.spacing.rawValue
        let spacing = Spacing(rawValue: spacingStr) ?? defaultValue.spacing
        let weightStr = json["weight"] as? String ?? defaultValue.weight.rawValue
        let weight = TextWeight(rawValue: weightStr) ?? defaultValue.weight
        return ErrorMessageConfig(size: size, spacing: spacing, weight: weight)
    }
}

// 27. InputsConfig
struct InputsConfig: Codable {
    var label: LabelConfig
    var errorMessage: ErrorMessageConfig
    
    static func deserialize(from json: [String: Any], defaultValue: InputsConfig) -> InputsConfig {
        let errorMsg = ErrorMessageConfig.deserialize(from: json.nestedDictionary(forKey: "errorMessage"), defaultValue: defaultValue.errorMessage)
        let label = LabelConfig.deserialize(from: json.nestedDictionary(forKey: "label"), defaultValue: defaultValue.label)
        return InputsConfig(label: label, errorMessage: errorMsg)
    }
}

// 28. MediaConfig
struct MediaConfig: Codable {
    var defaultPoster: String
    var playButton: String
    var allowInlinePlayback: Bool
    
    static func deserialize(from json: [String: Any], defaultValue: MediaConfig) -> MediaConfig {
        let poster = (json["defaultPoster"] as? String).flatMap { !$0.isEmpty ? $0 : defaultValue.defaultPoster } ?? defaultValue.defaultPoster
        let playButton = (json["playButton"] as? String).flatMap { !$0.isEmpty ? $0 : defaultValue.playButton } ?? defaultValue.playButton
        let inlinePlayback = json["allowInlinePlayback"] as? Bool ?? defaultValue.allowInlinePlayback
        return MediaConfig(defaultPoster: poster, playButton: playButton, allowInlinePlayback: inlinePlayback)
    }
}

// 29. HostWidthConfig
struct HostWidthConfig: Codable {
    var veryNarrow: UInt
    var narrow: UInt
    var standard: UInt
    
    static func deserialize(from json: [String: Any], defaultValue: HostWidthConfig) -> HostWidthConfig {
        return HostWidthConfig(
            veryNarrow: json["veryNarrow"] as? UInt ?? defaultValue.veryNarrow,
            narrow: json["narrow"] as? UInt ?? defaultValue.narrow,
            standard: json["standard"] as? UInt ?? defaultValue.standard
        )
    }
}

// 30. TextBlockConfig
struct TextBlockConfig: Codable {
    var headingLevel: UInt
    
    static func deserialize(from json: [String: Any], defaultValue: TextBlockConfig) -> TextBlockConfig {
        return TextBlockConfig(
            headingLevel: json["headingLevel"] as? UInt ?? defaultValue.headingLevel
        )
    }
}

// 31. TableConfig
struct TableConfig: Codable {
    var cellSpacing: UInt
    
    static func deserialize(from json: [String: Any], defaultValue: TableConfig) -> TableConfig {
        return TableConfig(
            cellSpacing: json["cellSpacing"] as? UInt ?? defaultValue.cellSpacing
        )
    }
}

// 32. BadgeConfig
struct BadgeConfig: Codable {
    var backgroundColor: String
    
    static func deserialize(from json: [String: Any], defaultValue: BadgeConfig) -> BadgeConfig {
        let bg = json["backgroundColor"] as? String ?? defaultValue.backgroundColor
        return BadgeConfig(backgroundColor: bg)
    }
}

// 33. CompoundButtonConfig
struct CompoundButtonConfig: Codable {
    var badgeConfig: BadgeConfig
    var borderColor: String
    
    static func deserialize(from json: [String: Any], defaultValue: CompoundButtonConfig) -> CompoundButtonConfig {
        let badge = BadgeConfig.deserialize(from: json.nestedDictionary(forKey: "badge"), defaultValue: defaultValue.badgeConfig)
        let border = json["borderColor"] as? String ?? defaultValue.borderColor
        return CompoundButtonConfig(badgeConfig: badge, borderColor: border)
    }
}

// 34. HostConfig
struct HostConfig: Codable {
    var fontFamily: String
    var supportsInteractivity: Bool
    var imageBaseUrl: String
    var fontSizes: FontSizesConfig
    var fontWeights: FontWeightsConfig
    var fontTypes: FontTypesDefinition
    var imageSizes: ImageSizesConfig
    var image: ImageConfig
    var separator: SeparatorConfig
    var spacing: SpacingConfig
    var adaptiveCard: AdaptiveCardConfig
    var imageSet: ImageSetConfig
    var factSet: FactSetConfig
    var actions: ActionsConfig
    var containerStyles: ContainerStylesDefinition
    var media: MediaConfig
    var inputs: InputsConfig
    var hostWidth: HostWidthConfig
    var textBlock: TextBlockConfig
    var textStyles: TextStylesConfig
    var ratingLabelConfig: RatingElementConfig
    var ratingInputConfig: RatingElementConfig
    var table: TableConfig
    var borderWidth: [String: UInt]   // mapping from element type key to width
    var cornerRadius: [String: UInt]    // mapping from element type key to radius
    var compoundButtonConfig: CompoundButtonConfig
    
    // Default initializer with sample defaults (adjust as needed).
    init() {
        self.fontFamily = ""
        self.supportsInteractivity = true
        self.imageBaseUrl = ""
        self.fontSizes = FontSizesConfig(small: UInt.max, default: UInt.max, medium: UInt.max, large: UInt.max, extraLarge: UInt.max)
        self.fontWeights = FontWeightsConfig(lighter: UInt.max, default: UInt.max, bolder: UInt.max)
        let defaultFontType = FontTypeDefinition(fontFamily: "", fontSizes: self.fontSizes, fontWeights: self.fontWeights)
        self.fontTypes = FontTypesDefinition(defaultFontType: defaultFontType, monospaceFontType: defaultFontType)
        self.imageSizes = ImageSizesConfig(smallSize: 80, mediumSize: 120, largeSize: 180)
        self.image = ImageConfig(imageSize: .auto)
        self.separator = SeparatorConfig(lineThickness: 1, lineColor: "#B2000000")
        self.spacing = SpacingConfig(smallSpacing: 3, defaultSpacing: 8, mediumSpacing: 20, largeSpacing: 30, extraLargeSpacing: 40, paddingSpacing: 20)
        self.adaptiveCard = AdaptiveCardConfig(allowCustomStyle: true)
        self.imageSet = ImageSetConfig(imageSize: .auto, maxImageHeight: 100)
        let defaultFactSetText = FactSetTextConfig(weight: .bolder, size: .defaultSize, isSubtle: false, color: .default, fontType: .defaultFont, wrap: true, maxWidth: UInt.max)
        self.factSet = FactSetConfig(title: defaultFactSetText, value: defaultFactSetText, spacing: 10)
        let defaultShowCard = ShowCardActionConfig(actionMode: .inline, style: .emphasis, inlineTopMargin: 16)
        self.actions = ActionsConfig(showCard: defaultShowCard, actionsOrientation: .horizontal, actionAlignment: .stretch, buttonSpacing: 10, maxActions: 5, spacing: .default, iconPlacement: .aboveTitle, iconSize: 16)
        // Default container styles with sample colors.
        let defaultColorConfig = ColorConfig(defaultColor: "#FF000000", subtleColor: "#B2000000", highlightColors: HighlightColorConfig(defaultColor: "#FFFFFF00", subtleColor: "#FFFFFFE0"))
        let defaultColorsConfig = ColorsConfig(default: defaultColorConfig,
                                               accent: ColorConfig(defaultColor: "#FF0000FF", subtleColor: "#B20000FF", highlightColors: HighlightColorConfig(defaultColor: "#FFFFFF00", subtleColor: "#FFFFFFE0")),
                                               dark: ColorConfig(defaultColor: "#FF101010", subtleColor: "#B2101010", highlightColors: HighlightColorConfig(defaultColor: "#FFFFFF00", subtleColor: "#FFFFFFE0")),
                                               light: ColorConfig(defaultColor: "#FFFFFFFF", subtleColor: "#B2FFFFFF", highlightColors: HighlightColorConfig(defaultColor: "#FFFFFF00", subtleColor: "#FFFFFFE0")),
                                               good: ColorConfig(defaultColor: "#FF008000", subtleColor: "#B2008000", highlightColors: HighlightColorConfig(defaultColor: "#FFFFFF00", subtleColor: "#FFFFFFE0")),
                                               warning: ColorConfig(defaultColor: "#FFFFD700", subtleColor: "#B2FFD700", highlightColors: HighlightColorConfig(defaultColor: "#FFFFFF00", subtleColor: "#FFFFFFE0")),
                                               attention: ColorConfig(defaultColor: "#FF8B0000", subtleColor: "#B28B0000", highlightColors: HighlightColorConfig(defaultColor: "#FFFFFF00", subtleColor: "#FFFFFFE0")))
        let defaultContainerStyle = ContainerStyleDefinition(backgroundColor: "#FFFFFFFF", borderColor: "#FF7F7F7F", foregroundColors: defaultColorsConfig)
        self.containerStyles = ContainerStylesDefinition(
            defaultPalette: defaultContainerStyle,
            emphasisPalette: ContainerStyleDefinition(backgroundColor: "#08000000", borderColor: "#08000000", foregroundColors: defaultColorsConfig),
            goodPalette: ContainerStyleDefinition(backgroundColor: "#FFD5F0DD", borderColor: "#FF7F7F7F", foregroundColors: defaultColorsConfig),
            attentionPalette: ContainerStyleDefinition(backgroundColor: "#F7E9E9", borderColor: "#FF7F7F7F", foregroundColors: defaultColorsConfig),
            warningPalette: ContainerStyleDefinition(backgroundColor: "#F7F7DF", borderColor: "#FF7F7F7F", foregroundColors: defaultColorsConfig),
            accentPalette: ContainerStyleDefinition(backgroundColor: "#DCE5F7", borderColor: "#FF7F7F7F", foregroundColors: defaultColorsConfig)
        )
        self.media = MediaConfig(defaultPoster: "", playButton: "", allowInlinePlayback: true)
        let defaultInputLabel = InputLabelConfig(color: .default, isSubtle: false, size: .defaultSize, suffix: "", weight: .defaultWeight)
        self.inputs = InputsConfig(label: LabelConfig(inputSpacing: .default, requiredInputs: defaultInputLabel, optionalInputs: defaultInputLabel),
                                   errorMessage: ErrorMessageConfig(size: .defaultSize, spacing: .default, weight: .defaultWeight))
        self.hostWidth = HostWidthConfig(veryNarrow: 0, narrow: 0, standard: 0)
        self.textBlock = TextBlockConfig(headingLevel: 2)
        let defaultTextStyle = TextStyleConfig(weight: .bolder, size: .large, isSubtle: false, color: .default, fontType: .defaultFont)
        self.textStyles = TextStylesConfig(heading: defaultTextStyle, columnHeader: defaultTextStyle)
        self.ratingLabelConfig = RatingElementConfig(filledStar: RatingStarCofig(marigoldColor: "#EAA300", neutralColor: "#212121"),
                                                      emptyStar: RatingStarCofig(marigoldColor: "#EAA300", neutralColor: "#212121"),
                                                      ratingTextColor: "#000000",
                                                      countTextColor: "#000000")
        self.ratingInputConfig = RatingElementConfig(filledStar: RatingStarCofig(marigoldColor: "#EAA300", neutralColor: "#212121"),
                                                      emptyStar: RatingStarCofig(marigoldColor: "#EAA300", neutralColor: "#212121"),
                                                      ratingTextColor: "#000000",
                                                      countTextColor: "#000000")
        self.table = TableConfig(cellSpacing: 8)
        self.borderWidth = [:]
        self.cornerRadius = [:]
        self.compoundButtonConfig = CompoundButtonConfig(badgeConfig: BadgeConfig(backgroundColor: "#5B5FC7"), borderColor: "#E1E1E1")
    }
    
    static func deserialize(from json: [String: Any]) -> HostConfig {
        var result = HostConfig()
        // Font Family
        if let fontFamily = json["fontFamily"] as? String, !fontFamily.isEmpty {
            result.fontFamily = fontFamily
        }
        // Supports Interactivity
        result.supportsInteractivity = json["supportsInteractivity"] as? Bool ?? result.supportsInteractivity
        // Image Base URL
        result.imageBaseUrl = json["imageBaseUrl"] as? String ?? result.imageBaseUrl
        
        // FactSet
        result.factSet = FactSetConfig.deserialize(from: json.nestedDictionary(forKey: "factSet"), defaultValue: result.factSet)
        // Font Sizes
        result.fontSizes = FontSizesConfig.deserialize(from: json.nestedDictionary(forKey: "fontSizes"), defaultValue: result.fontSizes)
        // Font Weights
        result.fontWeights = FontWeightsConfig.deserialize(from: json.nestedDictionary(forKey: "fontWeights"), defaultValue: result.fontWeights)
        // Font Types
        result.fontTypes = FontTypesDefinition.deserialize(from: json.nestedDictionary(forKey: "fontTypes"), defaultValue: result.fontTypes)
        // Container Styles
        result.containerStyles = ContainerStylesDefinition.deserialize(from: json.nestedDictionary(forKey: "containerStyles"), defaultValue: result.containerStyles)
        // Image Config
        result.image = ImageConfig.deserialize(from: json.nestedDictionary(forKey: "image"), defaultValue: result.image)
        // Image Set
        result.imageSet = ImageSetConfig.deserialize(from: json.nestedDictionary(forKey: "imageSet"), defaultValue: result.imageSet)
        // Image Sizes
        result.imageSizes = ImageSizesConfig.deserialize(from: json.nestedDictionary(forKey: "imageSizes"), defaultValue: result.imageSizes)
        // Separator
        result.separator = SeparatorConfig.deserialize(from: json.nestedDictionary(forKey: "separator"), defaultValue: result.separator)
        // Spacing
        result.spacing = SpacingConfig.deserialize(from: json.nestedDictionary(forKey: "spacing"), defaultValue: result.spacing)
        // Adaptive Card
        result.adaptiveCard = AdaptiveCardConfig.deserialize(from: json.nestedDictionary(forKey: "adaptiveCard"), defaultValue: result.adaptiveCard)
        // Actions
        result.actions = ActionsConfig.deserialize(from: json.nestedDictionary(forKey: "actions"), defaultValue: result.actions)
        // Media
        result.media = MediaConfig.deserialize(from: json.nestedDictionary(forKey: "media"), defaultValue: result.media)
        // Host Width
        result.hostWidth = HostWidthConfig.deserialize(from: json.nestedDictionary(forKey: "hostWidthBreakpoints"), defaultValue: result.hostWidth)
        // Inputs
        result.inputs = InputsConfig.deserialize(from: json.nestedDictionary(forKey: "inputs"), defaultValue: result.inputs)
        // Text Block
        result.textBlock = TextBlockConfig.deserialize(from: json.nestedDictionary(forKey: "textBlock"), defaultValue: result.textBlock)
        // Text Styles
        result.textStyles = TextStylesConfig.deserialize(from: json.nestedDictionary(forKey: "textStyles"), defaultValue: result.textStyles)
        // Rating Label Config
        result.ratingLabelConfig = RatingElementConfig.deserialize(from: json.nestedDictionary(forKey: "ratingLabel"), defaultValue: result.ratingLabelConfig)
        // Rating Input Config
        result.ratingInputConfig = RatingElementConfig.deserialize(from: json.nestedDictionary(forKey: "ratingInput"), defaultValue: result.ratingInputConfig)
        // Table
        result.table = TableConfig.deserialize(from: json.nestedDictionary(forKey: "table"), defaultValue: result.table)
        // Border Width & Corner Radius (assumed as dictionaries)
        result.borderWidth = json["borderWidth"] as? [String: UInt] ?? result.borderWidth
        result.cornerRadius = json["cornerRadius"] as? [String: UInt] ?? result.cornerRadius
        // Compound Button Config
        result.compoundButtonConfig = CompoundButtonConfig.deserialize(from: json.nestedDictionary(forKey: "compoundButton"), defaultValue: result.compoundButtonConfig)
        
        return result
    }
    
    static func deserialize(from jsonString: String) -> HostConfig {
        let data = jsonString.data(using: .utf8) ?? Data()
        let jsonObject = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] ?? [:]
        return HostConfig.deserialize(from: jsonObject)
    }
    
    // MARK: - Getter Methods
    
    func getFontType(_ type: FontType) -> FontTypeDefinition {
        switch type {
        case .monospace:
            return self.fontTypes.monospaceFontType
        case .defaultFont:
            fallthrough
        default:
            return self.fontTypes.defaultFontType
        }
    }
    
    func getFontFamily(for type: FontType) -> String {
        let fontTypeDef = getFontType(type)
        if !fontTypeDef.fontFamily.isEmpty {
            return fontTypeDef.fontFamily
        } else if type == .monospace {
            // Let the renderer decide a suitable monospace family.
            return ""
        } else {
            return self.fontFamily.isEmpty ? "" : self.fontFamily
        }
    }
    
    func getFontSize(for fontType: FontType, size: TextSize) -> UInt {
        var result = getFontType(fontType).fontSizes.getFontSize(for: size)
        if result == UInt.max {
            result = self.fontTypes.defaultFontType.fontSizes.getFontSize(for: size)
            if result == UInt.max {
                result = FontSizesConfig.getDefaultFontSize(for: size)
            }
        }
        return result
    }
    
    func getFontWeight(for fontType: FontType, weight: TextWeight) -> UInt {
        var result = getFontType(fontType).fontWeights.getFontWeight(for: weight)
        if result == UInt.max {
            result = self.fontTypes.defaultFontType.fontWeights.getFontWeight(for: weight)
            if result == UInt.max {
                result = FontWeightsConfig.getDefaultFontWeight(for: weight)
            }
        }
        return result
    }
    
    func getContainerStyle(for style: ContainerStyle) -> ContainerStyleDefinition {
        switch style {
        case .accent:
            return self.containerStyles.accentPalette
        case .attention:
            return self.containerStyles.attentionPalette
        case .emphasis:
            return self.containerStyles.emphasisPalette
        case .good:
            return self.containerStyles.goodPalette
        case .warning:
            return self.containerStyles.warningPalette
        case .default:
            fallthrough
        default:
            return self.containerStyles.defaultPalette
        }
    }
    
    private func getColor(from config: ColorConfig, isSubtle: Bool) -> String {
        return isSubtle ? config.subtleColor : config.defaultColor
    }
    
    func getForegroundColor(for style: ContainerStyle, color: ForegroundColor, isSubtle: Bool) -> String {
        let container = getContainerStyle(for: style)
        let colorsConfig = container.foregroundColors
        let selectedColor: ColorConfig
        switch color {
        case .accent:
            selectedColor = colorsConfig.accent
        case .attention:
            selectedColor = colorsConfig.attention
        case .dark:
            selectedColor = colorsConfig.dark
        case .good:
            selectedColor = colorsConfig.good
        case .light:
            selectedColor = colorsConfig.light
        case .warning:
            selectedColor = colorsConfig.warning
        case .default:
            fallthrough
        default:
            selectedColor = colorsConfig.default
        }
        return getColor(from: selectedColor, isSubtle: isSubtle)
    }
    
    func getHighlightColor(for style: ContainerStyle, color: ForegroundColor, isSubtle: Bool) -> String {
        let container = getContainerStyle(for: style)
        let colorsConfig = container.foregroundColors
        let selectedColor: ColorConfig
        switch color {
        case .accent:
            selectedColor = colorsConfig.accent
        case .attention:
            selectedColor = colorsConfig.attention
        case .dark:
            selectedColor = colorsConfig.dark
        case .good:
            selectedColor = colorsConfig.good
        case .light:
            selectedColor = colorsConfig.light
        case .warning:
            selectedColor = colorsConfig.warning
        case .default:
            fallthrough
        default:
            selectedColor = colorsConfig.default
        }
        return getHighlight(from: selectedColor.highlightColors, isSubtle: isSubtle)
    }
    
    private func getHighlight(from config: HighlightColorConfig, isSubtle: Bool) -> String {
        return isSubtle ? config.subtleColor : config.defaultColor
    }
    
    func getBorderColor(for style: ContainerStyle) -> String {
        return getContainerStyle(for: style).borderColor
    }
    
    func getBorderWidth(for elementType: CardElementType) -> UInt {
        let key = elementType.rawValue
        return self.borderWidth[key] ?? 1
    }
    
    func getCornerRadius(for elementType: CardElementType) -> UInt {
        let key = elementType.rawValue
        return self.cornerRadius[key] ?? 5
    }
}
