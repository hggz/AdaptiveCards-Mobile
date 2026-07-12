// Port of: drivers/devicelab (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import NIOCore
import NIOPosix
import SwiftMaestroFlow
import SwiftMaestroDriver
import SwiftMaestroProcess

/// The DeviceLab Android backend. Introspection, gestures, text input, and
/// screenshots go over a persistent WebSocket to the on-device DeviceLab server
/// (reached over an adb-forwarded port), which performs them natively — the
/// "~2x faster than UIAutomator2 HTTP" path. App lifecycle (install / launch /
/// stop / clear / open-link) still goes through `adb`.
///
/// The on-device server is a prebuilt artifact swiftmaestro connects to; it is not
/// part of this port (see docs/PROVENANCE.md).
public actor DeviceLabDriver: Driver {
    public nonisolated var platform: Platform { .android }

    private let adb: Adb
    private let client: DeviceLabClient
    private let launchAppId: String?
    private let ownedGroup: EventLoopGroup?

    /// Designated init. `ownedGroup` is shut down on `tearDown` when non-nil (the
    /// production factory owns one; tests pass their own group and keep ownership).
    public init(adb: Adb, client: DeviceLabClient, appId: String? = nil, ownedGroup: EventLoopGroup? = nil) {
        self.adb = adb
        self.client = client
        self.launchAppId = appId
        self.ownedGroup = ownedGroup
    }

    /// Production factory: builds a client (and the event-loop group it owns) from
    /// a WebSocket URL.
    public static func connecting(adb: Adb, webSocketURL: String, appId: String? = nil) -> DeviceLabDriver {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let client = DeviceLabClient(webSocketURL: webSocketURL, group: group)
        return DeviceLabDriver(adb: adb, client: client, appId: appId, ownedGroup: group)
    }

    // MARK: - Session lifecycle

    public func setUp() async throws {
        try await client.connect()
        _ = try? await client.send("ready") // best-effort readiness handshake
    }

    public func tearDown() async throws {
        await client.close()
        if let ownedGroup { try? await ownedGroup.shutdownGracefully() }
    }

    // MARK: - App lifecycle (adb)

    public func installApp(_ path: String) async throws { try await adb.installApp(path) }
    public func launchApp(_ appId: String, arguments: [String: String]) async throws { try await adb.launchApp(appId) }
    public func stopApp(_ appId: String) async throws { try await adb.forceStop(appId) }
    public func clearState(_ appId: String) async throws { try await adb.clearData(appId) }
    public func openLink(_ url: String) async throws { try await adb.openLink(url) }
    public func clearKeychain() async throws {} // Android has no iOS-style keychain.
    public func hideKeyboard() async throws { _ = try await client.send("hideKeyboard") }
    public func addMedia(_ paths: [String]) async throws { try await adb.addMedia(paths) }

    // MARK: - Introspection / gestures / input (WebSocket)

    public func viewHierarchy() async throws -> ViewHierarchy {
        let result = try await client.send("hierarchy")
        guard let root = result["root"] else {
            throw DeviceLabError.protocolError("hierarchy: response missing 'root'")
        }
        let data = try JSONSerialization.data(withJSONObject: root)
        let node = try JSONDecoder().decode(ViewNode.self, from: data)
        return ViewHierarchy(root: node, platform: .android)
    }

    public func tap(_ point: Point) async throws {
        _ = try await client.send("tap", params: ["x": point.x, "y": point.y])
    }

    public func longPress(_ point: Point) async throws {
        _ = try await client.send("longPress", params: ["x": point.x, "y": point.y, "durationMs": 800])
    }

    public func inputText(_ text: String) async throws {
        _ = try await client.send("inputText", params: ["text": text])
    }

    public func eraseText(_ count: Int) async throws {
        _ = try await client.send("eraseText", params: ["count": max(0, count)])
    }

    public func swipe(from: Point, to: Point, durationMs: Int) async throws {
        _ = try await client.send("swipe", params: ["x1": from.x, "y1": from.y,
                                                    "x2": to.x, "y2": to.y, "durationMs": durationMs])
    }

    public func scroll(_ direction: Direction) async throws {
        _ = try await client.send("scroll", params: ["direction": direction.rawValue])
    }

    public func pressKey(_ key: DeviceKey) async throws {
        _ = try await client.send("pressKey", params: ["keyCode": Self.keyCode(key)])
    }

    public func screenshot() async throws -> Data {
        let result = try await client.send("screenshot")
        guard let base64 = result["data"] as? String, let data = Data(base64Encoded: base64) else {
            throw DeviceLabError.protocolError("screenshot: response missing 'data'")
        }
        return data
    }

    // MARK: - Not yet ported (Phase 11)

    public func startRecording(_ path: String) async throws {
        throw DriverError.notSupported("startRecording on DeviceLab (later phase)")
    }
    public func stopRecording() async throws {
        throw DriverError.notSupported("stopRecording on DeviceLab (later phase)")
    }
    public func setLocation(latitude: Double, longitude: Double) async throws {
        _ = try await client.send("setLocation", params: [
            "latitude": latitude, "longitude": longitude,
        ])
    }

    // MARK: - Helpers

    /// Android `KEYCODE_*` numeric value for a `DeviceKey`. Unknown keys map to
    /// `KEYCODE_UNKNOWN` (0).
    static func keyCode(_ key: DeviceKey) -> Int {
        switch key {
        case .home: return 3
        case .back: return 4
        case .enter: return 66
        case .backspace: return 67
        case .tab: return 61
        case .lock: return 26
        case .power: return 26
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
