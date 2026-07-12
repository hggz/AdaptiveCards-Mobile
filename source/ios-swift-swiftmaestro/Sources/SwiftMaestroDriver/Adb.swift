// Port of: pkg/uiautomator2 + pkg/device (adb) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import SwiftMaestroProcess

/// Thin, typed wrapper over the `adb` command line, routed through a
/// `CommandRunner`. Every invocation is scoped to a device serial when one is
/// set (`adb -s <serial> ...`). Tests inject a recording `CommandRunner` to
/// assert argument construction without a real device.
public struct Adb: Sendable {
    public let runner: any CommandRunner
    public let adbPath: String
    public let serial: String?

    public init(runner: any CommandRunner = ProcessRunner(), adbPath: String = "adb", serial: String? = nil) {
        self.runner = runner
        self.adbPath = adbPath
        self.serial = serial
    }

    /// Return a copy scoped to a specific device serial.
    public func targeting(serial: String) -> Adb {
        Adb(runner: runner, adbPath: adbPath, serial: serial)
    }

    private func argv(_ args: [String]) -> [String] {
        var out: [String] = []
        if let serial { out += ["-s", serial] }
        out += args
        return out
    }

    @discardableResult
    public func run(_ args: [String], timeoutMs: Int? = nil) async throws -> ProcessResult {
        try await runner.runChecked(adbPath, argv(args), timeoutMs: timeoutMs, environment: nil)
    }

    // MARK: - Device / app lifecycle

    /// Serials of attached devices in the `device` state.
    public func devices() async throws -> [String] {
        let result = try await runner.run(adbPath, arguments: ["devices"], timeoutMs: 15_000, environment: nil)
        var serials: [String] = []
        for line in result.stdoutString.split(separator: "\n").dropFirst() {
            let fields = line.split(whereSeparator: { $0 == "\t" || $0 == " " })
            let parts = fields.map { String($0) }
            if parts.count >= 2, parts[1] == "device" { serials.append(parts[0]) }
        }
        return serials
    }

    public func installApp(_ apkPath: String) async throws {
        try await run(["install", "-r", "-g", apkPath], timeoutMs: 180_000)
    }

    public func launchApp(_ appId: String) async throws {
        try await run(["shell", "monkey", "-p", appId, "-c", "android.intent.category.LAUNCHER", "1"])
    }

    public func forceStop(_ appId: String) async throws {
        try await run(["shell", "am", "force-stop", appId])
    }

    public func clearData(_ appId: String) async throws {
        try await run(["shell", "pm", "clear", appId])
    }

    // MARK: - Port forwarding (to reach the on-device server)

    public func forward(hostPort: Int, devicePort: Int) async throws {
        try await run(["forward", "tcp:\(hostPort)", "tcp:\(devicePort)"])
    }

    public func removeForward(hostPort: Int) async throws {
        try await run(["forward", "--remove", "tcp:\(hostPort)"])
    }

    // MARK: - Input

    public func inputText(_ text: String) async throws {
        try await run(["shell", "input", "text", Adb.escapeInputText(text)])
    }

    public func inputTap(x: Int, y: Int) async throws {
        try await run(["shell", "input", "tap", "\(x)", "\(y)"])
    }

    public func inputSwipe(x1: Int, y1: Int, x2: Int, y2: Int, durationMs: Int) async throws {
        try await run(["shell", "input", "swipe", "\(x1)", "\(y1)", "\(x2)", "\(y2)", "\(durationMs)"])
    }

    public func keyEvent(_ arg: String) async throws {
        try await run(["shell", "input", "keyevent", arg])
    }

    public func openLink(_ url: String) async throws {
        try await run(["shell", "am", "start", "-a", "android.intent.action.VIEW", "-d", url])
    }

    /// Emulator geolocation (`adb emu geo fix` expects longitude before latitude).
    public func setLocation(latitude: Double, longitude: Double) async throws {
        try await run(["emu", "geo", "fix", "\(longitude)", "\(latitude)"])
    }

    /// Push media into Downloads and notify Android's media scanner.
    public func addMedia(_ paths: [String]) async throws {
        for path in paths {
            let name = (path as NSString).lastPathComponent
            let remote = "/sdcard/Download/\(name)"
            try await run(["push", path, remote], timeoutMs: 180_000)
            try await run(["shell", "am", "broadcast", "-a",
                           "android.intent.action.MEDIA_SCANNER_SCAN_FILE",
                           "-d", "file://\(remote)"])
        }
    }

    public func screencap() async throws -> Data {
        let result = try await runner.run(adbPath, arguments: argv(["exec-out", "screencap", "-p"]),
                                          timeoutMs: 30_000, environment: nil)
        guard result.exitCode == 0 else {
            throw ProcessError.nonZeroExit(command: "adb exec-out screencap -p",
                                           code: result.exitCode, stderr: result.stderrString)
        }
        return result.stdout
    }

    /// `adb shell input text` treats spaces specially and splits on shell
    /// metacharacters. Encode a space as `%s` and backslash-escape the rest so
    /// Unicode/text input survives intact.
    static func escapeInputText(_ text: String) -> String {
        var out = ""
        for ch in text {
            switch ch {
            case " ":
                out += "%s"
            case "&", "<", ">", "(", ")", "|", ";", "*", "\\", "\"", "'", "`", "$", "~":
                out += "\\" + String(ch)
            default:
                out.append(ch)
            }
        }
        return out
    }
}
