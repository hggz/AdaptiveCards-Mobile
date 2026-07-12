// Port of: pkg/device (process execution) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// The captured result of running an external tool.
public struct ProcessResult: Sendable, Equatable {
    public let exitCode: Int32
    public let stdout: Data
    public let stderr: Data

    public init(exitCode: Int32, stdout: Data, stderr: Data) {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
    }

    public var stdoutString: String { String(decoding: stdout, as: UTF8.self) }
    public var stderrString: String { String(decoding: stderr, as: UTF8.self) }
    public var succeeded: Bool { exitCode == 0 }
}

/// Errors raised while spawning or waiting on an external tool.
public enum ProcessError: Error, Sendable, Equatable, CustomStringConvertible {
    case toolNotFound(String)
    case launchFailed(command: String, reason: String)
    case timedOut(command: String, afterMs: Int)
    case nonZeroExit(command: String, code: Int32, stderr: String)

    public var description: String {
        switch self {
        case .toolNotFound(let name):
            return "tool not found on PATH: \(name)"
        case .launchFailed(let command, let reason):
            return "failed to launch '\(command)': \(reason)"
        case .timedOut(let command, let afterMs):
            return "'\(command)' timed out after \(afterMs)ms"
        case .nonZeroExit(let command, let code, let stderr):
            let tail = stderr.isEmpty ? "" : ": \(stderr)"
            return "'\(command)' exited with code \(code)\(tail)"
        }
    }
}

/// Abstraction over "run an external tool and capture its output". `ProcessRunner`
/// is the production implementation; tests inject a recording fake so driver
/// command construction can be validated without spawning anything.
public protocol CommandRunner: Sendable {
    func run(_ executable: String,
             arguments: [String],
             timeoutMs: Int?,
             environment: [String: String]?) async throws -> ProcessResult
}

public extension CommandRunner {
    /// Run a tool with no timeout and the inherited environment.
    func run(_ executable: String, _ arguments: [String]) async throws -> ProcessResult {
        try await run(executable, arguments: arguments, timeoutMs: nil, environment: nil)
    }

    /// Run a tool and throw `ProcessError.nonZeroExit` if it fails.
    @discardableResult
    func runChecked(_ executable: String,
                    _ arguments: [String],
                    timeoutMs: Int? = nil,
                    environment: [String: String]? = nil) async throws -> ProcessResult {
        let result = try await run(executable, arguments: arguments, timeoutMs: timeoutMs, environment: environment)
        guard result.exitCode == 0 else {
            throw ProcessError.nonZeroExit(command: "\(executable) \(arguments.joined(separator: " "))",
                                           code: result.exitCode,
                                           stderr: result.stderrString)
        }
        return result
    }
}
