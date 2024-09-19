import Foundation

// MARK: - AdaptiveCard
struct AdaptiveCard: Codable {
    let schema: String?
    let type: String
    let version: String
    let body: [CardElement]

    enum CodingKeys: String, CodingKey {
        case schema = "$schema"
        case type
        case version
        case body
    }
}

// MARK: - CardElement Enum
enum CardElement: Codable {
    case container(Container)
    case textBlock(TextBlock)
    case carousel(Carousel)
    case carouselPage(CarouselPage)
    case image(Image)
    case columnSet(ColumnSet)
    case column(Column)
    case imageSet(ImageSet)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "Container":
            let value = try Container(from: decoder)
            self = .container(value)
        case "TextBlock":
            let value = try TextBlock(from: decoder)
            self = .textBlock(value)
        case "Carousel":
            let value = try Carousel(from: decoder)
            self = .carousel(value)
        case "CarouselPage":
            let value = try CarouselPage(from: decoder)
            self = .carouselPage(value)
        case "Image":
            let value = try Image(from: decoder)
            self = .image(value)
        case "ColumnSet":
            let value = try ColumnSet(from: decoder)
            self = .columnSet(value)
        case "Column":
            let value = try Column(from: decoder)
            self = .column(value)
        case "ImageSet":
            let value = try ImageSet(from: decoder)
            self = .imageSet(value)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type: \(type)")
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .container(let value):
            try value.encode(to: encoder)
        case .textBlock(let value):
            try value.encode(to: encoder)
        case .carousel(let value):
            try value.encode(to: encoder)
        case .carouselPage(let value):
            try value.encode(to: encoder)
        case .image(let value):
            try value.encode(to: encoder)
        case .columnSet(let value):
            try value.encode(to: encoder)
        case .column(let value):
            try value.encode(to: encoder)
        case .imageSet(let value):
            try value.encode(to: encoder)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }
}

// MARK: - Container
struct Container: Codable {
    let type: String
    let items: [CardElement]
    let style: String?

    enum CodingKeys: String, CodingKey {
        case type
        case items
        case style
    }
}

// MARK: - TextBlock
struct TextBlock: Codable {
    let type: String
    let text: String
    let size: String?
    let style: String?
    let horizontalAlignment: String?
    let wrap: Bool?
    let isSubtle: Bool?
    let weight: String?

    enum CodingKeys: String, CodingKey {
        case type
        case text
        case size
        case style
        case horizontalAlignment
        case wrap
        case isSubtle
        case weight
    }
}

// MARK: - Carousel
struct Carousel: Codable {
    let type: String
    let spacing: String?
    let pages: [CarouselPage]
    let rtl: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case spacing
        case pages
        case rtl
    }
}

// MARK: - CarouselPage
struct CarouselPage: Codable {
    let type: String
    let id: String
    let items: [CardElement]
    let rtl: Bool?

    enum CodingKeys: String, CodingKey {
        case type
        case id
        case items
        case rtl
    }
}

// MARK: - Image
struct Image: Codable {
    let type: String
    let url: String
    let altText: String?
    let size: String?
    let horizontalAlignment: String?

    enum CodingKeys: String, CodingKey {
        case type
        case url
        case altText
        case size
        case horizontalAlignment
    }
}

// MARK: - ColumnSet
struct ColumnSet: Codable {
    let type: String
    let columns: [Column]
    let style: String?

    enum CodingKeys: String, CodingKey {
        case type
        case columns
        case style
    }
}

// MARK: - Column
struct Column: Codable {
    let type: String
    let width: String?
    let items: [CardElement]?
    let backgroundImage: BackgroundImage?
    let verticalContentAlignment: String?
    let spacing: String?

    enum CodingKeys: String, CodingKey {
        case type
        case width
        case items
        case backgroundImage
        case verticalContentAlignment
        case spacing
    }
}

// MARK: - ImageSet
struct ImageSet: Codable {
    let type: String
    let style: String?
    let size: String?
    let offset: Int?
    let images: [Image]

    enum CodingKeys: String, CodingKey {
        case type
        case style
        case size
        case offset
        case images
    }
}

// MARK: - BackgroundImage
struct BackgroundImage: Codable {
    let url: String
    let verticalAlignment: String?
    let horizontalAlignment: String?
}
