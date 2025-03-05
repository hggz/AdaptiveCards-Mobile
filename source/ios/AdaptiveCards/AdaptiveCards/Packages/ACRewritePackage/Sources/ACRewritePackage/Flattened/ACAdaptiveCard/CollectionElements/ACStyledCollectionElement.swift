//
//  ACStyledCollectionElement.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation


class SwiftACStyledCollectionElement: SwiftACCollectionCoreElement {
    var style: SwiftACContainerStyle?
    var verticalContentAlignment: SwiftACVerticalContentAlignment?
    var hasPadding: Bool?
    var showBorder: Bool?
    var roundedCorners: Bool?
    var hasBleed: Bool?
    var parentalId: SwiftACInternalId?
    var backgroundImage: SwiftACBackgroundImage?
    var selectAction: SwiftACBaseActionElement?
    var minHeight: UInt?

    enum CodingKeys: String, CodingKey {
        case style
        case verticalContentAlignment
        case hasPadding
        case showBorder
        case roundedCorners
        case hasBleed
        case parentalId
        case backgroundImage
        case selectAction
        case minHeight
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.style = try container.decodeIfPresent(SwiftACContainerStyle.self, forKey: .style)
        self.verticalContentAlignment = try container.decodeIfPresent(SwiftACVerticalContentAlignment.self, forKey: .verticalContentAlignment)
        self.hasPadding = try container.decodeIfPresent(Bool.self, forKey: .hasPadding)
        self.showBorder = try container.decodeIfPresent(Bool.self, forKey: .showBorder)
        self.roundedCorners = try container.decodeIfPresent(Bool.self, forKey: .roundedCorners)
        self.hasBleed = try container.decodeIfPresent(Bool.self, forKey: .hasBleed)
        self.parentalId = try container.decodeIfPresent(SwiftACInternalId.self, forKey: .parentalId)
        self.backgroundImage = try container.decodeIfPresent(SwiftACBackgroundImage.self, forKey: .backgroundImage)
        self.selectAction = try container.decodeIfPresent(SwiftACBaseActionElement.self, forKey: .selectAction)
        self.minHeight = try container.decodeIfPresent(UInt.self, forKey: .minHeight)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(style, forKey: .style)
        try container.encodeIfPresent(verticalContentAlignment, forKey: .verticalContentAlignment)
        try container.encodeIfPresent(hasPadding, forKey: .hasPadding)
        try container.encodeIfPresent(showBorder, forKey: .showBorder)
        try container.encodeIfPresent(roundedCorners, forKey: .roundedCorners)
        try container.encodeIfPresent(hasBleed, forKey: .hasBleed)
        try container.encodeIfPresent(parentalId, forKey: .parentalId)
        try container.encodeIfPresent(backgroundImage, forKey: .backgroundImage)
        try container.encodeIfPresent(selectAction, forKey: .selectAction)
        try container.encodeIfPresent(minHeight, forKey: .minHeight)
        try super.encode(to: encoder)
    }

//    func configForContainerStyle(context: ParseContext) {
//        configPadding(context: context)
//        configBleed(context: context)
//    }
//
//    private func configPadding(context: ParseContext) {
//        let padding = (getStyle() != .none) && (context.getParentalContainerStyle() != getStyle())
//        setPadding(padding)
//    }
//
//    private func configBleed(context: ParseContext) {
//        let id = context.paddingParentInternalId()
//        let canBleed = hasPadding && hasBleed
//        if canBleed && context.getBleedDirection() != .bleedRestricted {
//            setParentalId(id)
//            setBleedDirection(context.getBleedDirection())
//        } else {
//            setBleedDirection(.bleedRestricted)
//        }
//    }

}
