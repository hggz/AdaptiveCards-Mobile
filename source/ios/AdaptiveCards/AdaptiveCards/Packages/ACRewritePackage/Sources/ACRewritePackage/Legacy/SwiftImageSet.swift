import Foundation

/// Represents an image set element in an Adaptive Card.
class SwiftImageSet: SwiftBaseCardElement {
    // MARK: - Properties
    var images: [SwiftImage] = []
    var imageSize: SwiftImageSize = .auto
    
    // MARK: - Initializer
    init(id: String? = nil) {
        super.init(
            type: .imageSet,
            spacing: nil,
            height: nil,
            targetWidth: nil,
            separator: nil,
            isVisible: true,
            areaGridName: nil,
            id: id
        )
        populateKnownPropertiesSet()
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case images, imageSize
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the images array (using our helper for AnyCodable dictionaries)
        let rawImages = try container.decodeIfPresent([[String: AnyCodable]].self, forKey: .images) ?? []
        var finalImages = [SwiftImage]()
        for rawImg in rawImages {
            var dict = rawImg.mapValues { $0.value }
            // Ensure that the type is set to "Image"
            if let existingType = dict["type"] as? String {
                if existingType.lowercased() != "image" {
                    throw AdaptiveCardParseError.invalidType
                }
            } else {
                dict["type"] = "Image"
            }
            let base = try SwiftBaseCardElement.deserialize(from: dict)
            guard let img = base as? SwiftImage else {
                throw AdaptiveCardParseError.invalidType
            }
            finalImages.append(img)
        }
        self.images = finalImages
        
        // Decode imageSize; if missing, default to .auto
        self.imageSize = try container.decodeIfPresent(SwiftImageSize.self, forKey: .imageSize) ?? .auto
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(images, forKey: .images)
        try container.encode(imageSize, forKey: .imageSize)
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization
    /// Serializes the ImageSet into a JSON dictionary.
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        json["type"] = "ImageSet"
        // Use the rawValue directly, so that "Auto" is preserved.
        json["imageSize"] = imageSize.rawValue
        json["images"] = try images.map { try $0.serializeToJsonValue() }
        return json
    }
    
    // MARK: - Known Properties
    private func populateKnownPropertiesSet() {
        self.knownProperties.insert("images")
        self.knownProperties.insert("imageSize")
    }
    
    // MARK: - Resource Information
    func getResourceInformation(_ resourceInfo: inout [SwiftRemoteResourceInformation]) {
        for image in images {
            image.getResourceInformation(&resourceInfo)
        }
    }
}

/// Parses ImageSet elements in an Adaptive Card.
struct SwiftImageSetParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: .imageSet)
        let imageSet = try SwiftBaseCardElement.deserialize(from: value) as! SwiftImageSet
        
        // Grab the "images" array from the JSON.
        let imagesArray: [[String: Any]] = try SwiftParseUtil.getArray(from: value, key: "images", required: true)
        var images: [SwiftImage] = []
        for imageJson in imagesArray {
            var temp = imageJson
            if temp["type"] == nil {
                temp["type"] = "Image"
            }
            let base = try SwiftBaseCardElement.deserialize(from: temp)
            guard let asImage = base as? SwiftImage else {
                throw AdaptiveCardParseError.invalidType
            }
            images.append(asImage)
        }
        imageSet.images = images
        
        // Decode imageSize from the original JSON if present.
        if let sizeStr = value["imageSize"] as? String, let size = SwiftImageSize.fromString(sizeStr) {
            imageSet.imageSize = size
        } else {
            imageSet.imageSize = .auto
        }
        return imageSet
    }

    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        let jsonDict = try SwiftParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
