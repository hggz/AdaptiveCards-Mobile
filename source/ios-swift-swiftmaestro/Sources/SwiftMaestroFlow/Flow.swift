// Port of: pkg/flow/flow.go (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// A parsed Maestro flow: the header configuration document plus the ordered
/// list of steps.
public struct Flow: Sendable, Equatable {
    /// The application under test (`appId`). Optional — web flows omit it.
    public var appId: String?
    /// A human-readable flow name.
    public var name: String?
    /// Tags used for `--tags`/`--exclude-tags` filtering.
    public var tags: [String]
    /// Flow-level environment variables available to `${…}` interpolation.
    public var env: [String: String]
    /// Default per-command timeout in milliseconds.
    public var commandTimeout: Int?
    /// Whole-flow timeout in milliseconds. Nil/zero means no whole-flow limit.
    public var flowTimeout: Int?
    /// Device idle wait in milliseconds; `0` disables idle waits.
    public var waitForIdleTimeout: Int?
    /// The ordered steps to execute.
    public var steps: [MaestroStep]
    /// The file this flow was parsed from, when known (used by the validator to
    /// resolve relative `runFlow`/`runScript`/`addMedia` references).
    public var sourcePath: String?

    public init(
        appId: String? = nil,
        name: String? = nil,
        tags: [String] = [],
        env: [String: String] = [:],
        commandTimeout: Int? = nil,
        flowTimeout: Int? = nil,
        waitForIdleTimeout: Int? = nil,
        steps: [MaestroStep] = [],
        sourcePath: String? = nil
    ) {
        self.appId = appId
        self.name = name
        self.tags = tags
        self.env = env
        self.commandTimeout = commandTimeout
        self.flowTimeout = flowTimeout
        self.waitForIdleTimeout = waitForIdleTimeout
        self.steps = steps
        self.sourcePath = sourcePath
    }
}
