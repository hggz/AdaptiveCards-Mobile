// Port of: pkg/uiautomator2 (HTTP client) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import AsyncHTTPClient
import NIOCore
import NIOHTTP1
import NIOFoundationCompat

/// Thin HTTP client for the on-device appium-uiautomator2-server, reached over an
/// adb-forwarded local port. Speaks the W3C/JSON-Wire subset the driver needs:
/// readiness, session lifecycle, and page source (the UI hierarchy XML).
///
/// The server is a prebuilt artifact swiftmaestro installs and talks to; it is not
/// part of this port (see docs/PROVENANCE.md).
public struct UIAutomator2Client: Sendable {
    public let baseURL: String
    private let http: HTTPClient
    private let requestTimeout: TimeAmount

    public init(baseURL: String, http: HTTPClient = .shared, requestTimeoutMs: Int = 30_000) {
        self.baseURL = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
        self.http = http
        self.requestTimeout = .milliseconds(Int64(requestTimeoutMs))
    }

    /// `GET /status` — true when the server reports it is ready.
    public func status() async throws -> Bool {
        let (code, data) = try await send(.GET, "/status")
        guard code == 200 else { return false }
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return true }
        if let value = object["value"] as? [String: Any], let ready = value["ready"] as? Bool { return ready }
        if let ready = object["ready"] as? Bool { return ready }
        return true
    }

    /// `POST /session` — create a session and return its id.
    public func createSession(appId: String? = nil) async throws -> String {
        var capabilities: [String: Any] = ["platformName": "Android"]
        if let appId { capabilities["appium:appPackage"] = appId }
        let payload: [String: Any] = [
            "capabilities": ["alwaysMatch": capabilities],
            "desiredCapabilities": capabilities,
        ]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let (code, data) = try await send(.POST, "/session", body: body)
        guard code == 200 else {
            throw DriverError.toolFailure("create session failed (HTTP \(code))")
        }
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw DriverError.toolFailure("create session: unparseable response")
        }
        if let sessionId = object["sessionId"] as? String { return sessionId }
        if let value = object["value"] as? [String: Any], let sessionId = value["sessionId"] as? String {
            return sessionId
        }
        throw DriverError.toolFailure("create session: no sessionId in response")
    }

    /// `DELETE /session/:id` — best-effort teardown.
    public func deleteSession(_ sessionId: String) async throws {
        _ = try await send(.DELETE, "/session/\(sessionId)")
    }

    /// `GET /session/:id/source` — the current UI hierarchy as UIAutomator XML.
    public func source(sessionId: String) async throws -> String {
        let (code, data) = try await send(.GET, "/session/\(sessionId)/source")
        guard code == 200 else {
            throw DriverError.toolFailure("source failed (HTTP \(code))")
        }
        // The server may wrap the XML in a W3C `{ "value": "<xml>" }` envelope.
        if let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let value = object["value"] as? String {
            return value
        }
        return String(decoding: data, as: UTF8.self)
    }

    /// Direct W3C text input. Unlike `adb shell input text`, this preserves
    /// Unicode, whitespace, emoji, and shell metacharacters without escaping.
    public func inputText(sessionId: String, text: String) async throws {
        let path = "/session/\(sessionId)/keys"
        let body = try JSONSerialization.data(withJSONObject: ["value": [text], "text": text])
        let (code, _) = try await send(.POST, path, body: body)
        guard (200..<300).contains(code) else {
            throw DriverError.toolFailure("input text failed (HTTP \(code))")
        }
    }

    // MARK: - Transport

    private func send(_ method: HTTPMethod, _ path: String, body: Data? = nil) async throws -> (status: UInt, body: Data) {
        var request = HTTPClientRequest(url: baseURL + path)
        request.method = method
        if let body {
            request.headers.add(name: "Content-Type", value: "application/json")
            request.body = .bytes(ByteBuffer(data: body))
        }
        let response = try await http.execute(request, timeout: requestTimeout)
        let buffer = try await response.body.collect(upTo: 16 * 1024 * 1024)
        return (UInt(response.status.code), Data(buffer: buffer))
    }
}
