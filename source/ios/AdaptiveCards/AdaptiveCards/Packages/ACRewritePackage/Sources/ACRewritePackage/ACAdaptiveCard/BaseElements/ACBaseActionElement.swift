//
//  ACBaseActionElement.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation


class BaseActionElement: BaseElement {
    var title: String?
    var iconUrl: String?
    var style: String?
    var tooltip: String?
    var isEnabled: Bool?
    var type: ActionType?
    var mode: Mode?
    var role: ActionRole?

    enum CodingKeys: String, CodingKey {
        case title
        case iconUrl
        case style
        case tooltip
        case isEnabled
        case type
        case mode
        case role
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl)
        self.style = try container.decodeIfPresent(String.self, forKey: .style)
        self.tooltip = try container.decodeIfPresent(String.self, forKey: .tooltip)
        self.isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled)
        self.type = try container.decodeIfPresent(ActionType.self, forKey: .type)
        self.mode = try container.decodeIfPresent(Mode.self, forKey: .mode)
        self.role = try container.decodeIfPresent(ActionRole.self, forKey: .role)
        super.init()
    }
    
    // Method to encode properties
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(iconUrl, forKey: .iconUrl)
        try container.encodeIfPresent(style, forKey: .style)
        try container.encodeIfPresent(tooltip, forKey: .tooltip)
        try container.encodeIfPresent(isEnabled, forKey: .isEnabled)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(mode, forKey: .mode)
        try container.encodeIfPresent(role, forKey: .role)
    }
}

