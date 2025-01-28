//
//  ACRatingsTest.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 1/23/25.
//
import Foundation
import XCTest
@testable import ACRewritePackage


class ACRatingTests: XCTestCase {
    
    func testShowCardSerialization() {
        let cardWithShowCard = """
               {
                 "type": "AdaptiveCard",
                 "$schema": "https://adaptivecards.io/schemas/adaptive-card.json",
                 "version": "1.5",
                 "body": [
                   {
                     "type": "Rating",
                     "max": 20,
                     "value": 3.2,
                     "color": "marigold",
                     "size": "large",
                     "count": 150
                   },
                   {
                     "type": "Rating",
                     "style": "compact",
                     "value": 3.2,
                     "color": "marigold",
                     "count": 1000
                   }
                 ]
               }
               """
        
        do {
            let cardData = cardWithShowCard.data(using: .utf8)!
            let card = try JSONDecoder().decode(AdaptiveCard.self, from: cardData)
            
            guard case let .ratingLabel(ratingLabel) = card.body.first else {
                XCTFail("cannot parse ratings label")
                return
            }
        
            
            XCTAssertEqual(ratingLabel.color, "marigold")
            XCTAssertEqual(ratingLabel.type, CardElementType.ratingLabel)
            XCTAssertEqual(ratingLabel.value, 3.2)
            XCTAssertEqual(ratingLabel.max, 20)
            XCTAssertEqual(ratingLabel.count, 150)
            
        } catch {
            XCTFail("Deserialization or serialization failed with error: \(error)")
        }
    }
}

