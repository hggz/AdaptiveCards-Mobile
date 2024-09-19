import UIKit
import SwiftUI

@objc(AdaptiveCardsSharedSwift)
@objcMembers public class AdaptiveCardsSharedSwift: NSObject {
    
    public func parse(payload: String) -> UIView {
        guard let payloadData = payload.data(using: .utf8) else {
            debugPrint("unable to load payload data:\n\(payload)")
            let testView = UIView(frame: .zero)
            testView.backgroundColor = .red
            return testView
        }
        
        do {
            let adaptiveCard = try JSONDecoder().decode(AdaptiveCard.self, from: payloadData)
            debugPrint("successfully loaded adaptive card payload data")
            
            // Create the SwiftUI view using the parsed AdaptiveCard
            if #available(iOS 15.0, *) {
                let adaptiveCardView = AdaptiveCardView(adaptiveCard: adaptiveCard)
                // Wrap the SwiftUI view inside a UIHostingController
                let hostingController = UIHostingController(rootView: adaptiveCardView)
                
                // Set up the hosting controller's view
                let hostingView = hostingController.view
                hostingView?.backgroundColor = .clear // Optional: Set background if needed
                hostingView?.translatesAutoresizingMaskIntoConstraints = false
                
                return hostingView ?? UIView(frame: .zero)
            } else {
                // Fallback on earlier versions
                let errorView = UIView(frame: .zero)
                errorView.backgroundColor = .yellow
                return errorView
            }
            
            
        } catch {
            debugPrint("unable to parse adaptive card payload: \(error)\n\(payload)")
            let errorView = UIView(frame: .zero)
            errorView.backgroundColor = .green
            return errorView
        }
    }
}
