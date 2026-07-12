import Foundation
import SwiftMaestroDriver
import SwiftMaestroFlow

/// A hermetic `Driver` for executor/runner tests: records every action and
/// returns a canned view hierarchy. No real device, adb, or HTTP involved.
actor MockDriver: Driver {
    nonisolated var platform: Platform { .android }

    private var hierarchy: ViewHierarchy
    private(set) var actions: [String] = []
    private let onLaunch: (@Sendable () async -> Void)?
    private let failSetUp: Bool
    private let failInstall: Bool

    init(hierarchy: ViewHierarchy = MockDriver.sampleHierarchy(),
         onLaunch: (@Sendable () async -> Void)? = nil,
         failSetUp: Bool = false,
         failInstall: Bool = false) {
        self.hierarchy = hierarchy
        self.onLaunch = onLaunch
        self.failSetUp = failSetUp
        self.failInstall = failInstall
    }

    func setHierarchy(_ hierarchy: ViewHierarchy) { self.hierarchy = hierarchy }
    private func record(_ action: String) { actions.append(action) }

    func setUp() async throws {
        record("setUp")
        if failSetUp { throw DriverError.toolFailure("injected setup failure") }
    }
    func tearDown() async throws { record("tearDown") }
    func installApp(_ path: String) async throws {
        record("installApp(\(path))")
        if failInstall { throw DriverError.toolFailure("injected install failure") }
    }
    func launchApp(_ appId: String, arguments: [String: String]) async throws {
        record("launchApp(\(appId))")
        if let onLaunch { await onLaunch() }
    }
    func stopApp(_ appId: String) async throws { record("stopApp(\(appId))") }
    func clearState(_ appId: String) async throws { record("clearState(\(appId))") }
    func viewHierarchy() async throws -> ViewHierarchy { record("viewHierarchy"); return hierarchy }
    func waitForIdle(timeoutMs: Int) async throws { record("waitForIdle(\(timeoutMs))") }
    func tap(_ point: Point) async throws { record("tap(\(point.x),\(point.y))") }
    func longPress(_ point: Point) async throws { record("longPress(\(point.x),\(point.y))") }
    func inputText(_ text: String) async throws { record("inputText(\(text))") }
    func eraseText(_ count: Int) async throws { record("eraseText(\(count))") }
    func swipe(from: Point, to: Point, durationMs: Int) async throws {
        record("swipe(\(from.x),\(from.y)->\(to.x),\(to.y))")
    }
    func scroll(_ direction: Direction) async throws { record("scroll(\(direction.rawValue))") }
    func pressKey(_ key: DeviceKey) async throws { record("pressKey(\(key))") }
    func openLink(_ url: String) async throws { record("openLink(\(url))") }
    func clearKeychain() async throws { record("clearKeychain") }
    func hideKeyboard() async throws { record("hideKeyboard") }
    func addMedia(_ paths: [String]) async throws { record("addMedia(\(paths.joined(separator: ",")))") }
    func screenshot() async throws -> Data { record("screenshot"); return Data([0x89, 0x50, 0x4E, 0x47]) }
    func startRecording(_ path: String) async throws { throw DriverError.notSupported("startRecording") }
    func stopRecording() async throws { throw DriverError.notSupported("stopRecording") }
    func setLocation(latitude: Double, longitude: Double) async throws {
        record("setLocation(\(latitude),\(longitude))")
    }

    /// A small login-screen hierarchy: a clickable "Login" button and "Welcome".
    static func sampleHierarchy() -> ViewHierarchy {
        ViewHierarchy(
            root: ViewNode(
                className: "FrameLayout",
                bounds: Bounds(x: 0, y: 0, width: 1080, height: 1920),
                children: [
                    ViewNode(text: "Welcome", bounds: Bounds(x: 40, y: 100, width: 300, height: 60)),
                    ViewNode(text: "Login", resourceId: "com.example:id/login",
                             bounds: Bounds(x: 400, y: 500, width: 280, height: 90), clickable: true),
                ]
            ),
            platform: .android
        )
    }
}
