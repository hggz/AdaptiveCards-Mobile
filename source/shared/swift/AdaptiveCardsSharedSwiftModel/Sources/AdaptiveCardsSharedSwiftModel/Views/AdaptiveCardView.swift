import SwiftUI

@available(iOS 15.0, *)
struct AdaptiveCardView: View {
    let adaptiveCard: AdaptiveCard
    @StateObject private var viewModel = AdaptiveCardViewModel()

    var body: some View {
        VStack {
            if let body = adaptiveCard.body {
                ForEach(body.indices, id: \.self) { index in
                    AdaptiveCardElementView(element: body[index])
                        .environmentObject(viewModel)
                }
            }
            if let actions = adaptiveCard.actions {
                ForEach(actions.indices, id: \.self) { index in
                    actionButton(for: actions[index])
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    func actionButton(for action: Action) -> some View {
        Button(action.title ?? "Action") {
            viewModel.handleAction(action)
        }
        .padding()
    }
}
