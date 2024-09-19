import UIKit

class AnchorRenderer {

    typealias Renderer = (String?, [NSAttributedString.Key: Any]?) -> UIView?

    func defaultRenderer(displayText: String?, attributes: [NSAttributedString.Key: Any]?) -> UIView {
        
        // Create a button to act as an anchor link
        let button = UIButton(type: .system)
        
        if let displayText = displayText {
            button.setTitle(displayText, for: .normal)
        } else if let href = attributes?[.link] as? String {
            button.setTitle(href, for: .normal)
        }
        
        if let attributes = attributes {
            let attributedTitle = NSAttributedString(string: button.title(for: .normal) ?? "", attributes: attributes)
            button.setAttributedTitle(attributedTitle, for: .normal)
        }
        
        button.addTarget(self, action: #selector(handleAnchorTap(sender:)), for: .touchUpInside)
        
        return button
    }
    
    @objc func handleAnchorTap(sender: UIButton) {
        if let href = sender.attributedTitle(for: .normal)?.attribute(.link, at: 0, effectiveRange: nil) as? String {
            // Handle the link tap action, for example, by opening the URL
            if let url = URL(string: href) {
                UIApplication.shared.open(url)
            }
        }
    }
}

/*
 let renderer = AnchorRenderer()
 let view = renderer.defaultRenderer(displayText: "Click Me!", attributes: [.link: "https://www.example.com"])

 */
