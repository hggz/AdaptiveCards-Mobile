import XCTest
@testable import ACRewritePackage

final class MarkdownTests: XCTestCase {
    
    func testMarkDownBasicSanityTest_CanHandleEmptyStringTest() {
        let parser = MarkDownParser(txt: "")
        XCTAssertEqual("<p></p>", parser.transformToHtml())
        XCTAssertFalse(parser.hasHtmlTags())
    }
    
    func testMarkDownBasicSanityTest_CanHandleEmphasisTest() {
        let parser = MarkDownParser(txt: "*")
        XCTAssertEqual("<p>*</p>", parser.transformToHtml())
        XCTAssertFalse(parser.hasHtmlTags())
    }
    
    func testMarkDownBasicSanityTest_CanHandleStrongEmphasisTest() {
        let parser = MarkDownParser(txt: "**")
        XCTAssertEqual("<p>**</p>", parser.transformToHtml())
        XCTAssertFalse(parser.hasHtmlTags())
    }
    
    func testEmphasisLeftDelimiterTest_LeftDelimiterTest() {
        let parser = MarkDownParser(txt: "*foo bar*")
        XCTAssertEqual("<p><em>foo bar</em></p>", parser.transformToHtml())
    }
    
    func testEmphasisLeftDelimiterTest_UnderscoreLeftDelimiterTest() {
        let parser = MarkDownParser(txt: "_foo bar_")
        XCTAssertEqual("<p><em>foo bar</em></p>", parser.transformToHtml())
    }
    
    func testEmphasisLeftDelimiterTest_UnderscoreLeftDelimiterFalseCaseWithSpaceTest() {
        let parser = MarkDownParser(txt: "_ foo bar_")
        XCTAssertEqual("<p>_ foo bar_</p>", parser.transformToHtml())
        XCTAssertFalse(parser.hasHtmlTags())
    }
    
    func testEmphasisLeftDelimiterTest_LeftDelimiterFalseCaseWithAlphaNumericInfrontAndPuntuationBehind() {
        let parser = MarkDownParser(txt: "a*\"foo\"*")
        XCTAssertEqual("<p>a*&quot;foo&quot;*</p>", parser.transformToHtml())
    }
    
    func testEmphasisLeftDelimiterTest_UnderscoreLeftDelimiterFalseCaseWithAlphaNumericInfrontAndPuntuationBehind() {
        let parser = MarkDownParser(txt: "a_\"foo\"_")
        XCTAssertEqual("<p>a_&quot;foo&quot;_</p>", parser.transformToHtml())
    }
    
    func testEmphasisLeftDelimiterTest_LeftDelimiterIntraWordEmphasis() {
        let parser = MarkDownParser(txt: "foo*bar*")
        XCTAssertEqual("<p>foo<em>bar</em></p>", parser.transformToHtml())
    }
    
    func testEmphasisLeftDelimiterTest_UnderscoreLeftDelimiterIntraWordEmphasis() {
        let parser = MarkDownParser(txt: "foo_bar_")
        XCTAssertEqual("<p>foo_bar_</p>", parser.transformToHtml())
    }
    
    func testEmphasisLeftDelimiterTest_LeftDelimiterNumericIntraWordEmphasis() {
        let parser = MarkDownParser(txt: "5*6*78")
        XCTAssertEqual("<p>5<em>6</em>78</p>", parser.transformToHtml())
    }
    
    func testEmphasisLeftDelimiterTest_UnderscoreLeftDelimiterNumericIntraWordEmphasis() {
        let parser = MarkDownParser(txt: "5_6_78")
        XCTAssertEqual("<p>5_6_78</p>", parser.transformToHtml())
    }
    
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
    
    // ... continuing with more tests ...
    
    func testEmphasisDelimiterTest_MatchingRightDelimiterWithSpaceTest() {
        let parser = MarkDownParser(txt: "*foo *")
        XCTAssertEqual("<p>*foo *</p>", parser.transformToHtml())
    }
    
    func testEmphasisDelimiterTest_ValidDelimitersSurroundedByPunctuationTest() {
        let parser = MarkDownParser(txt: "*(*foo*)*")
        XCTAssertEqual("<p><em>(<em>foo</em>)</em></p>", parser.transformToHtml())
    }
    
    func testLinkBasicValidationTest_CanGenerateValidHtmlTagForLinkTest() {
        let parser = MarkDownParser(txt: "[hello](www.naver.com)")
        XCTAssertEqual("<p><a href=\"www.naver.com\">hello</a></p>", parser.transformToHtml())
    }
    
    func testListTest_SimpleValidListTest() {
        let parser = MarkDownParser(txt: "- hello")
        XCTAssertEqual("<ul><li>hello</li></ul>", parser.transformToHtml())
        
        let parser2 = MarkDownParser(txt: "* hello")
        XCTAssertEqual("<ul><li>hello</li></ul>", parser2.transformToHtml())
        
        let parser3 = MarkDownParser(txt: "+ hello")
        XCTAssertEqual("<ul><li>hello</li></ul>", parser3.transformToHtml())
    }
    
    func testOrderedListTest_SimpleValidListTest() {
        let parser = MarkDownParser(txt: "1. hello")
        XCTAssertEqual("<ol start=\"1\"><li>hello</li></ol>", parser.transformToHtml())
    }
    
    func testEscapeHtmlCharactersTest_GreaterThanTest() {
        let parser = MarkDownParser(txt: "5>3")
        XCTAssertEqual("<p>5&gt;3</p>", parser.transformToHtml())
    }
    
    func testEscapeHtmlCharactersTest_LessThanTest() {
        let parser = MarkDownParser(txt: "3<5")
        XCTAssertEqual("<p>3&lt;5</p>", parser.transformToHtml())
    }
    
    func testEscapeHtmlCharactersTest_QuotationTest() {
        let parser = MarkDownParser(txt: "\"Hello World!\"")
        XCTAssertEqual("<p>&quot;Hello World!&quot;</p>", parser.transformToHtml())
    }
    
    func testEscapeHtmlCharactersTest_AmpersandTest() {
        let parser = MarkDownParser(txt: "Green Eggs & Ham")
        XCTAssertEqual("<p>Green Eggs &amp; Ham</p>", parser.transformToHtml())
    }
    
    func testNonLatinCharacters_NoMarkdown() {
        let parser = MarkDownParser(txt: "以前の製品のリンクで検索")
        XCTAssertEqual("<p>以前の製品のリンクで検索</p>", parser.transformToHtml())
    }
    
    func testNonLatinCharacters_Bold() {
        let parser = MarkDownParser(txt: "**以前の製品のリンクで検索**")
        XCTAssertEqual("<p><strong>以前の製品のリンクで検索</strong></p>", parser.transformToHtml())
    }
    
    func testLinkBasicValidationTest_ValidLinkTestWithUnMatchingBrackets() {
        let parser = MarkDownParser(txt: "[[[[hello](www.naver.com)")
        XCTAssertEqual("<p>[[[<a href=\"www.naver.com\">hello</a></p>", parser.transformToHtml())
    }
    
    func testLinkBasicValidationTest_ValidLinkTestWithMatchingInnerBrackets() {
        let parser = MarkDownParser(txt: "[[hello]](www.naver.com)")
        XCTAssertEqual("<p><a href=\"www.naver.com\">[hello]</a></p>", parser.transformToHtml())
    }
    
        func testMultipleListWithLinkTest() {
        let parser = MarkDownParser(txt: "1. hello world\r2. hello hello\r3. new site = [adaptive card](www.adaptivecards.io)")
        XCTAssertEqual("<ol start=\"1\"><li>hello world</li><li>hello hello</li><li>new site = <a href=\"www.adaptivecards.io\">adaptive card</a></li></ol>", parser.transformToHtml())
    }

    func testEscapeHtmlCharactersTest_CanDetectEscapeTest() {
        let parser = MarkDownParser(txt: "")
        XCTAssertFalse(parser.isEscaped())
        
        _ = parser.transformToHtml()
        XCTAssertFalse(parser.isEscaped())
        
        let parser1 = MarkDownParser(txt: "&")
        _ = parser1.transformToHtml()
        XCTAssertTrue(parser1.isEscaped())
        
        let parser2 = MarkDownParser(txt: "Hello World&")
        _ = parser2.transformToHtml()
        XCTAssertTrue(parser2.isEscaped())
        
        let parser3 = MarkDownParser(txt: " & ")
        _ = parser3.transformToHtml()
        XCTAssertTrue(parser3.isEscaped())
    }

    func testRule9Test_MultipleOf3Test() {
        let parser = MarkDownParser(txt: "Hello***World***")
        XCTAssertEqual("<p>Hello***World***</p>", parser.transformToHtml())
    }

    func testDelimiterNestingTest_PunctuationDelimitersTest() {
        let parser = MarkDownParser(txt: "_foo __bar__ baz_")
        XCTAssertEqual("<p><em>foo <strong>bar</strong> baz</em></p>", parser.transformToHtml())

        let parser2 = MarkDownParser(txt: "*foo *bar**")
        XCTAssertEqual("<p><em>foo <em>bar</em></em></p>", parser2.transformToHtml())

        let parser3 = MarkDownParser(txt: "_foo _bar_ baz_")
        XCTAssertEqual("<p><em>foo <em>bar</em> baz</em></p>", parser3.transformToHtml())

        let parser4 = MarkDownParser(txt: "*foo **bar** baz*")
        XCTAssertEqual("<p><em>foo <strong>bar</strong> baz</em></p>", parser4.transformToHtml())

        let parser5 = MarkDownParser(txt: "*foo **bar *baz* bim** bop*")
        XCTAssertEqual("<p><em>foo <strong>bar <em>baz</em> bim</strong> bop</em></p>", parser5.transformToHtml())
    }

    func testRule11_12Test_EscapeTest() {
        let parser = MarkDownParser(txt: "foo *\\**")
        XCTAssertEqual("<p>foo <em>*</em></p>", parser.transformToHtml())

        let parser2 = MarkDownParser(txt: "foo **\\***")
        XCTAssertEqual("<p>foo <strong>*</strong></p>", parser2.transformToHtml())

        let parser3 = MarkDownParser(txt: "foo __\\___")
        XCTAssertEqual("<p>foo <strong>_</strong></p>", parser3.transformToHtml())
    }

    func testRule11_12Test_UnevenMatchingDelimiter() {
        let parser = MarkDownParser(txt: "**foo*")
        XCTAssertEqual("<p>*<em>foo</em></p>", parser.transformToHtml())

        let parser1 = MarkDownParser(txt: "*foo**")
        XCTAssertEqual("<p><em>foo</em>*</p>", parser1.transformToHtml())

        let parser2 = MarkDownParser(txt: "***foo**")
        XCTAssertEqual("<p>*<strong>foo</strong></p>", parser2.transformToHtml())

        let parser3 = MarkDownParser(txt: "*foo****")
        XCTAssertEqual("<p><em>foo</em>***</p>", parser3.transformToHtml())
    }

    func testRule13Test_strongEmphasisNesting() {
        let parser = MarkDownParser(txt: "****foo****")
        XCTAssertEqual("<p><strong><strong>foo</strong></strong></p>", parser.transformToHtml())

        let parser2 = MarkDownParser(txt: "******foo******")
        XCTAssertEqual("<p><strong><strong><strong>foo</strong></strong></strong></p>", parser2.transformToHtml())
    }

    func testRule14Test_strongAndEmphasisNesting() {
        let parser = MarkDownParser(txt: "***foo***")
        XCTAssertEqual("<p><strong><em>foo</em></strong></p>", parser.transformToHtml())

        let parser2 = MarkDownParser(txt: "_____foo_____")
        XCTAssertEqual("<p><strong><strong><em>foo</em></strong></strong></p>", parser2.transformToHtml())
    }

    func testRule15Test_OverlappingTest() {
        let parser = MarkDownParser(txt: "*foo _bar* baz_")
        XCTAssertEqual("<p><em>foo _bar</em> baz_</p>", parser.transformToHtml())

        let parser2 = MarkDownParser(txt: "*foo __bar *baz bim__ bam*")
        XCTAssertEqual("<p><em>foo <strong>bar *baz bim</strong> bam</em></p>", parser2.transformToHtml())
    }

    func testListTest_MultipleSimpleValidListTest() {
        let parser = MarkDownParser(txt: "- hello\n- world\n- hi")
        XCTAssertEqual("<ul><li>hello</li><li>world</li><li>hi</li></ul>", parser.transformToHtml())

        let parser2 = MarkDownParser(txt: "* hello\n* world\n* hi")
        XCTAssertEqual("<ul><li>hello</li><li>world</li><li>hi</li></ul>", parser2.transformToHtml())

        let parser3 = MarkDownParser(txt: "* hello\n- Hi")
        XCTAssertEqual("<ul><li>hello</li><li>Hi</li></ul>", parser3.transformToHtml())
    }

    func testOrderedListTest_ListStartsWithRandomNumberTest() {
        let parser = MarkDownParser(txt: "777. my list\rHello")
        XCTAssertEqual("<ol start=\"777\"><li>my list\rHello</li></ol>", parser.transformToHtml())
    }

    func testLinkNestedParenthesisTest() {
        let parser = MarkDownParser(txt: "[empty destination]()")
        XCTAssertEqual("<p><a href=\"\">empty destination</a></p>", parser.transformToHtml())

        let parser2 = MarkDownParser(txt: "[Stay tuned to Know [aaa] m (aa)ore](https://aaa.bbb.com/(a)sites(Test).doc?somegar)bageValue*afterstar()")
        XCTAssertEqual("<p><a href=\"https://aaa.bbb.com/(a)sites(Test).doc?somegar\">Stay tuned to Know [aaa] m (aa)ore</a>bageValue*afterstar()</p>", parser2.transformToHtml())

        let parser3 = MarkDownParser(txt: "[Stay tuned to Know more](https://aaa.bbb.com/(a)sites(Test).doc?somegarbageValue)*afterstar()")
        XCTAssertEqual("<p><a href=\"https://aaa.bbb.com/(a)sites(Test).doc?somegarbageValue\">Stay tuned to Know more</a>*afterstar()</p>", parser3.transformToHtml())
    }

    func testNonLatinCharacters_LinkTests() {
        let parser = MarkDownParser(txt: "It's OK!\rClick [以前の製品のリンクで検索](https://www.microsoft.com)\rClick [以前の製品のリンクで検索](https://www.microsoft.com)")
        XCTAssertEqual("<p>It's OK!\rClick <a href=\"https://www.microsoft.com\">以前の製品のリンクで検索</a>\rClick <a href=\"https://www.microsoft.com\">以前の製品のリンクで検索</a></p>", parser.transformToHtml())

        let parser2 = MarkDownParser(txt: "1. Click [以前の製品のリンクで検索](https://www.microsoft.com)\r2. Click [以前の製品のリンクで検索](https://www.microsoft.com)")
        XCTAssertEqual("<ol start=\"1\"><li>Click <a href=\"https://www.microsoft.com\">以前の製品のリンクで検索</a></li><li>Click <a href=\"https://www.microsoft.com\">以前の製品のリンクで検索</a></li></ol>", parser2.transformToHtml())
    }

    func testListTest_ListTestsWithInterHyphen() {
        let parser = MarkDownParser(txt: "- hello world - hello hello")
        XCTAssertEqual("<ul><li>hello world - hello hello</li></ul>", parser.transformToHtml())
        
        let parser2 = MarkDownParser(txt: "* hello world - hello hello")
        XCTAssertEqual("<ul><li>hello world - hello hello</li></ul>", parser2.transformToHtml())
        
        let parser3 = MarkDownParser(txt: "- hello world + hello hello")
        XCTAssertEqual("<ul><li>hello world + hello hello</li></ul>", parser3.transformToHtml())
    }
    
    func testListTest_MultipleListWithHyphenTests() {
        let parser = MarkDownParser(txt: "- hello world - hello hello\r- winner winner chicken dinner")
        XCTAssertEqual("<ul><li>hello world - hello hello</li><li>winner winner chicken dinner</li></ul>", parser.transformToHtml())
        
        let parser2 = MarkDownParser(txt: "* hello world * hello hello\r* winner winner chicken dinner")
        XCTAssertEqual("<ul><li>hello world * hello hello</li><li>winner winner chicken dinner</li></ul>", parser2.transformToHtml())
        
        let parser3 = MarkDownParser(txt: "+ hello world * hello hello\r+ winner winner chicken dinner")
        XCTAssertEqual("<ul><li>hello world * hello hello</li><li>winner winner chicken dinner</li></ul>", parser3.transformToHtml())
    }
    
    func testListTest_MultipleListWithHyphenAndEmphasisTests() {
        let parser = MarkDownParser(txt: "- hello world - hello hello\r- ***winner* winner** chicken dinner")
        XCTAssertEqual("<ul><li>hello world - hello hello</li><li><strong><em>winner</em> winner</strong> chicken dinner</li></ul>", parser.transformToHtml())
        
        let parser2 = MarkDownParser(txt: "* hello world * hello hello\r* ***winner* winner** chicken dinner")
        XCTAssertEqual("<ul><li>hello world * hello hello</li><li><strong><em>winner</em> winner</strong> chicken dinner</li></ul>", parser2.transformToHtml())
    }
    
    func testListTest_PtagedBlockElementFollowedByListTest() {
        let parser = MarkDownParser(txt: "Hello\r- my list")
        XCTAssertEqual("<p>Hello</p><ul><li>my list</li></ul>", parser.transformToHtml())
        XCTAssertTrue(parser.hasHtmlTags())
        
        let parser2 = MarkDownParser(txt: "Hello\r* my list")
        XCTAssertEqual("<p>Hello</p><ul><li>my list</li></ul>", parser2.transformToHtml())
        XCTAssertTrue(parser2.hasHtmlTags())
    }
    
    func testListTest_ListFollowedByPtagedBlockElementTest() {
        let parser = MarkDownParser(txt: "- my list\r\rHello")
        XCTAssertEqual("<ul><li>my list</li></ul><p>Hello</p>", parser.transformToHtml())
        
        let parser2 = MarkDownParser(txt: "* my list\r\rHello")
        XCTAssertEqual("<ul><li>my list</li></ul><p>Hello</p>", parser2.transformToHtml())
    }
    
    func testListTest_ListFollowedWithNewLineCharTest() {
        let parser = MarkDownParser(txt: "- my list\rHello")
        XCTAssertEqual("<ul><li>my list\rHello</li></ul>", parser.transformToHtml())
        
        let parser2 = MarkDownParser(txt: "* my list\rHello")
        XCTAssertEqual("<ul><li>my list\rHello</li></ul>", parser2.transformToHtml())
    }
    
    func testListTest_InvalidListStringReturnedUnchangedTest() {
        let parser = MarkDownParser(txt: "023-34-567")
        XCTAssertEqual("<p>023-34-567</p>", parser.transformToHtml())
        XCTAssertFalse(parser.hasHtmlTags())
    }
    
    func testOrderedListTest_PtagedBlockElementFollowedByListTest() {
        let parser = MarkDownParser(txt: "Hello\r1. my list")
        XCTAssertEqual("<p>Hello</p><ol start=\"1\"><li>my list</li></ol>", parser.transformToHtml())
        XCTAssertTrue(parser.hasHtmlTags())
    }
    
    func testOrderedListTest_ListFollowedByPtagedBlockElementTest() {
        let parser = MarkDownParser(txt: "1. my list\r\rHello")
        XCTAssertEqual("<ol start=\"1\"><li>my list</li></ol><p>Hello</p>", parser.transformToHtml())
    }
    
    func testOrderedListTest_ListFollowedWithNewLineCharTest() {
        let parser = MarkDownParser(txt: "1. my list\rHello")
        XCTAssertEqual("<ol start=\"1\"><li>my list\rHello</li></ol>", parser.transformToHtml())
    }
    
    func testLinkBasicValidationTest_InvalidLinkTest() {
        let parser = MarkDownParser(txt: "[hello(www.naver.com)")
        XCTAssertEqual("<p>[hello(www.naver.com)</p>", parser.transformToHtml())
        XCTAssertFalse(parser.hasHtmlTags())
    }
    
    func testLinkBasicValidationTest_InvalidLinkTestWithInvalidEmphasis() {
        let parser = MarkDownParser(txt: "*[*hello(www.naver.com)")
        XCTAssertEqual("<p>*[*hello(www.naver.com)</p>", parser.transformToHtml())
        XCTAssertFalse(parser.hasHtmlTags())
    }
    
    func testLinkBasicValidationTest_InvalidLinkTestWithValidEmphasis() {
        let parser = MarkDownParser(txt: "*[*hello(www.naver.com)*")
        XCTAssertEqual("<p>*[<em>hello(www.naver.com)</em></p>", parser.transformToHtml())
        XCTAssertTrue(parser.hasHtmlTags())
    }
    
    func testLinkBasicValidationTest_ValidLinkTestWithEscapedDelimiters() {
        let parser = MarkDownParser(txt: "[[cool link!]](https://contoso.com/New%20Document%20(1\\).docx)")
        XCTAssertEqual("<p><a href=\"https://contoso.com/New%20Document%20(1).docx\">[cool link!]</a></p>", parser.transformToHtml())
    }
    
    func testRule16Test_strongEmphasis() {
        let parser = MarkDownParser(txt: "**foo **bar baz**")
        XCTAssertEqual("<p>**foo <strong>bar baz</strong></p>", parser.transformToHtml())
        
        let parser2 = MarkDownParser(txt: "*foo *bar baz*")
        XCTAssertEqual("<p>*foo <em>bar baz</em></p>", parser2.transformToHtml())
        
        let parser3 = MarkDownParser(txt: "**K *J *foo**bar* *cool*")
        XCTAssertEqual("<p><strong>K *J *foo</strong>bar* <em>cool</em></p>", parser3.transformToHtml())
        
        let parser4 = MarkDownParser(txt: "**m *J *foo**bar *cool**")
        XCTAssertEqual("<p><strong>m *J *foo</strong>bar <em>cool</em>*</p>", parser4.transformToHtml())
    }
    
    func testStrongDelimiterTest() {
        let parser = MarkDownParser(txt: "**foo bar**")
        XCTAssertEqual("<p><strong>foo bar</strong></p>", parser.transformToHtml())

        let parser2 = MarkDownParser(txt: "** foo bar**")
        XCTAssertEqual("<p>** foo bar**</p>", parser2.transformToHtml())

        let parser3 = MarkDownParser(txt: "**foo bar **")
        XCTAssertEqual("<p>**foo bar **</p>", parser3.transformToHtml())
    }

}
