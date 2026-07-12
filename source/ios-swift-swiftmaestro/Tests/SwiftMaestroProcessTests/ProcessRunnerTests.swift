import XCTest
import Foundation
@testable import SwiftMaestroProcess

final class ProcessRunnerTests: XCTestCase {

    // Platform shell + command builders. The local gate runs on Windows; the
    // POSIX arms keep the suite runnable on macOS/Linux too.
    #if os(Windows)
    private var shell: String { ProcessInfo.processInfo.environment["ComSpec"] ?? "cmd.exe" }
    private func echo(_ s: String) -> [String] { ["/c", "echo \(s)"] }
    private func exit(_ code: Int) -> [String] { ["/c", "exit \(code)"] }
    private func echoStderr(_ s: String) -> [String] { ["/c", "echo \(s) 1>&2"] }
    private func spin() -> [String] { ["/c", "for /L %i in (1,0,2147483647) do @rem"] }
    private func echoVar(_ name: String) -> [String] { ["/c", "echo %\(name)%"] }
    #else
    private var shell: String { "/bin/sh" }
    private func echo(_ s: String) -> [String] { ["-c", "echo \(s)"] }
    private func exit(_ code: Int) -> [String] { ["-c", "exit \(code)"] }
    private func echoStderr(_ s: String) -> [String] { ["-c", "echo \(s) 1>&2"] }
    private func spin() -> [String] { ["-c", "while :; do :; done"] }
    private func echoVar(_ name: String) -> [String] { ["-c", "echo $\(name)"] }
    #endif

    func testEchoStdout() async throws {
        let result = try await ProcessRunner().run(shell, arguments: echo("hello"))
        XCTAssertEqual(result.exitCode, 0)
        XCTAssertTrue(result.stdoutString.contains("hello"), "stdout was: \(result.stdoutString)")
    }

    func testNonZeroExitCode() async throws {
        let result = try await ProcessRunner().run(shell, arguments: exit(7))
        XCTAssertEqual(result.exitCode, 7)
        XCTAssertFalse(result.succeeded)
    }

    func testStderrCaptured() async throws {
        let result = try await ProcessRunner().run(shell, arguments: echoStderr("boom"))
        XCTAssertTrue(result.stderrString.contains("boom"), "stderr was: \(result.stderrString)")
    }

    func testRunCheckedThrowsOnFailure() async {
        do {
            _ = try await ProcessRunner().runChecked(shell, exit(3))
            XCTFail("expected nonZeroExit")
        } catch let error as ProcessError {
            guard case .nonZeroExit(_, let code, _) = error else { return XCTFail("wrong error: \(error)") }
            XCTAssertEqual(code, 3)
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func testToolNotFoundThrows() async {
        do {
            _ = try await ProcessRunner().run("swiftmaestro-definitely-not-a-tool-\(UUID().uuidString)", arguments: [])
            XCTFail("expected toolNotFound")
        } catch let error as ProcessError {
            guard case .toolNotFound = error else { return XCTFail("wrong error: \(error)") }
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func testTimeoutTerminatesAndThrows() async {
        do {
            _ = try await ProcessRunner().run(shell, arguments: spin(), timeoutMs: 400)
            XCTFail("expected timedOut")
        } catch let error as ProcessError {
            guard case .timedOut = error else { return XCTFail("wrong error: \(error)") }
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func testEnvironmentOverlay() async throws {
        let result = try await ProcessRunner().run(shell, arguments: echoVar("SM_TEST_VAR"),
                                                   timeoutMs: nil, environment: ["SM_TEST_VAR": "overlaid"])
        XCTAssertTrue(result.stdoutString.contains("overlaid"), "stdout was: \(result.stdoutString)")
    }

    func testResolveExecutableRejectsUnknown() {
        XCTAssertNil(ProcessRunner.resolveExecutable("swiftmaestro-nope-\(UUID().uuidString)"))
    }
}
