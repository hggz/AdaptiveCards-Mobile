import SwiftUI

@available(iOS 15.0, *)
struct AdaptiveCardView: View {
    let adaptiveCard: AdaptiveCard
    @State private var formData: [String: String] = [:]

    var body: some View {
        VStack {
            ForEach(adaptiveCard.body.indices, id: \.self) { index in
                viewForElement(adaptiveCard.body[index])
            }
            if let actions = adaptiveCard.actions {
                ForEach(actions.indices, id: \.self) { index in
                    viewForAction(actions[index])
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    func viewForElement(_ element: CardElement) -> some View {
        switch element {
        case .inputText(let input):
            AnyView(
                TextField(input.label ?? input.id, text: bindingForInput(input.id, defaultValue: input.value ?? "DEFAULT_INPUT"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            )
        case .inputNumber(let input):
            AnyView(
                TextField(input.id, text: bindingForInput(input.id, defaultValue: input.value.map { String($0) } ?? ""))
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            )
        case .inputDate(let input):
            AnyView(
                DatePicker(selection: bindingForDateInput(input.id, defaultValue: input.value), displayedComponents: .date) {
                    Text(input.label ?? input.id)
                }
                .padding()
            )
        case .inputTime(let input):
            AnyView(
                DatePicker(selection: bindingForDateInput(input.id, defaultValue: input.value), displayedComponents: .hourAndMinute) {
                    Text(input.label ?? input.id)
                }
                .padding()
            )
        case .inputToggle(let input):
            AnyView(
                Toggle(isOn: bindingForToggleInput(input.id, defaultValue: input.value == input.valueOn)) {
                    Text(input.title ?? input.id)
                }
                .padding()
            )
        case .inputChoiceSet(let input):
            if input.isMultiSelect ?? false {
                AnyView(Text("Multi-select choice sets are not yet implemented"))
            } else {
                AnyView(
                    Picker(selection: bindingForInput(input.id, defaultValue: input.value ?? ""), label: Text(input.label ?? input.id)) {
                        ForEach(input.choices, id: \.value) { choice in
                            Text(choice.title).tag(choice.value)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                )
            }
        case .container(let container):
            AnyView(
                VStack {
                    ForEach(container.items.indices, id: \.self) { index in
                        viewForElement(container.items[index])
                    }
                }
            )
        case .textBlock(let textBlock):
            AnyView(
                Text(textBlock.text)
                    .font(fontForSize(textBlock.size))
                    .multilineTextAlignment(alignmentForHorizontal(textBlock.horizontalAlignment))
            )
        case .image(let image):
            if let url = URL(string: image.url) {
                AnyView(
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                )
            } else {
                AnyView(EmptyView())
            }
        default:
            AnyView(EmptyView())
        }
    }

    @ViewBuilder
    func viewForAction(_ action: CardElement) -> some View {
        switch action {
        case .actionSubmit(let action):
            AnyView(
                Button(action.title ?? "Submit") {
                    // Handle submit action
                    print("Form data: \(formData)")
                }
                .padding()
            )
        case .actionOpenUrl(let action):
            if let urlString = action.url, let url = URL(string: urlString) {
                AnyView(
                    Link(action.title ?? "Open URL", destination: url)
                        .padding()
                )
            } else {
                AnyView(EmptyView())
            }
        default:
            AnyView(EmptyView())
        }
    }

    // MARK: - Helper Functions for Bindings

    func bindingForInput(_ id: String, defaultValue: String) -> Binding<String> {
        Binding<String>(
            get: { formData[id, default: defaultValue] },
            set: { formData[id] = $0 }
        )
    }

    func bindingForToggleInput(_ id: String, defaultValue: Bool) -> Binding<Bool> {
        Binding<Bool>(
            get: { (formData[id] ?? "") == "true" },
            set: { formData[id] = $0 ? "true" : "false" }
        )
    }

    func bindingForDateInput(_ id: String, defaultValue: String?) -> Binding<Date> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let defaultDate = formatter.date(from: defaultValue ?? "") ?? Date()
        return Binding<Date>(
            get: {
                if let dateString = formData[id], let date = formatter.date(from: dateString) {
                    return date
                } else {
                    return defaultDate
                }
            },
            set: {
                formData[id] = formatter.string(from: $0)
            }
        )
    }

    // MARK: - Font and Alignment Helpers

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
