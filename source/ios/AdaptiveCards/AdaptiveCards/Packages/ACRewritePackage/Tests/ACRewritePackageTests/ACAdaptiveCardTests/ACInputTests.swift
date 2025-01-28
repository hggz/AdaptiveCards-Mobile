//
//  ACInputTests.swift
//  ACSwiftRewriteTests
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation

import XCTest
@testable import ACRewritePackage

final class ACInputTests: XCTestCase {
    
    func testAdaptiveCardInputParsing() throws {
        let json = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Default text input"
                },
                {
                    "type": "Input.Text",
                    "id": "defaultInputId",
                    "placeholder": "enter comment",
                    "maxLength": 500
                },
                {
                    "type": "TextBlock",
                    "text": "Multiline text input"
                },
                {
                    "type": "Input.Text",
                    "id": "multilineInputId",
                    "placeholder": "enter comment",
                    "maxLength": 500,
                    "isMultiline": true
                },
                {
                    "type": "TextBlock",
                    "text": "Pre-filled value"
                },
                {
                    "type": "Input.Text",
                    "id": "prefilledInputId",
                    "placeholder": "enter comment",
                    "maxLength": 500,
                    "isMultiline": true,
                    "value": "This value was pre-filled"
                }
            ],
            "actions": [
                {
                    "type": "Action.Submit",
                    "title": "OK"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let card = try decoder.decode(AdaptiveCard.self, from: json)
        
        XCTAssertEqual(card.schema, "http://adaptivecards.io/schemas/adaptive-card.json")
        XCTAssertEqual(card.type, "AdaptiveCard")
        XCTAssertEqual(card.version, "1.0")
        
        XCTAssertEqual(card.body.count, 6)
        
        guard case let .textBlock(textBlock) = card.body[0] else {
            XCTFail("Expected first body element to be a TextBlock")
            return
        }
        XCTAssertEqual(textBlock.text, "Default text input")
       
        
        guard case let .inputElement(.text(inputText)) = card.body[1]  else {
            XCTFail("Expected second body element to be an InputText")
            return
        }
        XCTAssertEqual(inputText.id, "defaultInputId")
        XCTAssertEqual(inputText.placeholder, "enter comment")
        XCTAssertEqual(inputText.maxLength, 500)
        XCTAssertNil(inputText.isMultiline)
        XCTAssertNil(inputText.value)
        
        guard case let .textBlock(textBlock2) = card.body[2] else {
            XCTFail("Expected third body element to be a TextBlock")
            return
        }
        XCTAssertEqual(textBlock2.text, "Multiline text input")
        
        guard case let .inputElement(.text(inputText2)) = card.body[3] else {
            XCTFail("Expected fourth body element to be an InputText")
            return
        }
        XCTAssertEqual(inputText2.id, "multilineInputId")
        XCTAssertEqual(inputText2.placeholder, "enter comment")
        XCTAssertEqual(inputText2.maxLength, 500)
        XCTAssertEqual(inputText2.isMultiline, true)
        XCTAssertNil(inputText2.value)
        
        guard case let .textBlock(textBlock3) = card.body[4] else {
            XCTFail("Expected fifth body element to be a TextBlock")
            return
        }
        XCTAssertEqual(textBlock3.text, "Pre-filled value")
        
        guard case let .inputElement(.text(inputText3))  = card.body[5] else {
            XCTFail("Expected sixth body element to be an InputText")
            return
        }
        XCTAssertEqual(inputText3.id, "prefilledInputId")
        XCTAssertEqual(inputText3.placeholder, "enter comment")
        XCTAssertEqual(inputText3.maxLength, 500)
        XCTAssertEqual(inputText3.isMultiline, true)
        XCTAssertEqual(inputText3.value, "This value was pre-filled")
        
        XCTAssertEqual(card.actions?.count, 1)
        
        guard case let .submit(actionSubmit) = card.actions?.first else {
            XCTFail("Expected first action to be an ActionSubmit")
            return
        }
        XCTAssertEqual(actionSubmit.title, "OK")
    }
    
    
}
