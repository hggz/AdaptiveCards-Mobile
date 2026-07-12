// Port of: pkg/report (Allure) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// A single Allure result file (`<uuid>-result.json`).
public struct AllureResultFile: Sendable, Equatable {
    public var name: String
    public var content: String
    public init(name: String, content: String) {
        self.name = name
        self.content = content
    }
}

/// Emits Allure-compatible result JSON — one object per flow, each with nested
/// step results. UUIDs are derived deterministically from the flow index so the
/// output is reproducible (Allure normally uses random UUIDs).
public struct AllureReportGenerator: ReportGenerator {
    public init() {}
    public var format: String { "allure" }
    public var fileName: String { "allure-results" }

    /// One result file per flow, ready to write into an `allure-results/` dir.
    public func resultFiles(_ report: TestReport) -> [AllureResultFile] {
        report.flows.enumerated().map { index, flow in
            let uuid = Self.uuid(for: flow, index: index)
            let object = buildResult(flow, uuid: uuid, startMs: report.startedAtEpochMs)
            return AllureResultFile(name: "\(uuid)-result.json",
                                    content: object.serialized(pretty: true) + "\n")
        }
    }

    /// A single JSON array of all result objects — convenient for inspection and
    /// golden comparison.
    public func generate(_ report: TestReport) -> String {
        let objects = report.flows.enumerated().map { index, flow in
            buildResult(flow, uuid: Self.uuid(for: flow, index: index), startMs: report.startedAtEpochMs)
        }
        return JSONValue.array(objects).serialized(pretty: true) + "\n"
    }

    private func buildResult(_ flow: FlowResult, uuid: String, startMs: Int64) -> JSONValue {
        var cursor = startMs
        var stepValues: [JSONValue] = []
        for step in flow.steps {
            let sStart = cursor
            let sStop = cursor + Int64(step.durationMs)
            cursor = sStop
            var stepFields: [(String, JSONValue)] = [
                ("name", .string(step.label ?? step.command)),
                ("status", .string(Self.allureStatus(step.status))),
                ("stage", .string("finished")),
                ("start", .int64(sStart)),
                ("stop", .int64(sStop)),
            ]
            if let msg = step.message {
                stepFields.append(("statusDetails", .object([("message", .string(msg))])))
            }
            stepValues.append(.object(stepFields))
        }

        var labels: [JSONValue] = [
            .object([("name", .string("suite")), ("value", .string("swiftmaestro"))]),
        ]
        if let appId = flow.appId {
            labels.append(.object([("name", .string("package")), ("value", .string(appId))]))
        }
        for tag in flow.tags {
            labels.append(.object([("name", .string("tag")), ("value", .string(tag))]))
        }

        var fields: [(String, JSONValue)] = [
            ("uuid", .string(uuid)),
            ("historyId", .string(uuid)),
            ("name", .string(flow.name)),
            ("fullName", .string(flow.filePath ?? flow.name)),
            ("status", .string(Self.allureStatus(flow.status))),
        ]
        if let msg = flow.message {
            fields.append(("statusDetails", .object([("message", .string(msg))])))
        }
        fields.append(("stage", .string("finished")))
        fields.append(("start", .int64(startMs)))
        fields.append(("stop", .int64(startMs + Int64(flow.durationMs))))
        fields.append(("labels", .array(labels)))
        fields.append(("steps", .array(stepValues)))
        return .object(fields)
    }

    private static func uuid(for flow: FlowResult, index: Int) -> String {
        "swiftmaestro-\(index)"
    }

    private static func allureStatus(_ s: RunStatus) -> String {
        switch s {
        case .passed: return "passed"
        case .failed: return "failed"
        case .error: return "broken"
        case .skipped: return "skipped"
        }
    }
}
