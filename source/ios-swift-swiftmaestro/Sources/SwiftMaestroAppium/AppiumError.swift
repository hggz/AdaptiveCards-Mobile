// Port of: drivers/appium + pkg/cloud (errors/security)
// (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// Errors from the Appium transport, capability loader, and driver.
public enum AppiumError: Error, Sendable, Equatable, CustomStringConvertible {
    case invalidURL(String)
    case insecureRemoteURL(String)
    case invalidCapabilities(String)
    case invalidResponse(String)
    case requestFailed(path: String, status: UInt, message: String)
    case transport(String)
    case missingSession

    public var description: String {
        switch self {
        case .invalidURL(let value):
            return "invalid Appium URL: \(value)"
        case .insecureRemoteURL(let value):
            return "remote Appium hubs require HTTPS (TLS verification is always enabled): \(value)"
        case .invalidCapabilities(let message):
            return "invalid Appium capabilities: \(message)"
        case .invalidResponse(let message):
            return "Appium invalid response: \(message)"
        case .requestFailed(let path, let status, let message):
            let suffix = message.isEmpty ? "" : ": \(message)"
            return "Appium request \(path) failed (HTTP \(status))\(suffix)"
        case .transport(let message):
            return "Appium transport failed: \(message)"
        case .missingSession:
            return "Appium session not started; call setUp() first"
        }
    }
}

/// Parsed endpoint with userinfo removed from request/log URLs. Credentials in a
/// URL become an Authorization header and are retained only as redaction values.
struct AppiumEndpoint: Sendable {
    let requestBaseURL: String
    let redactedURL: String
    let authorization: String?
    let secrets: [String]

    init(_ raw: String) throws {
        guard var components = URLComponents(string: raw),
              let scheme = components.scheme?.lowercased(),
              let host = components.host, !host.isEmpty,
              scheme == "http" || scheme == "https" else {
            throw AppiumError.invalidURL(AppiumRedactor.redact(raw, secrets: []))
        }

        let loopback = host.lowercased() == "localhost" || host == "127.0.0.1" || host == "::1"
        if scheme == "http", !loopback {
            var redacted = components
            redacted.user = nil
            redacted.password = nil
            throw AppiumError.insecureRemoteURL(redacted.string ?? "\(scheme)://\(host)")
        }

        let user = components.user?.removingPercentEncoding ?? components.user
        let password = components.password?.removingPercentEncoding ?? components.password
        var values: [String] = []
        if let user, !user.isEmpty { values.append(user) }
        if let password, !password.isEmpty { values.append(password) }

        if let user {
            let token = Data("\(user):\(password ?? "")".utf8).base64EncodedString()
            authorization = "Basic \(token)"
            values += [token, "Basic \(token)"]
        } else {
            authorization = nil
        }
        secrets = values

        components.user = nil
        components.password = nil
        components.fragment = nil
        guard var normalized = components.string else {
            throw AppiumError.invalidURL("\(scheme)://\(host)")
        }
        while normalized.hasSuffix("/") { normalized.removeLast() }
        requestBaseURL = normalized
        redactedURL = normalized
    }
}

/// Redacts known credential values and URL userinfo from any surfaced error.
enum AppiumRedactor {
    static func redact(_ message: String, secrets: [String]) -> String {
        var result = message
        for secret in Set(secrets).sorted(by: { $0.count > $1.count }) where !secret.isEmpty {
            result = result.replacingOccurrences(of: secret, with: "***")
        }
        if let regex = try? NSRegularExpression(pattern: #"(?i)(https?://)[^/@\s]+@"#) {
            let range = NSRange(result.startIndex..<result.endIndex, in: result)
            result = regex.stringByReplacingMatches(in: result, range: range, withTemplate: "$1***@")
        }
        return result
    }
}
