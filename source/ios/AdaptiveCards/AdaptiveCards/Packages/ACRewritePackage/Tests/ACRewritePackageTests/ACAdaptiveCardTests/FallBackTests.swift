//
//  FallBackTests.swift
//  ACSwiftRewriteTests
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation
import XCTest
@testable import ACRewritePackage

class FallbackTests: XCTestCase {

    func testElementFallbackSerialization() {
        let cardStr = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type" : "AdaptiveCard",
            "version" : "1.2",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Primary TextBlock",
                    "fallback": {
                        "type": "TextBlock",
                        "text": "Fallback TextBlock"
                    }
                }
            ]
        }
        """

        do {
            let cardData = cardStr.data(using: .utf8)!
            let card = try JSONDecoder().decode(AdaptiveCard.self, from: cardData)
            
            XCTAssertEqual(card.body.count, 1)
            if case let .textBlock(textBlock) = card.body.first  {
                XCTAssertEqual(textBlock.text, "Primary TextBlock")
                if case let .textBlock(fallBackElement) = textBlock.fallback {
                    XCTAssertEqual(fallBackElement.text, "Fallback TextBlock")
                } else {
                    XCTFail("Fallback is not a TextBlock")
                }
            } else {
                XCTFail("Body element is not a TextBlock")
            }
        } catch {
            XCTFail("Failed to decode AdaptiveCard: \(error)")
        }
    }

    func testComplexFallbackSerialization() {
        let cardStr = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type" : "AdaptiveCard",
            "version" : "1.2",
            "body": [
                {
                    "type": "ColumnSet",
                    "id": "A",
                    "columns": [
                        {
                            "type": "Column",
                            "id": "B",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "id": "C",
                                    "text": "C TextBlock",
                                    "fallback": {
                                        "type": "Container",
                                        "id": "E",
                                        "items": [
                                            {
                                                "type": "Image",
                                                "id": "I",
                                                "url": "http://adaptivecards.io/content/cats/2.png"
                                            },
                                            {
                                                "type": "TextBlock",
                                                "id": "J",
                                                "text": "C ColumnSet fallback textblock"
                                            }
                                        ]
                                    }
                                }
                            ]
                        }
                    ]
                },
                {
                    "type": "TextBlock",
                    "id": "F",
                    "text": "F TextBlock"
                }
            ]
        }
        """

        do {
            let cardData = cardStr.data(using: .utf8)!
            let card = try JSONDecoder().decode(AdaptiveCard.self, from: cardData)
            
            XCTAssertEqual(card.body.count, 2)
            if case let .columnSet(columnSet) = card.body.first {
                XCTAssertEqual(columnSet.id, "A")
                XCTAssertEqual(columnSet.columns.count, 1)
                if let column = columnSet.columns.first {
                    XCTAssertEqual(column.id, "B")
                    XCTAssertEqual(column.items.count, 1)
                    if case let .textBlock(textBlock) = column.items.first {
                        XCTAssertEqual(textBlock.id, "C")
                        XCTAssertEqual(textBlock.text, "C TextBlock")
                        if case let .container(fallbackContainer) = textBlock.fallback  {
                            XCTAssertEqual(fallbackContainer.id, "E")
                            XCTAssertEqual(fallbackContainer.items.count, 2)
                            if case let .image(image) = fallbackContainer.items.first {
                                XCTAssertEqual(image.id, "I")
                                XCTAssertEqual(image.url, "http://adaptivecards.io/content/cats/2.png")
                            } else {
                                XCTFail("First item in fallback container is not an Image")
                            }
                            if case let .textBlock(fallbackTextBlock) = fallbackContainer.items.last {
                                XCTAssertEqual(fallbackTextBlock.id, "J")
                                XCTAssertEqual(fallbackTextBlock.text, "C ColumnSet fallback textblock")
                            } else {
                                XCTFail("Second item in fallback container is not a TextBlock")
                            }
                        } else {
                            XCTFail("Fallback is not a Container")
                        }
                    } else {
                        XCTFail("First item in column is not a TextBlock")
                    }
                } else {
                    XCTFail("Column is missing")
                }
            } else {
                XCTFail("First body element is not a ColumnSet")
            }
            if case let .textBlock(textBlock) = card.body.last {
                XCTAssertEqual(textBlock.id, "F")
                XCTAssertEqual(textBlock.text, "F TextBlock")
            } else {
                XCTFail("Second body element is not a TextBlock")
            }
        } catch {
            XCTFail("Failed to decode AdaptiveCard: \(error)")
        }
    }
}
