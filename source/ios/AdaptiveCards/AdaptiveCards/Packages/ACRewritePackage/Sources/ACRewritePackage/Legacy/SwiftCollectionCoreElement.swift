import Foundation

protocol SwiftCollectionCoreElement: SwiftBaseCardElement {
    // Remove 'mutating' since BaseCardElement is a class.
    func deserializeChildren(from json: [String: Any]) throws
    
    static func deserialize<T: SwiftCollectionCoreElement>(from json: [String: Any], context: SwiftParseContext) throws -> T
}

extension SwiftCollectionCoreElement {
    static func deserialize<T: SwiftCollectionCoreElement>(from json: [String: Any], context: SwiftParseContext) throws -> T {
        // Call the BaseCardElement deserializer without a context parameter.
        let collection = try SwiftBaseCardElement.deserialize(from: json) as! T
        
        let canFallbackToAncestor = context.canFallbackToAncestor
        context.canFallbackToAncestor = canFallbackToAncestor || (collection.fallbackType != SwiftFallbackType.none)
        collection.canFallbackToAncestor = canFallbackToAncestor
        
        try collection.deserializeChildren(from: json)
        
        context.canFallbackToAncestor = canFallbackToAncestor
        
        return collection
    }
    
    func getResourceInformation<T: SwiftBaseCardElement>(_ elements: [T]) -> [SwiftRemoteResourceInformation] {
        return elements.flatMap { $0.getResourceInformation() }
    }
}

// MARK: - Stub Implementation for BaseCardElement Resource Info TODO

// If BaseCardElement does not already implement getResourceInformation(),
// add the following extension. (Remove this extension if your project already defines it.)
extension SwiftBaseCardElement {
    func getResourceInformation() -> [SwiftRemoteResourceInformation] {
        return []
    }
}
