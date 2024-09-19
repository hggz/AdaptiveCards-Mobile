import UIKit

// Enums

enum FontType: String {
    case `default`
    case monospace
}

enum TextColor: String {
    case `default`
    case dark
    case light
    case accent
    case good
    case warning
    case attention
}

enum TextSize: String {
    case small
    case `default`
    case medium
    case large
    case extraLarge
}

enum TextWeight: String {
    case lighter
    case `default`
    case bolder
}

enum LogLevel: String {
    case Info = "Info"
    case Warning = "Warning"
    case error = "Error"
}

enum RefreshMode: String {
    case disabled = "Disabled"
    case manual = "Manual"
    case automatic = "Automatic"
}

enum SizeUnit: String {
    case weight = "Weight"
    case pixel = "Pixel"
}

enum Spacing: String {
    case none = "None"
}

enum ActionButtonState: Int {
    case normal
    case expanded
    case subdued
}

enum TextBlockStyle: String {
    case defaultStyle = "default"
    case heading
    case columnHeader
}

enum HostWidth: String, CaseIterable {
    case veryNarrow
    case narrow
    case standard
    case wide
}

enum TargetWidthCondition: String {
    case atLeast
    case atMost
}

// Protocols and Structs

protocol ILocalizableString {
    var key: String { get }
    var defaultValue: String { get set }
}

protocol IMarkdownProcessingResult {
    var didProcess: Bool { get }
    var output: UIView? { get }
}

protocol IInput {
    var id: String? { get }
    var value: Any? { get }
    var valueAsString: String? { get }
    func validateValue() -> Bool
    func focus() -> Bool
    func resetDirtyState()
    func isDirty() -> Bool
    func isSet() -> Bool
    func resetValue()
}

protocol IImage {
    var allowExpand: Bool { get }
    var isSelectable: Bool { get }
}

protocol ITextProperties {
    var size: TextSize? { get }
    var weight: TextWeight? { get }
    var color: TextColor? { get }
    var fontType: FontType? { get }
    var isSubtle: Bool? { get }
    var wrap: Bool { get }
    var maxLines: Int? { get }
    var style: TextBlockStyle? { get }
}

protocol IProcessableUrl {
    var unprocessedUrl: String { get }
    func setProcessedUrl(value: String)
}

protocol IDataQueryRequest {
    var searchString: String { get }
//    var dataQuery: DataQuery { get }
    func onDataQueryCompleted(response: IDataQueryResponse)
}

protocol IDataQueryResponse {
    var query: String { get }
    var data: [String: Any] { get }
    var error: String? { get }
}

protocol IResourceInformation {
    var url: String { get }
    var mimeType: String { get }
}

class IElementSpacings {
    var padding: SpacingDefinition?
    var margin: SpacingDefinition?
    
    init(padding: SpacingDefinition, margin: SpacingDefinition) {
        self.padding = padding
        self.margin = margin
    }
}

// Classes and Structures

//struct DataQuery {}  // Implement according to your original design

struct AppletsSettings {
    var logEnabled: Bool
    var logLevel: LogLevel
    var maximumRetryAttempts: Int
    var defaultTimeBetweenRetryAttempts: Int
    var authPromptWidth: Int
    var authPromptHeight: Int
    var refresh: Refresh
    var onLogEvent: ((LogLevel, Any?, [Any]) -> Void)?
}

struct Refresh {
    var mode: RefreshMode
    var timeBetweenAutomaticRefreshes: Int
    var maximumConsecutiveAutomaticRefreshes: Int
    var allowManualRefreshesAfterAutomaticRefreshes: Bool
}

struct ISeparationDefinition {
    var spacing: Int
    var lineThickness: Int?
    var lineColor: UIColor?
}

class GlobalSettings {
    static var useMarkdownInRadioButtonAndCheckbox = true
    static var alwaysBleedSeparators = false
    static var enableFullJsonRoundTrip = false
    static var displayInputValidationErrors = true
    static var allowPreProcessingPropertyValues = false
    static var enableFallback = true
    static var useWebkitLineClamp = true
    static var allowMoreThanMaxActionsInOverflowMenu = false
    static var removePaddingFromContainersWithBackgroundImage = false
    static var resetInputsDirtyStateAfterActionExecution = true
    static var defaultUnlocalizableStringFallback = "Undefined"
    // ... Add other static variables here ...
    static let applets = AppletsSettings(
        logEnabled: true,
        logLevel: .error,
        maximumRetryAttempts: 3,
        defaultTimeBetweenRetryAttempts: 3000,
        authPromptWidth: 400,
        authPromptHeight: 600,
        refresh: Refresh(
            mode: .manual,
            timeBetweenAutomaticRefreshes: 3000,
            maximumConsecutiveAutomaticRefreshes: 3,
            allowManualRefreshesAfterAutomaticRefreshes: true
        )
    )
}

// Equivalent of TypeScript's object
struct ContentTypes {
    static let applicationJson = "application/json"
    static let applicationXWwwFormUrlencoded = "application/x-www-form-urlencoded"
}

// This should be a protocol, not a struct
protocol ISpacingDefinition {
    var left: Int { get set }
    var top: Int { get set }
    var right: Int { get set }
    var bottom: Int { get set }
}

class SpacingDefinition: ISpacingDefinition {
    var left = 0
    var top = 0
    var right = 0
    var bottom = 0

    init(top: Int = 0, right: Int = 0, bottom: Int = 0, left: Int = 0) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }
}

// Assuming Spacing enum is already defined elsewhere
class PaddingDefinition {
    var top: Spacing = .none
    var right: Spacing = .none
    var bottom: Spacing = .none
    var left: Spacing = .none

    init(top: Spacing = .none, right: Spacing = .none, bottom: Spacing = .none, left: Spacing = .none) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }
}

// Assuming SizeUnit enum is already defined elsewhere
class SizeAndUnit {
    var physicalSize: Int
    var unit: SizeUnit

    static func parse(input: String, requireUnitSpecifier: Bool = false) -> SizeAndUnit {
        // Implementation...
        fatalError("Implementation needed based on original TypeScript logic")
    }

    init(physicalSize: Int, unit: SizeUnit) {
        self.physicalSize = physicalSize
        self.unit = unit
    }
}

class TargetWidth {
    var width: HostWidth
    var condition: TargetWidthCondition?

    init(width: HostWidth = .wide, condition: TargetWidthCondition? = nil) {
        self.width = width
        self.condition = condition
    }

    static func parse(input: String) -> TargetWidth? {
        let regEx = "^(?:(atLeast|atMost):)?(veryNarrow|narrow|standard|wide)$"
        let matches = input.range(of: regEx, options: .regularExpression)

        guard matches != nil, let regex = try? NSRegularExpression(pattern: regEx) else { return nil }
        
        let results = regex.matches(in: input, range: NSRange(input.startIndex..., in: input))

        guard let firstMatch = results.first, firstMatch.numberOfRanges >= 3 else { return nil }

        let conditionString = (input as NSString).substring(with: firstMatch.range(at: 1)).lowercased()
        let widthString = (input as NSString).substring(with: firstMatch.range(at: 2)).lowercased()

        let condition: TargetWidthCondition?
        switch conditionString {
        case "atleast":
            condition = .atLeast
        case "atmost":
            condition = .atMost
        default:
            condition = nil
        }

        guard let width = HostWidth(rawValue: widthString) else { return nil }

        return TargetWidth(width: width, condition: condition)
    }

    func matches(hostWidth: HostWidth) -> Bool {
        guard let condition = self.condition else {
            return self.width == hostWidth
        }

        let targetWidthIndex = HostWidth.allCases.firstIndex(of: self.width) ?? -1
        let hostWidthIndex = HostWidth.allCases.firstIndex(of: hostWidth) ?? -1

        switch condition {
        case .atLeast:
            return targetWidthIndex <= hostWidthIndex
        case .atMost:
            return hostWidthIndex <= targetWidthIndex
        }
    }

    func toString() -> String {
        if let condition = self.condition {
            return "\(condition.rawValue):\(width.rawValue)"
        } else {
            return width.rawValue
        }
    }
}

typealias RenderArgs = [String: Any]
