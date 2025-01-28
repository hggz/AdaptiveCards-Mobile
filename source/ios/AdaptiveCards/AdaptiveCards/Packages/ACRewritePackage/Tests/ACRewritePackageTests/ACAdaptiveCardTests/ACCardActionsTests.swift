//
//  ACCardActionsTests.swift
//  ACSwiftRewriteTests
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation
import XCTest
@testable import ACRewritePackage

final class ACCardActionTests: XCTestCase {
    
    func testAdaptiveCardActionsParsing() throws {
        let json = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "Input.Text",
                    "id": "iconInlineActionId",
                    "label": "Text input with an inline action",
                    "inlineAction": {
                        "type": "Action.Submit",
                        "iconUrl": "https://adaptivecards.io/content/send.png",
                        "tooltip": "Send"
                    }
                },
                {
                    "type": "Input.Text",
                    "label": "Text input with an inline action with no icon",
                    "id": "textInlineActionId",
                    "inlineAction": {
                        "type": "Action.OpenUrl",
                        "title": "Reply",
                        "tooltip": "Reply to this message",
                        "url": "https://adaptivecards.io"
                    }
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let card = try decoder.decode(AdaptiveCard.self, from: json)
        
        XCTAssertEqual(card.schema, "http://adaptivecards.io/schemas/adaptive-card.json")
        XCTAssertEqual(card.type, "AdaptiveCard")
        XCTAssertEqual(card.version, "1.5")
        
        XCTAssertEqual(card.body.count, 2)
        
        guard case let .inputElement(.text(inputText1)) = card.body[0] else {
            XCTFail("Expected first body element to be an InputText")
            return
        }
        XCTAssertEqual(inputText1.id, "iconInlineActionId")
        XCTAssertEqual(inputText1.label, "Text input with an inline action")
        //XCTAssertNotNil(inputText1.inlineAction)
        
//            guard let inlineAction1 = inputText1.inlineAction as? ActionSubmit else {
//                XCTFail("Expected inline action to be an ActionSubmit")
//                return
//            }
//            XCTAssertEqual(inlineAction1.iconUrl, "https://adaptivecards.io/content/send.png")
//            XCTAssertEqual(inlineAction1.tooltip, "Send")
//
        guard case let .inputElement(.text(inputText2)) = card.body[1]  else {
            XCTFail("Expected second body element to be an InputText")
            return
        }
        XCTAssertEqual(inputText2.id, "textInlineActionId")
        XCTAssertEqual(inputText2.label, "Text input with an inline action with no icon")
//        XCTAssertNotNil(inputText2.inlineAction)
//        
//        guard let inlineAction2 = inputText2.inlineAction as? ActionOpenUrl else {
//            XCTFail("Expected inline action to be an ActionOpenUrl")
//            return
//        }
//        XCTAssertEqual(inlineAction2.title, "Reply")
//        XCTAssertEqual(inlineAction2.tooltip, "Reply to this message")
//        XCTAssertEqual(inlineAction2.url, "https://adaptivecards.io")
    }
}
