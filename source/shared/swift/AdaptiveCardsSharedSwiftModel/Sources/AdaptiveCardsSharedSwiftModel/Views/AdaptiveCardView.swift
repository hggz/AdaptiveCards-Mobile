import SwiftUI
import UIKit
import AVKit // Added for media playback

@available(iOS 15.0, *)
struct AdaptiveCardView: View {
    let adaptiveCard: AdaptiveCard
    @State private var formData: [String: String] = [:]

    var body: some View {
        VStack {
            if let body = adaptiveCard.body {
                ForEach(body.indices, id: \.self) { index in
                    viewForElement(body[index])
                }
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
        case .icon(let icon):
            iconView(icon)
        case .actionSet(let actionSet):
            ForEach(actionSet.actions.indices, id: \.self) { index in
                viewForAction(actionSet.actions[index])
            }
        case .compoundButton(let compoundButton):
            compoundButtonView(compoundButton)
        case .media(let media): // Handle media case
            mediaView(media)
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
    
    func iconView(_ icon: Icon) -> some View {
        let iconName = icon.name
        let size = iconSize(for: icon.size)
        let color = iconColor(for: icon.color)

        let imageView = SwiftUI.Image(systemName: iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundColor(color)

        if let selectAction = icon.selectAction {
            return AnyView(
                Button(action: {
                    handleAction(selectAction)
                }) {
                    imageView
                }
            )
        } else {
            return AnyView(imageView)
        }
    }
    
    @ViewBuilder
    func mediaView(_ media: Media) -> some View {
        if let source = media.sources.first, let url = URL(string: source.url) {
            let player = AVPlayer(url: url)
            if source.mimeType.starts(with: "video/") {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        Text(media.altText ?? "")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                            .padding(),
                        alignment: .bottomLeading
                    )
            } else if source.mimeType.starts(with: "audio/") {
                VStack {
                    if let posterUrl = media.poster, let imageUrl = URL(string: posterUrl) {
                        AsyncImage(url: imageUrl) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    HStack {
                        Button(action: {
                            player.play()
                        }) {
                            Text("Play")
                        }
                        Button(action: {
                            player.pause()
                        }) {
                            Text("Pause")
                        }
                    }
                }
            } else {
                Text("Unsupported media type")
            }
        } else {
            Text("No media source available")
        }
    }

    func handleAction(_ action: Action) {
        switch action {
        case .openUrl(let actionOpenUrl):
            if let urlString = actionOpenUrl.url, let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        case .submit(let actionSubmit):
            // Handle submit action
            print("Form data: \(formData)")
        case .showCard(let actionShowCard):
            // Handle show card action
            // You might want to present a new view or update the UI accordingly
            print("Show card action triggered")
        case .execute(let actionExecute):
            // Handle execute action
            print("Execute action triggered")
        default:
            break
        }
    }
    
    func compoundButtonView(_ compoundButton: CompoundButton) -> some View {
        Button(action: {
            if let selectAction = compoundButton.selectAction {
                handleAction(selectAction)
            }
        }) {
            HStack(alignment: .center, spacing: 10) {
                if let iconInfo = compoundButton.icon {
                    SwiftUI.Image(systemName: iconInfo.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
                VStack(alignment: .leading) {
                    Text(compoundButton.title)
                        .font(.headline)
                    if let description = compoundButton.description {
                        Text(description)
                            .font(.subheadline)
                    }
                }
                Spacer()
                if let badge = compoundButton.badge {
                    Text(badge)
                        .font(.caption)
                        .padding(4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    func viewForAction(_ action: Action) -> some View {
        switch action {
        case .openUrl(let action):
            if let urlString = action.url, let url = URL(string: urlString) {
                Button(action.title ?? "Open URL") {
                    UIApplication.shared.open(url)
                }
                .padding()
            } else {
                EmptyView()
            }
        case .submit(let action):
            Button(action.title ?? "Submit") {
                // Handle submit action
                print("Form data: \(formData)")
            }
            .padding()
        case .showCard(let action):
            Button(action.title ?? "Show Card") {
                // Handle show card action
                print("Show card action triggered")
                // Present the nested card
                let cardView = makeCardView(from: action.card)
                // For example, present it in a sheet
                // showModalCard(cardView)
            }
            .padding()
        case .execute(let action):
            Button(action.title ?? "Execute") {
                // Handle execute action
                print("Execute action triggered")
            }
            .padding()
        }
    }
    
    func makeCardView(from card: AdaptiveCard) -> some View {
        AdaptiveCardView(adaptiveCard: card)
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
    
    func iconSize(for size: String?) -> CGFloat {
        switch size {
        case "xxSmall":
            return 12
        case "xSmall":
            return 16
        case "Small":
            return 20
        case "Standard":
            return 24
        case "Medium":
            return 28
        case "Large":
            return 32
        case "xLarge":
            return 40
        case "xxLarge":
            return 48
        default:
            return 24 // Default size
        }
    }

    func iconColor(for color: String?) -> Color {
        switch color {
        case "accent":
            return .blue
        case "good":
            return .green
        case "warning":
            return .yellow
        case "attention":
            return .red
        default:
            return .primary
        }
    }
}
