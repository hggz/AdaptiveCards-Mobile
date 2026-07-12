// Port of: pkg/simulator + drivers/wda (host orchestration)
// (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import SwiftMaestroDriver
import SwiftMaestroProcess

/// Host-side operations the WDA driver may need before speaking HTTP. The
/// protocol lets portable driver tests inject a mock and avoid real Xcode tools.
public protocol WDAHostTooling: Sendable {
    func prepare() async throws
    func installApp(_ path: String) async throws
    func addMedia(_ paths: [String]) async throws
    func tearDown() async
}

public extension WDAHostTooling {
    func addMedia(_ paths: [String]) async throws {
        throw DriverError.notSupported("addMedia requires simulator host tooling")
    }
}

/// Simulator vs physical-device destination for xcodebuild / installation.
public enum IOSDestination: Sendable, Equatable {
    case simulator(String) // UDID or "booted"
    case device(String)    // physical-device UDID

    var identifier: String {
        switch self {
        case .simulator(let id), .device(let id): return id
        }
    }
}

/// Configuration for macOS WDA orchestration. `xcodeProjectPath` is optional: if
/// omitted, swiftmaestro assumes WDA is already running at the configured URL;
/// simulator bootstatus / physical-device iproxy setup still occurs.
public struct WDAHostConfiguration: Sendable, Equatable {
    public var destination: IOSDestination
    public var xcodeProjectPath: String?
    public var scheme: String
    public var derivedDataPath: String?
    public var hostPort: Int
    public var devicePort: Int
    public var iproxyPath: String

    public init(destination: IOSDestination = .simulator("booted"),
                xcodeProjectPath: String? = nil,
                scheme: String = "WebDriverAgentRunner",
                derivedDataPath: String? = nil,
                hostPort: Int = 8100,
                devicePort: Int = 8100,
                iproxyPath: String = "iproxy") {
        self.destination = destination
        self.xcodeProjectPath = xcodeProjectPath
        self.scheme = scheme
        self.derivedDataPath = derivedDataPath
        self.hostPort = hostPort
        self.devicePort = devicePort
        self.iproxyPath = iproxyPath
    }
}

/// macOS implementation using xcrun/simctl, xcodebuild, and iproxy. The type is
/// compiled on every host; only these tool-invocation methods runtime-gate on
/// non-macOS with a clear error. That keeps the WDA HTTP client mock-testable on
/// Windows/Linux without pretending Xcode exists there.
public actor XcodeWDAHostTooling: WDAHostTooling {
    public static let unsupportedHostMessage = "iOS testing requires macOS (xcrun/simctl/Xcode)."

    private let configuration: WDAHostConfiguration
    private let runner: ProcessRunner
    private var wdaProcess: LaunchedProcess?
    private var proxyProcess: LaunchedProcess?

    public init(configuration: WDAHostConfiguration, runner: ProcessRunner = ProcessRunner()) {
        self.configuration = configuration
        self.runner = runner
    }

    /// Fail clearly on non-macOS. Public so tests can assert the exact runtime
    /// gate while the rest of the WDA module continues to compile and run.
    public static func requireMacOS() throws {
        #if os(macOS)
        return
        #else
        throw DriverError.notSupported(unsupportedHostMessage)
        #endif
    }

    public func prepare() async throws {
        try Self.requireMacOS()
        #if os(macOS)
        switch configuration.destination {
        case .simulator(let udid):
            _ = try await runner.runChecked("xcrun", ["simctl", "bootstatus", udid, "-b"],
                                            timeoutMs: 180_000)
        case .device(let udid):
            proxyProcess = try await runner.spawn(configuration.iproxyPath,
                                                  arguments: ["\(configuration.hostPort)",
                                                              "\(configuration.devicePort)",
                                                              "-u", udid])
        }

        if let project = configuration.xcodeProjectPath {
            var arguments = [
                "-project", project,
                "-scheme", configuration.scheme,
                "-destination", "id=\(configuration.destination.identifier)",
            ]
            if let derivedDataPath = configuration.derivedDataPath {
                arguments += ["-derivedDataPath", derivedDataPath]
            }
            // `test` builds and launches WebDriverAgentRunner. It remains alive as
            // a long-running child while the HTTP driver uses it.
            arguments.append("test")
            wdaProcess = try await runner.spawn("xcodebuild", arguments: arguments)
        }
        #endif
    }

    public func installApp(_ path: String) async throws {
        try Self.requireMacOS()
        #if os(macOS)
        switch configuration.destination {
        case .simulator(let udid):
            _ = try await runner.runChecked("xcrun", ["simctl", "install", udid, path],
                                            timeoutMs: 180_000)
        case .device(let udid):
            _ = try await runner.runChecked("xcrun", [
                "devicectl", "device", "install", "app", "--device", udid, path,
            ], timeoutMs: 180_000)
        }
        #endif
    }

    public func addMedia(_ paths: [String]) async throws {
        try Self.requireMacOS()
        #if os(macOS)
        switch configuration.destination {
        case .simulator(let udid):
            _ = try await runner.runChecked("xcrun", ["simctl", "addmedia", udid] + paths,
                                            timeoutMs: 180_000)
        case .device:
            throw DriverError.notSupported("addMedia for physical iOS devices")
        }
        #endif
    }

    public func tearDown() async {
        wdaProcess?.terminate()
        proxyProcess?.terminate()
        wdaProcess = nil
        proxyProcess = nil
    }
}
