import UIKit

typealias ImageRenderer = (_ image: IImage, _ props: [String: Any]?) -> UIImageView?

func defaultImageRenderer(_ image: IImage, _ props: [String: Any]?) -> UIImageView? {
    let imageView = UIImageView()
    
    // Apply properties from props dictionary to the UIImageView instance
    // For example:
    // if let contentModeString = props?["contentMode"] as? String {
    //     imageView.contentMode = contentMode(from: contentModeString)
    // }
    
    // TODO: You'll need to apply the data from 'image' to your UIImageView.
    // This might include setting the image URL, etc.

    return imageView
}

// Helper function (example for contentMode)
// func contentMode(from string: String) -> UIView.ContentMode {
//     switch string {
//     case "scaleAspectFill":
//         return .scaleAspectFill
//     case "scaleAspectFit":
//         return .scaleAspectFit
//     default:
//         return .scaleToFill
//     }
// }
