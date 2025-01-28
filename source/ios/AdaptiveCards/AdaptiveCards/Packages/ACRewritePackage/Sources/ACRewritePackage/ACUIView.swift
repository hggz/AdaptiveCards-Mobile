//
//  ACUIView.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/20/24.
//

//
//import SwiftUI
//
//struct AdaptiveCardView: View {
//    let card: AdaptiveCard
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 10) {
//                ForEach(card.body, id: \.self) { element in
//                    renderElement(element)
//                }
//            }
//            .padding()
//            .background(
//                AsyncImage(url: URL(string: "https://adaptivecards.io/content/cats/1.png")) { image in
//                    image.resizable()
//                } placeholder: {
//                    Color.clear
//                }
//            )
//        }
//    }
//    @ViewBuilder
//        func renderElement(_ element: CardElement) -> some View {
//            switch element {
//            case .textBlock(let textBlock):
//                return AnyView(renderTextBlock(textBlock))
//            case .image(let image):
//                return AnyView(renderImage(image))
//            case .container(let container):
//                return AnyView(renderContainer(container))
//            case .factSet(let factSet):
//                return AnyView(renderFactSet(factSet))
//            case .imageSet(let imageSet):
//                return AnyView(renderImageSet(imageSet))
//            case .inputElement(let inputElement):
//                return AnyView(renderInputs(inputElement))
//            case .actionSet(let actionSet):
//                return AnyView(renderActionSet(actionSet))
//            case .richTextBlock(let richTextBlock):
//                return AnyView(renderRichTextBlock(richTextBlock))
//            case .container(let container):
//                AnyView(
//                    VStack(alignment: .leading, spacing: 10) {
//                        ForEach(container.items, id: \.self) { item in
//                            renderElement(item)
//                        }
//                    }
//                        .padding()
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(8)
//                )
//            case .columnSet(let columnSet):
//                AnyView(
//                    HStack(alignment: .top, spacing: 10) {
//                        ForEach(columnSet.columns, id: \.self) { column in
//                            VStack(alignment: .leading, spacing: 10) {
//                                ForEach(column.items, id: \.self) { item in
//                                    renderElement(item)
//                                }
//                            }
//                            .frame(width: column.width == "auto" ? nil : CGFloat(Double(column.width ?? "0") ?? 0))
//                        }
//                    }
//                )
//            default:
//                return AnyView(
//                    Text("Unsupported element")
//                        .font(.body)
//            }
//        }
//
//        @ViewBuilder
//        func renderTextBlock(_ textBlock: TextBlock) -> some View {
//            Text(textBlock.text)
//                .font(.system(size: textBlock.size?.rawValue == "large" ? 24 : 16))
//                .foregroundColor(textBlock.color?.rawValue == "default" ? .black : .gray)
//                .italic(textBlock.italic ?? false)
//                .strikethrough(textBlock.strikethrough ?? false)
//                .fontWeight(textBlock.weight?.rawValue == "bolder" ? .bold : .regular)
//                .lineLimit(textBlock.maxLines)
//                .frame(maxWidth: .infinity, alignment: textBlock.horizontalAlignment?.rawValue ?? "" == "center" ? .center : .leading)
//        }
//
//        @ViewBuilder
//        func renderImage(_ image: Image) -> some View {
//            AsyncImage(url: URL(string: image.url)) { image in
//                image.resizable()
//            } placeholder: {
//                Color.gray
//            }
//            .aspectRatio(contentMode: .fit)
//            .frame(maxWidth: .infinity, alignment: image.horizontalAlignment?.rawValue ?? "" == "center" ? .center : .leading)
//        }
//
//        @ViewBuilder
//        func renderContainer(_ container: Container) -> some View {
//            VStack(alignment: .leading, spacing: 10) {
//                ForEach(container.items, id: \.self) { item in
//                    renderElement(item)
//                }
//            }
//            .padding()
//            .background(Color.gray.opacity(0.1))
//            .cornerRadius(8)
//        }
//
//        @ViewBuilder
//        func renderFactSet(_ factSet: FactSet) -> some View {
//            VStack(alignment: .leading, spacing: 5) {
//                ForEach(factSet.facts, id: \.self) { fact in
//                    HStack {
//                        Text(fact.title)
//                            .fontWeight(.bold)
//                        Text(fact.value)
//                    }
//                }
//            }
//        }
//
//        @ViewBuilder
//        func renderImageSet(_ imageSet: ImageSet) -> some View {
//            HStack {
//                ForEach(imageSet.images ?? [], id: \.self) { image in
//                    AsyncImage(url: URL(string: image.url)) { image in
//                        image.resizable()
//                    } placeholder: {
//                        Color.gray
//                    }
//                    .aspectRatio(contentMode: .fit)
//                }
//            }
//        }
//
//        @ViewBuilder
//        func renderActionSet(_ actionSet: ActionSet) -> some View {
//            ForEach(actionSet.actions, id: \.self) { action in
//                renderAction(action)
//            }
//        }
//
//        @ViewBuilder
//        func renderRichTextBlock(_ richTextBlock: RichTextBlock) -> some View {
//            VStack(alignment: .leading) {
//                ForEach(richTextBlock.inlines, id: \.self) { textRun in
//                    Text(textRun.text)
//                        .font(.system(size: textRun.size == "large" ? 24 : 16))
//                        .foregroundColor(textRun.color == "Dark" ? .black : .gray)
//                        .italic(textRun.italic ?? false)
//                        .strikethrough(textRun.strikethrough ?? false)
//                        .underline(textRun.underline ?? false)
//                        .fontWeight(textRun.weight == "bolder" ? .bold : .regular)
//                }
//            }
//        }
//
//        @ViewBuilder
//        func renderInputs(_ input: InputElement) -> some View {
//            switch input {
//            case .text(let inputText):
//                return AnyView(
//                    TextField(inputText.label ?? "", text: .constant(inputText.value ?? ""))
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding()
//                )
//            case .number(let inputNumber):
//                return AnyView(
//                    TextField(inputNumber.label ?? "", value: .constant(inputNumber.value ?? 0), formatter: NumberFormatter())
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding()
//                )
//            case .date(let inputDate):
//                return AnyView(
//                    DatePicker(inputDate.label ?? "", selection: .constant(Date()), displayedComponents: .date)
//                        .padding()
//                )
//            case .time(let inputTime):
//                return AnyView(
//                    DatePicker(inputTime.label ?? "", selection: .constant(Date()), displayedComponents: .hourAndMinute)
//                        .padding()
//                )
//            case .toggle(let inputToggle):
//                return AnyView(
//                    Toggle(inputToggle.label ?? "", isOn: .constant(inputToggle.value == inputToggle.valueOn))
//                        .padding()
//                )
//            case .choiceSet(let inputChoiceSet):
//                return AnyView(
//                    VStack(alignment: .leading) {
//                        Text(inputChoiceSet.label ?? "")
//                        ForEach(inputChoiceSet.choices, id: \.self) { choice in
//                            Toggle(choice.title, isOn: .constant(inputChoiceSet.value?.contains(choice.value) ?? false))
//                        }
//                    }
//                    .padding()
//                )
//            default:
//                return AnyView(
//                    Text("Unsupported element")
//                        .font(.body)
//                    )
//            }
//        }
//
//        @ViewBuilder
//        func renderAction(_ action: ActionElement) -> some View {
//            switch action {
//            case .submit(let submit):
//                return AnyView(
//                    Button(submit.title ?? "Submit") {
//                        // Handle submit action
//                    }
//                    .disabled(!(submit.isEnabled ?? true))
//                )
//            case .openUrl(let openUrl):
//                return AnyView(
//                    Button(openUrl.title ?? "Open URL") {
//                        if let url = URL(string: openUrl.url) {
//                            UIApplication.shared.open(url)
//                        }
//                    }
//                    .disabled(!(openUrl.isEnabled ?? true))
//                )
//            case .execute(let execute):
//                return AnyView(
//                    Button(execute.title ?? "Execute") {
//                        // Handle execute action
//                    }
//                    .disabled(!(execute.isEnabled ?? true))
//                )
//            case .showCard(let showCard):
//                return AnyView(
//                    Button(showCard.title ?? "Show Card") {
//                        // Handle show card action
//                    }
//                    .disabled(!(showCard.isEnabled ?? true))
//                )
//            default:
//                return AnyView(
//                    Button("default") {
//                        // Handle show card action
//                    }.disabled(false)
//                )
//            }
//        }
//    }
//    
//    
//  
//                    
//                    
//                    
//                    
//                    
//                    
//                    
//                    
//                    
//                    
//                    
//                    
//                    
//                    
//                    
//                    
//                    
//                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
    
//
//    @ViewBuilder
//        func renderElement(_ element: CardElement) -> some View {
//            switch element {
//            case .textBlock(let textBlock):
//                AnyView(
//                    Text(textBlock.text)
//                        .font(textBlock.size?.rawValue ?? "" == "large" ? .largeTitle : .body)
//                )
//            case .image(let image):
//                AnyView(
//                    AsyncImage(url: URL(string: image.url)) { image in
//                        image.resizable()
//                    } placeholder: {
//                        Color.gray
//                    }
//                    .aspectRatio(contentMode: .fit)
//                )
//            case .container(let container):
//                AnyView(
//                    VStack(alignment: .leading, spacing: 10) {
//                        ForEach(container.items, id: \.self) { item in
//                            renderElement(item)
//                        }
//                    }
//                    .padding()
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(8)
//                )
//            case .columnSet(let columnSet):
//                AnyView(
//                    HStack(alignment: .top, spacing: 10) {
//                        ForEach(columnSet.columns, id: \.self) { column in
//                            VStack(alignment: .leading, spacing: 10) {
//                                ForEach(column.items, id: \.self) { item in
//                                    renderElement(item)
//                                }
//                            }
//                            .frame(width: column.width == "auto" ? nil : CGFloat(Double(column.width ?? "0") ?? 0))
//                        }
//                    }
//                )
//            default:
//                AnyView(
//                    Text("Unsupported element")
//                        .font(.body)
//                )
//            }
//        }

    
//    @ViewBuilder
//    func renderElement(_ element: CardElement) -> some View {
//        switch element {
//        case .textBlock(let textBlock):
//            Text(textBlock.text)
//                .font(textBlock.size?.rawValue ?? "" == "large" ? .largeTitle : .body)
//        case .image(let image):
//            AsyncImage(url: URL(string: image.url)) { image in
//                image.resizable()
//            } placeholder: {
//                Color.gray
//            }
//            .aspectRatio(contentMode: .fit)
//        case .container(let container):
//            VStack(alignment: .leading, spacing: 10) {
//                ForEach(container.items, id: \.self) { item in
//                    renderElement(item)
//                }
//            }
//            .padding()
//            .background(Color.gray.opacity(0.1))
//            .cornerRadius(8)
//        case .columnSet(let columnSet):
//            HStack(alignment: .top, spacing: 10) {
//                ForEach(columnSet.columns, id: \.self) { column in
//                    VStack(alignment: .leading, spacing: 10) {
//                        ForEach(column.items, id: \.self) { item in
//                            renderElement(item)
//                        }
//                    }
//                    .frame(width: column.width == "auto" ? nil : CGFloat(Double(column.width ?? "0") ?? 0))
//                }
//            }
//        
//        case .media(_):
//            Text("notSupported")
//                .font(.body)
//        case .richTextBlock(_):
//            Text("notSupported")
//                .font(.body)
//        case .textRun(_):
//            Text("notSupported")
//                .font(.body)
//        case .icon(_):
//            Text("notSupported")
//                .font(.body)
//        case .ratingLabel(_):
//            Text("notSupported")
//                .font(.body)
//        case .column(_):
//            Text("notSupported")
//                .font(.body)
//        case .factSet(_):
//            Text("notSupported")
//                .font(.body)
//        case .imageSet(_):
//            Text("notSupported")
//                .font(.body)
//        case .actionSet(_):
//            Text("notSupported")
//                .font(.body)
//        case .inputElement(_):
//            Text("notSupported")
//                .font(.body)
//        }
//    }



//struct AdaptiveCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        let jsonString = """
//        {
//            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
//            "type": "AdaptiveCard",
//            "version": "1.0",
//            "backgroundImage": "https://adaptivecards.io/content/cats/1.png",
//            "body": [
//                {
//                    "type": "TextBlock",
//                    "text": "This is some text",
//                    "size": "large"
//                },
//                {
//                    "type": "Container",
//                    "style": "default",
//                    "selectAction": {
//                        "type": "Action.Submit",
//                        "title": "Container_Action.Submit",
//                        "data": "Container_data"
//                    },
//                    "id": "Container_id",
//                    "spacing": "medium",
//                    "separator": false,
//                    "rtl": true,
//                    "items": [
//                        {
//                            "type": "ColumnSet",
//                            "id": "ColumnSet_id",
//                            "spacing": "large",
//                            "separator": true,
//                            "columns": [
//                                {
//                                    "type": "Column",
//                                    "style": "default",
//                                    "width": "auto",
//                                    "id": "Column_id1",
//                                    "rtl": false,
//                                    "items": [
//                                        {
//                                            "type": "Image",
//                                            "url": "https://adaptivecards.io/content/cats/1.png"
//                                        }
//                                    ]
//                                },
//                                {
//                                    "type": "Column",
//                                    "style": "emphasis",
//                                    "width": "20px",
//                                    "id": "Column_id2",
//                                    "items": [
//                                        {
//                                            "type": "Image",
//                                            "url": "https://adaptivecards.io/content/cats/2.png"
//                                        }
//                                    ]
//                                },
//                                {
//                                    "type": "Column",
//                                    "style": "default",
//                                    "width": "stretch",
//                                    "id": "Column_id3",
//                                    "items": [
//                                        {
//                                            "type": "Image",
//                                            "url": "https://adaptivecards.io/content/cats/3.png"
//                                        },
//                                        {
//                                            "type": "TextBlock",
//                                            "text": "Column3_TextBlock_text",
//                                            "id": "Column3_TextBlock_id",
//                                            "fontType": "display"
//                                        }
//                                    ]
//                                }
//                            ]
//                        }
//                    ]
//                }
//            ]
//        }
//        """
//        let jsonData = jsonString.data(using: .utf8)!
//        let card = try! JSONDecoder().decode(AdaptiveCard.self, from: jsonData)
//        
//        return AdaptiveCardView(card: card)
//    }
//}
