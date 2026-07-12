// Port of: pkg/emulator (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import SwiftMaestroProcess

public struct AndroidEmulatorConfiguration: Sendable, Equatable {
    public var avdName: String
    public var port: Int
    public var emulatorPath: String
    public var headless: Bool
    public var startupTimeoutMs: Int

    public init(avdName: String,
                port: Int = 5554,
                emulatorPath: String = "emulator",
                headless: Bool = true,
                startupTimeoutMs: Int = 180_000) {
        self.avdName = avdName
        self.port = port
        self.emulatorPath = emulatorPath
        self.headless = headless
        self.startupTimeoutMs = startupTimeoutMs
    }

    public var serial: String { "emulator-\(port)" }
}

/// Starts an Android AVD through the shared ProcessRunner, waits for boot
/// completion through adb, and kills it on teardown. No platform-specific Swift
/// module is needed; availability is determined by the installed tools.
public actor AndroidEmulatorLauncher: DriverLifecycle {
    private let configuration: AndroidEmulatorConfiguration
    private let runner: ProcessRunner
    private let adb: Adb
    private var process: LaunchedProcess?

    public init(configuration: AndroidEmulatorConfiguration,
                runner: ProcessRunner = ProcessRunner(),
                adbPath: String = "adb") {
        self.configuration = configuration
        self.runner = runner
        adb = Adb(runner: runner, adbPath: adbPath, serial: configuration.serial)
    }

    public func start() async throws {
        guard process == nil else { return }
        process = try await runner.spawn(configuration.emulatorPath,
                                         arguments: Self.arguments(configuration))
        do {
            _ = try await adb.run(["wait-for-device"], timeoutMs: configuration.startupTimeoutMs)
            let started = Date()
            while Date().timeIntervalSince(started) * 1000 < Double(configuration.startupTimeoutMs) {
                let result = try? await adb.run(["shell", "getprop", "sys.boot_completed"], timeoutMs: 10_000)
                if result?.stdoutString.trimmingCharacters(in: .whitespacesAndNewlines) == "1" { return }
                await emulatorNap(milliseconds: 500)
            }
            throw DriverError.timedOut("Android emulator \(configuration.avdName) did not boot after \(configuration.startupTimeoutMs)ms")
        } catch {
            await stop()
            throw error
        }
    }

    public func stop() async {
        _ = try? await adb.run(["emu", "kill"], timeoutMs: 15_000)
        process?.terminate()
        process = nil
    }

    static func arguments(_ configuration: AndroidEmulatorConfiguration) -> [String] {
        var arguments = [
            "-avd", configuration.avdName,
            "-port", "\(configuration.port)",
            "-no-audio", "-no-boot-anim", "-gpu", "swiftshader_indirect",
        ]
        if configuration.headless { arguments.append("-no-window") }
        return arguments
    }
}

private func emulatorNap(milliseconds: Int) async {
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(milliseconds)) {
            continuation.resume()
        }
    }
}
