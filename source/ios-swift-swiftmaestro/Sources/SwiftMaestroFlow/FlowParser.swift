// Port of: pkg/flow/parser.go (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import Yams

/// Parses a Maestro flow YAML document into the typed `Flow`/`MaestroStep` model.
///
/// A flow file is up to two YAML documents: an optional configuration mapping,
/// a `---` separator, and a sequence of step commands. Values are inspected
/// structurally (as upstream's Go parser does) rather than decoded via `Codable`,
/// because a step's shape depends on which command key it carries.
public enum FlowParser {

    // MARK: - Entry points

    /// Parse flow YAML text.
    public static func parse(_ text: String, sourcePath: String? = nil) throws -> Flow {
        // Normalize line endings up front so document splitting is independent of
        // how the file was authored or read (Windows editors and the platform
        // Foundation string reader can both surface CRLF/CR).
        let normalized = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        let (headerAny, stepsAny) = try splitDocuments(normalized)

        var flow = try parseHeader(headerAny)
        flow.steps = try parseSteps(stepsAny)
        flow.sourcePath = sourcePath

        if headerAny == nil && flow.steps.isEmpty {
            throw FlowParseError.emptyFlow
        }
        return flow
    }

    /// Read and parse a flow file, recording its path on the returned `Flow`.
    public static func parse(contentsOf path: String) throws -> Flow {
        let text: String
        do {
            text = try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            throw FlowParseError.malformedYAML("cannot read \(path): \(error)")
        }
        return try parse(text, sourcePath: path)
    }

    // MARK: - Document splitting

    private static func splitDocuments(_ text: String) throws -> (header: Any?, steps: Any?) {
        // Find the first standalone `---` line: the Maestro config/steps separator.
        let lines = text.components(separatedBy: "\n")
        var separator: Int?
        for (i, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: CharacterSet(charactersIn: " \t\r"))
            if trimmed == "---" { separator = i; break }
        }

        if let sep = separator {
            let headerText = lines[0..<sep].joined(separator: "\n")
            let stepsText = lines[(sep + 1)...].joined(separator: "\n")
            return (try loadSingle(headerText), try loadSingle(stepsText))
        }

        // No separator: a single document. A sequence is steps; a mapping is a
        // header-only flow (no steps).
        let doc = try loadSingle(text)
        if doc is [Any] {
            return (nil, doc)
        }
        return (doc, nil)
    }

    private static func loadSingle(_ text: String) throws -> Any? {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return nil }
        do {
            return try Yams.load(yaml: text)
        } catch {
            throw FlowParseError.malformedYAML(String(describing: error))
        }
    }

    // MARK: - Header

    private static func parseHeader(_ any: Any?) throws -> Flow {
        guard let any, !(any is NSNull) else { return Flow() }
        guard let map = asMap(any) else {
            throw FlowParseError.invalidStructure("flow configuration must be a mapping")
        }
        var flow = Flow()
        flow.appId = str(map["appId"])
        flow.name = str(map["name"])
        flow.tags = stringList(map["tags"])
        flow.env = stringMap(map["env"])
        flow.commandTimeout = int(map["commandTimeout"])
        flow.flowTimeout = int(map["flowTimeout"])
        flow.waitForIdleTimeout = int(map["waitForIdleTimeout"])
        return flow
    }

    // MARK: - Steps

    private static func parseSteps(_ any: Any?) throws -> [MaestroStep] {
        guard let any, !(any is NSNull) else { return [] }
        guard let list = any as? [Any] else {
            throw FlowParseError.invalidStructure("flow steps must be a list")
        }
        return try list.map { try parseStep($0) }
    }

    private static func parseStep(_ raw: Any) throws -> MaestroStep {
        if let name = raw as? String {
            return try parseCommand(name: name, value: nil, siblings: [:])
        }
        guard let map = asMap(raw) else {
            throw FlowParseError.invalidStructure("a step must be a command name or a mapping")
        }
        // A step mapping carries exactly one command key; `label`/`optional` may
        // appear as siblings of it (Maestro's inline-modifier syntax).
        let modifierKeys: Set<String> = ["label", "optional"]
        let commandKeys = map.keys.filter { !modifierKeys.contains($0) }
        guard commandKeys.count == 1, let name = commandKeys.first else {
            throw FlowParseError.invalidStructure(
                "each step must contain exactly one command (found: \(map.keys.sorted().joined(separator: ", ")))")
        }
        return try parseCommand(name: name, value: map[name], siblings: map)
    }

    // MARK: - Command dispatch

    private static func parseCommand(name: String, value: Any?, siblings: [String: Any]) throws -> MaestroStep {
        let lbl = label(value, siblings)
        let opt = optionalFlag(value, siblings)

        switch name {
        case "launchApp":
            return .launchApp(try parseLaunchApp(value, label: lbl))
        case "stopApp":
            return .stopApp(appId: appId(value), label: lbl)
        case "killApp":
            return .killApp(appId: appId(value), label: lbl)
        case "clearState":
            return .clearState(appId: appId(value), label: lbl)
        case "clearKeychain":
            return .clearKeychain(label: lbl)
        case "tapOn":
            return .tapOn(try parseTap(value, command: name, label: lbl, optional: opt))
        case "doubleTapOn":
            return .doubleTapOn(try parseTap(value, command: name, label: lbl, optional: opt))
        case "longPressOn":
            return .longPressOn(try parseTap(value, command: name, label: lbl, optional: opt))
        case "inputText":
            guard let text = str(value) ?? str(asMap(value)?["text"]) else {
                throw FlowParseError.invalidStep(command: name, reason: "requires text")
            }
            return .inputText(InputTextStep(text: text, label: lbl))
        case "eraseText":
            return .eraseText(count: int(value) ?? int(asMap(value)?["charactersToErase"]), label: lbl)
        case "copyTextFrom":
            guard let sel = try selector(value) else {
                throw FlowParseError.invalidStep(command: name, reason: "requires a selector")
            }
            return .copyTextFrom(selector: sel, label: lbl)
        case "pasteText":
            return .pasteText(label: lbl)
        case "assertVisible":
            return .assertVisible(try parseAssert(value, command: name, label: lbl, optional: opt))
        case "assertNotVisible":
            return .assertNotVisible(try parseAssert(value, command: name, label: lbl, optional: opt))
        case "assertTrue":
            guard let cond = str(value) ?? str(asMap(value)?["condition"]) else {
                throw FlowParseError.invalidStep(command: name, reason: "requires a condition expression")
            }
            return .assertTrue(condition: cond, label: lbl)
        case "scroll":
            return .scroll(parseScroll(value, label: lbl))
        case "scrollUntilVisible":
            return .scrollUntilVisible(try parseScrollUntilVisible(value, label: lbl))
        case "swipe":
            return .swipe(try parseSwipe(value, label: lbl))
        case "back":
            return .back(label: lbl)
        case "pressKey":
            guard let key = str(value) ?? str(asMap(value)?["key"]) else {
                throw FlowParseError.invalidStep(command: name, reason: "requires a key")
            }
            return .pressKey(key: DeviceKey.parse(key), label: lbl)
        case "hideKeyboard":
            return .hideKeyboard(label: lbl)
        case "openLink":
            return .openLink(try parseOpenLink(value, label: lbl))
        case "waitForAnimationToEnd":
            return .waitForAnimationToEnd(timeout: int(value) ?? int(asMap(value)?["timeout"]), label: lbl)
        case "takeScreenshot":
            return .takeScreenshot(try parseTakeScreenshot(value, label: lbl))
        case "startRecording":
            return .startRecording(StartRecordingStep(path: str(value) ?? str(asMap(value)?["path"]), label: lbl))
        case "stopRecording":
            return .stopRecording(label: lbl)
        case "setLocation":
            return try parseSetLocation(value, label: lbl)
        case "travel":
            return .travel(try parseTravel(value, label: lbl))
        case "addMedia":
            return .addMedia(files: try parseAddMedia(value, command: name), label: lbl)
        case "runFlow":
            return .runFlow(try parseRunFlow(value, label: lbl))
        case "runScript":
            return .runScript(try parseRunScript(value, command: name, label: lbl))
        case "evalScript":
            guard let script = str(value) ?? str(asMap(value)?["script"]) else {
                throw FlowParseError.invalidStep(command: name, reason: "requires a script expression")
            }
            return .evalScript(script: script, label: lbl)
        case "repeat":
            return .`repeat`(try parseRepeat(value, label: lbl))
        case "retry":
            return .retry(try parseRetry(value, label: lbl))
        default:
            throw FlowParseError.unknownCommand(name)
        }
    }

    // MARK: - Per-command parsers

    private static func parseLaunchApp(_ value: Any?, label: String?) throws -> LaunchAppStep {
        if let id = str(value) {
            return LaunchAppStep(appId: id, label: label)
        }
        guard let map = asMap(value) else {
            return LaunchAppStep(label: label)
        }
        return LaunchAppStep(
            appId: str(map["appId"]),
            clearState: bool(map["clearState"]),
            clearKeychain: bool(map["clearKeychain"]),
            stopApp: bool(map["stopApp"]),
            arguments: scalarMap(map["arguments"]),
            permissions: stringMap(map["permissions"]),
            label: label
        )
    }

    private static func parseTap(_ value: Any?, command: String, label: String?, optional: Bool?) throws -> TapStep {
        guard let sel = try selector(value) else {
            throw FlowParseError.invalidStep(command: command, reason: "requires a selector")
        }
        let map = asMap(value)
        return TapStep(
            selector: sel,
            repeatCount: int(map?["repeat"]),
            retryTapIfNoChange: bool(map?["retryTapIfNoChange"]),
            waitToSettleTimeoutMs: int(map?["waitToSettleTimeoutMs"]),
            label: label,
            optional: optional
        )
    }

    private static func parseAssert(_ value: Any?, command: String, label: String?, optional: Bool?) throws -> AssertStep {
        guard let sel = try selector(value) else {
            throw FlowParseError.invalidStep(command: command, reason: "requires a selector")
        }
        let map = asMap(value)
        return AssertStep(selector: sel, timeout: int(map?["timeout"]), label: label, optional: optional)
    }

    private static func parseScroll(_ value: Any?, label: String?) -> ScrollStep {
        if let s = str(value), let dir = Direction.parse(s) {
            return ScrollStep(direction: dir, label: label)
        }
        if let map = asMap(value), let s = str(map["direction"]), let dir = Direction.parse(s) {
            return ScrollStep(direction: dir, label: label)
        }
        return ScrollStep(direction: .down, label: label)
    }

    private static func parseScrollUntilVisible(_ value: Any?, label: String?) throws -> ScrollUntilVisibleStep {
        guard let map = asMap(value) else {
            throw FlowParseError.invalidStep(command: "scrollUntilVisible", reason: "requires an element selector")
        }
        guard let element = try selector(map["element"]) ?? selector(value) else {
            throw FlowParseError.invalidStep(command: "scrollUntilVisible", reason: "requires an element selector")
        }
        let dir = str(map["direction"]).flatMap(Direction.parse) ?? .down
        return ScrollUntilVisibleStep(
            element: element,
            direction: dir,
            timeout: int(map["timeout"]),
            speed: int(map["speed"]),
            visibilityPercentage: int(map["visibilityPercentage"]),
            centerElement: bool(map["centerElement"]),
            label: label
        )
    }

    private static func parseSwipe(_ value: Any?, label: String?) throws -> SwipeStep {
        if let s = str(value), let dir = Direction.parse(s) {
            return SwipeStep(direction: dir, label: label)
        }
        guard let map = asMap(value) else {
            throw FlowParseError.invalidStep(command: "swipe", reason: "requires a direction, start/end, or from")
        }
        let direction = str(map["direction"]).flatMap(Direction.parse)
        let start = str(map["start"]).flatMap(PointExpr.parse)
        let end = str(map["end"]).flatMap(PointExpr.parse)
        let from = try selector(map["from"])
        let duration = int(map["duration"])
        guard direction != nil || (start != nil && end != nil) || from != nil else {
            throw FlowParseError.invalidStep(
                command: "swipe", reason: "requires a direction, a start+end pair, or a from selector")
        }
        return SwipeStep(direction: direction, start: start, end: end, from: from, duration: duration, label: label)
    }

    private static func parseOpenLink(_ value: Any?, label: String?) throws -> OpenLinkStep {
        if let url = str(value) {
            return OpenLinkStep(url: url, label: label)
        }
        guard let map = asMap(value), let url = str(map["link"]) ?? str(map["url"]) else {
            throw FlowParseError.invalidStep(command: "openLink", reason: "requires a link URL")
        }
        return OpenLinkStep(url: url, autoVerify: bool(map["autoVerify"]), browser: bool(map["browser"]), label: label)
    }

    private static func parseTakeScreenshot(_ value: Any?, label: String?) throws -> TakeScreenshotStep {
        if let path = str(value) {
            return TakeScreenshotStep(path: path, label: label)
        }
        let map = asMap(value)
        return TakeScreenshotStep(path: str(map?["path"]), cropOn: try selector(map?["cropOn"]), label: label)
    }

    private static func parseSetLocation(_ value: Any?, label: String?) throws -> MaestroStep {
        if let s = str(value), let gp = GeoPoint.parse(s) {
            return .setLocation(latitude: gp.latitude, longitude: gp.longitude, label: label)
        }
        guard let map = asMap(value),
              let lat = dbl(map["latitude"]),
              let lng = dbl(map["longitude"]) else {
            throw FlowParseError.invalidStep(command: "setLocation", reason: "requires latitude and longitude")
        }
        return .setLocation(latitude: lat, longitude: lng, label: label)
    }

    private static func parseTravel(_ value: Any?, label: String?) throws -> TravelStep {
        guard let map = asMap(value), let rawPoints = map["points"] as? [Any] else {
            throw FlowParseError.invalidStep(command: "travel", reason: "requires a points list")
        }
        let points = try rawPoints.map { raw -> GeoPoint in
            if let s = str(raw), let gp = GeoPoint.parse(s) { return gp }
            if let m = asMap(raw) {
                if let ps = str(m["point"]), let gp = GeoPoint.parse(ps) { return gp }
                if let lat = dbl(m["latitude"]), let lng = dbl(m["longitude"]) {
                    return GeoPoint(latitude: lat, longitude: lng)
                }
            }
            throw FlowParseError.invalidStep(command: "travel", reason: "invalid travel point: \(raw)")
        }
        return TravelStep(points: points, speed: int(map["speed"]), label: label)
    }

    private static func parseAddMedia(_ value: Any?, command: String) throws -> [String] {
        if let list = value as? [Any] {
            return list.compactMap { str($0) }
        }
        if let one = str(value) { return [one] }
        if let map = asMap(value), let list = map["media"] as? [Any] {
            return list.compactMap { str($0) }
        }
        throw FlowParseError.invalidStep(command: command, reason: "requires one or more file paths")
    }

    private static func parseRunFlow(_ value: Any?, label: String?) throws -> RunFlowStep {
        if let file = str(value) {
            return RunFlowStep(file: file, label: label)
        }
        guard let map = asMap(value) else {
            throw FlowParseError.invalidStep(command: "runFlow", reason: "requires a file or inline commands")
        }
        let commands = try (map["commands"] as? [Any]).map { try $0.map { try parseStep($0) } } ?? []
        let file = str(map["file"])
        guard file != nil || !commands.isEmpty else {
            throw FlowParseError.invalidStep(command: "runFlow", reason: "requires a file or inline commands")
        }
        return RunFlowStep(
            file: file,
            commands: commands,
            env: scalarMap(map["env"]),
            whenCondition: try condition(map["when"]),
            label: label
        )
    }

    private static func parseRunScript(_ value: Any?, command: String, label: String?) throws -> RunScriptStep {
        if let file = str(value) {
            return RunScriptStep(file: file, label: label)
        }
        guard let map = asMap(value), let file = str(map["file"]) else {
            throw FlowParseError.invalidStep(command: command, reason: "requires a script file path")
        }
        return RunScriptStep(file: file, env: scalarMap(map["env"]), whenCondition: try condition(map["when"]), label: label)
    }

    private static func parseRepeat(_ value: Any?, label: String?) throws -> RepeatStep {
        guard let map = asMap(value) else {
            throw FlowParseError.invalidStep(command: "repeat", reason: "requires times/while and commands")
        }
        let commands = try (map["commands"] as? [Any])?.map { try parseStep($0) } ?? []
        guard !commands.isEmpty else {
            throw FlowParseError.invalidStep(command: "repeat", reason: "requires a commands list")
        }
        return RepeatStep(
            times: int(map["times"]),
            whileCondition: try condition(map["while"]),
            commands: commands,
            label: label
        )
    }

    private static func parseRetry(_ value: Any?, label: String?) throws -> RetryStep {
        guard let map = asMap(value) else {
            throw FlowParseError.invalidStep(command: "retry", reason: "requires commands")
        }
        let commands = try (map["commands"] as? [Any])?.map { try parseStep($0) } ?? []
        guard !commands.isEmpty else {
            throw FlowParseError.invalidStep(command: "retry", reason: "requires a commands list")
        }
        return RetryStep(
            maxRetries: int(map["maxRetries"]),
            whenCondition: try condition(map["when"]),
            commands: commands,
            label: label
        )
    }

    // MARK: - Selectors & conditions

    /// Build a `Selector` from a scalar string (text shorthand) or a mapping.
    static func selector(_ any: Any?) throws -> Selector? {
        guard let any, !(any is NSNull) else { return nil }
        if let s = any as? String {
            return Selector(text: s)
        }
        guard let map = asMap(any) else { return nil }
        var sel = Selector()
        sel.text = str(map["text"])
        sel.id = str(map["id"])
        sel.css = str(map["css"])
        sel.xpath = str(map["xpath"])
        sel.index = int(map["index"])
        if let ps = str(map["point"]) { sel.point = PointExpr.parse(ps) }
        sel.enabled = bool(map["enabled"])
        sel.checked = bool(map["checked"])
        sel.focused = bool(map["focused"])
        sel.selected = bool(map["selected"])
        if let rel = try selector(map["below"]) { sel.below = SelectorBox(rel) }
        if let rel = try selector(map["above"]) { sel.above = SelectorBox(rel) }
        if let rel = try selector(map["leftOf"]) { sel.leftOf = SelectorBox(rel) }
        if let rel = try selector(map["rightOf"]) { sel.rightOf = SelectorBox(rel) }
        if let rel = try selector(map["childOf"]) { sel.childOf = SelectorBox(rel) }
        if let rel = try selector(map["containsChild"]) { sel.containsChild = SelectorBox(rel) }
        if let list = map["containsDescendants"] as? [Any] {
            sel.containsDescendants = try list.compactMap { try selector($0) }
        }
        return sel.isEmpty ? nil : sel
    }

    static func condition(_ any: Any?) throws -> Condition? {
        guard let any, !(any is NSNull) else { return nil }
        if let s = any as? String {
            return Condition(trueExpression: s)
        }
        guard let map = asMap(any) else { return nil }
        let cond = Condition(
            visible: try selector(map["visible"]),
            notVisible: try selector(map["notVisible"]),
            trueExpression: str(map["true"]),
            platform: str(map["platform"])
        )
        if cond.visible == nil && cond.notVisible == nil && cond.trueExpression == nil && cond.platform == nil {
            return nil
        }
        return cond
    }

    // MARK: - Shared helpers

    private static func appId(_ value: Any?) -> String? {
        if let s = str(value) { return s }
        return str(asMap(value)?["appId"])
    }

    private static func label(_ value: Any?, _ siblings: [String: Any]) -> String? {
        if let m = asMap(value), let l = str(m["label"]) { return l }
        return str(siblings["label"])
    }

    private static func optionalFlag(_ value: Any?, _ siblings: [String: Any]) -> Bool? {
        if let m = asMap(value), let o = bool(m["optional"]) { return o }
        return bool(siblings["optional"])
    }

    // MARK: - Value coercion

    static func asMap(_ any: Any?) -> [String: Any]? {
        if let m = any as? [String: Any] { return m }
        if let m = any as? [AnyHashable: Any] {
            var out: [String: Any] = [:]
            for (k, v) in m { out[String(describing: k)] = v }
            return out
        }
        return nil
    }

    static func stringList(_ any: Any?) -> [String] {
        if let list = any as? [Any] { return list.compactMap { str($0) } }
        if let s = str(any) { return [s] }
        return []
    }

    static func stringMap(_ any: Any?) -> [String: String] {
        guard let map = asMap(any) else { return [:] }
        var out: [String: String] = [:]
        for (k, v) in map { if let s = str(v) { out[k] = s } }
        return out
    }

    static func scalarMap(_ any: Any?) -> [String: ScalarValue] {
        guard let map = asMap(any) else { return [:] }
        var out: [String: ScalarValue] = [:]
        for (k, v) in map { if let sv = scalar(v) { out[k] = sv } }
        return out
    }

    static func scalar(_ any: Any?) -> ScalarValue? {
        if let b = any as? Bool { return .bool(b) }
        if let i = any as? Int { return .int(i) }
        if let d = any as? Double { return .double(d) }
        if let s = any as? String { return .string(s) }
        return nil
    }

    static func str(_ any: Any?) -> String? {
        if let s = any as? String { return s }
        if let b = any as? Bool { return b ? "true" : "false" }
        if let i = any as? Int { return String(i) }
        if let d = any as? Double { return String(d) }
        return nil
    }

    static func int(_ any: Any?) -> Int? {
        if any is Bool { return nil }
        if let i = any as? Int { return i }
        if let d = any as? Double, d == d.rounded() { return Int(d) }
        if let s = any as? String { return Int(s) }
        return nil
    }

    static func dbl(_ any: Any?) -> Double? {
        if any is Bool { return nil }
        if let d = any as? Double { return d }
        if let i = any as? Int { return Double(i) }
        if let s = any as? String { return Double(s) }
        return nil
    }

    static func bool(_ any: Any?) -> Bool? {
        if let b = any as? Bool { return b }
        if let s = any as? String {
            switch s.lowercased() {
            case "true", "yes": return true
            case "false", "no": return false
            default: return nil
            }
        }
        return nil
    }
}
