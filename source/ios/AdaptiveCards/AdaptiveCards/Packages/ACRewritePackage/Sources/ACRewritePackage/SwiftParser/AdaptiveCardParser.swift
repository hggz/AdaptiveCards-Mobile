import Foundation

@objcMembers
public class AdaptiveCardParser: NSObject {
    
    /// Parses a payload string and returns a `AdaptiveCardParseResult`.
    /// For now, it returns stub data. Expand this as you port over functionality.
    public static func parse(payload: String) -> AdaptiveCardParseResult {
        let result = AdaptiveCardParseResult()

        // Create a placeholder AdaptiveCardModel
        let card = AdaptiveCardModel()
        card.refresh = "StubRefresh"
        card.authentication = "StubAuthentication"

        // Populate the result
        result.card = card
        // result.errors = ...
        // result.warnings = ...

        return result
    }
}
