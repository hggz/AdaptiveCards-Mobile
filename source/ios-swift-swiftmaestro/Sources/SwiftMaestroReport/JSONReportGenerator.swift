// Port of: pkg/report (JSON) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// Emits a structured JSON report with a run summary and per-flow/per-step detail.
public struct JSONReportGenerator: ReportGenerator {
    public init() {}
    public var format: String { "json" }
    public var fileName: String { "report.json" }

    public func generate(_ report: TestReport) -> String {
        let summary: JSONValue = .object([
            ("total", .int(report.total)),
            ("passed", .int(report.passed)),
            ("failed", .int(report.failed)),
            ("skipped", .int(report.skipped)),
            ("durationMs", .int(report.durationMs)),
            ("startedAt", .string(ReportFormatting.iso8601UTC(epochMs: report.startedAtEpochMs))),
            ("success", .bool(report.isSuccess)),
        ])

        let flows: JSONValue = .array(report.flows.map { flow in
            .object([
                ("name", .string(flow.name)),
                ("file", .optional(flow.filePath)),
                ("appId", .optional(flow.appId)),
                ("tags", .array(flow.tags.map { .string($0) })),
                ("device", .optional(flow.device)),
                ("status", .string(flow.status.rawValue)),
                ("durationMs", .int(flow.durationMs)),
                ("message", .optional(flow.message)),
                ("steps", .array(flow.steps.map { step in
                    .object([
                        ("command", .string(step.command)),
                        ("label", .optional(step.label)),
                        ("status", .string(step.status.rawValue)),
                        ("durationMs", .int(step.durationMs)),
                        ("message", .optional(step.message)),
                    ])
                })),
            ])
        })

        let root: JSONValue = .object([
            ("summary", summary),
            ("flows", flows),
        ])
        return root.serialized(pretty: true) + "\n"
    }
}
