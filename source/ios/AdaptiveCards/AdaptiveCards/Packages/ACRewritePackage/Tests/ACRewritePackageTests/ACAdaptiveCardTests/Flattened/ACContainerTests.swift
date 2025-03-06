//
//  ACContainerTests.swift
//  ACSwiftRewriteTests
//
//  Created by Rahul Pinjani on 9/18/24.
//

import Foundation
import XCTest
@testable import ACRewritePackage


final class ACContainerTests: XCTestCase {

        func testAdaptiveCardDecoding() throws {
            let json = """
                 {
                            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                            "type": "AdaptiveCard",
                            "version": "1.0",
                            "backgroundImage": "https://adaptivecards.io/content/cats/1.png",
                            "body": [
                                {
                                    "type": "TextBlock",
                                    "text": "This is some text",
                                    "size": "large"
                                },
                                {
                                    "type": "Container",
                                    "style": "default",
                                    "selectAction": {
                                        "type": "Action.Submit",
                                        "title": "Container_Action.Submit",
                                        "data": "Container_data"
                                    },
                                    "id": "Container_id",
                                    "spacing": "medium",
                                    "separator": false,
                                    "rtl": true,
                                    "items": [
                                        {
                                            "type": "ColumnSet",
                                            "id": "ColumnSet_id",
                                            "spacing": "large",
                                            "separator": true,
                                            "columns": [
                                                {
                                                    "type": "Column",
                                                    "style": "default",
                                                    "width": "auto",
                                                    "id": "Column_id1",
                                                    "rtl": false,
                                                    "items": [
                                                        {
                                                            "type": "Image",
                                                            "url": "https://adaptivecards.io/content/cats/1.png"
                                                        }
                                                    ]
                                                },
                                                {
                                                    "type": "Column",
                                                    "style": "emphasis",
                                                    "width": "20px",
                                                    "id": "Column_id2",
                                                    "items": [
                                                        {
                                                            "type": "Image",
                                                            "url": "https://adaptivecards.io/content/cats/2.png"
                                                        }
                                                    ]
                                                },
                                                {
                                                    "type": "Column",
                                                    "style": "default",
                                                    "width": "stretch",
                                                    "id": "Column_id3",
                                                    "items": [
                                                        {
                                                            "type": "Image",
                                                            "url": "https://adaptivecards.io/content/cats/3.png"
                                                        },
                                                        {
                                                            "type": "TextBlock",
                                                            "text": "Column3_TextBlock_text",
                                                            "id": "Column3_TextBlock_id",
                                                            "fontType": "display"
                                                        }
                                                    ]
                                                }
                                            ]
                                        }
                                    ]
                                }
                            ]
            
            }
            """.data(using: .utf8)!
            
            let decoder = JSONDecoder()
            let adaptiveCard = try decoder.decode(SwiftACAdaptiveCard.self, from: json)
            
            XCTAssertEqual(adaptiveCard.schema, "http://adaptivecards.io/schemas/adaptive-card.json")
            XCTAssertEqual(adaptiveCard.type, "AdaptiveCard")
            XCTAssertEqual(adaptiveCard.version, "1.0")
            if case let .imageUrl(image) = adaptiveCard.backgroundImage {
                XCTAssertEqual(image, "https://adaptivecards.io/content/cats/1.png")
            }
            XCTAssertEqual(adaptiveCard.body.count, 2)
            
            if case let .textBlock(textBlock) = adaptiveCard.body[0] {
                XCTAssertEqual(textBlock.text, "This is some text")
                XCTAssertEqual(textBlock.size, SwiftACTextSize.large)
            } else {
                XCTFail("Expected first body element to be a TextBlock")
            }
            
            if case let .container(container) = adaptiveCard.body[1] {
                XCTAssertEqual(container.style, SwiftACContainerStyle.default)
     
                XCTAssertEqual(container.id, "Container_id")
                XCTAssertEqual(container.spacing, SwiftACSpacing.medium)
                XCTAssertEqual(container.separator, false)
                XCTAssertEqual(container.rtl, true)
                XCTAssertEqual(container.items.count, 1)
                
                if case let .columnSet(columnSet) = container.items[0] {
                    XCTAssertEqual(columnSet.id, "ColumnSet_id")
                    XCTAssertEqual(columnSet.spacing, SwiftACSpacing.large)
                    XCTAssertEqual(columnSet.separator, true)
                    XCTAssertEqual(columnSet.columns.count, 3)
                    
                    let column1 = columnSet.columns[0]
                    XCTAssertEqual(column1.style, SwiftACContainerStyle.default)
                    XCTAssertEqual(column1.width, "auto")
                    XCTAssertEqual(column1.id, "Column_id1")
                    XCTAssertEqual(column1.rtl, false)
                    XCTAssertEqual(column1.items.count, 1)
                    
                    if case let .image(image) = column1.items[0] {
                        XCTAssertEqual(image.url, "https://adaptivecards.io/content/cats/1.png")
                    } else {
                        XCTFail("Expected first item in column1 to be an Image")
                    }
                    
                    let column2 = columnSet.columns[1]
                    XCTAssertEqual(column2.style, SwiftACContainerStyle.emphasis)
                    XCTAssertEqual(column2.width, "20px")
                    XCTAssertEqual(column2.id, "Column_id2")
                    XCTAssertEqual(column2.items.count, 1)
                    
                    if case let .image(image) = column2.items[0] {
                        XCTAssertEqual(image.url, "https://adaptivecards.io/content/cats/2.png")
                    } else {
                        XCTFail("Expected first item in column2 to be an Image")
                    }
                    
                    let column3 = columnSet.columns[2]
                    XCTAssertEqual(column3.style, SwiftACContainerStyle.default)
                    XCTAssertEqual(column3.width, "stretch")
                    XCTAssertEqual(column3.id, "Column_id3")
                    XCTAssertEqual(column3.items.count, 2)
                    
                    if case let .image(image) = column3.items[0] {
                        XCTAssertEqual(image.url, "https://adaptivecards.io/content/cats/3.png")
                    } else {
                        XCTFail("Expected first item in column3 to be an Image")
                    }
                    
                    if case let .textBlock(textBlock) = column3.items[1] {
                        XCTAssertEqual(textBlock.text, "Column3_TextBlock_text")
                     //   XCTAssertEqual(textBlock., "Column3_TextBlock_id")
                    } else {
                        XCTFail("Expected second item in column3 to be a TextBlock")
                    }
                } else {
                    XCTFail("Expected first item in container to be a ColumnSet")
                }
            } else {
                XCTFail("Expected second body element to be a Container")
            }
        }

}
