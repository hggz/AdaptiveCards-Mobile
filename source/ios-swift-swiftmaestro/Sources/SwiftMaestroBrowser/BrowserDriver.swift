// Port of: drivers/cdp (browser driver) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import NIOCore
import NIOPosix
import SwiftMaestroFlow
import SwiftMaestroDriver
import SwiftMaestroProcess

/// The Web backend: drives a headless Chromium-family browser over the Chrome
/// DevTools Protocol. App-lifecycle maps to navigation, gestures map to CDP
/// `Input.*` events, and the view hierarchy is a JS DOM snapshot — so the shared
/// element finder and flow executor work against web pages unchanged.
public actor BrowserDriver: Driver {
    public nonisolated var platform: Platform { .web }

    /// Where the CDP endpoint comes from: launch a browser we own, or attach to an
    /// already-running one (used by the hermetic mock and remote browsers).
    public enum Endpoint: Sendable {
        case launch(BrowserLaunchConfig)
        case attach(browserWebSocketURL: String)
    }

    private let endpoint: Endpoint
    private let launcher: BrowserLauncher
    private let group: EventLoopGroup
    private let ownsGroup: Bool

    private var launched: LaunchedProcess?
    private var connection: CDPConnection?
    private var sessionId: String?
    private var targetId: String?

    public init(endpoint: Endpoint,
                launcher: BrowserLauncher = BrowserLauncher(),
                group: EventLoopGroup? = nil) {
        self.endpoint = endpoint
        self.launcher = launcher
        if let group {
            self.group = group
            self.ownsGroup = false
        } else {
            self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            self.ownsGroup = true
        }
    }

    // MARK: - Session lifecycle

    public func setUp() async throws {
        let browserWebSocketURL: String
        switch endpoint {
        case .launch(let config):
            let launchedEndpoint = try await launcher.launch(config)
            self.launched = launchedEndpoint.process
            browserWebSocketURL = launchedEndpoint.browserWebSocketURL
        case .attach(let url):
            browserWebSocketURL = url
        }

        let connection = CDPConnection(webSocketURL: browserWebSocketURL, group: group)
        try await connection.connect()
        self.connection = connection

        // Create a page target and attach in flat mode (all commands over the one
        // socket, routed by sessionId).
        let created = try await connection.send("Target.createTarget", params: ["url": "about:blank"])
        guard let targetId = created["targetId"] as? String else {
            throw CDPError.protocolError("Target.createTarget returned no targetId")
        }
        self.targetId = targetId

        let attached = try await connection.send("Target.attachToTarget",
                                                 params: ["targetId": targetId, "flatten": true])
        guard let sessionId = attached["sessionId"] as? String else {
            throw CDPError.protocolError("Target.attachToTarget returned no sessionId")
        }
        self.sessionId = sessionId

        // Enable the domains we drive. Best-effort — a browser that does not
        // support one should not abort setup.
        _ = try? await connection.send("Page.enable", sessionId: sessionId)
        _ = try? await connection.send("Runtime.enable", sessionId: sessionId)
        _ = try? await connection.send("DOM.enable", sessionId: sessionId)
    }

    public func tearDown() async throws {
        if let connection {
            if case .launch = endpoint {
                // Ask the real browser to quit. Fire-and-forget: it exits without
                // replying, and on Windows it is detached from the launcher stub we
                // spawned, so a CDP shutdown is the reliable way to stop it.
                await connection.sendNoWait("Browser.close")
                await cdpNap(ms: 150)
            } else if let targetId {
                _ = try? await connection.send("Target.closeTarget", params: ["targetId": targetId])
            }
            await connection.close()
        }
        connection = nil
        sessionId = nil
        targetId = nil
        launched?.terminate()
        launched = nil
        if ownsGroup { try? await group.shutdownGracefully() }
    }

    // MARK: - App lifecycle (navigation)

    public func installApp(_ path: String) async throws {
        // The web has no install step; a web "app" is just a URL. No-op so a run
        // that happens to carry --app-file does not fail on web.
    }

    public func launchApp(_ appId: String, arguments: [String: String]) async throws {
        if Self.looksLikeURL(appId) { try await navigate(appId) }
    }

    public func stopApp(_ appId: String) async throws {
        try await navigate("about:blank")
    }

    public func clearState(_ appId: String) async throws {
        let (connection, sessionId) = try require()
        _ = try? await connection.send("Network.enable", sessionId: sessionId)
        _ = try? await connection.send("Network.clearBrowserCookies", sessionId: sessionId)
        _ = try? await evaluate("try { localStorage.clear(); sessionStorage.clear(); } catch (e) {}")
    }

    // MARK: - Introspection

    public func viewHierarchy() async throws -> ViewHierarchy {
        let result = try await evaluate(WebHierarchy.domSnapshotExpression)
        return try WebHierarchy.decodeHierarchy(fromEvaluateResult: result)
    }

    public func nativeBounds(for selector: Selector) async throws -> Bounds? {
        let kind: String
        let query: String
        if let css = selector.css { kind = "css"; query = css }
        else if let xpath = selector.xpath { kind = "xpath"; query = xpath }
        else { return nil }

        let expression = """
        /*__swiftmaestro_query__*/(function () {
          var kind = \(Self.jsonString(kind));
          var query = \(Self.jsonString(query));
          var el = kind === 'css'
            ? document.querySelector(query)
            : document.evaluate(query, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
          if (!el || !el.getBoundingClientRect) return null;
          var r = el.getBoundingClientRect();
          var s = window.getComputedStyle ? getComputedStyle(el) : null;
          if (s && (s.display === 'none' || s.visibility === 'hidden')) return null;
          if (r.width <= 0 || r.height <= 0) return null;
          return {x: Math.round(r.left), y: Math.round(r.top),
                  width: Math.round(r.width), height: Math.round(r.height)};
        })()
        """
        let response = try await evaluate(expression)
        guard let result = response["result"] as? [String: Any],
              let value = result["value"] as? [String: Any],
              let x = Self.int(value["x"]), let y = Self.int(value["y"]),
              let width = Self.int(value["width"]), let height = Self.int(value["height"]) else {
            return nil
        }
        return Bounds(x: x, y: y, width: width, height: height)
    }

        public func nativeText(for selector: Selector) async throws -> String? {
                let kind: String
                let query: String
                if let css = selector.css { kind = "css"; query = css }
                else if let xpath = selector.xpath { kind = "xpath"; query = xpath }
                else { return nil }
                let expression = """
                (function () {
                    var kind = \(Self.jsonString(kind));
                    var query = \(Self.jsonString(query));
                    var el = kind === 'css' ? document.querySelector(query)
                        : document.evaluate(query, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
                    return el ? (el.value || el.textContent || '') : null;
                })()
                """
                let response = try await evaluate(expression)
                return (response["result"] as? [String: Any])?["value"] as? String
        }

    public func waitForIdle(timeoutMs: Int) async throws {
        guard timeoutMs > 0 else { return }
        let start = Date()
        repeat {
            if let result = try? await evaluate("document.readyState"),
               let inner = result["result"] as? [String: Any],
               let state = inner["value"] as? String,
               state == "complete" {
                return
            }
            await cdpNap(ms: 50)
        } while Date().timeIntervalSince(start) * 1000 < Double(timeoutMs)
        throw DriverError.timedOut("browser did not become idle after \(timeoutMs)ms")
    }

    // MARK: - Gestures / input

    public func tap(_ point: Point) async throws {
        try await mouse("mousePressed", point)
        try await mouse("mouseReleased", point)
    }

    public func longPress(_ point: Point) async throws {
        try await mouse("mousePressed", point)
        await cdpNap(ms: 700)
        try await mouse("mouseReleased", point)
    }

    public func inputText(_ text: String) async throws {
        let (connection, sessionId) = try require()
        _ = try await connection.send("Input.insertText", params: ["text": text], sessionId: sessionId)
    }

    public func eraseText(_ count: Int) async throws {
        for _ in 0..<max(0, count) {
            try await key("Backspace", code: 8)
        }
    }

    public func swipe(from: Point, to: Point, durationMs: Int) async throws {
        try await mouse("mousePressed", from)
        try await mouse("mouseMoved", to)
        try await mouse("mouseReleased", to)
    }

    public func scroll(_ direction: Direction) async throws {
        let (connection, sessionId) = try require()
        let delta: (x: Int, y: Int)
        switch direction {
        case .down: delta = (0, 600)
        case .up: delta = (0, -600)
        case .left: delta = (-600, 0)
        case .right: delta = (600, 0)
        }
        _ = try await connection.send("Input.dispatchMouseEvent",
                                      params: ["type": "mouseWheel", "x": 200, "y": 300,
                                               "deltaX": delta.x, "deltaY": delta.y],
                                      sessionId: sessionId)
    }

    public func pressKey(_ deviceKey: DeviceKey) async throws {
        switch deviceKey {
        case .enter: try await key("Enter", code: 13)
        case .backspace: try await key("Backspace", code: 8)
        case .tab: try await key("Tab", code: 9)
        case .back: _ = try await evaluate("history.back()")
        case .home: try await navigate("about:blank")
        default: throw DriverError.notSupported("pressKey(\(deviceKey)) on the web driver")
        }
    }

    public func openLink(_ url: String) async throws {
        try await navigate(url)
    }

    public func clearKeychain() async throws { try await clearState("") }
    public func hideKeyboard() async throws {} // No virtual keyboard contract on desktop web.

    // MARK: - Media / capture

    public func screenshot() async throws -> Data {
        let (connection, sessionId) = try require()
        let result = try await connection.send("Page.captureScreenshot",
                                               params: ["format": "png"], sessionId: sessionId)
        guard let base64 = result["data"] as? String, let data = Data(base64Encoded: base64) else {
            throw DriverError.toolFailure("Page.captureScreenshot returned no data")
        }
        return data
    }

    public func startRecording(_ path: String) async throws {
        throw DriverError.notSupported("startRecording on the web driver (later phase)")
    }

    public func stopRecording() async throws {
        throw DriverError.notSupported("stopRecording on the web driver (later phase)")
    }

    public func setLocation(latitude: Double, longitude: Double) async throws {
        let (connection, sessionId) = try require()
        _ = try await connection.send("Emulation.setGeolocationOverride",
                                      params: ["latitude": latitude, "longitude": longitude, "accuracy": 1],
                                      sessionId: sessionId)
    }

    // MARK: - Helpers

    private func require() throws -> (CDPConnection, String) {
        guard let connection, let sessionId else {
            throw DriverError.toolFailure("browser session not started; call setUp() first")
        }
        return (connection, sessionId)
    }

    @discardableResult
    private func evaluate(_ expression: String) async throws -> [String: Any] {
        let (connection, sessionId) = try require()
        return try await connection.send("Runtime.evaluate",
                                         params: ["expression": expression,
                                                  "returnByValue": true,
                                                  "awaitPromise": true],
                                         sessionId: sessionId)
    }

    private func navigate(_ url: String) async throws {
        let (connection, sessionId) = try require()
        _ = try await connection.send("Page.navigate", params: ["url": url], sessionId: sessionId)
        await waitForLoad()
    }

    private func waitForLoad() async {
        for _ in 0..<40 {
            if let result = try? await evaluate("document.readyState"),
               let inner = result["result"] as? [String: Any],
               let state = inner["value"] as? String, state == "complete" {
                return
            }
            await cdpNap(ms: 50)
        }
    }

    private func mouse(_ type: String, _ point: Point) async throws {
        let (connection, sessionId) = try require()
        _ = try await connection.send("Input.dispatchMouseEvent",
                                      params: ["type": type, "x": point.x, "y": point.y,
                                               "button": "left", "clickCount": 1],
                                      sessionId: sessionId)
    }

    private func key(_ name: String, code: Int) async throws {
        let (connection, sessionId) = try require()
        let base: [String: Any] = ["key": name, "windowsVirtualKeyCode": code, "nativeVirtualKeyCode": code]
        _ = try await connection.send("Input.dispatchKeyEvent",
                                      params: base.merging(["type": "keyDown"]) { _, new in new },
                                      sessionId: sessionId)
        _ = try await connection.send("Input.dispatchKeyEvent",
                                      params: base.merging(["type": "keyUp"]) { _, new in new },
                                      sessionId: sessionId)
    }

    private static func looksLikeURL(_ value: String) -> Bool {
        for prefix in ["http://", "https://", "about:", "file:", "data:"] where value.hasPrefix(prefix) {
            return true
        }
        return false
    }

    private static func jsonString(_ value: String) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: [value]),
              let encoded = String(data: data, encoding: .utf8) else { return "\"\"" }
        return String(encoded.dropFirst().dropLast())
    }

    private static func int(_ value: Any?) -> Int? {
        if let value = value as? Int { return value }
        if let value = value as? Double { return Int(value.rounded()) }
        if let value = value as? NSNumber { return value.intValue }
        return nil
    }
}
