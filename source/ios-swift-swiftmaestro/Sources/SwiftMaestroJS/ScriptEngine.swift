// Port of: pkg/jsengine (engine) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import SwiftMaestroJSEngine

/// A single JavaScript context (the vendored Duktape engine via the C shim).
///
/// NOT thread-safe: a Duktape heap must not be used concurrently. `ScriptHost`
/// confines every access to one serial queue; this type assumes that discipline.
final class ScriptEngine {
    private let ctx: OpaquePointer
    private let httpBox: HTTPBox?

    /// Retains the binding so the pointer handed to C stays valid for the engine's
    /// lifetime (the C trampoline receives it as its `user` argument).
    final class HTTPBox {
        let binding: HTTPBinding
        init(_ binding: HTTPBinding) { self.binding = binding }
    }

    init(http: HTTPBinding?) throws {
        guard let ctx = smjs_new() else { throw ScriptError.engineUnavailable }
        self.ctx = ctx
        if let http {
            let box = HTTPBox(http)
            self.httpBox = box
            smjs_set_http(ctx, ScriptEngine.httpTrampoline, Unmanaged.passUnretained(box).toOpaque())
        } else {
            self.httpBox = nil
        }
    }

    deinit { smjs_free(ctx) }

    /// Evaluate `source` and return the result. Throws on a JS error.
    func evaluate(_ source: String) throws -> JSValue {
        var out: UnsafeMutablePointer<CChar>?
        var isUndefined: Int32 = 0
        let rc = smjs_eval(ctx, source, &out, &isUndefined)
        defer { if let out { smjs_free_cstr(out) } }
        let text = out.map { String(cString: $0) } ?? ""
        if rc != 0 { throw ScriptError.evaluationFailed(text) }
        if isUndefined != 0 { return .undefined }
        return JSValue.decode(json: text)
    }

    /// Run `source` for its side effects (e.g. assigning to `output`).
    @discardableResult
    func run(_ source: String) throws -> JSValue { try evaluate(source) }

    /// Set a global variable to a Swift string value.
    func setStringGlobal(_ name: String, _ value: String) {
        _ = smjs_set_global_json(ctx, name, ScriptEngine.jsonEncodeString(value))
    }

    /// Read a global variable as a `JSValue`.
    func getGlobal(_ name: String) -> JSValue {
        var out: UnsafeMutablePointer<CChar>?
        let rc = smjs_get_global_json(ctx, name, &out)
        defer { if let out { smjs_free_cstr(out) } }
        guard rc == 0, let out else { return .undefined }
        let text = String(cString: out)
        if text == "undefined" { return .undefined }
        return JSValue.decode(json: text)
    }

    // MARK: - HTTP trampoline

    /// A `@convention(c)` function pointer (captures nothing). Recovers the
    /// `HTTPBox` from `user`, runs the binding synchronously, and returns the
    /// response as a malloc'd JSON string the shim frees.
    private static let httpTrampoline: smjs_http_fn = { user, requestJSON in
        guard let user, let requestJSON else { return nil }
        let box = Unmanaged<HTTPBox>.fromOpaque(user).takeUnretainedValue()
        let responseJSON = ScriptEngine.performHTTP(box.binding, requestJSON: String(cString: requestJSON))
        return smjs_dup_cstr(responseJSON)
    }

    private static func performHTTP(_ binding: HTTPBinding, requestJSON: String) -> String {
        let object = (try? JSONSerialization.jsonObject(with: Data(requestJSON.utf8))) as? [String: Any] ?? [:]
        let method = (object["method"] as? String) ?? "GET"
        let url = (object["url"] as? String) ?? ""
        var headers: [String: String] = [:]
        if let rawHeaders = object["headers"] as? [String: Any] {
            for (key, value) in rawHeaders { headers[key] = "\(value)" }
        }
        let body = object["body"] as? String

        let response = binding.request(HTTPScriptRequest(method: method, url: url, headers: headers, body: body))
        let responseObject: [String: Any] = ["status": response.status, "body": response.body]
        let data = (try? JSONSerialization.data(withJSONObject: responseObject))
            ?? Data(#"{"status":-1,"body":""}"#.utf8)
        return String(decoding: data, as: UTF8.self)
    }

    /// Encode a Swift string as a JSON string literal (properly escaped) by
    /// serializing a one-element array and stripping the brackets.
    static func jsonEncodeString(_ value: String) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: [value]),
              let text = String(data: data, encoding: .utf8), text.count >= 2 else {
            return "\"\""
        }
        return String(text.dropFirst().dropLast())
    }
}
