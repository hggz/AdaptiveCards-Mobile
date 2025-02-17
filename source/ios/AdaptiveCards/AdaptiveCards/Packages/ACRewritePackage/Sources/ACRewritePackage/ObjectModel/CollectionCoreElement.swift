import Foundation

protocol CollectionCoreElement: BaseCardElement {
    // Remove 'mutating' since BaseCardElement is a class.
    func deserializeChildren(from json: [String: Any]) throws
    
    static func deserialize<T: CollectionCoreElement>(from json: [String: Any], context: ParseContext) throws -> T
}

extension CollectionCoreElement {
    static func deserialize<T: CollectionCoreElement>(from json: [String: Any], context: ParseContext) throws -> T {
        // Call the BaseCardElement deserializer without a context parameter.
        let collection = try BaseCardElement.deserialize(from: json) as! T
        
        let canFallbackToAncestor = context.canFallbackToAncestor
        context.canFallbackToAncestor = canFallbackToAncestor || (collection.fallbackType != FallbackType.none)
        collection.canFallbackToAncestor = canFallbackToAncestor
        
        try collection.deserializeChildren(from: json)
        
        context.canFallbackToAncestor = canFallbackToAncestor
        
        return collection
    }
    
    func getResourceInformation<T: BaseCardElement>(_ elements: [T]) -> [RemoteResourceInformation] {
        return elements.flatMap { $0.getResourceInformation() }
    }
}

// MARK: - Stub Implementation for BaseCardElement Resource Info TODO

// If BaseCardElement does not already implement getResourceInformation(),
// add the following extension. (Remove this extension if your project already defines it.)
extension BaseCardElement {
    func getResourceInformation() -> [RemoteResourceInformation] {
        return []
    }
}
