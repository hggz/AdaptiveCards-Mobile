// Port of: pkg/device (long-lived process) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// A handle to a long-lived child process the caller terminates explicitly,
/// rather than running it to completion. Used for servers swiftmaestro starts and
/// then drives — Chrome/Chromium/Edge for the Web (CDP) driver, and later the
/// Appium hub / emulators.
///
/// stdout/stderr/stdin are routed to the null device: a chatty child (Chrome logs
/// heavily to stderr) would otherwise fill an undrained pipe buffer and stall,
/// since nothing reads it. Termination is best-effort — on Windows `terminate()`
/// does not promptly reap grandchildren (renderer processes); the OS cleans them
/// up when the parent dies and the owning process exits
/// (see /memories/swift-foundation-process-windows.md).
public final class LaunchedProcess: @unchecked Sendable {
    private let process: Process
    private let lock = NSLock()
    public let commandDescription: String

    init(process: Process, commandDescription: String) {
        self.process = process
        self.commandDescription = commandDescription
    }

    public var isRunning: Bool {
        lock.lock(); defer { lock.unlock() }
        return process.isRunning
    }

    public var processIdentifier: Int32 {
        lock.lock(); defer { lock.unlock() }
        return process.processIdentifier
    }

    /// Best-effort termination. Safe to call more than once.
    public func terminate() {
        lock.lock(); defer { lock.unlock() }
        if process.isRunning { process.terminate() }
    }
}

public extension ProcessRunner {
    /// Spawn a long-lived process WITHOUT waiting for it to exit, returning a
    /// handle to terminate later. Output is discarded (null device). Use this for
    /// servers swiftmaestro drives (the CDP browser); use `run` for tools whose
    /// output and exit code you need (adb / xcrun / appium).
    func spawn(_ executable: String,
               arguments: [String],
               environment: [String: String]? = nil) throws -> LaunchedProcess {
        guard let executablePath = Self.resolveExecutable(executable) else {
            throw ProcessError.toolNotFound(executable)
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments
        if let environment {
            var merged = ProcessInfo.processInfo.environment
            for (key, value) in environment { merged[key] = value }
            process.environment = merged
        }
        // No reader for these, so route to the null device to avoid a full-pipe
        // stall on a verbose child.
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        process.standardInput = FileHandle.nullDevice

        let commandDescription = "\(executablePath) \(arguments.joined(separator: " "))"
        do {
            try process.run()
        } catch {
            throw ProcessError.launchFailed(command: commandDescription, reason: "\(error)")
        }
        return LaunchedProcess(process: process, commandDescription: commandDescription)
    }
}
