//
//  ACAdaptiveCardParser.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/18/24.
//

import Foundation

struct AdaptiveCard: Codable, Hashable {
    
    let schema: String?
    let type: String?
    let version: String?
    let unknown: String?
    let refresh: Refresh?
    let lang: String?
    let fallbackText: String?
    let speak: String?
    let minHeight: String?
    let verticalContentAlignment: VerticalAlignment?
    let backgroundImage: BackgroundImage?
    let body: [CardElement]
    let actions: [ActionElement]?
    let authentication: Authentication?
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
    
    static func == (lhs: AdaptiveCard, rhs: AdaptiveCard) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    func hash(into hasher: inout Hasher) {
        
    }
}

struct BackgroundImageObj: Codable {
    let url: String?
    let fillMode: ImageFillMode?
    let horizontalAlignment: HorizontalAlignment?
    let verticalAlignment: VerticalAlignment?
}

enum BackgroundImage: Codable {
    case imageUrl(String)
    case backgroundImage(BackgroundImageObj)
    
    init(from decoder: Decoder) throws {
        
        /// Response for rateLimit error is just an int value
        if let imageUrlStr = try? decoder.singleValueContainer().decode(String.self) {
            self = .imageUrl(imageUrlStr)
            return
        }
        if let backgroundImage = try? decoder.singleValueContainer().decode(BackgroundImageObj.self) {
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

struct Authentication: Codable {
    let connectionName: String
    let text: String
    let tokenExchangeResource: TokenExchangeResource
    let buttons: [AuthCardButton]
}

struct Refresh: Codable {
    let action: ActionExecute
    let userIds: [String]
}

struct TokenExchangeResource: Codable {
    let id: String
    let providerId: String
    let uri: String
}

struct AuthCardButton: Codable {
    let type: String
    let title: String
}




