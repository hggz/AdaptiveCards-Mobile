import XCTest
import Foundation
@testable import SwiftMaestroReport

final class ReportGeneratorTests: XCTestCase {

    // MARK: - Aggregates

    func testReportAggregates() {
        let report = sampleReport()
        XCTAssertEqual(report.total, 2)
        XCTAssertEqual(report.passed, 1)
        XCTAssertEqual(report.failed, 1)
        XCTAssertEqual(report.skipped, 0)
        XCTAssertEqual(report.durationMs, 1794)
        XCTAssertFalse(report.isSuccess)
    }

    func testTimestampFormatting() {
        XCTAssertEqual(ReportFormatting.iso8601UTC(epochMs: 1_700_000_000_000), "2023-11-14T22:13:20Z")
        XCTAssertEqual(ReportFormatting.iso8601UTC(epochMs: 0), "1970-01-01T00:00:00Z")
        XCTAssertEqual(ReportFormatting.seconds(fromMs: 1234), "1.234")
        XCTAssertEqual(ReportFormatting.seconds(fromMs: 40), "0.040")
        XCTAssertEqual(ReportFormatting.seconds(fromMs: 0), "0.000")
    }

    // MARK: - Golden files

    func testJSONReportGolden() {
        assertGolden(JSONReportGenerator().generate(sampleReport()), "report.json")
    }

    func testJUnitReportGolden() {
        assertGolden(JUnitReportGenerator().generate(sampleReport()), "report.xml")
    }

    func testHTMLReportGolden() {
        assertGolden(HTMLReportGenerator().generate(sampleReport()), "report.html")
    }

    func testAllureReportGolden() {
        assertGolden(AllureReportGenerator().generate(sampleReport()), "allure.json")
    }

    // MARK: - Structural validity (independent of goldens)

    func testJSONReportIsValidJSON() throws {
        let text = JSONReportGenerator().generate(sampleReport())
        let obj = try JSONSerialization.jsonObject(with: Data(text.utf8)) as? [String: Any]
        let summary = try XCTUnwrap(obj?["summary"] as? [String: Any])
        XCTAssertEqual(summary["failed"] as? Int, 1)
        XCTAssertEqual(summary["success"] as? Bool, false)
    }

    func testAllureOutputIsValidJSONAndMapsStatus() throws {
        let text = AllureReportGenerator().generate(sampleReport())
        let arr = try JSONSerialization.jsonObject(with: Data(text.utf8)) as? [[String: Any]]
        XCTAssertEqual(arr?.count, 2)
        XCTAssertEqual(arr?[0]["status"] as? String, "passed")
        XCTAssertEqual(arr?[1]["status"] as? String, "failed")
    }

    func testAllureResultFilesOnePerFlow() {
        let files = AllureReportGenerator().resultFiles(sampleReport())
        XCTAssertEqual(files.count, 2)
        XCTAssertEqual(files.map { $0.name }, ["swiftmaestro-0-result.json", "swiftmaestro-1-result.json"])
    }

    func testJUnitReportIsWellFormedXML() throws {
        let text = JUnitReportGenerator().generate(sampleReport())
        XCTAssertTrue(text.hasPrefix("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        XCTAssertTrue(text.contains("<testsuites name=\"swiftmaestro\" tests=\"6\" failures=\"1\" skipped=\"1\""))
        XCTAssertTrue(text.contains("<failure message=\"element not found: text=&quot;Pay&quot;\""))
        XCTAssertTrue(text.contains("<skipped/>"))
        XCTAssertTrue(text.hasSuffix("</testsuites>\n"))
    }
}
