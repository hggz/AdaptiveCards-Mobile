import UIKit
/*

class ValidationResults {
    var allIds: [String: Int] = [:]
    var validationEvents: [IValidationEvent] = []

    func addFailure(cardObject: CardObject, event: ValidationEvent, message: String) {
        // TODO
//        let validationEvent = ValidationEvent(phase: .validation, source: cardObject, event: event, message: message)
//        validationEvents.append(validationEvent)
    }
}

// TEMP

protocol IAction {
    var id: String? { get set }
    var title: String? { get set }
    var iconUrl: String? { get set }
    var style: ActionStyle { get set }
    var mode: ActionMode { get set }
    var tooltip: String? { get set }
    var isEnabled: Bool { get }
    var isExpandable: Bool { get set }
    var isExpanded: Bool { get set }
    var isInSubCard: Bool { get set }
    var hostConfig: HostConfig { get set }

    func execute()
    func expand(suppressStyle: Bool, raiseEvent: Bool)
    func collapse()
    func getInlineContent() -> RenderableCardObject?
    func updateEnabledState()
    func toJSON(context: Any)
    func isEffectivelyEnabled() -> Bool
    func focus() -> Bool
}

protocol IActionCollection {
    func actionExecuted(action: IAction)
}

typealias CardObjectType = CardObject.Type

class CardObject: TypedSerializableObject {
    // Assuming the existence of StringProperty, SerializableObjectProperty, Versions, and HostCapabilities based on your code.
    static let idProperty = StringProperty(targetVersion: Versions.v1_0, name: "id")
    static let requiresProperty = SerializableObjectProperty(targetVersion: Versions.v1_2, name: "requires", createInstance: { _ in HostCapabilities() }, nullable: false, defaultValue: HostCapabilities())

    var id: String? {
        get { return getValue(for: CardObject.idProperty) as! String }
        set { setValue(CardObject.idProperty, value: newValue) }
    }

    var requires: HostCapabilities {
        get { return getValue(for: CardObject.requiresProperty) as! HostCapabilities }
        set { setValue(CardObject.requiresProperty, value: newValue) }
    }

    private var _shouldFallback = false
    private var _parent: CardObject?

    func actionExecuted(_ action: IAction) {
        // Do nothing in base implementation
    }

    // Assuming the existence of BaseSerializationContext and SerializationContext based on your code.
    override func getDefaultSerializationContext() -> BaseSerializationContext {
        return SimpleSerializationContext()
    }

    var onPreProcessPropertyValue: ((CardObject, PropertyDefinition, Any) -> Any)?
    var onLocalizeString: ((String) -> String?)?

    // Assuming the existence of HostConfig, ThemeName, ILocalizableString, and GlobalSettings based on your code.
    var hostConfig: HostConfig { return HostConfig() }  // Stub
    var theme: ThemeName { return .dark }  // Stub

    // ... (other methods and computed properties from your TypeScript code)

    // For React rendering methods like renderAnchor or renderImage, you'd probably replace these with UIKit components, but for simplicity, I'm leaving them commented out here.
}

// TODO - needs UIKit adjustments.
class RenderableCardObject: CardObject {
    private var renderCount: Int = 0

    // This method will be overridden by subclasses to provide actual rendering logic
    func render(args: RenderArgs?) -> UIView? {
        // This is abstract in TypeScript, so just a placeholder here
        fatalError("Subclasses must override this")
    }

    private func invalidate() {
        renderCount += 1
    }

    override func afterParse() {
        super.afterParse()
        invalidate()
    }

    override func propertyChanged(property: PropertyDefinition, newValue: Any) {
        super.propertyChanged(property: property, newValue: newValue)
        invalidate()
    }

    func updateLayout(processChildren: Bool = true) {
//        super.updateLayout(processChildren: processChildren)
        invalidate()
    }

    // A method that can be called to get the rendered UIView. In UIKit, we don't generally render directly like in React, but this method can be used similarly.
    func Render(args: RenderArgs?) -> UIView? {
        return render(args: args)
    }

    var hasBeenRendered: Bool {
        return renderCount > 0
    }
}
*/
