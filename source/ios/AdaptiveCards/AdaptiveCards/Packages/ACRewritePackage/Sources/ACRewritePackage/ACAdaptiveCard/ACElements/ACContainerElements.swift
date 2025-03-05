//
//  ACContainers.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/18/24.
//

import Foundation

class Container: SwiftACStyledCollectionElement {

    let items: [SwiftACCardElement]
    let bleed: Bool?
    let rtl: Bool?


    enum CodingKeys: String, CodingKey {
        case items, bleed, rtl, id
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       
        items = try container.decode([SwiftACCardElement].self, forKey: .items)
        bleed = try container.decodeIfPresent(Bool.self, forKey: .bleed)
        rtl = try container.decodeIfPresent(Bool.self, forKey: .rtl)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(items, forKey: .items)
        try container.encodeIfPresent(bleed, forKey: .bleed)
        try container.encodeIfPresent(rtl, forKey: .rtl)
    }
}

class SwiftACColumnSet: SwiftACStyledCollectionElement {

    let columns: [SwiftACColumn]
    let bleed: Bool?
    let rtl: Bool?


    enum CodingKeys: String, CodingKey {
        case  columns, bleed, rtl, id
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       
        columns = try container.decode([SwiftACColumn].self, forKey: .columns)
        bleed = try container.decodeIfPresent(Bool.self, forKey: .bleed)
        rtl = try container.decodeIfPresent(Bool.self, forKey: .rtl)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(columns, forKey: .columns)
        try container.encodeIfPresent(bleed, forKey: .bleed)
        try container.encodeIfPresent(rtl, forKey: .rtl)
    
    }
}

class SwiftACColumn: SwiftACStyledCollectionElement, Hashable {

    static func == (lhs: SwiftACColumn, rhs: SwiftACColumn) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        
    }
    
    let items: [SwiftACCardElement]
    let width: String?
    let bleed: Bool?
    let rtl: Bool?

    enum CodingKeys: String, CodingKey {
        case items, width, bleed, rtl
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decode([SwiftACCardElement].self, forKey: .items)
        width = try container.decodeIfPresent(String.self, forKey: .width)
        bleed = try container.decodeIfPresent(Bool.self, forKey: .bleed)
        rtl = try container.decodeIfPresent(Bool.self, forKey: .rtl)
      
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(items, forKey: .items)
        try container.encodeIfPresent(width, forKey: .width)
        try container.encodeIfPresent(bleed, forKey: .bleed)
        try container.encodeIfPresent(rtl, forKey: .rtl)

    }
}

class SwiftACFactSet: SwiftACBaseCardElement {

    let facts: [SwiftACFact]
 

    enum CodingKeys: String, CodingKey {
        case facts
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        facts = try container.decode([SwiftACFact].self, forKey: .facts)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(facts, forKey: .facts)
   
        try super.encode(to: encoder)
    }
}

class SwiftACFact: SwiftACBaseCardElement, Hashable {
    
    static func == (lhs: SwiftACFact, rhs: SwiftACFact) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        
    }
    
    
    let title: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case title, value
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        value = try container.decode(String.self, forKey: .value)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(value, forKey: .value)
        try super.encode(to: encoder)
    }
}

class ImageSet: SwiftACBaseCardElement {
    
    let images: [SwiftACImage]?
    let imageSize: String?
    enum CodingKeys: String, CodingKey {
        case type, images, imageSize
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        images = try container.decodeIfPresent([SwiftACImage].self, forKey: .images)
        imageSize = try container.decodeIfPresent(String.self, forKey: .imageSize)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(images, forKey: .images)
        try container.encodeIfPresent(imageSize, forKey: .imageSize)
    }
   
}
class SwiftACTable: SwiftACCollectionCoreElement {

    let columns: [SwiftACTableColumnDefinition]
    let rows: [SwiftACTableRow]
    let firstRowAsHeaders: Bool?
    let showGridLines: Bool?
    let gridStyle: String?
    let horizontalCellContentAlignment: String?
    let verticalCellContentAlignment: String?
    
    enum CodingKeys: String, CodingKey {
        case columns, rows, firstRowAsHeaders, showGridLines, gridStyle, horizontalCellContentAlignment, verticalCellContentAlignment
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        columns = try container.decode([SwiftACTableColumnDefinition].self, forKey: .columns)
        rows = try container.decode([SwiftACTableRow].self, forKey: .rows)
        firstRowAsHeaders = try container.decodeIfPresent(Bool.self, forKey: .firstRowAsHeaders)
        showGridLines = try container.decodeIfPresent(Bool.self, forKey: .showGridLines)
        gridStyle = try container.decodeIfPresent(String.self, forKey: .gridStyle)
        horizontalCellContentAlignment = try container.decodeIfPresent(String.self, forKey: .horizontalCellContentAlignment)
        verticalCellContentAlignment = try container.decodeIfPresent(String.self, forKey: .verticalCellContentAlignment)
        
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(columns, forKey: .columns)
        try container.encode(rows, forKey: .rows)
        try container.encodeIfPresent(firstRowAsHeaders, forKey: .firstRowAsHeaders)
        try container.encodeIfPresent(showGridLines, forKey: .showGridLines)
        try container.encodeIfPresent(gridStyle, forKey: .gridStyle)
        try container.encodeIfPresent(horizontalCellContentAlignment, forKey: .horizontalCellContentAlignment)
        try container.encodeIfPresent(verticalCellContentAlignment, forKey: .verticalCellContentAlignment)
    }
}
   


struct SwiftACTableColumnDefinition: Codable {
    let width: String?
}

struct SwiftACTableRow: Codable {
    let type: String
    let cells: [SwiftACTableCell]
}

struct SwiftACTableCell: Codable {
    let type: String
    let items: [SwiftACCardElement]
    let style: String?
    let verticalContentAlignment: String?
}
