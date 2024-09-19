//
//  Container.swift
//
//
//  Created by Gabriel Medina on 14/09/23.
//

import Foundation
import UIKit

/*
class  Container {
    let allowCustomStyle: Bool = true
    let hasExplicitStyle: Bool = false
    
    let hostConfig: HostConfig
    let items: [CardElement]
    
    init(hostConfig: HostConfig, items: [CardElement] ) {
        self.hostConfig = hostConfig
        self.items = items
    }
    
    func applyBorder() {
        // No border in base implementation
    }
    
    func applyBackground(view: UIView, color: UIColor) {
        view.backgroundColor = color
    }
    
    
    func getSpacings() {
    }
    
    func getSeparatorSpacings() {
    }
    
    func getHasBackground(_ ignoreBackgroundImages: Bool = false) -> Bool {
        return false
    }
    
    func getDefaultPadding() -> PaddingDefinition {
        return PaddingDefinition( top: Spacing.none,
                                  right: Spacing.none,
                                  bottom: Spacing.none,
                                  left: Spacing.none )
    }
    
    func renderItems() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.clear

        let hostConfig = self.hostConfig

        var spacings = IElementSpacings(
            padding: SpacingDefinition(),
            margin: SpacingDefinition()
        )

        containerView.layoutMargins = UIEdgeInsets(
            top: CGFloat(spacings.margin?.top ?? 0),
            left: CGFloat(spacings.margin?.left ?? 0),
            bottom: CGFloat(spacings.margin?.bottom ?? 0),
            right: CGFloat(spacings.margin?.right ?? 0)
        )

        applyBackground(view: containerView, color: UIColor.blue)

        for item in self.items {
            let renderedItem = item.render() // Assuming the item has a render method
            
            // Add the rendered item as a subview
            containerView.addSubview(renderedItem)
        }

        return containerView
    }
    
    /*
    func renderItems() -> [JSX.Element] {
        var renderedItems: [JSX.Element] = []
        
        let hostConfig = self.hostConfig
        var props = createProps()
        props.className = hostConfig.makeCssClassName("ac-container")
        props.style.display = "flex"
        props.style.flexDirection = "column"
        
        let renderedItems = self.renderItems()
        
        var spacings = IElementSpacings(
            padding: Spacing(),
            margin: Spacing()
        )
        
        self.getSpacings(spacings)
        props.style.paddingLeft = spacings.padding.left
        props.style.paddingRight = spacings.padding.right
        props.style.paddingTop = spacings.padding.top
        props.style.paddingBottom = spacings.padding.bottom
        
        props.style.marginLeft = spacings.margin.left
        props.style.marginRight = spacings.margin.right
        props.style.marginTop = spacings.margin.top
        props.style.marginBottom = spacings.margin.bottom
        
        applySelectAction(props)
        applyBackground(props)
        applyBorder(props)
        customizeProps(props)
        
        return React.createElement("div", props, renderedItems)
    }
    */
    
    func internalValidateProperties(context: ValidationResults) {
        // super.internalValidateProperties(context)
        /*
        let explicitStyle = self.getValue(
            StylableCardElementContainer.styleProperty
        )
        
        if (explicitStyle != nil) {
            let styleDefinition = self.hostConfig.containerStyles.getStyleByName(explicitStyle)
            
            if (styleDefinition == nil) {
                context.addFailure(
                    self,
                    ValidationEvent.InvalidPropertyValue,
                    Strings.errors.invalidPropertyValue(explicitStyle, "style")
                )
            }
        }
        */
    }
    
    func getEffectiveStyle() -> String {
        return "Default"
    }
}


*/
