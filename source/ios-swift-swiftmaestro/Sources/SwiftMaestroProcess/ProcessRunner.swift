// Port of: pkg/device (process execution) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// Serializes and executes `Foundation.Process` spawns with a cross-platform-safe
/// pattern. This is the single choke point every shell-out driver (adb, xcrun,
/// chrome, appium) goes through.
///
/// The tricky bits, learned the hard way and encoded here:
///  - The blocking `run()`/`waitUntilExit()` work is dispatched off the actor's
///    executor (GCD), so the actor is never held by a synchronous wait. This is
///    the pattern that is reliable across macOS/Linux/Windows; `terminationHandler`
///    is deliberately not used.
///  - stdout/stderr are drained on separate GCD queues via `availableData`,
///    CONCURRENTLY with the child. `readabilityHandler` does not fire on Windows
///    swift-corelibs-foundation, and reading only after exit would deadlock on
///    output larger than the pipe buffer (e.g. a screenshot PNG).
///  - Timeouts fire via GCD `asyncAfter` (not `Task.sleep`, whose cooperative pool
///    can be starved by Foundation's process monitor on Windows) and resume the
///    caller directly through a one-shot latch, so a slow `terminate()` on a
///    process with grandchildren never stalls the caller.
public actor ProcessRunner: CommandRunner {
    public init() {}

    public func run(_ executable: String,
                    arguments: [String],
                    timeoutMs: Int? = nil,
                    environment: [String: String]? = nil) async throws -> ProcessResult {
        guard let executablePath = Self.resolveExecutable(executable) else {
            throw ProcessError.toolNotFound(executable)
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments
        if let environment {
            // Overlay onto the inherited environment: a replaced env block would
            // drop PATH/SystemRoot/SDKROOT and break the child on Windows.
            var merged = ProcessInfo.processInfo.environment
            for (key, value) in environment { merged[key] = value }
            process.environment = merged
        }

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe
        process.standardInput = Pipe()

        let invocation = ProcessInvocation()
        let commandDescription = "\(executablePath) \(arguments.joined(separator: " "))"

        return try await withCheckedThrowingContinuation { continuation in
            invocation.setContinuation(continuation)

            // All blocking Process work runs off the actor's executor.
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try process.run()
                } catch {
                    invocation.fail(ProcessError.launchFailed(command: commandDescription, reason: "\(error)"))
                    return
                }

                // Drain both pipes CONCURRENTLY with the child. `readabilityHandler`
                // does not fire on Windows swift-corelibs-foundation, and reading
                // only after exit would deadlock on output larger than the pipe
                // buffer. Each loop ends at EOF, when the child's write end closes.
                let outHandle = outPipe.fileHandleForReading
                let errHandle = errPipe.fileHandleForReading
                let drains = DispatchGroup()
                drains.enter()
                DispatchQueue.global().async {
                    while case let data = outHandle.availableData, !data.isEmpty {
                        invocation.appendStdout(data)
                    }
                    drains.leave()
                }
                drains.enter()
                DispatchQueue.global().async {
                    while case let data = errHandle.availableData, !data.isEmpty {
                        invocation.appendStderr(data)
                    }
                    drains.leave()
                }

                // Timeout watchdog resumes the caller directly via the latch, so a
                // slow terminate() on a process with grandchildren never stalls us.
                if let timeoutMs {
                    DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(timeoutMs)) {
                        if process.isRunning { process.terminate() }
                        invocation.fail(ProcessError.timedOut(command: commandDescription, afterMs: timeoutMs))
                    }
                }

                process.waitUntilExit()
                // Let the drains flush the tail (capped so a grandchild holding the
                // pipe open can't hang us forever). The latch makes complete() a
                // no-op if the timeout already fired.
                _ = drains.wait(timeout: .now() + .milliseconds(2000))
                invocation.complete(exitCode: process.terminationStatus)
            }
        }
    }

    /// Resolve an executable name to a concrete path. On Windows this prefers a
    /// real `.exe` over a `.cmd`/`.bat` shim (Foundation.Process cannot invoke
    /// `.cmd` shims — e.g. Azure CLI's `git.cmd`).
    public static func resolveExecutable(_ name: String) -> String? {
        let fm = FileManager.default
        if name.contains("/") || name.contains("\\") {
            return fm.fileExists(atPath: name) ? name : nil
        }
        let pathVar = ProcessInfo.processInfo.environment["PATH"] ?? ""
        #if os(Windows)
        let dirs = pathVar.split(separator: ";").map(String.init)
        if name.contains(".") {
            for dir in dirs {
                let candidate = dir + "\\" + name
                if fm.fileExists(atPath: candidate) { return candidate }
            }
            return nil
        }
        for ext in ["exe", "cmd", "bat"] {
            for dir in dirs {
                let candidate = "\(dir)\\\(name).\(ext)"
                if fm.fileExists(atPath: candidate) { return candidate }
            }
        }
        return nil
        #else
        let dirs = pathVar.split(separator: ":").map(String.init)
        for dir in dirs {
            let candidate = dir + "/" + name
            if fm.isExecutableFile(atPath: candidate) { return candidate }
        }
        return nil
        #endif
    }
}

/// One-shot latch shared between the readability handlers, the termination
/// handler, and the timeout task. Guards a single continuation resume.
private final class ProcessInvocation {
    private let lock = NSLock()
    private var stdout = Data()
    private var stderr = Data()
    private var finished = false
    private var continuation: CheckedContinuation<ProcessResult, Error>?

    func setContinuation(_ c: CheckedContinuation<ProcessResult, Error>) {
        lock.lock(); continuation = c; lock.unlock()
    }

    func appendStdout(_ data: Data) { lock.lock(); stdout.append(data); lock.unlock() }
    func appendStderr(_ data: Data) { lock.lock(); stderr.append(data); lock.unlock() }

    func complete(exitCode: Int32) {
        lock.lock()
        if finished { lock.unlock(); return }
        finished = true
        let result = ProcessResult(exitCode: exitCode, stdout: stdout, stderr: stderr)
        let c = continuation
        continuation = nil
        lock.unlock()
        c?.resume(returning: result)
    }

    func fail(_ error: Error) {
        lock.lock()
        if finished { lock.unlock(); return }
        finished = true
        let c = continuation
        continuation = nil
        lock.unlock()
        c?.resume(throwing: error)
    }
}
