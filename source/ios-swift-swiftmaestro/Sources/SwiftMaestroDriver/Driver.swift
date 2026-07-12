// Port of: pkg/driver (contract) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import SwiftMaestroFlow

/// Errors surfaced by a driver. `elementNotFound` renders the Maestro-style
/// message the CLI prints (e.g. `element not found: text="Login"`).
public enum DriverError: Error, Sendable, Equatable, CustomStringConvertible {
    case elementNotFound(String)
    case notSupported(String)
    case toolFailure(String)
    case timedOut(String)

    public var description: String {
        switch self {
        case .elementNotFound(let s): return "element not found: \(s)"
        case .notSupported(let s): return "not supported: \(s)"
        case .toolFailure(let s): return "tool failure: \(s)"
        case .timedOut(let s): return "timed out: \(s)"
        }
    }
}

/// The single contract every backend implements (UIAutomator2, DeviceLab, WDA,
/// Browser/CDP, Appium). A new backend is a new conformance and nothing else;
/// higher layers (executor, element finder) are written against this protocol.
///
/// Concrete conformances arrive in later phases; Phase 2 defines the contract and
/// the `ViewHierarchy` the finder matches against.
public protocol Driver: Sendable {
    var platform: Platform { get }

    func setUp() async throws
    func tearDown() async throws

    func installApp(_ path: String) async throws
    func launchApp(_ appId: String, arguments: [String: String]) async throws
    func stopApp(_ appId: String) async throws
    func clearState(_ appId: String) async throws

    /// The current UI tree, normalized for the element finder.
    func viewHierarchy() async throws -> ViewHierarchy

    /// Optional backend-native selector resolution. Browser/CDP uses this for
    /// CSS/XPath; other drivers may return nil and use the normalized hierarchy.
    func nativeBounds(for selector: Selector) async throws -> Bounds?
    func nativeText(for selector: Selector) async throws -> String?

    /// Wait for backend quiescence. `timeoutMs == 0` disables the wait.
    func waitForIdle(timeoutMs: Int) async throws

    func tap(_ point: Point) async throws
    func longPress(_ point: Point) async throws
    func inputText(_ text: String) async throws
    func eraseText(_ count: Int) async throws
    func swipe(from: Point, to: Point, durationMs: Int) async throws
    func scroll(_ direction: Direction) async throws
    func pressKey(_ key: DeviceKey) async throws
    func openLink(_ url: String) async throws
    func clearKeychain() async throws
    func hideKeyboard() async throws
    func addMedia(_ paths: [String]) async throws

    func screenshot() async throws -> Data
    func startRecording(_ path: String) async throws
    func stopRecording() async throws

    func setLocation(latitude: Double, longitude: Double) async throws
}

public extension Driver {
    func nativeBounds(for selector: Selector) async throws -> Bounds? { nil }
    func nativeText(for selector: Selector) async throws -> String? { nil }
    func waitForIdle(timeoutMs: Int) async throws {}
    func clearKeychain() async throws { throw DriverError.notSupported("clearKeychain") }
    func hideKeyboard() async throws { throw DriverError.notSupported("hideKeyboard") }
    func addMedia(_ paths: [String]) async throws { throw DriverError.notSupported("addMedia") }
}
