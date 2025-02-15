import Foundation

@objcMembers
public class AdaptiveCardParseResult: NSObject {
    public var card: AdaptiveCardModel?
    public var errors: [NSError]?
    public var warnings: [NSError]?

    public override init() {
        super.init()
    }
}
