import Foundation

/// Represents a unique identifier for elements during deserialization.
struct InternalId: Hashable, Codable {
    private static var currentInternalId: UInt = 0
    private let internalId: UInt

    /// Creates a new InternalId with the next available unique identifier.
    static func next() -> InternalId {
        currentInternalId += 1
        return InternalId(id: currentInternalId)
    }

    /// Retrieves the current InternalId without incrementing.
    static func current() -> InternalId {
        return InternalId(id: currentInternalId)
    }

    /// Represents an invalid internal ID.
    static let invalid: InternalId = InternalId(id: 0)

    /// Returns the hash value for this internal ID.
    func hashValue() -> UInt {
        return internalId
    }

    // MARK: - Equatable & Hashable
    static func == (lhs: InternalId, rhs: InternalId) -> Bool {
        return lhs.internalId == rhs.internalId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(internalId)
    }

    // Private initializer to control ID assignment
    private init(id: UInt) {
        self.internalId = id
    }
}
