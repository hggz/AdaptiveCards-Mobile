import SwiftUI

@available(iOS 15.0, *)
struct AdaptiveCardView: View {
    let adaptiveCard: AdaptiveCard

    var body: some View {
        VStack {
            ForEach(adaptiveCard.body.indices, id: \.self) { index in
                viewForElement(adaptiveCard.body[index])
            }
        }
    }

    @ViewBuilder
    func viewForElement(_ element: CardElement) -> some View {
        switch element {
        case .container(let container):
            AnyView(
                VStack {
                    ForEach(container.items.indices, id: \.self) { index in
                        viewForElement(container.items[index])
                    }
                }
                .padding()
            )
        case .textBlock(let textBlock):
            AnyView(
                Text(textBlock.text)
                    .font(fontForSize(textBlock.size))
                    .multilineTextAlignment(alignmentForHorizontal(textBlock.horizontalAlignment))
                    .padding()
            )
        case .image(let image):
            if let url = URL(string: image.url) {
                AnyView(
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .padding()
                )
            } else {
                AnyView(EmptyView())
            }
        // Add cases for other elements as needed
        default:
            AnyView(EmptyView())
        }
    }

    @available(iOS 15.0, *)
    func fontForSize(_ size: String?) -> Font {
        switch size {
        case "ExtraLarge":
            return .largeTitle
        case "Large":
            return .title
        case "Medium":
            return .title2
        case "Small":
            return .body
        default:
            return .body
        }
    }

    func alignmentForHorizontal(_ alignment: String?) -> TextAlignment {
        switch alignment {
        case "Center":
            return .center
        case "Right":
            return .trailing
        default:
            return .leading
        }
    }
}
