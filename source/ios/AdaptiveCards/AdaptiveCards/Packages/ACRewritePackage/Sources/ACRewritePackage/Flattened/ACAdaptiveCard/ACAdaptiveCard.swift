//
//  ACAdaptiveCardParser.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/18/24.
//

import Foundation

struct SwiftACAdaptiveCard: Codable, Hashable {
    
    let schema: String?
    let type: String?
    let version: String?
    let unknown: String?
    let refresh: SwiftACRefresh?
    let lang: String?
    let fallbackText: String?
    let speak: String?
    let minHeight: String?
    let verticalContentAlignment: SwiftACVerticalAlignment?
    let backgroundImage: SwiftACBackgroundImage?
    let body: [SwiftACCardElement]
    let actions: [SwiftACActionElement]?
    let authentication: SwiftACAuthentication?
    let rtl: Bool?

    enum CodingKeys: String, CodingKey {
        case schema = "$schema"
        case type
        case version
        case unknown
        case lang
        case refresh
        case fallbackText
        case speak
        case minHeight
        case verticalContentAlignment
        case backgroundImage
        case body
        case actions
        case authentication
        case rtl
    }
    
    static func == (lhs: SwiftACAdaptiveCard, rhs: SwiftACAdaptiveCard) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    func hash(into hasher: inout Hasher) {
        
    }
}

struct SwiftACBackgroundImageObj: Codable {
    let url: String?
    let fillMode: SwiftACImageFillMode?
    let horizontalAlignment: SwiftACHorizontalAlignment?
    let verticalAlignment: SwiftACVerticalAlignment?
}

enum SwiftACBackgroundImage: Codable {
    case imageUrl(String)
    case backgroundImage(SwiftACBackgroundImageObj)
    
    init(from decoder: Decoder) throws {
        
        /// Response for rateLimit error is just an int value
        if let imageUrlStr = try? decoder.singleValueContainer().decode(String.self) {
            self = .imageUrl(imageUrlStr)
            return
        }
        if let backgroundImage = try? decoder.singleValueContainer().decode(SwiftACBackgroundImageObj.self) {
            self = .backgroundImage(backgroundImage)
            return
        }
        throw DecodingError.dataCorruptedError(in: try decoder.singleValueContainer(), debugDescription: "Failed to parse bot response.")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .imageUrl(let image):
            try container.encode(image)
        case .backgroundImage(let imageObj):
            try container.encode(imageObj)
        }
    }
}

struct SwiftACAuthentication: Codable {
    let connectionName: String
    let text: String
    let tokenExchangeResource: SwiftACTokenExchangeResource
    let buttons: [SwiftACAuthCardButton]
}

struct SwiftACRefresh: Codable {
    let action: SwiftACActionExecute
    let userIds: [String]
}

struct SwiftACTokenExchangeResource: Codable {
    let id: String
    let providerId: String
    let uri: String
}

struct SwiftACAuthCardButton: Codable {
    let type: String
    let title: String
}
