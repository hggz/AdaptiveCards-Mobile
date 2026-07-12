import XCTest
@testable import SwiftMaestroFlow

final class FlowValidatorTests: XCTestCase {

    private let validator = FlowValidator()

    func testValidDirectoryHasNoIssues() {
        let result = validator.validate(path: Fixtures.path("validator/valid"))
        XCTAssertTrue(result.isValid, "unexpected issues: \(result.issues)")
    }

    func testValidSingleFilePasses() {
        let result = validator.validate(path: Fixtures.path("validator/valid/main.yaml"))
        XCTAssertTrue(result.isValid, "unexpected issues: \(result.issues)")
    }

    func testMissingReferencedFilesAreReported() {
        let result = validator.validate(path: Fixtures.path("validator/missing"))
        let missing = result.issues(ofKind: .missingFile)
        XCTAssertEqual(missing.count, 3, "issues: \(result.issues)")
        XCTAssertTrue(missing.contains { $0.message.contains("does-not-exist.js") })
        XCTAssertTrue(missing.contains { $0.message.contains("nope.yaml") })
        XCTAssertTrue(missing.contains { $0.message.contains("missing.png") })
    }

    func testCircularRunFlowIsDetected() {
        let result = validator.validate(path: Fixtures.path("validator/circular"))
        XCTAssertEqual(result.issues(ofKind: .circularDependency).count, 1, "issues: \(result.issues)")
    }

    func testSelfReferentialRunFlowIsDetected() {
        let result = validator.validate(path: Fixtures.path("validator/selfcycle"))
        XCTAssertEqual(result.issues(ofKind: .circularDependency).count, 1, "issues: \(result.issues)")
    }

    func testUnknownCommandSurfacesAsSyntaxIssue() {
        let result = validator.validate(path: Fixtures.path("validator/syntax"))
        let syntax = result.issues(ofKind: .syntax)
        XCTAssertEqual(syntax.count, 1, "issues: \(result.issues)")
        XCTAssertTrue(syntax[0].message.contains("frobnicateWidget"))
    }

    func testMalformedYamlSurfacesAsSyntaxIssue() {
        let result = validator.validate(path: Fixtures.path("validator/malformed"))
        XCTAssertEqual(result.issues(ofKind: .syntax).count, 1, "issues: \(result.issues)")
    }

    func testMissingPathReportsNoFlowFiles() {
        let result = validator.validate(path: Fixtures.path("validator/does-not-exist"))
        XCTAssertEqual(result.issues(ofKind: .missingFile).count, 1)
        XCTAssertFalse(result.isValid)
    }
}
