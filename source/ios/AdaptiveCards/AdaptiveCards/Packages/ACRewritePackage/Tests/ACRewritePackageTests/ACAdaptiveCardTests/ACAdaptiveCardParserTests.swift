////
////  ACAdaptiveCardParserTests.swift
////  ACSwiftRewriteTests
////
////  Created by Rahul Pinjani on 9/18/24.
////

import Foundation
import XCTest
@testable import ACRewritePackage

class ACAdaptiveCardParserTests: XCTestCase {
    func testParseAdaptiveCard() throws {
        let json = """
            {
                "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                "type": "AdaptiveCard",
                "version": "1.0",
                "backgroundImage": "https://adaptivecards.io/content/cats/1.png",
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
                            "title": "authentication_buttons_0_title"
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
                        "text": "TextBlock_text",
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
                    }
                ]
            }
            """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let card = try decoder.decode(SwiftACAdaptiveCard.self, from: data)
        
        XCTAssertEqual(card.schema, "http://adaptivecards.io/schemas/adaptive-card.json")
        XCTAssertEqual(card.type, "AdaptiveCard")
        XCTAssertEqual(card.version, "1.0")
        if case let .imageUrl(image) = card.backgroundImage {
            XCTAssertEqual(image, "https://adaptivecards.io/content/cats/1.png")
        }
        XCTAssertEqual(card.refresh?.action.type, SwiftACActionType.execute)
      //  XCTAssertEqual(card.refresh?.action.id, "refresh_action_id")
        XCTAssertEqual(card.refresh?.action.verb, "refresh_action_verb")
        XCTAssertEqual(card.refresh?.userIds.first, "refresh_userIds_0")
        XCTAssertEqual(card.authentication?.text, "authentication_text")
        XCTAssertEqual(card.authentication?.connectionName, "authentication_connectionName")
        XCTAssertEqual(card.authentication?.tokenExchangeResource.id, "authentication_tokenExchangeResource_id")
        XCTAssertEqual(card.authentication?.tokenExchangeResource.uri, "authentication_tokenExchangeResource_uri")
        XCTAssertEqual(card.authentication?.tokenExchangeResource.providerId, "authentication_tokenExchangeResource_providerId")
        XCTAssertEqual(card.authentication?.buttons.first?.type, "authentication_buttons_0_type")
        XCTAssertEqual(card.authentication?.buttons.first?.title, "authentication_buttons_0_title")
        XCTAssertEqual(card.fallbackText, "fallbackText")
        XCTAssertEqual(card.speak, "speak")
        XCTAssertEqual(card.lang, "en")
        XCTAssertEqual(card.rtl, false)
    }
    
    func testCardElementsDecoding() throws {
        let json = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "backgroundImage": "https://adaptivecards.io/content/cats/1.png",
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
                    "text": "TextBlock_text",
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
                        "type": "Action.OpenUrl",
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
                        "title": "Container_Action.Submit",
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
                            "label": "Input.Text_label",
                            "maxLength": 10,
                            "placeholder": "Input.Text_placeholder",
                            "style": "text",
                            "value": "Input.Text_value",
                            "spacing": "small",
                            "isRequired": false,
                            "regex": "([A-Z])\\w+",
                            "inlineAction": {
                                "type": "Action.Submit",
                                "iconUrl": "https://adaptivecards.io/content/cats/1.png",
                                "title": "Input.Text_Action.Submit"
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
                            "label": "Input.ChoiceSet_label",
                            "style": "compact",
                            "value": "Input.Choice2,Input.Choice4",
                            "choices": [
                                {
                                    "type": "Input.Choice",
                                    "title": "Input.Choice1_title",
                                    "value": "Input.Choice1"
                                },
                                {
                                    "type": "Input.Choice",
                                    "title": "Input.Choice2_title",
                                    "value": "Input.Choice2"
                                },
                                {
                                    "type": "Input.Choice",
                                    "title": "Input.Choice3_title",
                                    "value": "Input.Choice3"
                                },
                                {
                                    "type": "Input.Choice",
                                    "title": "Input.Choice4_title",
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
                            "title": "ActionSet.Action.Submit",
                            "id": "ActionSet.Action.Submit_id",
                            "associatedInputs": "none",
                            "tooltip": "tooltip",
                            "isEnabled": false
                        },
                        {
                            "type": "Action.OpenUrl",
                            "title": "ActionSet.Action.OpenUrl",
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
                    "title": "Action.Execute_title",
                    "id": "Action.Execute_id",
                    "associatedInputs": "none",
                    "isEnabled": false,
                    "data": {
                        "Action.Execute_data_keyA": "Action.Execute_data_valueA"
                    }
                },
                {
                    "type": "Action.ShowCard",
                    "title": "Action.ShowCard",
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
                                "text": "Action.ShowCard text"
                            }
                        ]
                    }
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        do {
            let card = try decoder.decode(SwiftACAdaptiveCard.self, from: json)
            
            // Validate card properties
            XCTAssertEqual(card.type, "AdaptiveCard")
            XCTAssertEqual(card.version, "1.0")
            if case let .imageUrl(image) = card.backgroundImage { 
                XCTAssertEqual(image, "https://adaptivecards.io/content/cats/1.png")
            }
            
            // Validate refresh properties
          //  XCTAssertEqual(card.refresh?.action.id, "refresh_action_id")
            XCTAssertEqual(card.refresh?.action.verb, "refresh_action_verb")
            XCTAssertEqual(card.refresh?.userIds.first, "refresh_userIds_0")
            
            // Validate authentication properties
            XCTAssertEqual(card.authentication?.text, "authentication_text")
            XCTAssertEqual(card.authentication?.connectionName, "authentication_connectionName")
            XCTAssertEqual(card.authentication?.tokenExchangeResource.id, "authentication_tokenExchangeResource_id")
            XCTAssertEqual(card.authentication?.tokenExchangeResource.uri, "authentication_tokenExchangeResource_uri")
            XCTAssertEqual(card.authentication?.tokenExchangeResource.providerId, "authentication_tokenExchangeResource_providerId")
            XCTAssertEqual(card.authentication?.buttons.first?.type, "authentication_buttons_0_type")
            XCTAssertEqual(card.authentication?.buttons.first?.title, "authentication_buttons_0_title")
            
            // Validate other properties
            XCTAssertEqual(card.fallbackText, "fallbackText")
            XCTAssertEqual(card.speak, "speak")
            XCTAssertEqual(card.lang, "en")
            XCTAssertEqual(card.rtl, false)
            
            // Validate body elements
            XCTAssertEqual(card.body.count, 8)
            
            // TextBlock
            if case let .textBlock(textBlock) = card.body[0] {
                XCTAssertEqual(textBlock.text, "TextBlock_text")
              //  XCTAssertEqual(textBlock.id, "TextBlock_id")
            } else {
                XCTFail("Failed to decode TextBlock")
            }
            
            // Image
            if case let .image(image) = card.body[1] {
                XCTAssertEqual(image.url, "https://adaptivecards.io/content/cats/1.png")
                XCTAssertEqual(image.id, "Image_id")
            } else {
                XCTFail("Failed to decode Image")
            }
            
            // Container
            if case let .container(container) = card.body[2] {
                XCTAssertEqual(container.id, "Container_id")
                XCTAssertEqual(container.items.count, 1)
                if case let .columnSet(columnSet) = container.items[0] {
                    XCTAssertEqual(columnSet.id, "ColumnSet_id")
                    XCTAssertEqual(columnSet.columns.count, 3)
                } else {
                    XCTFail("Failed to decode ColumnSet")
                }
            } else {
                XCTFail("Failed to decode Container")
            }
            
            // FactSet
            if case let .factSet(factSet) = card.body[3] {
                XCTAssertEqual(factSet.id, "FactSet_id")
                XCTAssertEqual(factSet.facts.count, 2)
                XCTAssertEqual(factSet.facts[0].title, "Topping")
                XCTAssertEqual(factSet.facts[0].value, "poppyseeds")
            } else {
                XCTFail("Failed to decode FactSet")
            }
            
            // ImageSet
            if case let .imageSet(imageSet) = card.body[4] {
              //  XCTAssertEqual(imageSet.id, "ImageSet_id")
                XCTAssertEqual(imageSet.images?.count ?? 0, 3)
                XCTAssertEqual(imageSet.images?[0].url ?? "", "https://adaptivecards.io/content/cats/1.png")
            } else {
                XCTFail("Failed to decode ImageSet")
            }
            
            // Container with inputs
            if case let .container(container) = card.body[5] {
                XCTAssertEqual(container.id, "Container_id_inputs")
                XCTAssertEqual(container.items.count, 7)
                
                // Input.Text
                if case let .inputElement(.text(inputText)) = container.items[0] {
                 //   XCTAssertEqual(inputText.id, "Input.Text_id")
                    XCTAssertEqual(inputText.value, "Input.Text_value")
                } else {
                    XCTFail("Failed to decode Input.Text")
                }
                
                // Input.Number
                if case let .inputElement(.number(inputNumber)) = container.items[1] {
                   // XCTAssertEqual(inputNumber.id, "Input.Number_id")
                    XCTAssertEqual(inputNumber.value, 4.5)
                } else {
                    XCTFail("Failed to decode Input.Number")
                }
                
                // Input.Date
                if case let .inputElement(.date(inputDate)) = container.items[2] {
                //    XCTAssertEqual(inputDate.id, "Input.Date_id")
                    XCTAssertEqual(inputDate.value, "8/9/2018")
                } else {
                    XCTFail("Failed to decode Input.Date")
                }
                
                // Input.Time
                if case let .inputElement(.time(inputTime)) = container.items[3] {
                   // XCTAssertEqual(inputTime.id, "Input.Time_id")
                    XCTAssertEqual(inputTime.value, "13:00")
                } else {
                    XCTFail("Failed to decode Input.Time")
                }
                
                // Input.Toggle
                if case let .inputElement(.toggle(inputToggle)) = container.items[4] {
                    // XCTAssertEqual(inputToggle.id, "Input.Toggle_id")
                    XCTAssertEqual(inputToggle.value, "Input.Toggle_on")
                } else {
                    XCTFail("Failed to decode Input.Toggle")
                }
                
                // Input.ChoiceSet
                if case let .inputElement(.choiceSet(inputChoiceSet)) = container.items[6] {
                   // XCTAssertEqual(inputChoiceSet.id, "Input.ChoiceSet_id")
                    XCTAssertEqual(inputChoiceSet.value, "Input.Choice2,Input.Choice4")
                    XCTAssertEqual(inputChoiceSet.choices.count, 4)
                } else {
                    XCTFail("Failed to decode Input.ChoiceSet")
                }
            } else {
                XCTFail("Failed to decode Container with inputs")
            }
            
            // ActionSet
            if case let .actionSet(actionSet) = card.body[6] {
                XCTAssertEqual(actionSet.actions.count, 2)
                if case let .submit(actionSubmit) = actionSet.actions[0] {
                   // XCTAssertEqual(actionSubmit.id, "ActionSet.Action.Submit_id")
                } else {
                    XCTFail("Failed to decode Action.Submit")
                }
                if case let .openUrl(actionOpenUrl) = actionSet.actions[1] {
                //    XCTAssertEqual(actionOpenUrl.id, "ActionSet.Action.OpenUrl_id")
                } else {
                    XCTFail("Failed to decode Action.OpenUrl")
                }
            } else {
                XCTFail("Failed to decode ActionSet")
            }
            
            // RichTextBlock
            if case let .richTextBlock(richTextBlock) = card.body[7] {
                XCTAssertEqual(richTextBlock.id, "RichTextBlock_id")
                XCTAssertEqual(richTextBlock.inlines.count, 2)
               let textRun = richTextBlock.inlines[0]
               XCTAssertEqual(textRun.text, "This is a text run")
               
            } else {
                XCTFail("Failed to decode RichTextBlock")
            }
            
        }
    }
}



