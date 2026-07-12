// Port of: drivers/appium (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import SwiftMaestroFlow
import SwiftMaestroDriver
import SwiftMaestroWDA

/// Portable Android/iOS Appium backend for local hubs and HTTPS cloud grids.
/// The same W3C client drives both platforms; page source is normalized through
/// the existing Android or iOS hierarchy parser so the shared element finder is
/// unchanged.
public actor AppiumDriver: Driver {
    public nonisolated let platform: Platform

    private let client: AppiumClient
    private let capabilities: AppiumCapabilities
    private let platformName: String
    private let launchAppId: String?
    private var sessionId: String?
    private var recordingPath: String?

    public init(client: AppiumClient,
                capabilities: AppiumCapabilities,
                platform: Platform,
                appId: String? = nil) throws {
        guard platform == .android || platform == .ios else {
            throw DriverError.notSupported("Appium supports Android and iOS targets")
        }
        self.client = client
        self.capabilities = capabilities
        self.platform = platform
        platformName = platform == .ios ? "iOS" : "Android"
        launchAppId = appId
    }

    public func setUp() async throws {
        sessionId = try await client.createSession(capabilities: capabilities)
    }

    public func tearDown() async throws {
        if let sessionId { try? await client.deleteSession(sessionId) }
        sessionId = nil
    }

    public func installApp(_ path: String) async throws {
        try await client.installApp(sessionId: try requireSession(), appPath: path)
    }

    public func launchApp(_ appId: String, arguments: [String: String]) async throws {
        let identifier = appId.isEmpty ? (launchAppId ?? "") : appId
        guard !identifier.isEmpty else { throw DriverError.toolFailure("launchApp requires an app id") }
        try await client.activateApp(sessionId: try requireSession(), appId: identifier,
                                     platformName: platformName)
    }

    public func stopApp(_ appId: String) async throws {
        let identifier = appId.isEmpty ? (launchAppId ?? "") : appId
        guard !identifier.isEmpty else { throw DriverError.toolFailure("stopApp requires an app id") }
        try await client.terminateApp(sessionId: try requireSession(), appId: identifier,
                                      platformName: platformName)
    }

    public func clearState(_ appId: String) async throws {
        guard platform == .android else {
            throw DriverError.notSupported("clearState on iOS Appium (lands in parity polish)")
        }
        let identifier = appId.isEmpty ? (launchAppId ?? "") : appId
        guard !identifier.isEmpty else { throw DriverError.toolFailure("clearState requires an app id") }
        try await client.clearApp(sessionId: try requireSession(), appId: identifier)
    }

    public func viewHierarchy() async throws -> ViewHierarchy {
        let source = try await client.source(sessionId: try requireSession())
        switch platform {
        case .android: return try AndroidHierarchyParser.parse(xml: source)
        case .ios: return try IOSHierarchyParser.parse(xml: source)
        case .web: throw DriverError.notSupported("web hierarchy through Appium")
        }
    }

    public func tap(_ point: Point) async throws {
        try await client.tap(sessionId: try requireSession(), x: point.x, y: point.y)
    }

    public func longPress(_ point: Point) async throws {
        try await client.longPress(sessionId: try requireSession(), x: point.x, y: point.y, durationMs: 800)
    }

    public func inputText(_ text: String) async throws {
        try await client.inputText(sessionId: try requireSession(), text: text)
    }

    public func eraseText(_ count: Int) async throws {
        guard count > 0 else { return }
        if platform == .android {
            for _ in 0..<count { try await client.pressAndroidKey(sessionId: try requireSession(), keyCode: 67) }
        } else {
            try await client.inputText(sessionId: try requireSession(), text: String(repeating: "\u{8}", count: count))
        }
    }

    public func swipe(from: Point, to: Point, durationMs: Int) async throws {
        try await client.swipe(sessionId: try requireSession(),
                               from: (from.x, from.y), to: (to.x, to.y), durationMs: durationMs)
    }

    public func scroll(_ direction: Direction) async throws {
        try await client.scroll(sessionId: try requireSession(), direction: direction.rawValue)
    }

    public func pressKey(_ key: DeviceKey) async throws {
        let session = try requireSession()
        if platform == .android {
            try await client.pressAndroidKey(sessionId: session, keyCode: Self.androidKeyCode(key))
            return
        }
        switch key {
        case .home: try await client.pressIOSButton(sessionId: session, name: "home")
        case .volumeUp: try await client.pressIOSButton(sessionId: session, name: "volumeUp")
        case .volumeDown: try await client.pressIOSButton(sessionId: session, name: "volumeDown")
        case .enter: try await client.inputText(sessionId: session, text: "\n")
        case .tab: try await client.inputText(sessionId: session, text: "\t")
        case .backspace: try await client.inputText(sessionId: session, text: "\u{8}")
        default: throw DriverError.notSupported("pressKey(\(key)) on iOS Appium")
        }
    }

    public func openLink(_ url: String) async throws {
        try await client.openURL(sessionId: try requireSession(), url: url)
    }

    public func clearKeychain() async throws {
        if platform == .ios { try await client.clearKeychains(sessionId: try requireSession()) }
    }

    public func hideKeyboard() async throws {
        try await client.hideKeyboard(sessionId: try requireSession())
    }

    public func addMedia(_ paths: [String]) async throws {
        let session = try requireSession()
        for path in paths {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let name = (path as NSString).lastPathComponent
            let remote = platform == .ios
                ? "@com.apple.mobileslideshow:documents/\(name)"
                : "/sdcard/Download/\(name)"
            try await client.pushFile(sessionId: session, remotePath: remote, data: data)
        }
    }

    public func screenshot() async throws -> Data {
        try await client.screenshot(sessionId: try requireSession())
    }

    public func startRecording(_ path: String) async throws {
        try await client.startRecordingScreen(sessionId: try requireSession())
        recordingPath = path
    }

    public func stopRecording() async throws {
        guard var path = recordingPath else {
            throw DriverError.toolFailure("stopRecording called before startRecording")
        }
        let data = try await client.stopRecordingScreen(sessionId: try requireSession())
        if (path as NSString).pathExtension.isEmpty { path += ".mp4" }
        let url = URL(fileURLWithPath: path)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                withIntermediateDirectories: true)
        try data.write(to: url, options: [])
        recordingPath = nil
    }

    public func setLocation(latitude: Double, longitude: Double) async throws {
        try await client.setLocation(sessionId: try requireSession(), latitude: latitude, longitude: longitude)
    }

    private func requireSession() throws -> String {
        guard let sessionId else { throw AppiumError.missingSession }
        return sessionId
    }

    static func androidKeyCode(_ key: DeviceKey) -> Int {
        switch key {
        case .home: return 3
        case .back: return 4
        case .enter: return 66
        case .backspace: return 67
        case .tab: return 61
        case .lock, .power: return 26
        case .volumeUp: return 24
        case .volumeDown: return 25
        case .remoteUp: return 19
        case .remoteDown: return 20
        case .remoteLeft: return 21
        case .remoteRight: return 22
        case .remoteCenter: return 23
        case .other: return 0
        }
    }
}
