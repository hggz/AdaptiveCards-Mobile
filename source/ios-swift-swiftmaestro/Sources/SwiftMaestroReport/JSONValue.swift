// Deterministic JSON writer for report output.
//
// Foundation's JSONEncoder differs across platforms in forward-slash escaping
// (`\/` on Apple/Windows, `/` on swift-corelibs Linux) and does not guarantee a
// stable key order, which would make golden fixtures non-portable. This small
// writer emits ordered, escaped JSON identically everywhere.

import Foundation

public enum JSONValue {
    case string(String)
    case int(Int)
    case int64(Int64)
    case bool(Bool)
    indirect case array([JSONValue])
    indirect case object([(String, JSONValue)])
    case null

    /// Convenience: a string value, or `null` when the input is nil.
    public static func optional(_ s: String?) -> JSONValue {
        s.map { .string($0) } ?? .null
    }

    public func serialized(pretty: Bool = true) -> String {
        var out = ""
        write(into: &out, indent: 0, pretty: pretty)
        return out
    }

    private func write(into out: inout String, indent: Int, pretty: Bool) {
        let nl = pretty ? "\n" : ""
        let pad = pretty ? String(repeating: "  ", count: indent + 1) : ""
        let end = pretty ? String(repeating: "  ", count: indent) : ""
        switch self {
        case .string(let s): out += JSONValue.escape(s)
        case .int(let i): out += String(i)
        case .int64(let i): out += String(i)
        case .bool(let b): out += b ? "true" : "false"
        case .null: out += "null"
        case .array(let items):
            if items.isEmpty { out += "[]"; return }
            out += "[" + nl
            for (i, item) in items.enumerated() {
                out += pad
                item.write(into: &out, indent: indent + 1, pretty: pretty)
                out += (i < items.count - 1 ? "," : "") + nl
            }
            out += end + "]"
        case .object(let pairs):
            if pairs.isEmpty { out += "{}"; return }
            out += "{" + nl
            for (i, kv) in pairs.enumerated() {
                out += pad + JSONValue.escape(kv.0) + (pretty ? ": " : ":")
                kv.1.write(into: &out, indent: indent + 1, pretty: pretty)
                out += (i < pairs.count - 1 ? "," : "") + nl
            }
            out += end + "}"
        }
    }

    /// RFC 8259 string escaping. Deliberately does NOT escape `/`.
    static func escape(_ s: String) -> String {
        var r = "\""
        for scalar in s.unicodeScalars {
            switch scalar {
            case "\"": r += "\\\""
            case "\\": r += "\\\\"
            case "\n": r += "\\n"
            case "\r": r += "\\r"
            case "\t": r += "\\t"
            case "\u{08}": r += "\\b"
            case "\u{0C}": r += "\\f"
            default:
                if scalar.value < 0x20 {
                    r += String(format: "\\u%04x", scalar.value)
                } else {
                    r.unicodeScalars.append(scalar)
                }
            }
        }
        r += "\""
        return r
    }
}
