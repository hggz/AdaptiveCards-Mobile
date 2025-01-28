//
//  ACParseWarning.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation

enum AdaptiveCardParseWarningCode {
    case unknown
    case assetLoadFailed
    case unsupportedSchemaVersion
    // Add other warning codes as needed
}

class AdaptiveCardParseWarning {
    private var code: AdaptiveCardParseWarningCode
    private var message: String

    init(code: AdaptiveCardParseWarningCode, message: String) {
        self.code = code
        self.message = message
    }

    func getWarningCode() -> AdaptiveCardParseWarningCode {
        return code
    }

    func getReason() -> String {
        return message
    }
}
