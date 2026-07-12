// Port of: drivers/uiautomator2 (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import SwiftMaestroFlow
import SwiftMaestroProcess

/// The default Android driver. App lifecycle and coordinate gestures go through
/// `adb`; hierarchy and Unicode-safe text input use the on-device HTTP server
/// (reached via an adb-forwarded port) and parsed into a normalized
/// `ViewHierarchy`.
///
/// The on-device server is a prebuilt Apache-2.0 artifact swiftmaestro installs
/// and speaks to; it is not part of this port (see docs/PROVENANCE.md).
public actor UIAutomator2Driver: Driver {
    public nonisolated var platform: Platform { .android }

    private let adb: Adb
    private let client: UIAutomator2Client
    private let launchAppId: String?
    private var sessionId: String?

    public init(adb: Adb, client: UIAutomator2Client, appId: String? = nil) {
        self.adb = adb
        self.client = client
        self.launchAppId = appId
    }

    // MARK: - Session lifecycle

    public func setUp() async throws {
        guard try await client.status() else {
            throw DriverError.toolFailure("UIAutomator2 server is not ready")
        }
        sessionId = try await client.createSession(appId: launchAppId)
    }

    public func tearDown() async throws {
        if let sessionId { try? await client.deleteSession(sessionId) }
        sessionId = nil
    }

    // MARK: - App lifecycle (adb)

    public func installApp(_ path: String) async throws { try await adb.installApp(path) }
    public func launchApp(_ appId: String, arguments: [String: String]) async throws { try await adb.launchApp(appId) }
    public func stopApp(_ appId: String) async throws { try await adb.forceStop(appId) }
    public func clearState(_ appId: String) async throws { try await adb.clearData(appId) }

    // MARK: - Introspection (HTTP)

    public func viewHierarchy() async throws -> ViewHierarchy {
        let xml = try await client.source(sessionId: requireSession())
        return try AndroidHierarchyParser.parse(xml: xml)
    }

    // MARK: - Gestures / input (adb)

    public func tap(_ point: Point) async throws { try await adb.inputTap(x: point.x, y: point.y) }

    public func longPress(_ point: Point) async throws {
        try await adb.inputSwipe(x1: point.x, y1: point.y, x2: point.x, y2: point.y, durationMs: 800)
    }

    public func inputText(_ text: String) async throws {
        try await client.inputText(sessionId: requireSession(), text: text)
    }

    public func eraseText(_ count: Int) async throws {
        for _ in 0..<max(0, count) { try await adb.keyEvent("67") } // KEYCODE_DEL
    }

    public func swipe(from: Point, to: Point, durationMs: Int) async throws {
        try await adb.inputSwipe(x1: from.x, y1: from.y, x2: to.x, y2: to.y, durationMs: durationMs)
    }

    public func scroll(_ direction: Direction) async throws {
        let (from, to) = Self.scrollGesture(direction)
        try await adb.inputSwipe(x1: from.x, y1: from.y, x2: to.x, y2: to.y, durationMs: 300)
    }

    public func pressKey(_ key: DeviceKey) async throws { try await adb.keyEvent(Self.keyEventArg(key)) }

    public func openLink(_ url: String) async throws { try await adb.openLink(url) }
    public func clearKeychain() async throws {} // Android has no iOS-style keychain.
    public func hideKeyboard() async throws { try await adb.keyEvent("111") } // KEYCODE_ESCAPE
    public func addMedia(_ paths: [String]) async throws { try await adb.addMedia(paths) }

    public func screenshot() async throws -> Data { try await adb.screencap() }

    // MARK: - Not yet ported (Phase 11)

    public func startRecording(_ path: String) async throws {
        throw DriverError.notSupported("startRecording (lands in a later phase)")
    }
    public func stopRecording() async throws {
        throw DriverError.notSupported("stopRecording (lands in a later phase)")
    }
    public func setLocation(latitude: Double, longitude: Double) async throws {
        try await adb.setLocation(latitude: latitude, longitude: longitude)
    }

    // MARK: - Helpers

    private func requireSession() throws -> String {
        guard let sessionId else {
            throw DriverError.toolFailure("no active session; call setUp() first")
        }
        return sessionId
    }

    /// Android KEYCODE argument for `adb shell input keyevent`. Unknown keys pass
    /// through verbatim (adb accepts `KEYCODE_*` names as well as numbers).
    static func keyEventArg(_ key: DeviceKey) -> String {
        switch key {
        case .home: return "3"
        case .back: return "4"
        case .enter: return "66"
        case .backspace: return "67"
        case .tab: return "61"
        case .lock: return "26"      // KEYCODE_POWER locks the screen
        case .volumeUp: return "24"
        case .volumeDown: return "25"
        case .power: return "26"
        case .remoteUp: return "19"
        case .remoteDown: return "20"
        case .remoteLeft: return "21"
        case .remoteRight: return "22"
        case .remoteCenter: return "23"
        case .other(let name): return name
        }
    }

    /// Nominal swipe endpoints for a scroll in a direction. Refined to real
    /// screen bounds in a later phase.
    static func scrollGesture(_ direction: Direction) -> (from: Point, to: Point) {
        switch direction {
        case .down: return (Point(x: 540, y: 1400), Point(x: 540, y: 600))
        case .up: return (Point(x: 540, y: 600), Point(x: 540, y: 1400))
        case .left: return (Point(x: 800, y: 900), Point(x: 200, y: 900))
        case .right: return (Point(x: 200, y: 900), Point(x: 800, y: 900))
        }
    }
}
