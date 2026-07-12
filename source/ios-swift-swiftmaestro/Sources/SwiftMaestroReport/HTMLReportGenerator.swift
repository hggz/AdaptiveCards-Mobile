// Port of: pkg/report (HTML) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// Emits a self-contained HTML report (inline CSS, no external assets). The only
/// timestamp shown is derived from the run's start time, so output is deterministic.
public struct HTMLReportGenerator: ReportGenerator {
    public init() {}
    public var format: String { "html" }
    public var fileName: String { "report.html" }

    public func generate(_ report: TestReport) -> String {
        let esc = ReportFormatting.htmlEscape
        let started = ReportFormatting.iso8601UTC(epochMs: report.startedAtEpochMs)
        let overall = report.isSuccess ? "passed" : "failed"

        var out = ""
        out += "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n"
        out += "<meta charset=\"UTF-8\">\n"
        out += "<title>swiftmaestro report</title>\n"
        out += "<style>\n"
        out += "body{font-family:-apple-system,Segoe UI,Roboto,sans-serif;margin:2rem;color:#222}\n"
        out += "h1{font-size:1.4rem}table{border-collapse:collapse;width:100%;margin:1rem 0}\n"
        out += "th,td{border:1px solid #ddd;padding:.4rem .6rem;text-align:left;font-size:.9rem}\n"
        out += "th{background:#f4f4f4}.passed{color:#137333}.failed{color:#c5221f}\n"
        out += ".error{color:#c5221f}.skipped{color:#8a6d00}.pill{font-weight:600}\n"
        out += "</style>\n</head>\n<body>\n"
        out += "<h1>swiftmaestro report <span class=\"pill \(overall)\">\(overall)</span></h1>\n"
        out += "<p>Started: \(started)</p>\n"
        out += "<p>Total: \(report.total) &middot; Passed: \(report.passed)"
        out += " &middot; Failed: \(report.failed) &middot; Skipped: \(report.skipped)"
        out += " &middot; Duration: \(ReportFormatting.seconds(fromMs: report.durationMs))s</p>\n"

        for flow in report.flows {
            out += "<h2>\(esc(flow.name)) <span class=\"pill \(flow.status.rawValue)\">\(flow.status.rawValue)</span></h2>\n"
            if let appId = flow.appId {
                out += "<p>appId: \(esc(appId))"
                if !flow.tags.isEmpty { out += " &middot; tags: \(esc(flow.tags.joined(separator: ", ")))" }
                out += "</p>\n"
            }
            out += "<table>\n<tr><th>#</th><th>Command</th><th>Status</th><th>Duration</th><th>Message</th></tr>\n"
            for (i, step) in flow.steps.enumerated() {
                let name = step.label ?? step.command
                out += "<tr><td>\(i + 1)</td><td>\(esc(name))</td>"
                out += "<td class=\"\(step.status.rawValue)\">\(step.status.rawValue)</td>"
                out += "<td>\(ReportFormatting.seconds(fromMs: step.durationMs))s</td>"
                out += "<td>\(esc(step.message ?? ""))</td></tr>\n"
            }
            out += "</table>\n"
        }

        out += "</body>\n</html>\n"
        return out
    }
}
