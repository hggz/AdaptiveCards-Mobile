// Port of: drivers/wda (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import SwiftMaestroFlow
import SwiftMaestroDriver

/// iOS backend driven through WebDriverAgent's portable HTTP API. The HTTP half
/// runs on every host; optional `WDAHostTooling` prepares xcrun/simctl/xcodebuild
/// and therefore runtime-gates to macOS. Tests pass mock HTTP + mock tooling on
/// Windows/Linux without any Apple framework or Xcode dependency.
public actor WDADriver: Driver {
    public nonisolated var platform: Platform { .ios }

    private let client: WDAClient
    private let tooling: (any WDAHostTooling)?
    private let launchBundleId: String?
    private let startupAttempts: Int
    private let startupIntervalMs: Int
    private var sessionId: String?

    public init(client: WDAClient,
                tooling: (any WDAHostTooling)? = nil,
                bundleId: String? = nil,
                startupAttempts: Int = 50,
                startupIntervalMs: Int = 200) {
        self.client = client
        self.tooling = tooling
        self.launchBundleId = bundleId
        self.startupAttempts = max(1, startupAttempts)
        self.startupIntervalMs = max(0, startupIntervalMs)
    }

    // MARK: - Session lifecycle

    public func setUp() async throws {
        do {
            if let tooling { try await tooling.prepare() }

            var ready = false
            var lastError: Error?
            for attempt in 0..<startupAttempts {
                do {
                    if try await client.status() { ready = true; break }
                } catch {
                    lastError = error
                }
                if attempt + 1 < startupAttempts { await wdaNap(milliseconds: startupIntervalMs) }
            }
            guard ready else {
                let suffix = lastError.map { ": \($0)" } ?? ""
                throw DriverError.toolFailure("WebDriverAgent is not ready\(suffix)")
            }
            sessionId = try await client.createSession(bundleId: launchBundleId)
        } catch {
            sessionId = nil
            if let tooling { await tooling.tearDown() }
            throw error
        }
    }

    public func tearDown() async throws {
        if let sessionId { try? await client.deleteSession(sessionId) }
        sessionId = nil
        if let tooling { await tooling.tearDown() }
    }

    // MARK: - App lifecycle

    public func installApp(_ path: String) async throws {
        guard let tooling else {
            throw DriverError.notSupported("installApp via remote WDA requires macOS host tooling")
        }
        try await tooling.installApp(path)
    }

    public func launchApp(_ appId: String, arguments: [String: String]) async throws {
        let bundleId = appId.isEmpty ? (launchBundleId ?? "") : appId
        guard !bundleId.isEmpty else { throw DriverError.toolFailure("launchApp requires an iOS bundle id") }
        try await client.launchApp(sessionId: try requireSession(), bundleId: bundleId, environment: arguments)
    }

    public func stopApp(_ appId: String) async throws {
        let bundleId = appId.isEmpty ? (launchBundleId ?? "") : appId
        guard !bundleId.isEmpty else { throw DriverError.toolFailure("stopApp requires an iOS bundle id") }
        try await client.terminateApp(sessionId: try requireSession(), bundleId: bundleId)
    }

    public func clearState(_ appId: String) async throws {
        throw DriverError.notSupported("clearState on WDA (lands in the parity-polish phase)")
    }

    // MARK: - Introspection

    public func viewHierarchy() async throws -> ViewHierarchy {
        let xml = try await client.source(sessionId: try requireSession())
        return try IOSHierarchyParser.parse(xml: xml)
    }

    // MARK: - Gestures / input

    public func tap(_ point: Point) async throws {
        try await client.tap(sessionId: try requireSession(), x: point.x, y: point.y)
    }

    public func longPress(_ point: Point) async throws {
        try await client.touchAndHold(sessionId: try requireSession(), x: point.x, y: point.y,
                                      durationSeconds: 0.8)
    }

    public func inputText(_ text: String) async throws {
        try await client.inputText(sessionId: try requireSession(), text: text)
    }

    public func eraseText(_ count: Int) async throws {
        guard count > 0 else { return }
        try await client.inputText(sessionId: try requireSession(), text: String(repeating: "\u{8}", count: count))
    }

    public func swipe(from: Point, to: Point, durationMs: Int) async throws {
        try await client.drag(sessionId: try requireSession(),
                              fromX: from.x, fromY: from.y, toX: to.x, toY: to.y,
                              durationSeconds: Double(max(0, durationMs)) / 1000.0)
    }

    public func scroll(_ direction: Direction) async throws {
        try await client.scroll(sessionId: try requireSession(), direction: direction.rawValue)
    }

    public func pressKey(_ key: DeviceKey) async throws {
        let session = try requireSession()
        switch key {
        case .home:
            try await client.pressButton(sessionId: session, name: "home")
        case .volumeUp:
            try await client.pressButton(sessionId: session, name: "volumeUp")
        case .volumeDown:
            try await client.pressButton(sessionId: session, name: "volumeDown")
        case .enter:
            try await client.inputText(sessionId: session, text: "\n")
        case .tab:
            try await client.inputText(sessionId: session, text: "\t")
        case .backspace:
            try await client.inputText(sessionId: session, text: "\u{8}")
        default:
            throw DriverError.notSupported("pressKey(\(key)) on WDA")
        }
    }

    public func openLink(_ url: String) async throws {
        try await client.openURL(sessionId: try requireSession(), url: url)
    }

    public func clearKeychain() async throws {
        try await client.clearKeychains(sessionId: try requireSession())
    }

    public func hideKeyboard() async throws {
        try await client.dismissKeyboard(sessionId: try requireSession())
    }

    public func addMedia(_ paths: [String]) async throws {
        guard let tooling else { throw DriverError.notSupported("addMedia requires macOS host tooling") }
        try await tooling.addMedia(paths)
    }

    public func screenshot() async throws -> Data {
        try await client.screenshot(sessionId: try requireSession())
    }

    // MARK: - Deferred parity-polish commands

    public func startRecording(_ path: String) async throws {
        throw DriverError.notSupported("startRecording on WDA (lands in the parity-polish phase)")
    }

    public func stopRecording() async throws {
        throw DriverError.notSupported("stopRecording on WDA (lands in the parity-polish phase)")
    }

    public func setLocation(latitude: Double, longitude: Double) async throws {
        try await client.setLocation(sessionId: try requireSession(),
                                     latitude: latitude, longitude: longitude)
    }

    private func requireSession() throws -> String {
        guard let sessionId else { throw WDAError.missingSession }
        return sessionId
    }
}

/// GCD-backed wait: remains responsive on Windows even if Foundation.Process's
/// monitor is busy (the same discipline used by other process-backed drivers).
private func wdaNap(milliseconds: Int) async {
    guard milliseconds > 0 else { return }
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(milliseconds)) {
            continuation.resume()
        }
    }
}
