// Port of: pkg/report (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// A single-file report generator (JSON, JUnit XML, HTML). Allure emits a set of
/// files and has its own API in `AllureReportGenerator`.
public protocol ReportGenerator: Sendable {
    /// Short format identifier: `json`, `junit`, `html`.
    var format: String { get }
    /// The conventional output file name for this format.
    var fileName: String { get }
    /// Render the report to a single text document.
    func generate(_ report: TestReport) -> String
}

/// Deterministic, locale-independent formatting helpers shared by the
/// generators. None of these consult the wall clock or the current locale, so
/// output bytes are identical on every platform.
enum ReportFormatting {

    /// ISO-8601 UTC timestamp (`YYYY-MM-DDTHH:MM:SSZ`) from epoch milliseconds,
    /// computed arithmetically to avoid `DateFormatter` locale/timezone drift.
    static func iso8601UTC(epochMs: Int64) -> String {
        let secs = floorDiv(epochMs, 1000)
        let dayCount = Int(floorDiv(secs, 86400))
        let tod = Int(secs - Int64(dayCount) * 86400)
        let (y, m, d) = civilFromDays(dayCount)
        let hh = tod / 3600
        let mm = (tod % 3600) / 60
        let ss = tod % 60
        return String(format: "%04d-%02d-%02dT%02d:%02d:%02dZ", y, m, d, hh, mm, ss)
    }

    /// Milliseconds rendered as fractional seconds (`1234` -> `"1.234"`),
    /// assembled from integers so no locale decimal separator can sneak in.
    static func seconds(fromMs ms: Int) -> String {
        let whole = ms / 1000
        let frac = abs(ms % 1000)
        let f = String(frac)
        let padded = String(repeating: "0", count: max(0, 3 - f.count)) + f
        return "\(whole).\(padded)"
    }

    static func floorDiv(_ a: Int64, _ b: Int64) -> Int64 {
        let q = a / b
        let r = a % b
        return (r != 0 && (r < 0) != (b < 0)) ? q - 1 : q
    }

    /// Howard Hinnant's `civil_from_days`: days-since-epoch -> (year, month, day).
    static func civilFromDays(_ z0: Int) -> (Int, Int, Int) {
        var z = z0
        z += 719468
        let era = (z >= 0 ? z : z - 146096) / 146097
        let doe = z - era * 146097
        let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365
        let y = yoe + era * 400
        let doy = doe - (365 * yoe + yoe / 4 - yoe / 100)
        let mp = (5 * doy + 2) / 153
        let d = doy - (153 * mp + 2) / 5 + 1
        let m = mp < 10 ? mp + 3 : mp - 9
        return (m <= 2 ? y + 1 : y, m, d)
    }

    static func xmlEscape(_ s: String) -> String {
        var r = ""
        for c in s {
            switch c {
            case "&": r += "&amp;"
            case "<": r += "&lt;"
            case ">": r += "&gt;"
            case "\"": r += "&quot;"
            case "'": r += "&apos;"
            default: r.append(c)
            }
        }
        return r
    }

    static func htmlEscape(_ s: String) -> String {
        var r = ""
        for c in s {
            switch c {
            case "&": r += "&amp;"
            case "<": r += "&lt;"
            case ">": r += "&gt;"
            case "\"": r += "&quot;"
            default: r.append(c)
            }
        }
        return r
    }
}
