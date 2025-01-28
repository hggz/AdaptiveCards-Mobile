//
//  ACContainers.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/18/24.
//

import Foundation

class Container: StyledCollectionElement {

    let items: [CardElement]
    let bleed: Bool?
    let rtl: Bool?


    enum CodingKeys: String, CodingKey {
        case items, bleed, rtl, id
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       
        items = try container.decode([CardElement].self, forKey: .items)
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

class ColumnSet: StyledCollectionElement {

    let columns: [Column]
    let bleed: Bool?
    let rtl: Bool?


    enum CodingKeys: String, CodingKey {
        case  columns, bleed, rtl, id
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       
        columns = try container.decode([Column].self, forKey: .columns)
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

class Column: StyledCollectionElement, Hashable {

    static func == (lhs: Column, rhs: Column) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        
    }
    
    let items: [CardElement]
    let width: String?
    let bleed: Bool?
    let rtl: Bool?

    enum CodingKeys: String, CodingKey {
        case items, width, bleed, rtl
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decode([CardElement].self, forKey: .items)
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

class FactSet: BaseCardElement {

    let facts: [Fact]
 

    enum CodingKeys: String, CodingKey {
        case facts
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        facts = try container.decode([Fact].self, forKey: .facts)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(facts, forKey: .facts)
   
        try super.encode(to: encoder)
    }
}

class Fact: BaseCardElement, Hashable {
    
    static func == (lhs: Fact, rhs: Fact) -> Bool {
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

class ImageSet: BaseCardElement {
    
    let images: [Image]?
    let imageSize: String?
    enum CodingKeys: String, CodingKey {
        case type, images, imageSize
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        images = try container.decodeIfPresent([Image].self, forKey: .images)
        imageSize = try container.decodeIfPresent(String.self, forKey: .imageSize)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(images, forKey: .images)
        try container.encodeIfPresent(imageSize, forKey: .imageSize)
    }
   
}
class Table: CollectionCoreElement {

    let columns: [TableColumnDefinition]
    let rows: [TableRow]
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
        columns = try container.decode([TableColumnDefinition].self, forKey: .columns)
        rows = try container.decode([TableRow].self, forKey: .rows)
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
   


struct TableColumnDefinition: Codable {
    let width: String?
}

struct TableRow: Codable {
    let type: String
    let cells: [TableCell]
}

struct TableCell: Codable {
    let type: String
    let items: [CardElement]
    let style: String?
    let verticalContentAlignment: String?
}
