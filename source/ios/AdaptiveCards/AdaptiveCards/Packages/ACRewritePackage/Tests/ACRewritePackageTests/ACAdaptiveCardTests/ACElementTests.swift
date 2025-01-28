//
//  ACElementTests.swift
//  ACSwiftRewriteTests
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation
import XCTest
@testable import ACRewritePackage


class ACElementTests: XCTestCase {
    
    func testShowCardSerialization() {
        let cardWithShowCard = """
               {
                   "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                   "type" : "AdaptiveCard",
                   "version" : "2.0",
                   "body" : [
                       {
                           "type": "TextBlock",
                           "text" : "This card's action will show another card"
                       }
                   ],
                   "actions": [
                       {
                           "type": "Action.ShowCard",
                           "title" : "Action.ShowCard",
                           "card" : {
                               "type": "AdaptiveCard",
                               "body" : [
                                   {
                                       "type": "TextBlock",
                                       "text" : "What do you think?"
                                   }
                               ],
                               "actions": [
                                   {
                                       "type": "Action.Submit",
                                       "title" : "Neat!"
                                   }
                               ]
                           }
                       }
                   ]
               }
               """
        
        do {
            let cardData = cardWithShowCard.data(using: .utf8)!
            let card = try JSONDecoder().decode(AdaptiveCard.self, from: cardData)
            
            guard case let .showCard(showCardAction) = card.actions?.first else {
                XCTFail("First action is not a ShowCardAction")
                return
            }
            let showCard = showCardAction.card
            
            XCTAssertEqual(card.version, "2.0")
            XCTAssertEqual(showCard.body.count, 1)
            if case let .textBlock(textBlock) = showCard.body.first {
                XCTAssertEqual(textBlock.text, "What do you think?")
            }
            
            XCTAssertEqual(showCard.actions?.count, 1)
            if case let .submit(submitAction) = showCard.actions?.first {
                XCTAssertEqual(submitAction.title, "Neat!")
            }
            
        } catch {
            XCTFail("Deserialization or serialization failed with error: \(error)")
        }
    }
}
