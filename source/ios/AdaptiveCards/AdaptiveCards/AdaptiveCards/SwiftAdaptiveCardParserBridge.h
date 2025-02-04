//
//  SwiftAdaptiveCardParserBridge.h
//  AdaptiveCards
//
//  Created by Hugo Gonzalez on 2/4/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACOAdaptiveCardParseResult;

NS_ASSUME_NONNULL_BEGIN

@interface SwiftAdaptiveCardParserBridge : NSObject

/// Calls into Swift code to parse the payload,
/// then bridges the Swift result back to an ACOAdaptiveCardParseResult.
+ (ACOAdaptiveCardParseResult *)parsePayloadWithSwift:(NSString *)payload;

@end

NS_ASSUME_NONNULL_END
