//
//  ACParseResult.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation

protocol ParseResultProtocol {
    init(adaptiveCard: AdaptiveCard, warnings: [AdaptiveCardParseWarning])

    func getAdaptiveCard() -> AdaptiveCard
    func getWarnings() -> [AdaptiveCardParseWarning]
}

class ParseResult: ParseResultProtocol {
    private var m_adaptiveCard: AdaptiveCard
    private var m_warnings: [AdaptiveCardParseWarning]

    required init(adaptiveCard: AdaptiveCard, warnings: [AdaptiveCardParseWarning]) {
        self.m_adaptiveCard = adaptiveCard
        self.m_warnings = warnings
    }

    func getAdaptiveCard() -> AdaptiveCard {
        return m_adaptiveCard
    }

    func getWarnings() -> [AdaptiveCardParseWarning] {
        return m_warnings
    }
}

