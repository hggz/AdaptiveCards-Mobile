// Port of: drivers/appium (W3C HTTP client)
// (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import AsyncHTTPClient
import NIOCore
import NIOHTTP1
import NIOFoundationCompat

/// Portable Appium 2.x/3.x W3C client. Local loopback HTTP is allowed for a
/// developer-run Appium server; every non-loopback hub must use HTTPS. No
/// insecure TLS switch exists: async-http-client's certificate verification is
/// always left enabled.
public struct AppiumClient: Sendable {
    private let endpoint: AppiumEndpoint
    private let http: HTTPClient
    private let requestTimeout: TimeAmount

    public init(baseURL: String, http: HTTPClient = .shared, requestTimeoutMs: Int = 60_000) throws {
        endpoint = try AppiumEndpoint(baseURL)
        self.http = http
        requestTimeout = .milliseconds(Int64(requestTimeoutMs))
    }

    public var redactedBaseURL: String { endpoint.redactedURL }

    public func status() async throws -> Bool {
        let response = try await send(.GET, "/status")
        guard Self.isSuccess(response.status) else { return false }
        guard let object = Self.object(response.body) else { return true }
        if let value = object["value"] as? [String: Any], let ready = value["ready"] as? Bool {
            return ready
        }
        if let ready = object["ready"] as? Bool { return ready }
        return true
    }

    public func createSession(capabilities: AppiumCapabilities) async throws -> String {
        let payload: [String: Any] = [
            "capabilities": [
                "alwaysMatch": capabilities.anyObject,
                "firstMatch": [[:]],
            ],
        ]
        let path = "/session"
        let response = try await send(.POST, path, json: payload,
                                      additionalSecrets: capabilities.sensitiveValues)
        try requireSuccess(response, path: path, additionalSecrets: capabilities.sensitiveValues)
        guard let object = Self.object(response.body) else {
            throw AppiumError.invalidResponse("create session returned non-JSON")
        }
        if let sessionId = object["sessionId"] as? String { return sessionId }
        if let value = object["value"] as? [String: Any], let sessionId = value["sessionId"] as? String {
            return sessionId
        }
        throw AppiumError.invalidResponse("create session returned no sessionId")
    }

    public func deleteSession(_ sessionId: String) async throws {
        let path = "/session/\(sessionId)"
        let response = try await send(.DELETE, path)
        try requireSuccess(response, path: path)
    }

    public func source(sessionId: String) async throws -> String {
        let path = "/session/\(sessionId)/source"
        let response = try await send(.GET, path)
        try requireSuccess(response, path: path)
        if let object = Self.object(response.body), let value = object["value"] as? String { return value }
        return String(decoding: response.body, as: UTF8.self)
    }

    // MARK: - W3C actions / app lifecycle

    public func performActions(sessionId: String, actions: [[String: Any]]) async throws {
        try await command(sessionId, "/actions", ["actions": actions])
    }

    public func tap(sessionId: String, x: Int, y: Int) async throws {
        try await pointerGesture(sessionId: sessionId, actions: [
            ["type": "pointerMove", "duration": 0, "x": x, "y": y, "origin": "viewport"],
            ["type": "pointerDown", "button": 0],
            ["type": "pointerUp", "button": 0],
        ])
    }

    public func longPress(sessionId: String, x: Int, y: Int, durationMs: Int) async throws {
        try await pointerGesture(sessionId: sessionId, actions: [
            ["type": "pointerMove", "duration": 0, "x": x, "y": y, "origin": "viewport"],
            ["type": "pointerDown", "button": 0],
            ["type": "pause", "duration": max(0, durationMs)],
            ["type": "pointerUp", "button": 0],
        ])
    }

    public func swipe(sessionId: String, from: (Int, Int), to: (Int, Int), durationMs: Int) async throws {
        try await pointerGesture(sessionId: sessionId, actions: [
            ["type": "pointerMove", "duration": 0, "x": from.0, "y": from.1, "origin": "viewport"],
            ["type": "pointerDown", "button": 0],
            ["type": "pointerMove", "duration": max(0, durationMs), "x": to.0, "y": to.1,
             "origin": "viewport"],
            ["type": "pointerUp", "button": 0],
        ])
    }

    public func inputText(sessionId: String, text: String) async throws {
        try await command(sessionId, "/keys", ["value": [text], "text": text])
    }

    public func openURL(sessionId: String, url: String) async throws {
        try await command(sessionId, "/url", ["url": url])
    }

    public func setLocation(sessionId: String, latitude: Double, longitude: Double) async throws {
        try await command(sessionId, "/location", [
            "location": ["latitude": latitude, "longitude": longitude, "altitude": 0],
        ])
    }

    public func screenshot(sessionId: String) async throws -> Data {
        let path = "/session/\(sessionId)/screenshot"
        let response = try await send(.GET, path)
        try requireSuccess(response, path: path)
        guard let object = Self.object(response.body),
              let base64 = object["value"] as? String,
              let data = Data(base64Encoded: base64) else {
            throw AppiumError.invalidResponse("screenshot returned no base64 value")
        }
        return data
    }

    public func executeScript(sessionId: String, script: String, arguments: [[String: Any]]) async throws {
        try await command(sessionId, "/execute/sync", ["script": script, "args": arguments])
    }

    public func installApp(sessionId: String, appPath: String) async throws {
        try await executeScript(sessionId: sessionId, script: "mobile: installApp",
                                arguments: [["appPath": appPath]])
    }

    public func activateApp(sessionId: String, appId: String, platformName: String) async throws {
        let key = platformName.lowercased() == "ios" ? "bundleId" : "appId"
        try await executeScript(sessionId: sessionId, script: "mobile: activateApp",
                                arguments: [[key: appId]])
    }

    public func terminateApp(sessionId: String, appId: String, platformName: String) async throws {
        let key = platformName.lowercased() == "ios" ? "bundleId" : "appId"
        try await executeScript(sessionId: sessionId, script: "mobile: terminateApp",
                                arguments: [[key: appId]])
    }

    public func clearApp(sessionId: String, appId: String) async throws {
        try await executeScript(sessionId: sessionId, script: "mobile: clearApp",
                                arguments: [["appId": appId]])
    }

    public func scroll(sessionId: String, direction: String) async throws {
        try await executeScript(sessionId: sessionId, script: "mobile: scrollGesture",
                                arguments: [["direction": direction.lowercased(), "percent": 0.75]])
    }

    public func pressAndroidKey(sessionId: String, keyCode: Int) async throws {
        try await command(sessionId, "/appium/device/press_keycode", ["keycode": keyCode])
    }

    public func pressIOSButton(sessionId: String, name: String) async throws {
        try await executeScript(sessionId: sessionId, script: "mobile: pressButton",
                                arguments: [["name": name]])
    }

    public func hideKeyboard(sessionId: String) async throws {
        try await command(sessionId, "/appium/device/hide_keyboard", [:])
    }

    public func clearKeychains(sessionId: String) async throws {
        try await executeScript(sessionId: sessionId, script: "mobile: clearKeychains", arguments: [[:]])
    }

    public func pushFile(sessionId: String, remotePath: String, data: Data) async throws {
        try await command(sessionId, "/appium/device/push_file", [
            "path": remotePath, "data": data.base64EncodedString(),
        ])
    }

    public func startRecordingScreen(sessionId: String) async throws {
        try await command(sessionId, "/appium/start_recording_screen", ["options": [:]])
    }

    public func stopRecordingScreen(sessionId: String) async throws -> Data {
        let path = "/session/\(sessionId)/appium/stop_recording_screen"
        let response = try await send(.POST, path, json: ["options": [:]])
        try requireSuccess(response, path: path)
        guard let object = Self.object(response.body),
              let base64 = object["value"] as? String,
              let data = Data(base64Encoded: base64) else {
            throw AppiumError.invalidResponse("stop recording returned no base64 value")
        }
        return data
    }

    // MARK: - Transport

    private func pointerGesture(sessionId: String, actions: [[String: Any]]) async throws {
        try await performActions(sessionId: sessionId, actions: [[
            "type": "pointer",
            "id": "finger1",
            "parameters": ["pointerType": "touch"],
            "actions": actions,
        ]])
    }

    private func command(_ sessionId: String, _ suffix: String, _ payload: [String: Any]) async throws {
        let path = "/session/\(sessionId)\(suffix)"
        let response = try await send(.POST, path, json: payload)
        try requireSuccess(response, path: path)
    }

    private func send(_ method: HTTPMethod,
                      _ path: String,
                      json: [String: Any]? = nil,
                      additionalSecrets: [String] = []) async throws -> (status: UInt, body: Data) {
        var request = HTTPClientRequest(url: endpoint.requestBaseURL + path)
        request.method = method
        if let authorization = endpoint.authorization {
            request.headers.add(name: "Authorization", value: authorization)
        }
        if let json {
            let data = try JSONSerialization.data(withJSONObject: json)
            request.headers.add(name: "Content-Type", value: "application/json")
            request.body = .bytes(ByteBuffer(data: data))
        }
        do {
            let response = try await http.execute(request, timeout: requestTimeout)
            let buffer = try await response.body.collect(upTo: 16 * 1024 * 1024)
            return (UInt(response.status.code), Data(buffer: buffer))
        } catch {
            let message = AppiumRedactor.redact("\(error)",
                                                secrets: endpoint.secrets + additionalSecrets)
            throw AppiumError.transport(message)
        }
    }

    private func requireSuccess(_ response: (status: UInt, body: Data),
                                path: String,
                                additionalSecrets: [String] = []) throws {
        guard Self.isSuccess(response.status) else {
            var message = String(decoding: response.body, as: UTF8.self)
            if let object = Self.object(response.body),
               let value = object["value"] as? [String: Any],
               let errorMessage = value["message"] as? String {
                message = errorMessage
            }
            message = AppiumRedactor.redact(message, secrets: endpoint.secrets + additionalSecrets)
            throw AppiumError.requestFailed(path: path, status: response.status, message: message)
        }
    }

    private static func isSuccess(_ status: UInt) -> Bool { (200..<300).contains(status) }
    private static func object(_ data: Data) -> [String: Any]? {
        (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}
