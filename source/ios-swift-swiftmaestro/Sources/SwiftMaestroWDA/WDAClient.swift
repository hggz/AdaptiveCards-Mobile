// Port of: pkg/wda (HTTP client) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import AsyncHTTPClient
import NIOCore
import NIOHTTP1
import NIOFoundationCompat

/// Portable WebDriverAgent HTTP client. This half has no Apple-only imports and
/// runs on Windows/Linux/macOS; tests exercise it against a local NIO mock.
/// Only `XcodeWDAHostTooling` (xcrun/simctl/xcodebuild/iproxy) is macOS-gated.
public struct WDAClient: Sendable {
    public let baseURL: String
    private let http: HTTPClient
    private let requestTimeout: TimeAmount

    public init(baseURL: String, http: HTTPClient = .shared, requestTimeoutMs: Int = 30_000) {
        self.baseURL = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
        self.http = http
        self.requestTimeout = .milliseconds(Int64(requestTimeoutMs))
    }

    /// `GET /status` — true when WDA responds successfully and reports ready.
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

    /// `POST /session` — create a WDA session and return its id.
    public func createSession(bundleId: String? = nil) async throws -> String {
        var capabilities: [String: Any] = [
            "platformName": "iOS",
            "automationName": "XCUITest",
        ]
        if let bundleId, !bundleId.isEmpty { capabilities["bundleId"] = bundleId }
        let payload: [String: Any] = [
            "capabilities": ["alwaysMatch": capabilities],
            "desiredCapabilities": capabilities,
        ]
        let response = try await send(.POST, "/session", json: payload)
        try requireSuccess(response, path: "/session")
        guard let object = Self.object(response.body) else {
            throw WDAError.invalidResponse("create session returned non-JSON")
        }
        if let sessionId = object["sessionId"] as? String { return sessionId }
        if let value = object["value"] as? [String: Any], let sessionId = value["sessionId"] as? String {
            return sessionId
        }
        throw WDAError.invalidResponse("create session returned no sessionId")
    }

    public func deleteSession(_ sessionId: String) async throws {
        let path = "/session/\(sessionId)"
        let response = try await send(.DELETE, path)
        try requireSuccess(response, path: path)
    }

    /// Current iOS accessibility hierarchy as WDA XML.
    public func source(sessionId: String) async throws -> String {
        let path = "/session/\(sessionId)/source"
        let response = try await send(.GET, path)
        try requireSuccess(response, path: path)
        if let object = Self.object(response.body), let value = object["value"] as? String { return value }
        return String(decoding: response.body, as: UTF8.self)
    }

    // MARK: - App lifecycle

    public func launchApp(sessionId: String, bundleId: String, environment: [String: String]) async throws {
        try await command(sessionId, "/wda/apps/launch", [
            "bundleId": bundleId,
            "arguments": [],
            "environment": environment,
        ])
    }

    public func terminateApp(sessionId: String, bundleId: String) async throws {
        try await command(sessionId, "/wda/apps/terminate", ["bundleId": bundleId])
    }

    // MARK: - Gestures / input

    public func tap(sessionId: String, x: Int, y: Int) async throws {
        try await command(sessionId, "/wda/tap/0", ["x": x, "y": y])
    }

    public func touchAndHold(sessionId: String, x: Int, y: Int, durationSeconds: Double) async throws {
        try await command(sessionId, "/wda/touchAndHold", [
            "x": x, "y": y, "duration": durationSeconds,
        ])
    }

    public func inputText(sessionId: String, text: String) async throws {
        try await command(sessionId, "/wda/keys", ["value": [text]])
    }

    public func drag(sessionId: String, fromX: Int, fromY: Int,
                     toX: Int, toY: Int, durationSeconds: Double) async throws {
        try await command(sessionId, "/wda/dragfromtoforduration", [
            "fromX": fromX, "fromY": fromY, "toX": toX, "toY": toY,
            "duration": durationSeconds,
        ])
    }

    public func scroll(sessionId: String, direction: String) async throws {
        try await command(sessionId, "/wda/scroll", ["direction": direction.lowercased()])
    }

    public func pressButton(sessionId: String, name: String) async throws {
        try await command(sessionId, "/wda/pressButton", ["name": name])
    }

    public func openURL(sessionId: String, url: String) async throws {
        try await command(sessionId, "/url", ["url": url])
    }

    public func dismissKeyboard(sessionId: String) async throws {
        try await command(sessionId, "/wda/keyboard/dismiss", [:])
    }

    public func clearKeychains(sessionId: String) async throws {
        try await command(sessionId, "/wda/apps/clearKeychains", [:])
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
            throw WDAError.invalidResponse("screenshot returned no base64 value")
        }
        return data
    }

    // MARK: - Transport

    private func command(_ sessionId: String, _ suffix: String, _ payload: [String: Any]) async throws {
        let path = "/session/\(sessionId)\(suffix)"
        let response = try await send(.POST, path, json: payload)
        try requireSuccess(response, path: path)
    }

    private func send(_ method: HTTPMethod,
                      _ path: String,
                      json: [String: Any]? = nil) async throws -> (status: UInt, body: Data) {
        var request = HTTPClientRequest(url: baseURL + path)
        request.method = method
        if let json {
            let data = try JSONSerialization.data(withJSONObject: json)
            request.headers.add(name: "Content-Type", value: "application/json")
            request.body = .bytes(ByteBuffer(data: data))
        }
        let response = try await http.execute(request, timeout: requestTimeout)
        let buffer = try await response.body.collect(upTo: 16 * 1024 * 1024)
        return (UInt(response.status.code), Data(buffer: buffer))
    }

    private func requireSuccess(_ response: (status: UInt, body: Data), path: String) throws {
        guard Self.isSuccess(response.status) else {
            var message = String(decoding: response.body, as: UTF8.self)
            if let object = Self.object(response.body),
               let value = object["value"] as? [String: Any],
               let errorMessage = value["message"] as? String {
                message = errorMessage
            }
            throw WDAError.requestFailed(path: path, status: response.status, message: message)
        }
    }

    private static func isSuccess(_ status: UInt) -> Bool { (200..<300).contains(status) }

    private static func object(_ data: Data) -> [String: Any]? {
        (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}
