import Foundation

struct Strings {
    struct Errors {
        static func unknownElementType(typeName: String) -> String {
            return "Unknown element type \"\(typeName)\". Fallback will be used if present."
        }

        static func unknownActionType(typeName: String) -> String {
            return "Unknown action type \"\(typeName)\". Fallback will be used if present."
        }

        static func elementTypeNotAllowed(typeName: String) -> String {
            return "Element type \"\(typeName)\" is not allowed in this context."
        }
        
        static func actionTypeNotAllowed(typeName: String) -> String {
            return "Action type \"\(typeName)\" is not allowed in this context."
        }

        static func invalidPropertyValue(value: Any, propertyName: String) -> String {
            return "Invalid value \"\(value)\" for property \"\(propertyName)\"."
        }

        static func showCardMustHaveCard() -> String {
            return "An Action.ShowCard must have its \"card\" property set to a valid AdaptiveCard object."
        }

        static func invalidColumnWidth(invalidWidth: String) -> String {
            return "Invalid column width \"\(invalidWidth)\" - defaulting to \"auto\"."
        }

        static func invalidCardVersion(defaultingToVersion: String) -> String {
            return "Invalid card version. Defaulting to \"\(defaultingToVersion)\"."
        }

        static func invalidVersionString(versionString: String) -> String {
            return "Invalid version string \"\(versionString)\"."
        }

        static func propertyValueNotSupported(value: Any, propertyName: String, supportedInVersion: String, versionUsed: String) -> String {
            return "Value \"\(value)\" for property \"\(propertyName)\" is supported in version \(supportedInVersion), but you are using version \(versionUsed)."
        }

        static func propertyNotSupported(propertyName: String, supportedInVersion: String, versionUsed: String) -> String {
            return "Property \"\(propertyName)\" is supported in version \(supportedInVersion), but you are using version \(versionUsed)."
        }

        static func indexOutOfRange(index: Int) -> String {
            return "Index out of range (\(index))."
        }

        static func elementCannotBeUsedAsInline() -> String {
            return "RichTextBlock.addInline: the specified card element cannot be used as a RichTextBlock inline."
        }

        static func inlineAlreadyParented() -> String {
            return "RichTextBlock.addInline: the specified inline already belongs to another RichTextBlock."
        }

        static func interactivityNotAllowed() -> String {
            return "Interactivity is not allowed."
        }

        static func inputsMustHaveUniqueId() -> String {
            return "All inputs must have a unique Id."
        }

        static func choiceSetMustHaveAtLeastOneChoice() -> String {
            return "An Input.ChoiceSet must have at least one choice defined."
        }

        static func choiceSetChoicesMustHaveTitleAndValue() -> String {
            return "All choices in an Input.ChoiceSet must have their title and value properties set."
        }

        static func propertyMustBeSet(propertyName: String) -> String {
            return "Property \"\(propertyName)\" must be set."
        }

        static func actionHttpHeadersMustHaveNameAndValue() -> String {
            return "All headers of an Action.Http must have their name and value properties set."
        }

        static func tooManyActions(maximumActions: Int) -> String {
            return "Maximum number of actions exceeded (\(maximumActions))."
        }

        static func tooLittleTimeDelay(minAutoplayDelay: Int) -> String {
            return "Autoplay Delay is too short (\(minAutoplayDelay))."
        }

        static func columnAlreadyBelongsToAnotherSet() -> String {
            return "This column already belongs to another ColumnSet."
        }

        static func invalidCardType() -> String {
            return "Invalid or missing card type. Make sure the card's type property is set to \"AdaptiveCard\"."
        }

        static func unsupportedCardVersion(version: String, maxSupportedVersion: String) -> String {
            return "The specified card version (\(version)) is not supported or still in preview. The latest released card version is \(maxSupportedVersion)."
        }

        static func duplicateId(id: String) -> String {
            return "Duplicate Id \"\(id)\"."
        }

        static func markdownProcessingNotEnabled() -> String {
            return "Markdown processing isn't enabled. Please see https://www.npmjs.com/package/adaptivecards#supporting-markdown"
        }

        static func elementAlreadyParented() -> String {
            return "The element already belongs to another container."
        }

        static func actionAlreadyParented() -> String {
            return "The action already belongs to another element."
        }

        static func elementTypeNotStandalone(typeName: String) -> String {
            return "Elements of type \(typeName) cannot be used as standalone elements."
        }
    }

    struct MagicCodeInputCard {
        static func tryAgain() -> String {
            return "That didn't work... let's try again."
        }

        static func pleaseLogin() -> String {
            return "Please login in the popup. You will obtain a magic code. Paste that code below and select \"Submit\""
        }

        static func enterMagicCode() -> String {
           return "Enter magic code"
        }
       
        static func pleaseEnterMagicCodeYouReceived() -> String {
            return "Please enter the magic code you received."
        }

        static func submit() -> String {
            return "Submit"
        }

        static func cancel() -> String {
            return "Cancel"
        }

        static func somethingWentWrong() -> String {
            return "Something went wrong. This action can't be handled."
        }

        static func authenticationFailed() -> String {
            return "Authentication failed."
        }
    }

    struct Runtime {
        static func automaticRefreshPaused() -> String {
            return "Automatic refresh paused."
        }

        static func clickToRestartAutomaticRefresh() -> String {
            return "Click to restart."
        }
        
        static func refreshThisCard() -> String {
            return "Refresh this card"
        }
    }

    struct Hints {
        static func dontUseWeightedAndStretchedColumnsInSameSet() -> String {
            return "It is not recommended to use weighted and stretched columns in the same ColumnSet, because in such a situation stretched columns will always get the minimum amount of space."
        }
    }

    struct Defaults {
        static func inlineActionTitle() -> String {
            return "Inline Action"
        }

        static func overflowButtonText() -> String {
            return "..."
        }
        
        static func overflowButtonTooltip() -> String {
            return "More options"
        }
        
        static func mediaPlayerAriaLabel() -> String {
            return "Media content"
        }
        
        static func mediaPlayerPlayMedia() -> String {
            return "Play media"
        }
        
        static func youTubeVideoPlayer() -> String {
            return "YouTube video player"
        }
        
        static func vimeoVideoPlayer() -> String {
            return "Vimeo video player"
        }
        
        static func dailymotionVideoPlayer() -> String {
            return "Dailymotion video player"
        }
    }
}
