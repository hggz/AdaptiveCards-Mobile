// Port of: pkg/report (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// The outcome of a flow or a single step.
public enum RunStatus: String, Sendable, Codable, Equatable {
    case passed
    case failed
    case skipped
    case error
}

/// The result of executing one flow step.
public struct StepResult: Sendable, Codable, Equatable {
    public var command: String
    public var label: String?
    public var status: RunStatus
    public var durationMs: Int
    public var message: String?

    public init(command: String, label: String? = nil, status: RunStatus,
                durationMs: Int = 0, message: String? = nil) {
        self.command = command
        self.label = label
        self.status = status
        self.durationMs = durationMs
        self.message = message
    }
}

/// The result of executing one flow (against one device).
public struct FlowResult: Sendable, Codable, Equatable {
    public var name: String
    public var filePath: String?
    public var appId: String?
    public var tags: [String]
    public var device: String?
    public var status: RunStatus
    public var durationMs: Int
    public var message: String?
    public var steps: [StepResult]

    public init(name: String, filePath: String? = nil, appId: String? = nil,
                tags: [String] = [], device: String? = nil, status: RunStatus,
                durationMs: Int = 0, message: String? = nil, steps: [StepResult] = []) {
        self.name = name
        self.filePath = filePath
        self.appId = appId
        self.tags = tags
        self.device = device
        self.status = status
        self.durationMs = durationMs
        self.message = message
        self.steps = steps
    }

    public var failedSteps: Int { steps.filter { $0.status == .failed || $0.status == .error }.count }
    public var skippedSteps: Int { steps.filter { $0.status == .skipped }.count }
}

/// A complete test run: the flows that were executed plus a run start time.
///
/// Time is carried as epoch milliseconds (not `Date`) so report output is fully
/// deterministic — golden fixtures compare byte-for-byte across platforms.
public struct TestReport: Sendable, Codable, Equatable {
    public var flows: [FlowResult]
    public var startedAtEpochMs: Int64

    public init(flows: [FlowResult] = [], startedAtEpochMs: Int64 = 0) {
        self.flows = flows
        self.startedAtEpochMs = startedAtEpochMs
    }

    public var total: Int { flows.count }
    public var passed: Int { flows.filter { $0.status == .passed }.count }
    public var failed: Int { flows.filter { $0.status == .failed || $0.status == .error }.count }
    public var skipped: Int { flows.filter { $0.status == .skipped }.count }
    public var durationMs: Int { flows.reduce(0) { $0 + $1.durationMs } }
    public var isSuccess: Bool { failed == 0 }
}
