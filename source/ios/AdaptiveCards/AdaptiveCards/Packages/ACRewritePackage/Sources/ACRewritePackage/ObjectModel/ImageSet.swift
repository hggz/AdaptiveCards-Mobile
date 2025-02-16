import Foundation

/// Represents an image set element in an Adaptive Card.
class ImageSet: BaseCardElement {
    // MARK: - Properties
    var images: [Image] = []
    var imageSize: ImageSize = .none  // Default value
    
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
        self.images = try container.decodeIfPresent([Image].self, forKey: .images) ?? []
        self.imageSize = try container.decodeIfPresent(ImageSize.self, forKey: .imageSize) ?? .none
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
    func serializeToJsonVal() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        // If imageSize is not .none, add it using a converter.
        if imageSize != .none {
            json["imageSize"] = imageSize.rawValue
        }
        // Add the images array.
        json["images"] = try images.map { try $0.serializeToJsonVal() }
        return json
    }
    
    // MARK: - Known Properties
    private func populateKnownPropertiesSet() {
        self.knownProperties.insert("images")
        self.knownProperties.insert("imageSize")
    }
    
    // MARK: - Resource Information
    func getResourceInformation(_ resourceInfo: inout [RemoteResourceInformation]) {
        for image in images {
            image.getResourceInformation(&resourceInfo)
        }
    }
}

/// Parses ImageSet elements in an Adaptive Card.
struct ImageSetParser: BaseCardElementParser {
    func deserialize(context: inout ParseContext, value: [String: Any]) throws -> BaseCardElement {
        // Verify that the type is "ImageSet".
        try ParseUtil.expectTypeString(value, expected: .imageSet)
        
        // Deserialize an ImageSet using the generic helper.
        let imageSet: ImageSet = try BaseCardElement.deserialize(from: value) as! ImageSet
        
        // Set the imageSize property.
        imageSet.imageSize = try ParseUtil.getEnumValue(from: value, key: "imageSize", defaultValue: .none, converter: ImageSize.fromString)
        
        // Parse the images array.
        let imagesArray: [[String: Any]] = try ParseUtil.getArray(from: value, key: "images", required: true)
        var images: [Image] = []
        for imageJson in imagesArray {
            // Deserialize each image (using the global helper).
            let baseElement = try BaseCardElement.deserialize(from: imageJson)
            if let image = baseElement as? Image {
                images.append(image)
            }
        }
        imageSet.images = images
        
        return imageSet
    }
    
    func deserialize(fromString context: inout ParseContext, value: String) throws -> BaseCardElement {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: &context, value: jsonDict)
    }
}
