import SwiftUI

@available(iOS 15.0, *)
class AdaptiveCardViewModel: ObservableObject {
    @Published var formData: [String: String] = [:]
    @Published var showModalCard: AdaptiveCard?

    func handleAction(_ action: Action) {
        switch action {
        case .openUrl(let actionOpenUrl):
            if let urlString = actionOpenUrl.url, let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        case .submit(_):
            // Handle submit action
            print("Form data: \(formData)")
        case .showCard(let actionShowCard):
            // Handle show card action
            // You might want to present a new view or update the UI accordingly
            print("Show card action triggered")
            self.showModalCard = actionShowCard.card
        case .execute(_):
            // Handle execute action
            print("Execute action triggered")
        }
    }

    // MARK: - Binding Methods

    func bindingForInput(_ id: String, defaultValue: String) -> Binding<String> {
        Binding<String>(
            get: { self.formData[id, default: defaultValue] },
            set: { self.formData[id] = $0 }
        )
    }

    func bindingForToggleInput(_ id: String, defaultValue: Bool) -> Binding<Bool> {
        Binding<Bool>(
            get: { (self.formData[id] ?? "") == "true" },
            set: { self.formData[id] = $0 ? "true" : "false" }
        )
    }

    func bindingForDateInput(_ id: String, defaultValue: String?) -> Binding<Date> {
        let formatter = ISO8601DateFormatter()
        let defaultDate = defaultValue.flatMap { formatter.date(from: $0) } ?? Date()
        return Binding<Date>(
            get: {
                if let dateString = self.formData[id], let date = formatter.date(from: dateString) {
                    return date
                } else {
                    return defaultDate
                }
            },
            set: {
                self.formData[id] = formatter.string(from: $0)
            }
        )
    }

    // Add any other shared functions or state
}
