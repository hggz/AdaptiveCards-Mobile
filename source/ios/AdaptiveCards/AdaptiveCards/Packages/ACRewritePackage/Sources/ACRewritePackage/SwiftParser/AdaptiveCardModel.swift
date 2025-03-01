import Foundation

@objcMembers
public class AdaptiveCardModel: NSObject {
    public var card: SwiftAdaptiveCard?
    
    public func getWarnings() -> [NSError] {
        return []
    }

    public override init() {
        super.init()
    }
}
