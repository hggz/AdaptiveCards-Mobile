// Port of: pkg/core (platform/geometry) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// The kind of target a driver automates.
public enum Platform: String, Sendable, Codable, Equatable {
    case android
    case ios
    case web
}

/// An absolute screen coordinate in device pixels.
public struct Point: Sendable, Codable, Equatable {
    public var x: Int
    public var y: Int
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

/// An axis-aligned bounding box in device pixels.
public struct Bounds: Sendable, Codable, Equatable {
    public var x: Int
    public var y: Int
    public var width: Int
    public var height: Int

    public init(x: Int, y: Int, width: Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public var right: Int { x + width }
    public var bottom: Int { y + height }
    public var centerX: Int { x + width / 2 }
    public var centerY: Int { y + height / 2 }
    public var center: Point { Point(x: centerX, y: centerY) }
}
