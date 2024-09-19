//
//  HostConfig.swift
//  
//
//  Created by Vikrant Singh on 9/13/23.
//

/*
import UIKit

// Enums
enum SeparatorThickness: CGFloat {
    case none = 0.0
    case thin = 1.0
    case thick = 2.0
}

struct ColorConfig {
    var defaultColor: UIColor
    var subtleColor: UIColor
}

struct ContainerStyleDefinition {
    var backgroundColor: UIColor
    var foregroundColors: [String: ColorConfig]
}

struct AdaptiveCardConfig {
    var allowCustomStyle: Bool
    var backgroundColor: UIColor?
    var padding: UIEdgeInsets
}

struct ImageSetConfig {
    var imageSize: ImageSize
    var maxImageHeight: CGFloat
}

struct MediaConfig {
    var defaultPoster: String
    var allowInlinePlayback: Bool
}

struct FactSetTextConfig {
//    var title: TextConfig
//    var value: TextConfig
}

struct FontSizeConfig {
    var small: CGFloat
    var defaultSize: CGFloat
    var medium: CGFloat
    var large: CGFloat
    var extraLarge: CGFloat
}

struct FontWeightsConfig {
    var lighter: CGFloat
    var defaultWeight: CGFloat
    var bolder: CGFloat
}

struct InputConfig {
    var backgroundColor: UIColor
    var borderColor: UIColor
    var borderThickness: CGFloat
    var isUnderlined: Bool
    var inlineActionIcon: String
    var inlineActionAlignment: HorizontalAlignment
    var inlineActionBackgroundColor: UIColor
    var inlineActionBorderColor: UIColor
    var inlineActionBorderThickness: CGFloat
    var inlineActionTitle: String
    var inlineActionIconPlacement: IconPlacement
    var inlineActionIconSize: ImageSize
    var spacing: Spacing
    var separator: Bool
    var label: String
    var errorMessage: String
}

enum IconPlacement: String {
    case aboveTitle = "AboveTitle"
    case leftOfTitle = "LeftOfTitle"
    case rightOfTitle = "RightOfTitle"
    case belowTitle = "BelowTitle"
}

struct ChoiceSetInputConfig {
    var choiceSpacing: Spacing
    var isMultiSelect: Bool
    var style: String
    var isCompact: Bool
    var inlineActionIcon: String
    var placeholderTextColor: UIColor
}

struct DateInputConfig {
    var placeholderTextColor: UIColor
}

struct NumberInputConfig {
    var placeholderTextColor: UIColor
}

struct TextInputConfig {
    var placeholderTextColor: UIColor
    var isMultiline: Bool
}

struct TimeInputConfig {
    var placeholderTextColor: UIColor
}

struct ToggleInputConfig {
    var title: String
    var valueOn: String
    var valueOff: String
    var wrap: Bool
}

struct ActionConfig {
    var actionsOrientation: Orientation
    var actionAlignment: ActionAlignment
    var buttonSpacing: CGFloat
    var maxActions: Int
    var overflowDirection: OverflowDirection
    var isEnabled: Bool
    var iconSize: CGFloat
    var iconPlacement: IconPlacement
    var iconPosition: IconPosition
}

enum OverflowDirection: String {
    case upward
    case downward
}

enum IconPosition: String {
    case aboveTitle
    case leftOfTitle
    case rightOfTitle
    case belowTitle
}

struct ContainerConfig {
    var normal: ContainerStyleDefinition
    var emphasis: ContainerStyleDefinition
    var good: ContainerStyleDefinition
    var attention: ContainerStyleDefinition
    var warning: ContainerStyleDefinition
    var accent: ContainerStyleDefinition
}

struct CardElementConfig {
    var separator: Bool
    var spacing: Spacing
    var height: String // Depending on the possible values, you may want to change this to an enum.
    var verticalContentAlignment: VerticalAlignment
    var showGridLines: Bool
}

struct ImageConfig {
    var size: ImageSize
    var autoSize: Bool
    var pixelWidth: Int?
    var pixelHeight: Int?
    var altText: String?
    var horizontalAlignment: HorizontalAlignment
}

struct RichTextBlockConfig {
    var horizontalAlignment: HorizontalAlignment
    var wrap: Bool
    var maxLines: Int
}


struct FactSetConfig {
//    var title: TextConfig
//    var value: TextConfig
    var spacing: Spacing
}


struct ShowCardConfig {
    var backgroundColor: UIColor
    var padding: UIEdgeInsets
    var inlineTopMargin: CGFloat
    var style: String // This might be "emphasis", "default", etc. Depending on the usage, consider using an enum.
}


struct MediaElementConfig {
    var poster: String?
    var altText: String?
}


struct SliderInputConfig {
    var minValue: CGFloat
    var maxValue: CGFloat
    var step: CGFloat
    var orientation: Orientation
}

struct SeparatorConfig {
    var lineThickness: CGFloat
    var lineColor: UIColor
}

struct ColorSetConfig {
    var good: ColorConfig
    var warning: ColorConfig
    var attention: ColorConfig
    var accent: ColorConfig
    var dark: ColorConfig
    var light: ColorConfig
}

struct TooltipConfig {
    var backgroundColor: UIColor
    var fontColor: UIColor
    var fontSize: CGFloat
    var wrap: Bool
}

struct ChoiceSetConfig {
    var style: ChoiceSetStyle
    var isMultiSelect: Bool
    var choiceSpacing: CGFloat
}

enum ChoiceSetStyle: String {
    case compact
    case expanded
}

struct RatingConfig {
    var maxStars: Int
    var starSize: CGFloat
    var emptyStarColor: UIColor
    var filledStarColor: UIColor
}

struct PaginationConfig {
    var pageSize: Int
    var currentPageIndicatorColor: UIColor
    var otherPageIndicatorColor: UIColor
}

struct AnimationConfig {
    var duration: Double
    var type: AnimationType
}

enum AnimationType: String {
    case fade
    case slide
    case pop
}



//struct HostConfig {
//    var supportsInteractivity: Bool
//
//    var fontFamily: String
//    var fontSizes: FontSizeConfig
//    var fontWeights: FontWeightsConfig
//    var imageSizes: [ImageSize: CGFloat]
//    var containerStyles: [String: ContainerStyleDefinition]
//
//    var adaptiveCard: AdaptiveCardConfig
//    var imageSet: ImageSetConfig
//    var media: MediaConfig
//    var factSet: FactSetTextConfig
//
//    var inputs: InputConfig
//    var choiceSetInput: ChoiceSetInputConfig
//    var dateInput: DateInputConfig
//    var numberInput: NumberInputConfig
//    var textInput: TextInputConfig
//    var timeInput: TimeInputConfig
//    var toggleInput: ToggleInputConfig
//    var actions: ActionConfig
//
//    var container: ContainerConfig
//    var cardElement: CardElementConfig
//    var image: ImageConfig
//    var richTextBlock: RichTextBlockConfig
//
//    var showCardAction: ShowCardConfig
//    var mediaElement: MediaElementConfig
//    var sliderInput: SliderInputConfig
//
//    var separator: SeparatorConfig
//    var colorSet: ColorSetConfig
//
//    var tooltip: TooltipConfig
//    var choiceSet: ChoiceSetConfig
//
//    var rating: RatingConfig
//    var pagination: PaginationConfig?
//    var animation: AnimationConfig?
//
//    init() {
//
//        // Default Implementation for now - TODO : Pixel Perfected.
//        supportsInteractivity = true
//        fontFamily = "HelveticaNeue"
//
//        fontSizes = FontSizeConfig(
//            small: 12,
//            defaultSize: 14,
//            medium: 17,
//            large: 20,
//            extraLarge: 24
//        )
//
//        fontWeights = FontWeightsConfig(
//            lighter: 200,
//            defaultWeight: 400,
//            bolder: 600
//        )
//
//        imageSizes = [
//            .small: 40,
//            .medium: 80,
//            .large: 120
//        ]
//
//        containerStyles = [
//            "default": ContainerStyleDefinition(backgroundColor: .white, foregroundColors: [:]),
//            "emphasis": ContainerStyleDefinition(backgroundColor: UIColor(white: 0.9, alpha: 1.0), foregroundColors: [:])
//        ]
//
////        adaptiveCard = AdaptiveCardConfig(backgroundColor: .white, padding: PaddingConfig(all: 10))
////        imageSet = ImageSetConfig(imageSize: .medium, maxImageHeight: 200, imageAlignment: .left, imageFillMode: .cover)
////        media = MediaConfig(defaultPoster: .black, allowInlinePlayback: .white)
////        factSet = FactSetTextConfig(title: TextBlockConfig(size: .default, weight: .bolder), value: TextBlockConfig(size: .default, weight: .default))
//
//
//        tooltip = TooltipConfig(backgroundColor: .black, fontColor: .white, fontSize: 12, wrap: true)
////        dateInput = DateInputConfig(dateFormat: "MM/dd/yyyy")
////        numberInput = NumberInputConfig(min: 0, max: 100, step: 1)
//        choiceSet = ChoiceSetConfig(style: .compact, isMultiSelect: false, choiceSpacing: 10)
//
////        image = ImageConfig(size: .medium, autoPlay: false, start: 0)
//        rating = RatingConfig(maxStars: 5, starSize: 20, emptyStarColor: .lightGray, filledStarColor: .yellow)
//        pagination = PaginationConfig(pageSize: 10, currentPageIndicatorColor: .blue, otherPageIndicatorColor: .gray)
//        animation = AnimationConfig(duration: 0.3, type: .fade)
//
////        inputs = InputConfig(focusColor: .blue, backgroundColor: .white)
//
////        choiceSetInput = ChoiceSetInputConfig(spacing: 10, separatorColor: .lightGray)
////        textInput = TextInputConfig(backgroundColor: .white, borderColor: .lightGray, focusColor: .blue)
////        timeInput = TimeInputConfig(timeFormat: "hh:mm")
////        toggleInput = ToggleInputConfig(onColor: .green, offColor: .red)
//
////        actions = ActionConfig(buttonBackgroundColor: .blue, buttonTextColor: .white)
//
////        container = ContainerConfig(spacing: 10, separatorColor: .lightGray)
////        cardElement = CardElementConfig(margin: 10)
////        richTextBlock = RichTextBlockConfig(fontSize: .default, fontWeight: .default)
////
////        factSet = FactSetConfig(title: TextBlockConfig(size: .default, weight: .bolder), value: TextBlockConfig(size: .default, weight: .default))
////        showCardAction = ShowCardConfig(animationDuration: 0.3, backgroundColor: .white)
////        mediaElement = MediaElementConfig(backgroundColor: .black, controlsColor: .white)
////        sliderInput = SliderInputConfig(minValue: 0, maxValue: 100, step: 1, trackColor: .blue, thumbColor: .white)
////
////        separator = SeparatorConfig(lineThickness: 1, lineColor: .lightGray)
////
////        colorSet = ColorSetConfig(
////            default: ColorDefinition(backgroundColor: .white, foregroundColor: .black),
////            subtle: ColorDefinition(backgroundColor: UIColor(white: 0.95, alpha: 1.0), foregroundColor: .darkGray),
////            accent: ColorDefinition(backgroundColor: .blue, foregroundColor: .white),
////            good: ColorDefinition(backgroundColor: .green, foregroundColor: .white),
////            warning: ColorDefinition(backgroundColor: .yellow, foregroundColor: .black),
////            attention: ColorDefinition(backgroundColor: .red, foregroundColor: .white)
////        )
////
////        showCardAction = ShowCardConfig(animationDuration: 0.3, backgroundColor: .white)
////
////        mediaElement = MediaElementConfig(backgroundColor: .black, controlsColor: .white, posterPlaceholder: UIImage(named: "posterPlaceholder"))
////
////        sliderInput = SliderInputConfig(minValue: 0, maxValue: 100, step: 1, trackColor: .blue, thumbColor: .white)
////
////        separator = SeparatorConfig(thickness: 1, color: .lightGray, spacing: 10)
////
////        colorSet = ColorSetConfig(
////            default: ColorDefinition(backgroundColor: .white, foregroundColor: .black),
////            subtle: ColorDefinition(backgroundColor: UIColor(white: 0.95, alpha: 1.0), foregroundColor: .darkGray),
////            accent: ColorDefinition(backgroundColor: .blue, foregroundColor: .white),
////            good: ColorDefinition(backgroundColor: .green, foregroundColor: .white),
////            warning: ColorDefinition(backgroundColor: .yellow, foregroundColor: .black),
////            attention: ColorDefinition(backgroundColor: .red, foregroundColor: .white)
////        )
//
//
//    }
//
//}

struct Separator {
    let lineThickness: Int = 1
    let lineColor: String = "#EEEEEE"
}

struct ImageSizes {
    let small: Int = 40
    let medium: Int = 80
    let large: Int = 160
}

class FontTypeDefinition {
    
    static let monospace = FontTypeDefinition(fontFamily: "'Courier New', Courier, monospace")
    
    var fontFamily: String = "Segoe UI,Segoe,Segoe WP,Helvetica Neue,Helvetica,sans-serif"
    
    var fontSizes: [String: Int] = [
        "small": 12,
        "default": 14,
        "medium": 17,
        "large": 21,
        "extraLarge": 26
    ]
    
    var fontWeights: [String: Int] = [
        "lighter": 200,
        "default": 400,
        "bolder": 600
    ]
    
    init(fontFamily: String? = nil) {
        if let fontFamily = fontFamily {
            self.fontFamily = fontFamily
        }
    }
    
    func parse(_ obj: [String: Any]) {
        if let fontFamily = obj["fontFamily"] as? String {
            self.fontFamily = fontFamily
        }
        
        if let fontSizes = obj["fontSizes"] as? [String: Int] {
            self.fontSizes["small"] = fontSizes["small"] ?? self.fontSizes["small"]
            self.fontSizes["default"] = fontSizes["default"] ?? self.fontSizes["default"]
            self.fontSizes["medium"] = fontSizes["medium"] ?? self.fontSizes["medium"]
            self.fontSizes["large"] = fontSizes["large"] ?? self.fontSizes["large"]
            self.fontSizes["extraLarge"] = fontSizes["extraLarge"] ?? self.fontSizes["extraLarge"]
        }
        
        if let fontWeights = obj["fontWeights"] as? [String: Int] {
            self.fontWeights["lighter"] = fontWeights["lighter"] ?? self.fontWeights["lighter"]
            self.fontWeights["default"] = fontWeights["default"] ?? self.fontWeights["default"]
            self.fontWeights["bolder"] = fontWeights["bolder"] ?? self.fontWeights["bolder"]
        }
    }
}

class HostConfig {
    let hostCapabilities = HostCapabilities()
    // ... other properties ...

    let spacing = Spacing.none
    let separator = Separator()
    let imageSizes = ImageSizes()

    // For other objects like ContainerStyleSet, InputConfig, etc.,
    // you'd similarly define their Swift equivalents, then create instances here.

    var cssClassNamePrefix: String?
    var alwaysAllowBleed = false

    // Assuming some type of FontTypeDefinition, FontTypeSet, and other types
    // are defined elsewhere in Swift as well

    init(obj: Any? = nil) {
        // Parsing logic and initialization from `obj`

        // For instance, if `obj` is a dictionary:
        if let objDict = obj as? [String: Any] {
            if let choiceSetInputValueSeparator = objDict["choiceSetInputValueSeparator"] as? String {
//                self.choiceSetInputValueSeparator = choiceSetInputValueSeparator
            }
            // ... and so on for other properties ...
        }
    }

    func getFontTypeDefinition(style: FontType?) -> FontTypeDefinition {
        // TODO
        return .init()
    }

    func getEffectiveSpacing(spacing: Spacing) -> Int {
        // TODO
        return 8
    }

    // ... other methods ...

    var fontFamily: String? {
        get {
            // TODO
            return getFontTypeDefinition(style: .default).fontFamily
        }
        set {
            // TODO
        }
    }

    // ... other computed properties ...
}
*/
