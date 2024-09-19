//
//  CardElementContainer.swift
//  
//
//  Created by Vikrant Singh on 9/14/23.
//

import Foundation
import UIKit // Required for UIView manipulation

/*
class CardElementContainer: CardElement {
    
    /*
    static let selectActionProperty = "selectAction"
    
    private var _selectAction: Action?
    
    var selectAction: Action? {
        get { return _selectAction }
        set { _selectAction = newValue }
    }
    
    var allowVerticalOverflow: Bool = false
    
    // Define methods which are abstract in TypeScript. They will need to be overridden by any subclass.
    func getItemCount() -> Int { fatalError("Must be overridden") }
    func getItemAt(index: Int) -> CardElement { fatalError("Must be overridden") }
    func getFirstVisibleRenderedItem() -> CardElement? { fatalError("Must be overridden") }
    func getLastVisibleRenderedItem() -> CardElement? { fatalError("Must be overridden") }
    func removeItem(item: CardElement) -> Bool { fatalError("Must be overridden") }

    func isElementAllowed(_ element: CardElement) -> Bool {
        return hostConfig.supportsInteractivity || !element.isInteractive
    }

    func getSpacings(_ spacings: IElementSpacings) {
        // Implementation depends on exact spacings processing.
        // This is a placeholder based on the TypeScript version.
        let physicalPadding = SpacingDefinition()

        if let effectivePadding = self.getEffectivePadding() {
            physicalPadding = hostConfig.paddingDefinitionToSpacingDefinition(effectivePadding)
        }

        spacings.padding = Padding(top: physicalPadding.top,
                                   right: physicalPadding.right,
                                   bottom: physicalPadding.bottom,
                                   left: physicalPadding.left)
    }

    func customizeProps(_ props: inout AllHTMLAttributes) {
        // No customization in base implementation.
    }

    var isSelectable: Bool {
        return false
    }

    func forbiddenChildElements() -> [String] {
        return []
    }

    func releaseDOMResources() {
        // Assuming that releaseDOMResources is used to free up any resources.
        // The direct equivalent in Swift/UIKit would be removing references and allowing deinitialization.
        // However, here's a basic version:

        for i in 0..<getItemCount() {
            getItemAt(index: i).releaseDOMResources()
        }
    }

    func internalValidateProperties(context: ValidationResults) {
        // Validate properties.
        // This is a very basic conversion. Logic might need to be expanded based on your needs.

        for i in 0..<getItemCount() {
            let item = getItemAt(index: i)

            if !hostConfig.supportsInteractivity && item.isInteractive {
                context.addFailure(element: self, event: .interactivityNotAllowed, message: "Interactivity not allowed.")
            }

            if !isElementAllowed(item) {
                context.addFailure(element: self, event: .elementTypeNotAllowed, message: "Element type \(item.getJsonTypeName()) not allowed.")
            }

            item.internalValidateProperties(context: context)
        }

        selectAction?.internalValidateProperties(context: context)
    }

    func updateLayout(processChildren: Bool = true) {
        if processChildren {
            for i in 0..<getItemCount() {
                getItemAt(index: i).updateLayout()
            }
        }
    }

    func getAllInputs(processActions: Bool = true) -> [IInput] {
        var result: [IInput] = []

        for i in 0..<getItemCount() {
            let element = getItemAt(index: i)
            // Assuming there's a method `shouldRenderForTargetWidth`
            if element.shouldRenderForTargetWidth() {
                result.append(contentsOf: element.getAllInputs(processActions: processActions))
            }
        }

        return result
    }

    func getAllActions() -> [IAction] {
        var result: [IAction] = []
        
        for i in 0..<getItemCount() {
            let element = getItemAt(index: i)
            if element.shouldRenderForTargetWidth() {
                result.append(contentsOf: element.getAllActions())
            }
        }

        if let action = selectAction {
            result.append(action)
        }

        return result
    }

    func getResourceInformation() -> [IResourceInformation] {
        var result: [IResourceInformation] = []

        for i in 0..<getItemCount() {
            result.append(contentsOf: getItemAt(index: i).getResourceInformation())
        }

        return result
    }

    func getElementById(id: String) -> CardElement? {
        if let result = super.getElementById(id: id) {
            return result
        }

        for i in 0..<getItemCount() {
            let element = getItemAt(index: i)
            if element.shouldRenderForTargetWidth(), let foundElement = element.getElementById(id: id) {
                return foundElement
            }
        }

        return nil
    }
    
    
    func applySelectAction(_ view: UIView) {
        guard let action = selectAction else { return }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        view.addGestureRecognizer(tapGesture)
        // Add more event handlers as needed, like for keyboard presses
    }
    
    @objc private func handleTapGesture() {
        guard let action = selectAction, action.isEnabled else { return }
        action.execute()
    }
 */
}

*/
