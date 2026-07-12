// Port of: pkg/report (JUnit XML) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// Emits a JUnit-style XML report: one `<testsuite>` per flow, one `<testcase>`
/// per step. Consumed by CI systems that understand the JUnit schema.
public struct JUnitReportGenerator: ReportGenerator {
    public init() {}
    public var format: String { "junit" }
    public var fileName: String { "report.xml" }

    public func generate(_ report: TestReport) -> String {
        let esc = ReportFormatting.xmlEscape
        var out = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        out += "<testsuites name=\"swiftmaestro\" tests=\"\(stepCount(report))\""
        out += " failures=\"\(failureCount(report))\" skipped=\"\(skipCount(report))\""
        out += " time=\"\(ReportFormatting.seconds(fromMs: report.durationMs))\">\n"

        for flow in report.flows {
            out += "  <testsuite name=\"\(esc(flow.name))\" tests=\"\(flow.steps.count)\""
            out += " failures=\"\(flow.failedSteps)\" skipped=\"\(flow.skippedSteps)\""
            out += " time=\"\(ReportFormatting.seconds(fromMs: flow.durationMs))\""
            out += " timestamp=\"\(ReportFormatting.iso8601UTC(epochMs: report.startedAtEpochMs))\">\n"

            for step in flow.steps {
                let caseName = step.label ?? step.command
                out += "    <testcase name=\"\(esc(caseName))\" classname=\"\(esc(flow.name))\""
                out += " time=\"\(ReportFormatting.seconds(fromMs: step.durationMs))\""
                switch step.status {
                case .passed:
                    out += "/>\n"
                case .skipped:
                    out += ">\n      <skipped/>\n    </testcase>\n"
                case .failed, .error:
                    let msg = step.message ?? "step failed"
                    let type = step.status == .error ? "Error" : "AssertionError"
                    out += ">\n      <failure message=\"\(esc(msg))\" type=\"\(type)\">\(esc(msg))</failure>\n"
                    out += "    </testcase>\n"
                }
            }
            out += "  </testsuite>\n"
        }
        out += "</testsuites>\n"
        return out
    }

    private func stepCount(_ r: TestReport) -> Int { r.flows.reduce(0) { $0 + $1.steps.count } }
    private func failureCount(_ r: TestReport) -> Int { r.flows.reduce(0) { $0 + $1.failedSteps } }
    private func skipCount(_ r: TestReport) -> Int { r.flows.reduce(0) { $0 + $1.skippedSteps } }
}
