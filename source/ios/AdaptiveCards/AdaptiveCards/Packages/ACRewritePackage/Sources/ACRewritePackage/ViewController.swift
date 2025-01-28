//
//  ViewController.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/18/24.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the UIKit view
        if let card = loadAdaptiveCard(){
            let customView = AdaptiveCardViewUIKit(card: card)
            customView.backgroundColor = .clear
            
            // Add the view to the view controller's view hierarchy
            view.addSubview(customView)
            
            // Set up constraints for the view
            customView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                customView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                customView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                customView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
                customView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
                
            ])
        }
    }
    
    func loadAdaptiveCard() -> AdaptiveCard? {
            let jsonString = """
            {
                "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                "type": "AdaptiveCard",
                "version": "1.0",
                "refresh": {
                    "action": {
                        "type": "Action.Execute",
                        "id": "refresh_action_id",
                        "verb": "refresh_action_verb"
                    },
                    "userIds": [
                        "refresh_userIds_0"
                    ]
                },
                "authentication": {
                    "text": "authentication_text",
                    "connectionName": "authentication_connectionName",
                    "tokenExchangeResource": {
                        "id": "authentication_tokenExchangeResource_id",
                        "uri": "authentication_tokenExchangeResource_uri",
                        "providerId": "authentication_tokenExchangeResource_providerId"
                    },
                    "buttons": [
                        {
                            "type": "authentication_buttons_0_type",
                            "title": "authentication_buttons_0_title",
                            "image": "authentication_buttons_0_image",
                            "value": "authentication_buttons_0_value"
                        }
                    ]
                },
                "fallbackText": "fallbackText",
                "speak": "speak",
                "lang": "en",
                "rtl": false,
                "body": [
                    {
                        "type": "TextBlock",
                        "text": "Test Text",
                        "color": "default",
                        "horizontalAlignment": "left",
                        "isSubtle": false,
                        "italic": true,
                        "maxLines": 1,
                        "size": "default",
                        "weight": "default",
                        "wrap": false,
                        "id": "TextBlock_id",
                        "spacing": "default",
                        "separator": false,
                        "strikethrough": true,
                        "style": "Heading"
                    },
                    {
                        "type": "Image",
                        "altText": "Image_altText",
                        "horizontalAlignment": "center",
                        "selectAction": {
                            "type": "Action OpenUrl",
                            "title": "Image_Action.OpenUrl",
                            "url": "https://adaptivecards.io/"
                        },
                        "size": "auto",
                        "style": "person",
                        "url": "https://adaptivecards.io/content/cats/1.png",
                        "id": "Image_id",
                        "isVisible": false,
                        "spacing": "none",
                        "separator": true
                    },
                    {
                        "type": "Container",
                        "style": "default",
                        "selectAction": {
                            "type": "Action.Submit",
                            "title": "Action Submit",
                            "data": "Container_data"
                        },
                        "id": "Container_id",
                        "spacing": "medium",
                        "separator": false,
                        "rtl": true,
                        "items": [
                            {
                                "type": "ColumnSet",
                                "id": "ColumnSet_id",
                                "spacing": "large",
                                "separator": true,
                                "columns": [
                                    {
                                        "type": "Column",
                                        "style": "default",
                                        "width": "auto",
                                        "id": "Column_id1",
                                        "rtl": false,
                                        "items": [
                                            {
                                                "type": "Image",
                                                "url": "https://adaptivecards.io/content/cats/1.png"
                                            }
                                        ]
                                    },
                                    {
                                        "type": "Column",
                                        "style": "emphasis",
                                        "width": "20px",
                                        "id": "Column_id2",
                                        "items": [
                                            {
                                                "type": "Image",
                                                "url": "https://adaptivecards.io/content/cats/2.png"
                                            }
                                        ]
                                    },
                                    {
                                        "type": "Column",
                                        "style": "default",
                                        "width": "stretch",
                                        "id": "Column_id3",
                                        "items": [
                                            {
                                                "type": "Image",
                                                "url": "https://adaptivecards.io/content/cats/3.png"
                                            },
                                            {
                                                "type": "TextBlock",
                                                "text": "Column3_TextBlock_text",
                                                "id": "Column3_TextBlock_id",
                                                "fontType": "display"
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    },
                    {
                        "type": "FactSet",
                        "id": "FactSet_id",
                        "facts": [
                            {
                                "type": "Fact",
                                "title": "Topping",
                                "value": "poppyseeds"
                            },
                            {
                                "type": "Fact",
                                "title": "Topping",
                                "value": "onion flakes"
                            }
                        ]
                    },
                    {
                        "type": "ImageSet",
                        "imageSize": "auto",
                        "id": "ImageSet_id",
                        "separator": true,
                        "images": [
                            {
                                "type": "Image",
                                "url": "https://adaptivecards.io/content/cats/1.png"
                            },
                            {
                                "type": "Image",
                                "url": "https://adaptivecards.io/content/cats/2.png"
                            },
                            {
                                "type": "Image",
                                "url": "https://adaptivecards.io/content/cats/3.png"
                            }
                        ]
                    },
                    {
                        "type": "Container",
                        "id": "Container_id_inputs",
                        "items": [
                            {
                                "type": "Input.Text",
                                "id": "Input.Text_id",
                                "isMultiline": false,
                                "label": "Input text placeholder",
                                "maxLength": 10,
                                "placeholder": "Input text placeholder",
                                "style": "text",
                                "value": "Input Text value",
                                "spacing": "small",
                                "isRequired": false,
                                "regex": "([A-Z])\\w+",
                                "inlineAction": {
                                    "type": "Action.Submit",
                                    "iconUrl": "https://adaptivecards.io/content/cats/1.png",
                                    "title": "Input Text Action Submit"
                                }
                            },
                            {
                                "type": "Input.Number",
                                "id": "Input.Number_id",
                                "label": "Input.Number_label",
                                "max": 9.5,
                                "min": 3.5,
                                "placeholder": "Input.Number_placeholder",
                                "value": 4.5,
                                "isRequired": true
                            },
                            {
                                "type": "Input.Date",
                                "id": "Input.Date_id",
                                "label": "Input.Date_label",
                                "min": "8/1/2018",
                                "max": "1/1/2020",
                                "placeholder": "Input.Date_placeholder",
                                "value": "8/9/2018"
                            },
                            {
                                "type": "Input.Time",
                                "id": "Input.Time_id",
                                "label": "Input.Time_label",
                                "min": "10:00",
                                "max": "17:00",
                                "value": "13:00",
                                "placeholder": "Input.Time_placeholder",
                                "isRequired": true,
                                "errorMessage": "Input.Time.ErrorMessage"
                            },
                            {
                                "type": "Input.Toggle",
                                "id": "Input.Toggle_id",
                                "label": "Input.Toggle_label",
                                "title": "Input.Toggle_title",
                                "value": "Input.Toggle_on",
                                "valueOff": "Input.Toggle_off",
                                "valueOn": "Input.Toggle_on"
                            },
                            {
                                "type": "TextBlock",
                                "weight": "bolder",
                                "size": "large",
                                "text": "Everybody's got choices"
                            },
                            {
                                "type": "Input.ChoiceSet",
                                "id": "Input.ChoiceSet_id",
                                "isMultiSelect": true,
                                "label": "Input ChoiceSet Labels",
                                "style": "compact",
                                "value": "Input.Choice2,Input.Choice4",
                                "choices": [
                                    {
                                        "type": "Input.Choice",
                                        "title": "Choice1 title",
                                        "value": "Input.Choice1"
                                    },
                                    {
                                        "type": "Input.Choice",
                                        "title": "Choice2 title",
                                        "value": "Input.Choice2"
                                    },
                                    {
                                        "type": "Input.Choice",
                                        "title": "Choice3 title",
                                        "value": "Input.Choice3"
                                    },
                                    {
                                        "type": "Input.Choice",
                                        "title": "Choice4 title",
                                        "value": "Input.Choice4"
                                    }
                                ]
                            }
                        ]
                    },
                    {
                        "type": "ActionSet",
                        "actions": [
                            {
                                "type": "Action.Submit",
                                "title": "Action Submit",
                                "id": "ActionSet.Action.Submit_id",
                                "associatedInputs": "none",
                                "tooltip": "tooltip",
                                "isEnabled": false
                            },
                            {
                                "type": "Action.OpenUrl",
                                "title": "Action OpenUrl",
                                "id": "ActionSet.Action.OpenUrl_id",
                                "tooltip": "tooltip",
                                "url": "https://adaptivecards.io/",
                                "isEnabled": true
                            }
                        ]
                    },
                    {
                        "type": "RichTextBlock",
                        "id": "RichTextBlock_id",
                        "horizontalAlignment": "right",
                        "inlines": [
                            {
                                "color": "Dark",
                                "fontType": "Monospace",
                                "highlight": true,
                                "isSubtle": true,
                                "italic": true,
                                "size": "large",
                                "strikethrough": true,
                                "text": "This is a text run",
                                "type": "TextRun",
                                "underline": true,
                                "weight": "bolder"
                            },
                            {
                                "type": "TextRun",
                                "text": "This is another text run",
                                "selectAction": { "type": "Action.Submit" }
                            },
                        ]
                    }
                ],
                "actions": [
                    {
                        "type": "Action.Submit",
                        "title": "Action.Submit",
                        "id": "Action.Submit_id",
                        "tooltip": "tooltip",
                        "isEnabled": true,
                        "data": {
                            "submitValue": true
                        }
                    },
                    {
                        "type": "Action.Execute",
                        "verb": "Action.Execute_verb",
                        "title": "Action Execute",
                        "id": "Action.Execute_id",
                        "associatedInputs": "none",
                        "isEnabled": false,
                        "data": {
                            "Action.Execute_data_keyA": "Action.Execute_data_valueA"
                        }
                    },
                    {
                        "type": "Action.ShowCard",
                        "title": "Action ShowCard",
                        "id": "Action.ShowCard_id",
                        "tooltip": "tooltip",
                        "card": {
                            "type": "AdaptiveCard",
                            "backgroundImage": {
                                "url": "https://adaptivecards.io/content/cats/1.png",
                                "fillMode": "repeat",
                                "verticalAlignment": "center",
                                "horizontalAlignment": "right"
                            },
                            "body": [
                                {
                                    "type": "TextBlock",
                                    "isSubtle": true,
                                    "text": "Action ShowCard"
                                }
                            ]
                        }
                    }
                ]
            }
            """
            let jsonData = jsonString.data(using: .utf8)!
            return try? JSONDecoder().decode(AdaptiveCard.self, from: jsonData)
        }
    
}



class AdaptiveCardViewUIKit: UIView {
    
    var card: AdaptiveCard?
    
    init(card: AdaptiveCard) {
        self.card = card
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupView() {
        guard let card = card else { return }
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 10
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        for element in card.body {
            let view = renderElement(element)
            contentView.addArrangedSubview(view)
        }
        
        if case let .imageUrl(imgUrl) = card.backgroundImage {
            guard let url = URL(string: imgUrl) else { return  }
            let backgroundImageView = UIImageView()
            backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.clipsToBounds = true
            addSubview(backgroundImageView)
            sendSubviewToBack(backgroundImageView)
            
            NSLayoutConstraint.activate([
                backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
                backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
                backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
            
            // Load image asynchronously
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        backgroundImageView.image = image
                    }
                }
            }
        }
    }
    
    private func renderElement(_ element: CardElement) -> UIView {
        switch element {
        case .textBlock(let textBlock):
            return renderTextBlock(textBlock)
        case .image(let image):
            return renderImage(image)
        case .container(let container):
            return renderContainer(container)
        case .factSet(let factSet):
            return renderFactSet(factSet)
        case .imageSet(let imageSet):
            return renderImageSet(imageSet)
        case .inputElement(let inputElement):
            return renderInputs(inputElement)
        case .actionSet(let actionSet):
            return renderActionSet(actionSet)
        case .richTextBlock(let richTextBlock):
            return renderRichTextBlock(richTextBlock)
        default:
            return UIView()
        }
    }
    
    private func renderTextBlock(_ textBlock: TextBlock) -> UIView {
        let label = UILabel()
        label.text = textBlock.text
        label.font = UIFont.systemFont(ofSize: textBlock.size?.rawValue == "large" ? 24 : 16)
        label.textColor = textBlock.color?.rawValue == "default" ? .black : .gray
        
        if textBlock.italic ?? false {
            label.font = UIFont.italicSystemFont(ofSize: textBlock.size?.rawValue == "large" ? 24 : 16)
        }
       
        label.font = textBlock.weight?.rawValue == "bolder" ? .boldSystemFont(ofSize: label.font.pointSize) : label.font
        label.numberOfLines = textBlock.maxLines ?? 0
        label.textAlignment = textBlock.horizontalAlignment?.rawValue == "center" ? .center : .left
        return label
    }
    
    private func renderImage(_ image: Image) -> UIView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let url = URL(string: image.url) {
            // Load image asynchronously
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }
        }
        
        return imageView
    }
    
    private func renderContainer(_ container: Container) -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for item in container.items {
            let view = renderElement(item)
            stackView.addArrangedSubview(view)
        }
        
        let containerView = UIView()
        containerView.addSubview(stackView)
        containerView.layer.cornerRadius = 8
        containerView.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.1).cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        ])
        
        return containerView
    }
    
    private func renderFactSet(_ factSet: FactSet) -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for fact in factSet.facts {
            let factView = UIStackView()
            factView.axis = .horizontal
            factView.spacing = 5
            factView.translatesAutoresizingMaskIntoConstraints = false
            
            let titleLabel = UILabel()
            titleLabel.text = fact.title
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            
            let valueLabel = UILabel()
            valueLabel.text = fact.value
            valueLabel.font = UIFont.systemFont(ofSize: 16)
            
            factView.addArrangedSubview(titleLabel)
            factView.addArrangedSubview(valueLabel)
            stackView.addArrangedSubview(factView)
        }
        
        return stackView
    }
    
    private func renderImageSet(_ imageSet: ImageSet) -> UIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for image in imageSet.images ?? [] {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            if let url = URL(string: image.url) {
                // Load image asynchronously
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    }
                }
            }
            
            stackView.addArrangedSubview(imageView)
        }
        
        return stackView
    }
    
    private func renderInputs(_ input: InputElement) -> UIView {
        switch input {
        case .text(let inputText):
            let textField = UITextField()
            textField.placeholder = inputText.label
            textField.text = inputText.value
            textField.borderStyle = .roundedRect
            return textField
        case .number(let inputNumber):
            let textField = UITextField()
            textField.placeholder = inputNumber.label
            textField.text = "\(inputNumber.value ?? 0)"
            textField.keyboardType = .numberPad
            textField.borderStyle = .roundedRect
            return textField
        case .date(let inputDate):
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            return datePicker
        case .time(let inputTime):
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .time
            return datePicker
        case .toggle(let inputToggle):
            let toggle = UISwitch()
            toggle.isOn = inputToggle.value == inputToggle.valueOn
            return toggle
        case .choiceSet(let inputChoiceSet):
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = inputChoiceSet.label
            stackView.addArrangedSubview(label)
            
            for choice in inputChoiceSet.choices {
                let toggle = UISwitch()
                toggle.isOn = inputChoiceSet.value?.contains(choice.value) ?? false
                let choiceLabel = UILabel()
                choiceLabel.text = choice.title
                
                let choiceStackView = UIStackView()
                choiceStackView.axis = .horizontal
                choiceStackView.spacing = 10
                choiceStackView.addArrangedSubview(choiceLabel)
                choiceStackView.addArrangedSubview(toggle)
                
                stackView.addArrangedSubview(choiceStackView)
            }
            return stackView
        default:
            return UIView()

        }
    }
    
    private func renderActionSet(_ actionSet: ActionSet) -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for action in actionSet.actions {
            let button = renderAction(action)
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }
    
    private func renderRichTextBlock(_ richTextBlock: RichTextBlock) -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for textRun in richTextBlock.inlines {
            let label = UILabel()
            label.text = textRun.text
            label.font = UIFont.systemFont(ofSize: textRun.size?.rawValue ?? "" == "large" ? 24 : 16)
            label.textColor = textRun.color?.rawValue == "Dark" ? .black  : .gray
            label.font = textRun.weight?.rawValue ?? "" == "bolder" ? .boldSystemFont(ofSize: label.font.pointSize) : label.font
            stackView.addArrangedSubview(label)
        }
        
        return stackView
    }
    
    private func renderAction(_ action: ActionElement) -> UIButton {
        let button = CustomButton(type: .system)

        switch action {
        case .submit(let submit):
            button.setTitle(submit.title, for: .normal)
            button.isEnabled = submit.isEnabled ?? true
            button.addTarget(self, action: #selector(handleSubmitAction(_:)), for: .touchUpInside)
        case .openUrl(let openUrl):
            button.setTitle(openUrl.title, for: .normal)
            button.isEnabled = openUrl.isEnabled ?? true
            button.url = openUrl.url
            button.addTarget(self, action: #selector(handleOpenUrlAction(_:)), for: .touchUpInside)
        case .execute(let execute):
            button.setTitle(execute.title, for: .normal)
            button.isEnabled = execute.isEnabled ?? true
            button.addTarget(self, action: #selector(handleExecuteAction(_:)), for: .touchUpInside)
        case .showCard(let showCard):
            button.setTitle(showCard.title, for: .normal)
            button.isEnabled = showCard.isEnabled ?? true
            button.addTarget(self, action: #selector(handleShowCardAction(_:)), for: .touchUpInside)
        default:
            break
        }
        
        return button
    }
    
    @objc private func handleSubmitAction(_ sender: UIButton) {
        // Handle submit action
    }
    
    @objc private func handleOpenUrlAction(_ sender: CustomButton) {
        guard let url = URL(string: sender.url ?? "") else {
          return
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc private func handleExecuteAction(_ sender: UIButton) {
        // Handle execute action
    }
    
    @objc private func handleShowCardAction(_ sender: UIButton) {
        // Handle show card action
    }
}

class CustomButton: UIButton {
    var url: String?
}
