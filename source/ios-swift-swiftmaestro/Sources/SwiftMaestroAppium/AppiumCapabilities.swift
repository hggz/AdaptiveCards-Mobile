// Port of: pkg/cloud (capabilities) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import SwiftMaestroDriver

/// JSON value used for arbitrary Appium capabilities while remaining Sendable,
/// Equatable, and Codable across the Swift/C JSON boundary.
public enum CapabilityValue: Sendable, Equatable, Codable {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([CapabilityValue])
    case object([String: CapabilityValue])

    public init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer() {
            if single.decodeNil() { self = .null; return }
            if let value = try? single.decode(Bool.self) { self = .bool(value); return }
            if let value = try? single.decode(Int.self) { self = .int(value); return }
            if let value = try? single.decode(Double.self) { self = .double(value); return }
            if let value = try? single.decode(String.self) { self = .string(value); return }
        }
        if var array = try? decoder.unkeyedContainer() {
            var values: [CapabilityValue] = []
            while !array.isAtEnd { values.append(try array.decode(CapabilityValue.self)) }
            self = .array(values)
            return
        }
        if let object = try? decoder.container(keyedBy: CapabilityCodingKey.self) {
            var values: [String: CapabilityValue] = [:]
            for key in object.allKeys {
                values[key.stringValue] = try object.decode(CapabilityValue.self, forKey: key)
            }
            self = .object(values)
            return
        }
        throw AppiumError.invalidCapabilities("unsupported JSON value")
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .null:
            var container = encoder.singleValueContainer(); try container.encodeNil()
        case .bool(let value):
            var container = encoder.singleValueContainer(); try container.encode(value)
        case .int(let value):
            var container = encoder.singleValueContainer(); try container.encode(value)
        case .double(let value):
            var container = encoder.singleValueContainer(); try container.encode(value)
        case .string(let value):
            var container = encoder.singleValueContainer(); try container.encode(value)
        case .array(let values):
            var container = encoder.unkeyedContainer()
            for value in values { try container.encode(value) }
        case .object(let values):
            var container = encoder.container(keyedBy: CapabilityCodingKey.self)
            for (key, value) in values {
                try container.encode(value, forKey: CapabilityCodingKey(stringValue: key)!)
            }
        }
    }

    var anyValue: Any {
        switch self {
        case .null: return NSNull()
        case .bool(let value): return value
        case .int(let value): return value
        case .double(let value): return value
        case .string(let value): return value
        case .array(let values): return values.map(\.anyValue)
        case .object(let values): return values.mapValues(\.anyValue)
        }
    }

    var sensitiveValues: [String] {
        switch self {
        case .array(let values): return values.flatMap(\.sensitiveValues)
        case .object(let values):
            return values.flatMap { key, value in
                Self.isSensitiveKey(key) ? value.stringLeaves : value.sensitiveValues
            }
        default: return []
        }
    }

    private var stringLeaves: [String] {
        switch self {
        case .string(let value): return [value]
        case .array(let values): return values.flatMap(\.stringLeaves)
        case .object(let values): return values.values.flatMap(\.stringLeaves)
        default: return []
        }
    }

    private static func isSensitiveKey(_ key: String) -> Bool {
        let normalized = key.lowercased().replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "-", with: "")
        return ["username", "user", "accesskey", "key", "secret", "password",
                "token", "authorization"].contains(normalized)
    }
}

/// An arbitrary W3C `alwaysMatch` capability map.
public struct AppiumCapabilities: Sendable, Equatable {
    public private(set) var values: [String: CapabilityValue]

    public init(_ values: [String: CapabilityValue] = [:]) { self.values = values }

    /// Load a plain JSON capability object from `--caps`.
    public static func load(path: String) throws -> AppiumCapabilities {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let values = try JSONDecoder().decode([String: CapabilityValue].self, from: data)
            return AppiumCapabilities(values)
        } catch let error as AppiumError {
            throw error
        } catch {
            throw AppiumError.invalidCapabilities("could not read/decode \((path as NSString).lastPathComponent): \(error)")
        }
    }

    public subscript(key: String) -> CapabilityValue? {
        get { values[key] }
        set { values[key] = newValue }
    }

    public func merging(_ overrides: AppiumCapabilities) -> AppiumCapabilities {
        var merged = values
        for (key, value) in overrides.values { merged[key] = value }
        return AppiumCapabilities(merged)
    }

    var anyObject: [String: Any] { values.mapValues(\.anyValue) }
    var sensitiveValues: [String] { CapabilityValue.object(values).sensitiveValues }

    /// JSON safe for logs/errors: credential fields are replaced, never emitted.
    public func redactedJSON() -> String {
        let redacted = Self.redact(values)
        guard let data = try? JSONSerialization.data(withJSONObject: redacted.mapValues(\.anyValue),
                                                      options: [.sortedKeys]) else { return "{}" }
        return String(decoding: data, as: UTF8.self)
    }

    private static func redact(_ values: [String: CapabilityValue]) -> [String: CapabilityValue] {
        var output: [String: CapabilityValue] = [:]
        for (key, value) in values {
            let normalized = key.lowercased().replacingOccurrences(of: "_", with: "")
                .replacingOccurrences(of: "-", with: "")
            if ["username", "user", "accesskey", "key", "secret", "password",
                "token", "authorization"].contains(normalized) {
                output[key] = .string("***")
            } else if case .object(let nested) = value {
                output[key] = .object(redact(nested))
            } else if case .array(let array) = value {
                output[key] = .array(array.map { item in
                    if case .object(let nested) = item { return .object(redact(nested)) }
                    return item
                })
            } else {
                output[key] = value
            }
        }
        return output
    }
}

/// Supported cloud Appium grids and their W3C vendor namespace.
public enum CloudProvider: String, Sendable, Equatable, CaseIterable {
    case browserStack
    case sauceLabs
    case lambdaTest
    case testingBot

    public static func parse(_ value: String) -> CloudProvider? {
        let normalized = value.lowercased()
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: " ", with: "")
        switch normalized {
        case "browserstack": return .browserStack
        case "saucelabs", "sauce": return .sauceLabs
        case "lambdatest", "lambda": return .lambdaTest
        case "testingbot": return .testingBot
        default: return nil
        }
    }

    public var namespace: String {
        switch self {
        case .browserStack: return "bstack:options"
        case .sauceLabs: return "sauce:options"
        case .lambdaTest: return "lt:options"
        case .testingBot: return "tb:options"
        }
    }

    public var defaultHubURL: String {
        switch self {
        case .browserStack: return "https://hub-cloud.browserstack.com/wd/hub"
        case .sauceLabs: return "https://ondemand.us-west-1.saucelabs.com/wd/hub"
        case .lambdaTest: return "https://mobile-hub.lambdatest.com/wd/hub"
        case .testingBot: return "https://hub.testingbot.com/wd/hub"
        }
    }
}

public struct CloudCredentials: Sendable, Equatable {
    public var username: String
    public var accessKey: String
    public init(username: String, accessKey: String) {
        self.username = username
        self.accessKey = accessKey
    }
}

public struct CloudSessionMetadata: Sendable, Equatable {
    public var project: String?
    public var build: String?
    public var name: String?
    public init(project: String? = nil, build: String? = nil, name: String? = nil) {
        self.project = project
        self.build = build
        self.name = name
    }
}

/// Provider-specific capability builders. Credentials are namespaced according
/// to each grid's W3C shape and can be redacted by `AppiumCapabilities`.
public enum CloudCapabilities {
    public static func make(provider: CloudProvider,
                            platform: Platform,
                            deviceName: String,
                            platformVersion: String? = nil,
                            app: String? = nil,
                            credentials: CloudCredentials,
                            metadata: CloudSessionMetadata = .init(),
                            additional: AppiumCapabilities = .init()) -> AppiumCapabilities {
        var values = additional.values
        values["platformName"] = .string(platform == .ios ? "iOS" : "Android")
        values["appium:deviceName"] = .string(deviceName)
        values["appium:automationName"] = .string(platform == .ios ? "XCUITest" : "UiAutomator2")
        if let platformVersion { values["appium:platformVersion"] = .string(platformVersion) }
        if let app { values["appium:app"] = .string(app) }

        var options: [String: CapabilityValue] = [:]
        if case .object(let existing)? = values[provider.namespace] { options = existing }
        switch provider {
        case .browserStack:
            options["userName"] = .string(credentials.username)
            options["accessKey"] = .string(credentials.accessKey)
            if let project = metadata.project { options["projectName"] = .string(project) }
            if let build = metadata.build { options["buildName"] = .string(build) }
            if let name = metadata.name { options["sessionName"] = .string(name) }
        case .sauceLabs:
            options["username"] = .string(credentials.username)
            options["accessKey"] = .string(credentials.accessKey)
            if let name = metadata.name { options["name"] = .string(name) }
            if let build = metadata.build { options["build"] = .string(build) }
        case .lambdaTest:
            options["username"] = .string(credentials.username)
            options["accessKey"] = .string(credentials.accessKey)
            options["w3c"] = .bool(true)
            if let project = metadata.project { options["project"] = .string(project) }
            if let build = metadata.build { options["build"] = .string(build) }
            if let name = metadata.name { options["name"] = .string(name) }
        case .testingBot:
            options["key"] = .string(credentials.username)
            options["secret"] = .string(credentials.accessKey)
            if let name = metadata.name { options["name"] = .string(name) }
            if let build = metadata.build { options["build"] = .string(build) }
        }
        values[provider.namespace] = .object(options)
        return AppiumCapabilities(values)
    }
}

private struct CapabilityCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int? { nil }
    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { nil }
}
