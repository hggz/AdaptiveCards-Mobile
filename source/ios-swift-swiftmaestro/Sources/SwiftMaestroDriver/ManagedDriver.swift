// Port of: pkg/emulator + pkg/driver (managed lifecycle)
// (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import SwiftMaestroFlow

/// Lifecycle paired with a driver (an emulator, local Appium server, etc.).
public protocol DriverLifecycle: Sendable {
    func start() async throws
    func stop() async
}

/// Driver decorator that starts host infrastructure before backend setup and
/// guarantees best-effort shutdown after teardown or a setup failure.
public actor ManagedDriver: Driver {
    public nonisolated let platform: Platform
    private let base: any Driver
    private let lifecycle: any DriverLifecycle

    public init(base: any Driver, lifecycle: any DriverLifecycle) {
        self.base = base
        self.lifecycle = lifecycle
        platform = base.platform
    }

    public func setUp() async throws {
        try await lifecycle.start()
        do { try await base.setUp() }
        catch { await lifecycle.stop(); throw error }
    }

    public func tearDown() async throws {
        try? await base.tearDown()
        await lifecycle.stop()
    }

    public func installApp(_ path: String) async throws { try await base.installApp(path) }
    public func launchApp(_ appId: String, arguments: [String: String]) async throws {
        try await base.launchApp(appId, arguments: arguments)
    }
    public func stopApp(_ appId: String) async throws { try await base.stopApp(appId) }
    public func clearState(_ appId: String) async throws { try await base.clearState(appId) }
    public func viewHierarchy() async throws -> ViewHierarchy { try await base.viewHierarchy() }
    public func nativeBounds(for selector: Selector) async throws -> Bounds? {
        try await base.nativeBounds(for: selector)
    }
    public func nativeText(for selector: Selector) async throws -> String? {
        try await base.nativeText(for: selector)
    }
    public func waitForIdle(timeoutMs: Int) async throws { try await base.waitForIdle(timeoutMs: timeoutMs) }
    public func tap(_ point: Point) async throws { try await base.tap(point) }
    public func longPress(_ point: Point) async throws { try await base.longPress(point) }
    public func inputText(_ text: String) async throws { try await base.inputText(text) }
    public func eraseText(_ count: Int) async throws { try await base.eraseText(count) }
    public func swipe(from: Point, to: Point, durationMs: Int) async throws {
        try await base.swipe(from: from, to: to, durationMs: durationMs)
    }
    public func scroll(_ direction: Direction) async throws { try await base.scroll(direction) }
    public func pressKey(_ key: DeviceKey) async throws { try await base.pressKey(key) }
    public func openLink(_ url: String) async throws { try await base.openLink(url) }
    public func clearKeychain() async throws { try await base.clearKeychain() }
    public func hideKeyboard() async throws { try await base.hideKeyboard() }
    public func addMedia(_ paths: [String]) async throws { try await base.addMedia(paths) }
    public func screenshot() async throws -> Data { try await base.screenshot() }
    public func startRecording(_ path: String) async throws { try await base.startRecording(path) }
    public func stopRecording() async throws { try await base.stopRecording() }
    public func setLocation(latitude: Double, longitude: Double) async throws {
        try await base.setLocation(latitude: latitude, longitude: longitude)
    }
}
