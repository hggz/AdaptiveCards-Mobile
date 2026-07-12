// Port of: pkg/flow/step.go (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

// MARK: - Primitive value types

/// A YAML scalar preserved with its type (used for launch arguments and the
/// `env` overrides that `runFlow`/`runScript` can pass to subflows/scripts).
public enum ScalarValue: Sendable, Equatable, CustomStringConvertible {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)

    public var description: String {
        switch self {
        case .string(let s): return s
        case .int(let i): return String(i)
        case .double(let d): return String(d)
        case .bool(let b): return String(b)
        }
    }
}

/// A scroll / swipe direction.
public enum Direction: String, Sendable, Equatable, CaseIterable {
    case up = "UP"
    case down = "DOWN"
    case left = "LEFT"
    case right = "RIGHT"

    /// Case-insensitive parse of `UP`/`DOWN`/`LEFT`/`RIGHT`.
    public static func parse(_ raw: String) -> Direction? {
        Direction(rawValue: raw.trimmingCharacters(in: .whitespaces).uppercased())
    }
}

/// A hardware / navigation key for `pressKey`. Unrecognized values are preserved
/// verbatim via `.other` so upstream key names keep working.
public enum DeviceKey: Sendable, Equatable, CustomStringConvertible {
    case home
    case back
    case enter
    case lock
    case power
    case tab
    case backspace
    case volumeUp
    case volumeDown
    case remoteUp
    case remoteDown
    case remoteLeft
    case remoteRight
    case remoteCenter
    case other(String)

    public static func parse(_ raw: String) -> DeviceKey {
        let key = raw.trimmingCharacters(in: .whitespaces).lowercased()
        switch key {
        case "home": return .home
        case "back": return .back
        case "enter": return .enter
        case "lock": return .lock
        case "power": return .power
        case "tab": return .tab
        case "backspace", "delete": return .backspace
        case "volume up", "volumeup", "volume_up": return .volumeUp
        case "volume down", "volumedown", "volume_down": return .volumeDown
        case "remote dpad up", "remote up": return .remoteUp
        case "remote dpad down", "remote down": return .remoteDown
        case "remote dpad left", "remote left": return .remoteLeft
        case "remote dpad right", "remote right": return .remoteRight
        case "remote dpad center", "remote center": return .remoteCenter
        default: return .other(raw)
        }
    }

    public var description: String {
        switch self {
        case .home: return "home"
        case .back: return "back"
        case .enter: return "enter"
        case .lock: return "lock"
        case .power: return "power"
        case .tab: return "tab"
        case .backspace: return "backspace"
        case .volumeUp: return "volume up"
        case .volumeDown: return "volume down"
        case .remoteUp: return "remote dpad up"
        case .remoteDown: return "remote dpad down"
        case .remoteLeft: return "remote dpad left"
        case .remoteRight: return "remote dpad right"
        case .remoteCenter: return "remote dpad center"
        case .other(let s): return s
        }
    }
}

/// A `when:` / `while:` guard used by `runFlow`, `runScript`, `repeat`, `retry`.
public struct Condition: Sendable, Equatable {
    public var visible: Selector?
    public var notVisible: Selector?
    public var trueExpression: String?   // the `true:` field — a JS/`${…}` expression
    public var platform: String?

    public init(visible: Selector? = nil, notVisible: Selector? = nil,
                trueExpression: String? = nil, platform: String? = nil) {
        self.visible = visible
        self.notVisible = notVisible
        self.trueExpression = trueExpression
        self.platform = platform
    }
}

// MARK: - Command payloads

public struct LaunchAppStep: Sendable, Equatable {
    public var appId: String?
    public var clearState: Bool?
    public var clearKeychain: Bool?
    public var stopApp: Bool?
    public var arguments: [String: ScalarValue]
    public var permissions: [String: String]
    public var label: String?

    public init(appId: String? = nil, clearState: Bool? = nil, clearKeychain: Bool? = nil,
                stopApp: Bool? = nil, arguments: [String: ScalarValue] = [:],
                permissions: [String: String] = [:], label: String? = nil) {
        self.appId = appId
        self.clearState = clearState
        self.clearKeychain = clearKeychain
        self.stopApp = stopApp
        self.arguments = arguments
        self.permissions = permissions
        self.label = label
    }
}

/// Shared payload for `tapOn` / `doubleTapOn` / `longPressOn`.
public struct TapStep: Sendable, Equatable {
    public var selector: Selector
    public var repeatCount: Int?
    public var retryTapIfNoChange: Bool?
    public var waitToSettleTimeoutMs: Int?
    public var label: String?
    public var optional: Bool?

    public init(selector: Selector, repeatCount: Int? = nil, retryTapIfNoChange: Bool? = nil,
                waitToSettleTimeoutMs: Int? = nil, label: String? = nil, optional: Bool? = nil) {
        self.selector = selector
        self.repeatCount = repeatCount
        self.retryTapIfNoChange = retryTapIfNoChange
        self.waitToSettleTimeoutMs = waitToSettleTimeoutMs
        self.label = label
        self.optional = optional
    }
}

public struct InputTextStep: Sendable, Equatable {
    public var text: String
    public var label: String?
    public init(text: String, label: String? = nil) {
        self.text = text
        self.label = label
    }
}

/// Shared payload for `assertVisible` / `assertNotVisible`.
public struct AssertStep: Sendable, Equatable {
    public var selector: Selector
    public var timeout: Int?
    public var label: String?
    public var optional: Bool?
    public init(selector: Selector, timeout: Int? = nil, label: String? = nil, optional: Bool? = nil) {
        self.selector = selector
        self.timeout = timeout
        self.label = label
        self.optional = optional
    }
}

public struct ScrollStep: Sendable, Equatable {
    public var direction: Direction
    public var label: String?
    public init(direction: Direction = .down, label: String? = nil) {
        self.direction = direction
        self.label = label
    }
}

public struct ScrollUntilVisibleStep: Sendable, Equatable {
    public var element: Selector
    public var direction: Direction
    public var timeout: Int?
    public var speed: Int?
    public var visibilityPercentage: Int?
    public var centerElement: Bool?
    public var label: String?
    public init(element: Selector, direction: Direction = .down, timeout: Int? = nil,
                speed: Int? = nil, visibilityPercentage: Int? = nil,
                centerElement: Bool? = nil, label: String? = nil) {
        self.element = element
        self.direction = direction
        self.timeout = timeout
        self.speed = speed
        self.visibilityPercentage = visibilityPercentage
        self.centerElement = centerElement
        self.label = label
    }
}

/// `swipe` has three mutually-exclusive forms: a `direction`, an explicit
/// `start`+`end` coordinate pair, or a `from` selector (optionally with `end`).
public struct SwipeStep: Sendable, Equatable {
    public var direction: Direction?
    public var start: PointExpr?
    public var end: PointExpr?
    public var from: Selector?
    public var duration: Int?
    public var label: String?
    public init(direction: Direction? = nil, start: PointExpr? = nil, end: PointExpr? = nil,
                from: Selector? = nil, duration: Int? = nil, label: String? = nil) {
        self.direction = direction
        self.start = start
        self.end = end
        self.from = from
        self.duration = duration
        self.label = label
    }
}

public struct OpenLinkStep: Sendable, Equatable {
    public var url: String
    public var autoVerify: Bool?
    public var browser: Bool?
    public var label: String?
    public init(url: String, autoVerify: Bool? = nil, browser: Bool? = nil, label: String? = nil) {
        self.url = url
        self.autoVerify = autoVerify
        self.browser = browser
        self.label = label
    }
}

public struct TakeScreenshotStep: Sendable, Equatable {
    public var path: String?
    public var cropOn: Selector?
    public var label: String?
    public init(path: String? = nil, cropOn: Selector? = nil, label: String? = nil) {
        self.path = path
        self.cropOn = cropOn
        self.label = label
    }
}

public struct StartRecordingStep: Sendable, Equatable {
    public var path: String?
    public var label: String?
    public init(path: String? = nil, label: String? = nil) {
        self.path = path
        self.label = label
    }
}

/// A single GPS waypoint for `travel`.
public struct GeoPoint: Sendable, Equatable {
    public var latitude: Double
    public var longitude: Double
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    /// Parse `"<lat>,<lng>"`.
    public static func parse(_ raw: String) -> GeoPoint? {
        let parts = raw.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2,
              let lat = Double(parts[0].trimmingCharacters(in: .whitespaces)),
              let lng = Double(parts[1].trimmingCharacters(in: .whitespaces)) else { return nil }
        return GeoPoint(latitude: lat, longitude: lng)
    }
}

public struct TravelStep: Sendable, Equatable {
    public var points: [GeoPoint]
    public var speed: Int?
    public var label: String?
    public init(points: [GeoPoint], speed: Int? = nil, label: String? = nil) {
        self.points = points
        self.speed = speed
        self.label = label
    }
}

public struct RunFlowStep: Sendable, Equatable {
    public var file: String?
    public var commands: [MaestroStep]
    public var env: [String: ScalarValue]
    public var whenCondition: Condition?
    public var label: String?
    public init(file: String? = nil, commands: [MaestroStep] = [],
                env: [String: ScalarValue] = [:], whenCondition: Condition? = nil,
                label: String? = nil) {
        self.file = file
        self.commands = commands
        self.env = env
        self.whenCondition = whenCondition
        self.label = label
    }
}

public struct RunScriptStep: Sendable, Equatable {
    public var file: String
    public var env: [String: ScalarValue]
    public var whenCondition: Condition?
    public var label: String?
    public init(file: String, env: [String: ScalarValue] = [:],
                whenCondition: Condition? = nil, label: String? = nil) {
        self.file = file
        self.env = env
        self.whenCondition = whenCondition
        self.label = label
    }
}

public struct RepeatStep: Sendable, Equatable {
    public var times: Int?
    public var whileCondition: Condition?
    public var commands: [MaestroStep]
    public var label: String?
    public init(times: Int? = nil, whileCondition: Condition? = nil,
                commands: [MaestroStep] = [], label: String? = nil) {
        self.times = times
        self.whileCondition = whileCondition
        self.commands = commands
        self.label = label
    }
}

public struct RetryStep: Sendable, Equatable {
    public var maxRetries: Int?
    public var whenCondition: Condition?
    public var commands: [MaestroStep]
    public var label: String?
    public init(maxRetries: Int? = nil, whenCondition: Condition? = nil,
                commands: [MaestroStep] = [], label: String? = nil) {
        self.maxRetries = maxRetries
        self.whenCondition = whenCondition
        self.commands = commands
        self.label = label
    }
}

// MARK: - The typed step model

/// One Maestro flow command. Modeled as an enum with one case per command —
/// upstream (and Maestro's own `MaestroCommand.kt`) uses a single struct with
/// 35+ nullable fields; the enum makes illegal states unrepresentable.
public enum MaestroStep: Sendable, Equatable {
    case launchApp(LaunchAppStep)
    case stopApp(appId: String?, label: String?)
    case killApp(appId: String?, label: String?)
    case clearState(appId: String?, label: String?)
    case clearKeychain(label: String?)
    case tapOn(TapStep)
    case doubleTapOn(TapStep)
    case longPressOn(TapStep)
    case inputText(InputTextStep)
    case eraseText(count: Int?, label: String?)          // nil = erase all
    case copyTextFrom(selector: Selector, label: String?)
    case pasteText(label: String?)
    case assertVisible(AssertStep)
    case assertNotVisible(AssertStep)
    case assertTrue(condition: String, label: String?)
    case scroll(ScrollStep)
    case scrollUntilVisible(ScrollUntilVisibleStep)
    case swipe(SwipeStep)
    case back(label: String?)
    case pressKey(key: DeviceKey, label: String?)
    case hideKeyboard(label: String?)
    case openLink(OpenLinkStep)
    case waitForAnimationToEnd(timeout: Int?, label: String?)
    case takeScreenshot(TakeScreenshotStep)
    case startRecording(StartRecordingStep)
    case stopRecording(label: String?)
    case setLocation(latitude: Double, longitude: Double, label: String?)
    case travel(TravelStep)
    case addMedia(files: [String], label: String?)
    case runFlow(RunFlowStep)
    case runScript(RunScriptStep)
    case evalScript(script: String, label: String?)
    case `repeat`(RepeatStep)
    case retry(RetryStep)

    /// The canonical command name as it appears in a flow file.
    public var commandName: String {
        switch self {
        case .launchApp: return "launchApp"
        case .stopApp: return "stopApp"
        case .killApp: return "killApp"
        case .clearState: return "clearState"
        case .clearKeychain: return "clearKeychain"
        case .tapOn: return "tapOn"
        case .doubleTapOn: return "doubleTapOn"
        case .longPressOn: return "longPressOn"
        case .inputText: return "inputText"
        case .eraseText: return "eraseText"
        case .copyTextFrom: return "copyTextFrom"
        case .pasteText: return "pasteText"
        case .assertVisible: return "assertVisible"
        case .assertNotVisible: return "assertNotVisible"
        case .assertTrue: return "assertTrue"
        case .scroll: return "scroll"
        case .scrollUntilVisible: return "scrollUntilVisible"
        case .swipe: return "swipe"
        case .back: return "back"
        case .pressKey: return "pressKey"
        case .hideKeyboard: return "hideKeyboard"
        case .openLink: return "openLink"
        case .waitForAnimationToEnd: return "waitForAnimationToEnd"
        case .takeScreenshot: return "takeScreenshot"
        case .startRecording: return "startRecording"
        case .stopRecording: return "stopRecording"
        case .setLocation: return "setLocation"
        case .travel: return "travel"
        case .addMedia: return "addMedia"
        case .runFlow: return "runFlow"
        case .runScript: return "runScript"
        case .evalScript: return "evalScript"
        case .`repeat`: return "repeat"
        case .retry: return "retry"
        }
    }

    /// Nested commands for the container steps (`runFlow` inline, `repeat`,
    /// `retry`). Empty for leaf commands. Used by the validator to walk the tree.
    public var nestedCommands: [MaestroStep] {
        switch self {
        case .runFlow(let s): return s.commands
        case .`repeat`(let s): return s.commands
        case .retry(let s): return s.commands
        default: return []
        }
    }
}
