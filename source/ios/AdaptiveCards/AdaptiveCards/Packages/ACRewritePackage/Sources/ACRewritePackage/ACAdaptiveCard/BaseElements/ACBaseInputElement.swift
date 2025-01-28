//
//  ACBaseInputElement.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation


class BaseInputElement: BaseCardElement {
    var isRequired: Bool?
    var errorMessage: String?
    var label: String?
    var valueChangedAction: ValueChangedAction?
    
    enum CodingKeys: String, CodingKey {
        case isRequired
        case errorMessage
        case label
        case valueChangedAction
    }
    
    // Conformance to Encodable
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(isRequired, forKey: .isRequired)
        try container.encodeIfPresent(errorMessage, forKey: .errorMessage)
        try container.encodeIfPresent(label, forKey: .label)
        try container.encodeIfPresent(valueChangedAction, forKey: .valueChangedAction)
        try super.encode(to: encoder)
    }
    
    // Conformance to Decodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isRequired = try container.decodeIfPresent(Bool.self, forKey: .isRequired)
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.valueChangedAction = try container.decodeIfPresent(ValueChangedAction.self, forKey: .valueChangedAction)
        try super.init(from: decoder)
    }

}
