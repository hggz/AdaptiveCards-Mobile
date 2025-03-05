//
//  ParseResult.swift
//  ACRewritePackage
//
//  Created by You on Today's Date.
//

import Foundation

/// A Swift version of ParseResult, which wraps an AdaptiveCard plus any warnings from parsing.
public class SwiftParseResult {
    
    private let mAdaptiveCard: SwiftAdaptiveCard
    private let mWarnings: [SwiftAdaptiveCardParseWarning]
    
    /// Creates a new ParseResult containing the parsed AdaptiveCard and any parse warnings.
    public init(adaptiveCard: SwiftAdaptiveCard, warnings: [SwiftAdaptiveCardParseWarning]) {
        self.mAdaptiveCard = adaptiveCard
        self.mWarnings = warnings
    }
    
    /// Returns the parsed AdaptiveCard.
    public func getAdaptiveCard() -> SwiftAdaptiveCard {
        return mAdaptiveCard
    }
    
    /// Returns any warnings that occurred during parsing.
    public func getWarnings() -> [SwiftAdaptiveCardParseWarning] {
        return mWarnings
    }
    
    /// For convenience, you can also expose them as properties:
    public var adaptiveCard: SwiftAdaptiveCard {
        return mAdaptiveCard
    }
    
    public var warnings: [SwiftAdaptiveCardParseWarning] {
        return mWarnings
    }
}
