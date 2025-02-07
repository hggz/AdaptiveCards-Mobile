import Foundation

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
}

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
}

struct FontTypeDefinition: Codable {
    var fontFamily: String?
    var fontSizes: FontSizesConfig
    var fontWeights: FontWeightsConfig
    
    static func deserialize(from json: [String: Any], defaultValue: FontTypeDefinition) -> FontTypeDefinition {
        return FontTypeDefinition(
            fontFamily: json["fontFamily"] as? String ?? defaultValue.fontFamily,
            fontSizes: FontSizesConfig.deserialize(from: json["fontSizes"] as? [String: Any] ?? [:], defaultValue: defaultValue.fontSizes),
            fontWeights: FontWeightsConfig.deserialize(from: json["fontWeights"] as? [String: Any] ?? [:], defaultValue: defaultValue.fontWeights)
        )
    }
}

struct FontTypesDefinition: Codable {
    var defaultFontType: FontTypeDefinition
    var monospaceFontType: FontTypeDefinition
    
    static func deserialize(from json: [String: Any], defaultValue: FontTypesDefinition) -> FontTypesDefinition {
        return FontTypesDefinition(
            defaultFontType: FontTypeDefinition.deserialize(from: json["default"] as? [String: Any] ?? [:], defaultValue: defaultValue.defaultFontType),
            monospaceFontType: FontTypeDefinition.deserialize(from: json["monospace"] as? [String: Any] ?? [:], defaultValue: defaultValue.monospaceFontType)
        )
    }
}

struct HighlightColorConfig: Codable {
    var defaultColor: String
    var subtleColor: String
    
    static func deserialize(from json: [String: Any], defaultValue: HighlightColorConfig) -> HighlightColorConfig {
        return HighlightColorConfig(
            defaultColor: json["defaultColor"] as? String ?? defaultValue.defaultColor,
            subtleColor: json["subtleColor"] as? String ?? defaultValue.subtleColor
        )
    }
}

struct ColorConfig: Codable {
    var defaultColor: String
    var subtleColor: String
    var highlightColors: HighlightColorConfig
    
    static func deserialize(from json: [String: Any], defaultValue: ColorConfig) -> ColorConfig {
        return ColorConfig(
            defaultColor: json["defaultColor"] as? String ?? defaultValue.defaultColor,
            subtleColor: json["subtleColor"] as? String ?? defaultValue.subtleColor,
            highlightColors: HighlightColorConfig.deserialize(from: json["highlightColors"] as? [String: Any] ?? [:], defaultValue: defaultValue.highlightColors)
        )
    }
}

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
            default: ColorConfig.deserialize(from: json["default"] as? [String: Any] ?? [:], defaultValue: defaultValue.default),
            accent: ColorConfig.deserialize(from: json["accent"] as? [String: Any] ?? [:], defaultValue: defaultValue.accent),
            dark: ColorConfig.deserialize(from: json["dark"] as? [String: Any] ?? [:], defaultValue: defaultValue.dark),
            light: ColorConfig.deserialize(from: json["light"] as? [String: Any] ?? [:], defaultValue: defaultValue.light),
            good: ColorConfig.deserialize(from: json["good"] as? [String: Any] ?? [:], defaultValue: defaultValue.good),
            warning: ColorConfig.deserialize(from: json["warning"] as? [String: Any] ?? [:], defaultValue: defaultValue.warning),
            attention: ColorConfig.deserialize(from: json["attention"] as? [String: Any] ?? [:], defaultValue: defaultValue.attention)
        )
    }
}

struct ContainerStyleDefinition: Codable {
    var backgroundColor: String
    var borderColor: String
    var foregroundColors: ColorsConfig
    
    static func deserialize(from json: [String: Any], defaultValue: ContainerStyleDefinition) -> ContainerStyleDefinition {
        return ContainerStyleDefinition(
            backgroundColor: json["backgroundColor"] as? String ?? defaultValue.backgroundColor,
            borderColor: json["borderColor"] as? String ?? defaultValue.borderColor,
            foregroundColors: ColorsConfig.deserialize(from: json["foregroundColors"] as? [String: Any] ?? [:], defaultValue: defaultValue.foregroundColors)
        )
    }
}

struct ContainerStylesDefinition: Codable {
    var defaultPalette: ContainerStyleDefinition
    var emphasisPalette: ContainerStyleDefinition
    
    static func deserialize(from json: [String: Any], defaultValue: ContainerStylesDefinition) -> ContainerStylesDefinition {
        return ContainerStylesDefinition(
            defaultPalette: ContainerStyleDefinition.deserialize(from: json["default"] as? [String: Any] ?? [:], defaultValue: defaultValue.defaultPalette),
            emphasisPalette: ContainerStyleDefinition.deserialize(from: json["emphasis"] as? [String: Any] ?? [:], defaultValue: defaultValue.emphasisPalette)
        )
    }
}

struct HostConfig: Codable {
    var fontFamily: String?
    var supportsInteractivity: Bool
    var imageBaseUrl: String?
    var fontSizes: FontSizesConfig
    var fontWeights: FontWeightsConfig
    var fontTypes: FontTypesDefinition
    var containerStyles: ContainerStylesDefinition
    
    static func deserialize(from json: [String: Any]) -> HostConfig {
        return HostConfig(
            fontFamily: json["fontFamily"] as? String,
            supportsInteractivity: json["supportsInteractivity"] as? Bool ?? true,
            imageBaseUrl: json["imageBaseUrl"] as? String,
            fontSizes: FontSizesConfig.deserialize(from: json["fontSizes"] as? [String: Any] ?? [:], defaultValue: FontSizesConfig()),
            fontWeights: FontWeightsConfig.deserialize(from: json["fontWeights"] as? [String: Any] ?? [:], defaultValue: FontWeightsConfig()),
            fontTypes: FontTypesDefinition.deserialize(from: json["fontTypes"] as? [String: Any] ?? [:], defaultValue: FontTypesDefinition(defaultFontType: FontTypeDefinition(fontFamily: "", fontSizes: FontSizesConfig(), fontWeights: FontWeightsConfig()), monospaceFontType: FontTypeDefinition(fontFamily: "", fontSizes: FontSizesConfig(), fontWeights: FontWeightsConfig()))),
            containerStyles: ContainerStylesDefinition.deserialize(from: json["containerStyles"] as? [String: Any] ?? [:], defaultValue: ContainerStylesDefinition(defaultPalette: ContainerStyleDefinition(backgroundColor: "#FFFFFF", borderColor: "#000000", foregroundColors: ColorsConfig(default: ColorConfig(defaultColor: "#000000", subtleColor: "#CCCCCC", highlightColors: HighlightColorConfig(defaultColor: "#FFFFFF", subtleColor: "#DDDDDD")), accent: ColorConfig(defaultColor: "", subtleColor: "", highlightColors: HighlightColorConfig(defaultColor: "", subtleColor: "")), dark: ColorConfig(defaultColor: "", subtleColor: "", highlightColors: HighlightColorConfig(defaultColor: "", subtleColor: "")), light: ColorConfig(defaultColor: "", subtleColor: "", highlightColors: HighlightColorConfig(defaultColor: "", subtleColor: "")), good: ColorConfig(defaultColor: "", subtleColor: "", highlightColors: HighlightColorConfig(defaultColor: "", subtleColor: "")), warning: ColorConfig(defaultColor: "", subtleColor: "", highlightColors: HighlightColorConfig(defaultColor: "", subtleColor: "")), attention: ColorConfig(defaultColor: "", subtleColor: "", highlightColors: HighlightColorConfig(defaultColor: "", subtleColor: ""))))))
        )
    }
}
