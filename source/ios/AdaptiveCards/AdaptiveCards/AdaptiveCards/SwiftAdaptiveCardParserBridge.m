//
//  SwiftAdaptiveCardParserBridge.m
//  AdaptiveCards
//
//  Created by Hugo Gonzalez on 2/4/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "SwiftAdaptiveCardParserBridge.h"

#import <AdaptiveCards/ACOAdaptiveCardParseResult.h>
#import <AdaptiveCards/ACOAdaptiveCard.h>
#import <AdaptiveCards/ACORefresh.h>
#import <AdaptiveCards/ACOAuthentication.h>

#import <ACRewritePackage-Swift.h>

@implementation SwiftAdaptiveCardParserBridge

+ (ACOAdaptiveCardParseResult *)parsePayloadWithSwift:(NSString *)payload {
    AdaptiveCardParseResult *swiftResult = [AdaptiveCardParser parseWithPayload:payload];

    if (!swiftResult) {
        return [[ACOAdaptiveCardParseResult alloc] init:nil errors:nil warnings:nil];
    }

    AdaptiveCardModel *swiftCard = swiftResult.card;
    ACOAdaptiveCard *objCCard = [[ACOAdaptiveCard alloc] init];

    if (swiftCard.refresh) {
        // Map Swift refresh to ACORefresh (placeholder logic for now)
//        ACORefresh *refresh = [[ACORefresh alloc] init:nil];
//        objCCard.refresh = refresh;
    }
    if (swiftCard.authentication) {
        // Map Swift authentication to ACOAuthentication
//        ACOAuthentication *auth = [[ACOAuthentication alloc] init:nil];
//        objCCard.authentication = auth;
    }

    // TODO - dont use nserror, use the adaptivecard error
    NSArray<NSError *> *errors = swiftResult.errors ? swiftResult.errors : nil;
    NSArray<NSError *> *warnings = swiftResult.warnings ? swiftResult.warnings : nil;

    ACOAdaptiveCardParseResult *finalResult =
        [[ACOAdaptiveCardParseResult alloc] init:objCCard errors:errors warnings:warnings];

    return finalResult;
}

@end
