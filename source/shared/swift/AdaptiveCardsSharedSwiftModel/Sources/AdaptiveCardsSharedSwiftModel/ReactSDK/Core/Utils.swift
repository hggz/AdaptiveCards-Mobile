import UIKit

func addClass(props: inout [String: Any], classNames: String...) {
    var classList = props["className"] as? [String] ?? []
    classList.append(contentsOf: classNames)
    props["className"] = classList.joined(separator: " ")
}

func createProps() -> [String: Any] {
    return ["style": [:]]
}

func isMobileOS() -> Bool {
    // On iOS, the app will only be running on an iPhone or iPad, so we can safely return true.
    return true
}

func generateUniqueId() -> String {
    return "__ac-\(UUID().uuidString)"
}

func appendChild(node: UIView, child: UIView?) {
    if let childView = child {
        node.addSubview(childView)
    }
}

func parseString(obj: Any, defaultValue: String? = nil) -> String? {
    if let str = obj as? String {
        return str
    }
    return defaultValue
}

func parseNumber(obj: Any, defaultValue: Int? = nil) -> Int? {
    if let num = obj as? Int {
        return num
    }
    return defaultValue
}

func parseBool(value: Any, defaultValue: Bool? = nil) -> Bool? {
    if let boolValue = value as? Bool {
        return boolValue
    } else if let strValue = value as? String {
        switch strValue.lowercased() {
        case "true":
            return true
        case "false":
            return false
        default:
            return defaultValue
        }
    }
    return defaultValue
}

func padStart(s: String, prefix: String, targetLength: Int) -> String {
    var result = s
    while result.count < targetLength {
        result = prefix + result
    }
    return result
}

func dateToString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)
}

func getEnumValueByName(enumType: [Int: String], name: String) -> Int? {
    for (key, value) in enumType {
        if value.lowercased() == name.lowercased() {
            return key
        }
    }
    return nil
}

func parseEnum(enumType: [Int: String], name: String, defaultValue: Int? = nil) -> Int? {
    if let enumValue = getEnumValueByName(enumType: enumType, name: name) {
        return enumValue
    }
    return defaultValue
}

func stringToCssColor(color: String?) -> String? {
    if let hexColor = color {
        let regex = try? NSRegularExpression(pattern: "#([0-9A-F]{2})([0-9A-F]{2})([0-9A-F]{2})([0-9A-F]{2})?", options: .caseInsensitive)
        if let match = regex?.firstMatch(in: hexColor, options: [], range: NSRange(location: 0, length: hexColor.utf16.count)),
           let r = Int((hexColor as NSString).substring(with: match.range(at: 1)), radix: 16),
           let g = Int((hexColor as NSString).substring(with: match.range(at: 2)), radix: 16),
           let b = Int((hexColor as NSString).substring(with: match.range(at: 3)), radix: 16) {
            let aRange = match.range(at: 4)
            if aRange.location != NSNotFound, let a = Int((hexColor as NSString).substring(with: aRange), radix: 16) {
                return String(format: "rgba(%d,%d,%d,%f)", r, g, b, CGFloat(a) / 255.0)
            } else {
                return String(format: "rgb(%d,%d,%d)", r, g, b)
            }
        }
    }
    return color
}

func hexStringToUIColor(hexColor: String?) -> UIColor? {
    guard let hexColor = hexColor else {
        return nil
    }

    let regex = try? NSRegularExpression(pattern: "#([0-9A-F]{2})([0-9A-F]{2})([0-9A-F]{2})([0-9A-F]{2})?", options: .caseInsensitive)
    if let match = regex?.firstMatch(in: hexColor, options: [], range: NSRange(location: 0, length: hexColor.utf16.count)),
       let r = Int((hexColor as NSString).substring(with: match.range(at: 1)), radix: 16),
       let g = Int((hexColor as NSString).substring(with: match.range(at: 2)), radix: 16),
       let b = Int((hexColor as NSString).substring(with: match.range(at: 3)), radix: 16) {

        let aRange = match.range(at: 4)
        if aRange.location != NSNotFound, let a = Int((hexColor as NSString).substring(with: aRange), radix: 16) {
            return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
        } else {
            return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
        }
    }

    return nil
}

func clearElementChildren(element: UIView) {
    for subview in element.subviews {
        subview.removeFromSuperview()
    }
}

class GestureHandlerUtility: NSObject {
    
    @objc func elementTapped(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = true
    }
    
    static func addCancelSelectActionEventHandler(to element: UIView) {
        let handler = GestureHandlerUtility()
        let tapGesture = UITapGestureRecognizer(target: handler, action: #selector(handler.elementTapped(sender:)))
        element.addGestureRecognizer(tapGesture)
        // Store the handler in the gesture so it's retained as long as the gesture is alive
        // This is a workaround since we're not keeping the handler anywhere else
        objc_setAssociatedObject(tapGesture, &tapGestureAssociationKey, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private var tapGestureAssociationKey = 0
