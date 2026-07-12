import Foundation
import SwiftMaestroProcess

/// A `CommandRunner` that records invocations and returns canned results, so
/// adb/driver command construction can be asserted without spawning anything.
actor MockCommandRunner: CommandRunner {
    struct Call: Sendable, Equatable {
        let executable: String
        let arguments: [String]
    }

    private(set) var calls: [Call] = []
    private let responder: (@Sendable (String, [String]) -> ProcessResult)?

    init(responder: (@Sendable (String, [String]) -> ProcessResult)? = nil) {
        self.responder = responder
    }

    func run(_ executable: String,
             arguments: [String],
             timeoutMs: Int?,
             environment: [String: String]?) async throws -> ProcessResult {
        calls.append(Call(executable: executable, arguments: arguments))
        if let responder { return responder(executable, arguments) }
        return ProcessResult(exitCode: 0, stdout: Data(), stderr: Data())
    }
}
