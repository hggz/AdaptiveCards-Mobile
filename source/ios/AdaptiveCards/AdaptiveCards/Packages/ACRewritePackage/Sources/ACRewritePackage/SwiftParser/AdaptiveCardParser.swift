import Foundation

@objcMembers
public class AdaptiveCardParser: NSObject {
    
    /// Parses a payload string and returns a `AdaptiveCardParseResult`.
    /// For now, it returns stub data. Expand this as you port over functionality.
    public static func parse(payload: String) -> AdaptiveCardParseResult {
        let result = AdaptiveCardParseResult()

        
        guard let parseResult = try? SwiftAdaptiveCard.deserializeFromString(payload, version: "1.0") else {
            return result
        }
        
//        result.card = parseResult.adaptiveCard
//        result.warnings = parseResult.

        return result
    }
}
