//
//  ACParseWarning.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation

enum SwiftACAdaptiveCardParseWarningCode {
    case unknown
    case assetLoadFailed
    case unsupportedSchemaVersion
    // Add other warning codes as needed
}

class SwiftACAdaptiveCardParseWarning {
    private var code: SwiftACAdaptiveCardParseWarningCode
    private var message: String

    init(code: SwiftACAdaptiveCardParseWarningCode, message: String) {
        self.code = code
        self.message = message
    }

    func getWarningCode() -> SwiftACAdaptiveCardParseWarningCode {
        return code
    }

    func getReason() -> String {
        return message
    }
}
