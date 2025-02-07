import Foundation

protocol CollectionCoreElement: BaseCardElement {
    mutating func deserializeChildren(from json: [String: Any]) throws
    
    static func deserialize<T: CollectionCoreElement>(from json: [String: Any], context: inout ParseContext) throws -> T
}

extension CollectionCoreElement {
    static func deserialize<T: CollectionCoreElement>(from json: [String: Any], context: inout ParseContext) throws -> T {
        var collection = try BaseCardElement.deserialize(from: json, context: &context) as! T
        
        let canFallbackToAncestor = context.canFallbackToAncestor
        context.canFallbackToAncestor = canFallbackToAncestor || (collection.fallbackType != .none)
        collection.canFallbackToAncestor = canFallbackToAncestor

        try collection.deserializeChildren(from: json)

        context.canFallbackToAncestor = canFallbackToAncestor
        
        return collection
    }
    
    func getResourceInformation<T: BaseCardElement>(_ elements: [T]) -> [RemoteResourceInformation] {
        return elements.flatMap { $0.getResourceInformation() }
    }
}
