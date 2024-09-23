import SwiftUI
import AVKit

@available(iOS 15.0, *)
struct AdaptiveCardElementView: View {
    let element: CardElement
    @EnvironmentObject var viewModel: AdaptiveCardViewModel

    var body: some View {
        switch element {
        case .textBlock(let textBlock):
            Text(textBlock.text)
                .font(fontForSize(textBlock.size))
                .multilineTextAlignment(alignmentForHorizontal(textBlock.horizontalAlignment))
                .padding()

        case .image(let image):
            if let url = URL(string: image.url) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
            } else {
                EmptyView()
            }

        case .inputText(let input):
            TextField(input.label ?? input.id, text: viewModel.bindingForInput(input.id, defaultValue: input.value ?? ""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

        case .inputNumber(let input):
            TextField(input.id, text: viewModel.bindingForInput(input.id, defaultValue: input.value.map { String($0) } ?? ""))
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

        case .inputDate(let input):
            DatePicker(selection: viewModel.bindingForDateInput(input.id, defaultValue: input.value), displayedComponents: .date) {
                Text(input.label ?? input.id)
            }
            .padding()

        case .inputTime(let input):
            DatePicker(selection: viewModel.bindingForDateInput(input.id, defaultValue: input.value), displayedComponents: .hourAndMinute) {
                Text(input.label ?? input.id)
            }
            .padding()

        case .inputToggle(let input):
            Toggle(isOn: viewModel.bindingForToggleInput(input.id, defaultValue: input.value == input.valueOn)) {
                Text(input.title ?? input.id)
            }
            .padding()

        case .inputChoiceSet(let input):
            if input.isMultiSelect ?? false {
                Text("Multi-select choice sets are not yet implemented")
            } else {
                Picker(selection: viewModel.bindingForInput(input.id, defaultValue: input.value ?? ""), label: Text(input.label ?? input.id)) {
                    ForEach(input.choices, id: \.value) { choice in
                        Text(choice.title).tag(choice.value)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }

        case .table(let table):
            AdaptiveCardTableView(table: table)
                .environmentObject(viewModel)

        case .media(let media):
            mediaView(media)

        case .icon(let icon):
            iconView(icon)

        case .actionSet(let actionSet):
            ForEach(actionSet.actions.indices, id: \.self) { index in
                actionButton(for: actionSet.actions[index])
            }

        case .compoundButton(let compoundButton):
            compoundButtonView(compoundButton)

        case .container(let container):
            VStack {
                ForEach(container.items.indices, id: \.self) { index in
                    AdaptiveCardElementView(element: container.items[index])
                        .environmentObject(viewModel)
                }
            }
            
        case .factSet(let factSet):
            factSetView(factSet)
            
        case .columnSet(let columnSet):
            columnSetView(columnSet)
            
        // Handle other cases if necessary

        default:
            EmptyView()
        }
    }
    
    func columnSetView(_ columnSet: ColumnSet) -> some View {
        HStack(alignment: .top, spacing: spacingValue(columnSet.spacing)) {
            ForEach(columnSet.columns.indices, id: \.self) { index in
                let column = columnSet.columns[index]
                columnView(column)
                if column.separator == true && index < columnSet.columns.count - 1 {
                    Divider()
                }
            }
        }
    }

    func spacingValue(_ spacing: String?) -> CGFloat {
        switch spacing?.lowercased() {
        case "none":
            return 0
        case "small":
            return 8
        case "default", "medium":
            return 16
        case "large":
            return 24
        case "extraLarge":
            return 32
        default:
            return 16 // Default spacing
        }
    }

    func columnView(_ column: Column) -> some View {
        let width = calculateWidth(column.width)
        return VStack(alignment: .leading, spacing: 0) {
            if let items = column.items {
                ForEach(items.indices, id: \.self) { index in
                    AdaptiveCardElementView(element: items[index])
                        .environmentObject(viewModel)
                }
            }
        }
        .frame(width: width)
        .padding()
    }

    func calculateWidth(_ width: ColumnWidth?) -> CGFloat? {
        guard let width = width else { return nil }
        switch width {
        case .auto:
            return nil
        case .stretch:
            return nil // Stretch to fill available space
        case .absolute(let value):
            return CGFloat(value)
        case .weight(let value):
            // Implement logic based on weight
            return nil
        case .pixel(let value):
            // Parse pixel value from string, e.g., "110px"
            if let number = Double(value.replacingOccurrences(of: "px", with: "")) {
                return CGFloat(number)
            }
            return nil
        case .undefined:
            return nil
        }
    }
    
    func factSetView(_ factSet: FactSet) -> some View {
        VStack(alignment: .leading) {
            ForEach(factSet.facts.indices, id: \.self) { index in
                let fact = factSet.facts[index]
                HStack(alignment: .top) {
                    Text(fact.title)
                        .fontWeight(.bold)
                        .frame(width: 100, alignment: .leading)
                    Text(fact.value)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
    }

    // MARK: - Helper Views

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
                    viewModel.handleAction(selectAction)
                }) {
                    imageView
                }
            )
        } else {
            return AnyView(imageView)
        }
    }

    func compoundButtonView(_ compoundButton: CompoundButton) -> some View {
        Button(action: {
            if let selectAction = compoundButton.selectAction {
                viewModel.handleAction(selectAction)
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
    func actionButton(for action: Action) -> some View {
        Button(action.title ?? "Action") {
            viewModel.handleAction(action)
        }
        .padding()
    }

    // MARK: - Helper Functions

    func fontForSize(_ size: String?) -> Font {
        switch size?.lowercased() {
        case "extralarge":
            return .largeTitle
        case "large":
            return .title
        case "medium":
            return .title2
        case "small":
            return .body
        default:
            return .body
        }
    }

    func alignmentForHorizontal(_ alignment: String?) -> TextAlignment {
        switch alignment?.lowercased() {
        case "center":
            return .center
        case "right":
            return .trailing
        default:
            return .leading
        }
    }

    func iconSize(for size: String?) -> CGFloat {
        switch size?.lowercased() {
        case "xxsmall":
            return 12
        case "xsmall":
            return 16
        case "small":
            return 20
        case "standard":
            return 24
        case "medium":
            return 28
        case "large":
            return 32
        case "xlarge":
            return 40
        case "xxlarge":
            return 48
        default:
            return 24 // Default size
        }
    }

    func iconColor(for color: String?) -> Color {
        switch color?.lowercased() {
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
