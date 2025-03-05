//
//  ACParseResult.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation

protocol SwiftACParseResultProtocol {
    init(adaptiveCard: SwiftACAdaptiveCard, warnings: [SwiftACAdaptiveCardParseWarning])

    func getAdaptiveCard() -> SwiftACAdaptiveCard
    func getWarnings() -> [SwiftACAdaptiveCardParseWarning]
}

class ParseResult: SwiftACParseResultProtocol {
    private var m_adaptiveCard: SwiftACAdaptiveCard
    private var m_warnings: [SwiftACAdaptiveCardParseWarning]

    required init(adaptiveCard: SwiftACAdaptiveCard, warnings: [SwiftACAdaptiveCardParseWarning]) {
        self.m_adaptiveCard = adaptiveCard
        self.m_warnings = warnings
    }

    func getAdaptiveCard() -> SwiftACAdaptiveCard {
        return m_adaptiveCard
    }

    func getWarnings() -> [SwiftACAdaptiveCardParseWarning] {
        return m_warnings
    }
}

