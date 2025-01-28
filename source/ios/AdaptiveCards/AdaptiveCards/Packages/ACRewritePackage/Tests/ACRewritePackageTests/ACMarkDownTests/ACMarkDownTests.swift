//
//  ACMarkDownTests.swift
//  ACSwiftRewriteTests
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation
import XCTest

@testable import ACRewritePackage
class MarkdownTests: XCTestCase {

    func testEmphasisLeftDelimiterTest_UnderscoreLeftDelimiterCanBeProceededAndFollowedByPunct() {
        let parser = MarkDownParser(txt: "foo-_(bar)_")
        XCTAssertEqual("<p>foo-<em>(bar)</em></p>", parser.transformToHtml())
    }

    func testEmphasisDelimiterTest_MatchingRightDelimiterTest() {
        let parser = MarkDownParser(txt: "_foo_")
        XCTAssertEqual("<p><em>foo</em></p>", parser.transformToHtml())
    }

    func testEmphasisDelimiterTest_NonMatchingDelimiterTest() {
        let parser = MarkDownParser(txt: "_foo*")
        XCTAssertEqual("<p>_foo*</p>", parser.transformToHtml())
    }

    func testEmphasisDelimiterTest_MatchingRightDelimiterWithSpaceTest() {
        let parser = MarkDownParser(txt: "*foo *")
        XCTAssertEqual("<p>*foo *</p>", parser.transformToHtml())
    }

    func testEmphasisDelimiterTest_ValidDelimitersSurroundedByPunctuationTest() {
        let parser = MarkDownParser(txt: "*(*foo*)*")
        XCTAssertEqual("<p><em>(<em>foo</em>)</em></p>", parser.transformToHtml())
    }

    func testEmphasisDelimiterTest_PunctuationSurroundedByDelimiterValidTest() {
        let parser = MarkDownParser(txt: "*(foo)*")
        XCTAssertEqual("<p><em>(foo)</em></p>", parser.transformToHtml())
    }

    func testEmphasisDelimiterTest_ValidIntraWordEmphasisTest() {
        let parser = MarkDownParser(txt: "*foo*bar")
        XCTAssertEqual("<p><em>foo</em>bar</p>", parser.transformToHtml())
    }

    func testEmphasisDelimiterTest_WhiteSpaceClosingEmphasisInvalidTest() {
        let parser = MarkDownParser(txt: "_foo bar _")
        XCTAssertEqual("<p>_foo bar _</p>", parser.transformToHtml())
    }

    func testEmphasisDelimiterTest_InvalidIntraWordEmphasisTest() {
        let parser = MarkDownParser(txt: "_foo_bar")
        XCTAssertEqual("<p>_foo_bar</p>", parser.transformToHtml())
    }

    func testEmphasisDelimiterTest_RightDelimiterFollowedByPunctuationValidTest() {
        let parser = MarkDownParser(txt: "_(bar)_.")
        XCTAssertEqual("<p><em>(bar)</em>.</p>", parser.transformToHtml())
    }

    func testStrongDelimiterTest_SimpleValidCaseTest() {
        let parser = MarkDownParser(txt: "**foo bar**")
        XCTAssertEqual("<p><strong>foo bar</strong></p>", parser.transformToHtml())
        let parser1 = MarkDownParser(txt: "__foo bar__")
        XCTAssertEqual("<p><strong>foo bar</strong></p>", parser1.transformToHtml())
    }

    func testStrongDelimiterTest_DelimiterWithSpaceInvalidCaseTest() {
        let parser = MarkDownParser(txt: "** foo bar**")
        XCTAssertEqual("<p>** foo bar**</p>", parser.transformToHtml())
    }

    func testEscapeHtmlCharactersTest_CanDetectEscapeTest() {
        let parser = MarkDownParser(txt: "")
        XCTAssertEqual(false, parser.isEscaped())
        _ = parser.transformToHtml()
        XCTAssertEqual(false, parser.isEscaped())

        let parser1 = MarkDownParser(txt: "&")
        _ = parser1.transformToHtml()
        XCTAssertEqual(true, parser1.isEscaped())

        let parser2 = MarkDownParser(txt: "Hello World&")
        _ = parser2.transformToHtml()
        XCTAssertEqual(true, parser2.isEscaped())

        let parser3 = MarkDownParser(txt: " & ")
        _ = parser3.transformToHtml()
        XCTAssertEqual(true, parser3.isEscaped())
    }

    func testRule9Test_MultipleOf3Test() {
        XCTAssertEqual("<p>Hello***World***</p>", MarkDownParser(txt: "Hello***World***").transformToHtml())
    }
}
