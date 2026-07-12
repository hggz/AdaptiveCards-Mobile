// Port of: pkg/browser (DOM hierarchy) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import SwiftMaestroDriver

/// Builds a normalized `ViewHierarchy` from the browser DOM.
///
/// Rather than walking CDP `DOM.*` node-by-node, we evaluate a single JavaScript
/// snippet (`Runtime.evaluate` with `returnByValue`) that serializes the document
/// into the same `ViewNode` JSON shape the element finder already understands —
/// so web selectors (`text=`, `id=`) work through the identical finder used for
/// Android. The `__swiftmaestro_dom__` marker lets the test mock recognize the
/// snapshot request.
public enum WebHierarchy {
    /// JavaScript that serializes `document.documentElement` into `ViewNode` JSON.
    public static let domSnapshotExpression = """
    /*__swiftmaestro_dom__*/(function () {
      function text(el) {
        var parts = [];
        var kids = el.childNodes || [];
        for (var i = 0; i < kids.length; i++) {
          if (kids[i].nodeType === 3) {
            var t = (kids[i].textContent || "").trim();
            if (t) parts.push(t);
          }
        }
        return parts.join(" ").trim() || null;
      }
      function attr(el, name) {
        return el.getAttribute ? el.getAttribute(name) : null;
      }
      function visible(el, rect) {
        var style = window.getComputedStyle ? getComputedStyle(el) : null;
        if (style && (style.display === "none" || style.visibility === "hidden")) return false;
        return rect.width > 0 && rect.height > 0;
      }
      function walk(el) {
        var rect = el.getBoundingClientRect
          ? el.getBoundingClientRect()
          : { left: 0, top: 0, width: 0, height: 0 };
        var tag = (el.tagName || "").toLowerCase();
        var clickable =
          ["a", "button", "input", "select", "textarea"].indexOf(tag) >= 0 ||
          attr(el, "onclick") != null ||
          attr(el, "role") === "button";
        var node = {
          tag: tag || null,
          resourceId: el.id || null,
          text: text(el),
          accessibilityId: attr(el, "data-testid") || attr(el, "aria-label") || null,
          className: typeof el.className === "string" ? el.className || null : null,
          bounds: {
            x: Math.round(rect.left),
            y: Math.round(rect.top),
            width: Math.round(rect.width),
            height: Math.round(rect.height)
          },
          clickable: clickable,
          visible: visible(el, rect),
          children: []
        };
        var children = el.children || [];
        for (var i = 0; i < children.length; i++) {
          node.children.push(walk(children[i]));
        }
        return node;
      }
      return walk(document.documentElement);
    })()
    """

    /// Decode the `{ result: { value: <node> } }` payload of a `Runtime.evaluate`
    /// (with `returnByValue: true`) response into a `ViewHierarchy`.
    public static func decodeHierarchy(fromEvaluateResult result: [String: Any]) throws -> ViewHierarchy {
        guard let inner = result["result"] as? [String: Any] else {
            throw CDPError.protocolError("Runtime.evaluate: missing 'result' in response")
        }
        guard let value = inner["value"] else {
            throw CDPError.protocolError("Runtime.evaluate: missing 'value' (was returnByValue set?)")
        }
        let data = try JSONSerialization.data(withJSONObject: value)
        let root = try JSONDecoder().decode(ViewNode.self, from: data)
        return ViewHierarchy(root: root, platform: .web)
    }
}
