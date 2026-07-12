// Port of: pkg/jsengine (values) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// A JavaScript value marshalled across the Swift/JS boundary as JSON. Modeled
/// as an enum so `${…}` substitution and `assertTrue`/`when` truthiness are typed
/// rather than stringly-guessed.
public enum JSValue: Sendable, Equatable {
    case undefined
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([JSValue])
    case object([String: JSValue])

    /// JavaScript truthiness (`if (value)`), used by `assertTrue` / `when`.
    public var isTruthy: Bool {
        switch self {
        case .undefined, .null: return false
        case .bool(let b): return b
        case .number(let n): return n != 0 && !n.isNaN
        case .string(let s): return !s.isEmpty
        case .array, .object: return true
        }
    }

    /// The value as text for `${…}` substitution: primitives render plainly,
    /// integers without a decimal point, and compound values as compact JSON.
    public var stringValue: String {
        switch self {
        case .undefined: return ""
        case .null: return "null"
        case .bool(let b): return b ? "true" : "false"
        case .number(let n):
            if n.rounded() == n && abs(n) < 1e15 { return String(Int64(n)) }
            return String(n)
        case .string(let s): return s
        case .array, .object: return (try? jsonString()) ?? ""
        }
    }

    /// Decode a single value from the JSON the engine emits. Robust to top-level
    /// primitives (`42`, `"abc"`, `true`) by decoding through a one-element array.
    public static func decode(json: String) -> JSValue {
        let wrapped = "[\(json)]"
        guard let values = try? JSONDecoder().decode([JSValue].self, from: Data(wrapped.utf8)),
              let first = values.first else {
            return .undefined
        }
        return first
    }

    func jsonString() throws -> String {
        let data = try JSONEncoder().encode(self)
        return String(decoding: data, as: UTF8.self)
    }
}

extension JSValue: Decodable {
    public init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer() {
            if single.decodeNil() { self = .null; return }
            // Bool before Double: JSONDecoder is type-strict, so `true` decodes as
            // Bool and never as a number, and vice versa.
            if let b = try? single.decode(Bool.self) { self = .bool(b); return }
            if let n = try? single.decode(Double.self) { self = .number(n); return }
            if let s = try? single.decode(String.self) { self = .string(s); return }
        }
        if var unkeyed = try? decoder.unkeyedContainer() {
            var out: [JSValue] = []
            while !unkeyed.isAtEnd { out.append(try unkeyed.decode(JSValue.self)) }
            self = .array(out); return
        }
        if let keyed = try? decoder.container(keyedBy: JSDynamicCodingKey.self) {
            var out: [String: JSValue] = [:]
            for key in keyed.allKeys { out[key.stringValue] = try keyed.decode(JSValue.self, forKey: key) }
            self = .object(out); return
        }
        self = .undefined
    }
}

extension JSValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .undefined, .null:
            var c = encoder.singleValueContainer(); try c.encodeNil()
        case .bool(let b):
            var c = encoder.singleValueContainer(); try c.encode(b)
        case .number(let n):
            var c = encoder.singleValueContainer(); try c.encode(n)
        case .string(let s):
            var c = encoder.singleValueContainer(); try c.encode(s)
        case .array(let a):
            var c = encoder.unkeyedContainer()
            for v in a { try c.encode(v) }
        case .object(let o):
            var c = encoder.container(keyedBy: JSDynamicCodingKey.self)
            for (k, v) in o { try c.encode(v, forKey: JSDynamicCodingKey(stringValue: k)!) }
        }
    }
}

/// A coding key for arbitrary JSON object member names.
private struct JSDynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int? { nil }
    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { nil }
}
