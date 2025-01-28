//
//  ACCollectionCoreElement.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation

class CollectionCoreElement: BaseCardElement {
    var elements: [BaseCardElement]?
    
    enum CodingKeys: String, CodingKey {
        case elements
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.elements = try container.decodeIfPresent([BaseCardElement].self, forKey: .elements)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(elements, forKey: .elements)
        try super.encode(to: encoder)
    }

}
