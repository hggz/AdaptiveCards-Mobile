/*
import Foundation

struct IValidationEvent {
    var source: SerializableObject? // You might need to define SerializableObject in Swift or replace it with the corresponding type
    var phase: ValidationPhase
    var event: ValidationEvent
    var message: String
}

class Version: Comparable {
    private var versionString: String
    private var major: Int
    private var minor: Int
    var isValid: Bool = true
    private var label: String?

    init(major: Int = 1, minor: Int = 1, label: String? = nil) {
        self.major = major
        self.minor = minor
        self.label = label
        self.versionString = "\(major).\(minor)"
    }

    static func parse(versionString: String, context: BaseSerializationContext) -> Version? {
        if versionString.isEmpty {
            return nil
        }

        let result = Version()
        result.versionString = versionString

        let regEx = try! NSRegularExpression(pattern: "(\\d+).(\\d+)", options: [])
        let matches = regEx.matches(in: versionString, options: [], range: NSRange(versionString.startIndex..., in: versionString))

        if let match = matches.first, match.numberOfRanges == 3 {
            result.major = Int((versionString as NSString).substring(with: match.range(at: 1))) ?? 0
            result.minor = Int((versionString as NSString).substring(with: match.range(at: 2))) ?? 0
        } else {
            result.isValid = false
        }

        if !result.isValid {
//            context.logParseEvent(event: .invalidPropertyValue, message: "Invalid version string \(result.versionString)")
        }

        return result
    }

    func toString() -> String {
        return !isValid ? versionString : "\(major).\(minor)"
    }

    func toJSON() -> String {
        return self.toString()
    }

    static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major < rhs.major {
            return true
        } else if lhs.major == rhs.major {
            return lhs.minor < rhs.minor
        }
        return false
    }

    static func == (lhs: Version, rhs: Version) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor
    }

    var displayLabel: String {
        return label ?? self.toString()
    }
}

enum TargetVersion {
    case version(Version)
    case anyVersion
}

class Versions {
    static let v1_0 = Version(major: 1, minor: 0)
    static let v1_1 = Version(major: 1, minor: 1)
    static let v1_2 = Version(major: 1, minor: 2)
    static let v1_3 = Version(major: 1, minor: 3)
    static let v1_4 = Version(major: 1, minor: 4)
    static let v1_5 = Version(major: 1, minor: 5)
    static let v1_6 = Version(major: 1, minor: 6, label: "1.6 Preview")
    static let latest = Versions.v1_5

    static func getAllDeclaredVersions() -> [Version] {
        // Simplified: You can expand upon this if necessary
        return [v1_0, v1_1, v1_2, v1_3, v1_4, v1_5, v1_6].sorted()
    }
}

func isVersionLessOrEqual(version: TargetVersion, targetVersion: TargetVersion) -> Bool {
    switch (version, targetVersion) {
    case (.version(let v1), .version(let v2)):
        return v1 <= v2
    default:
        return true
    }
}

class BaseSerializationContext {
    private var validationEvents: [ValidationEvent] = []
    var onAfterObjectParsed: ((SerializableObject, PropertyBag) -> Void)?
    var toJSONOriginalParam: Any? // Swift uses "Any" for a type that can be anything
    var targetVersion: Version
    var hostContext: Any? // or a specific type if you have it
    
    init(targetVersion: Version = Versions.latest) {
        self.targetVersion = targetVersion
    }
    
    func serializeValue(target: inout [String: Any], propertyName: String, propertyValue: Any?, defaultValue: Any? = nil, forceDeleteIfNullOrDefault: Bool = false) {
        guard let propertyValue = propertyValue else {
            if !GlobalSettings.enableFullJsonRoundTrip || forceDeleteIfNullOrDefault {
                target.removeValue(forKey: propertyName)
            }
            return
        }
        
        if let defaultValue = defaultValue, "\(propertyValue)" == "\(defaultValue)" {
            if !GlobalSettings.enableFullJsonRoundTrip {
                target.removeValue(forKey: propertyName)
            }
            return
        }
        
        target[propertyName] = propertyValue
    }
    
    // You can create similar methods for serializeString, serializeDate, etc.
    // The approach would be mostly the same, with types replaced to match Swift's types
    
    func clearEvents() {
        validationEvents = []
    }
    
    func logEvent(source: SerializableObject?, phase: ValidationPhase, event: ValidationEvent, message: String) {
        // TODO
//        validationEvents.append(ValidationEvent(source: source, phase: phase, event: event, message: message))
    }
    
    func logParseEvent(source: SerializableObject?, event: ValidationEvent, message: String) {
        logEvent(source: source, phase: .parse, event: event, message: message)
    }
    
    func getEvent(at index: Int) -> ValidationEvent {
        return validationEvents[index]
    }
    
    var eventCount: Int {
        return validationEvents.count
    }
}

typealias PropertyBag = [String: Any]

protocol SerializableObjectDelegate: AnyObject {
    func propertyChanged(sender: SerializableObject, property: PropertyDefinition, newValue: Any)
}

class SimpleSerializationContext: BaseSerializationContext { }

class SerializableObjectSchema {
    private var _properties: [PropertyDefinition] = []
    let key: String
    
    init(key: String) {
        self.key = key
    }
    
    func indexOf(prop: PropertyDefinition) -> Int {
        return _properties.firstIndex { $0 === prop } ?? -1
    }
    
    func add(_ properties: [PropertyDefinition]) {
        for prop in properties {
            if indexOf(prop: prop) == -1 {
                _properties.append(prop)
            }
        }
    }
    
    func remove(_ properties: PropertyDefinition...) {
        for prop in properties {
            while true {
                let index = indexOf(prop: prop)
                if index >= 0 {
                    _properties.remove(at: index)
                } else {
                    break
                }
            }
        }
    }
    
    func getItemAt(index: Int) -> PropertyDefinition {
        return _properties[index]
    }
    
    func getCount() -> Int {
        return _properties.count
    }
}

class SerializableObject {
    
    static var currentKey = 0
    static var onRegisterCustomProperties: ((SerializableObject, SerializableObjectSchema) -> Void)?
    static var defaultMaxVersion = Versions.latest
    
    private static var _schemaCache: [String: SerializableObjectSchema] = [:]
    
    private var _isParsing = false
    private var _propertyBag: PropertyBag = [:]
    private var _rawProperties: PropertyBag = [:]
    
    var delegate: SerializableObjectDelegate?
    
    let key = SerializableObject.currentKey
    var maxVersion: Version = SerializableObject.defaultMaxVersion
    
    init() {
        let s = getSchema()
        
        // Initialize properties with default values
        for i in 0..<s.getCount() {
            let prop = s.getItemAt(index: i)
            if let initialValue = prop.onGetInitialValue?(self) {
                setValue(prop, value: initialValue)
            }
        }
        
        SerializableObject.currentKey += 1
    }
    
    func hasAllDefaultValues() -> Bool {
        let schema = getSchema()

        for i in 0..<schema.getCount() {
            let prop = schema.getItemAt(index: i)
            if !hasDefaultValue(for: prop) {
                return false
            }
        }

        return true
    }
    
    public func afterParse() {
        // TODO
    }
    
    func propertyChanged(property: PropertyDefinition, newValue: Any) {
        delegate?.propertyChanged(sender: self, property: property, newValue: newValue)
    }
    
    func internalParse(source: PropertyBag, context: BaseSerializationContext) {
           
           guard !_isParsing else { return }
           
           _isParsing = true
           
           defer {
               _isParsing = false
               if let afterParse = context.onAfterObjectParsed {
                   afterParse(self, source)
               }
           }
           
           _propertyBag = [:]
           _rawProperties = GlobalSettings.enableFullJsonRoundTrip ? (source ?? [:]) : [:]
           
           let sourceData = source
               let s = self.getSchema()
               
               for i in 0..<s.getCount() {
                   let prop = s.getItemAt(index: i)
                   
                   if prop.isSerializationEnabled {
                       var propertyValue: Any? = prop.onGetInitialValue != nil ? prop.onGetInitialValue!(self) : nil
                       
                       if sourceData.keys.contains(prop.name) {
                           if prop.targetVersion < context.targetVersion || prop.targetVersion == context.targetVersion {
                               propertyValue = prop.parse(sender: self, source: sourceData, context: context)
                           } else {
//                               context.logParseEvent(sender: self, event: .UnsupportedProperty, message: Strings.errors.propertyNotSupported(prop.name, prop.targetVersion.toString(), context.targetVersion.toString()))
                           }
                       }
                       
                       self.setValue(prop, value: propertyValue)
                   }
               }
//               self.resetDefaultValues()
       }
       
       // The equivalent of internalToJSON
       func internalToJSON(target: inout PropertyBag, context: BaseSerializationContext) {
           
           let s = self.getSchema()
           var serializedProperties: [String] = []
           
           for i in 0..<s.getCount() {
               let prop = s.getItemAt(index: i)
               
               if prop.isSerializationEnabled, prop.targetVersion < context.targetVersion || prop.targetVersion == context.targetVersion, !serializedProperties.contains(prop.name) {
                   prop.toJSON(self, target: target, value: self.getValue(for: prop)!, context: context)
                   serializedProperties.append(prop.name)
               }
           }
       }
    
    func hasDefaultValue(for prop: PropertyDefinition) -> Bool {
        // TODO
//       return getValue(for: prop) == prop.defaultValue
        return false
   }
    
    func populateSchema(schema: SerializableObjectSchema) {
        var properties: [PropertyDefinition] = []

        let mirror = Mirror(reflecting: self)

        for child in mirror.children {
            if let propertyValue = child.value as? PropertyDefinition {
                properties.append(propertyValue)
            }
        }

        if !properties.isEmpty {
            let sortedProperties = properties.sorted { $0.sequentialNumber < $1.sequentialNumber }
            schema.add(sortedProperties)
        }

        if let onRegisterCustomProperties = SerializableObject.onRegisterCustomProperties {
            onRegisterCustomProperties(self, schema)
        }
    }
    
    func getSchema() -> SerializableObjectSchema {
        var schema: SerializableObjectSchema? = SerializableObject._schemaCache[self.getSchemaKey()]
        
        if schema == nil {
            schema = SerializableObjectSchema(key: self.getSchemaKey())
            
            self.populateSchema(schema: schema!)
            
            SerializableObject._schemaCache[schema!.key] = schema
        }
        
        return schema!
    }
    
    func getSchemaKey() -> String {
        // This method should be overridden in subclasses
        fatalError("Must be overridden in subclasses.")
    }
    
    // More methods and properties...
    
    func getValue(for prop: PropertyDefinition) -> Any? {
        return _propertyBag[prop.getInternalName()] ?? prop.defaultValue
    }
    
    func setValue(_ prop: PropertyDefinition, value: Any?) {
        // Handle setting value
        // ... More logic here ...
        
        if !_isParsing {
            delegate?.propertyChanged(sender: self, property: prop, newValue: value ?? NSNull())
        }
    }
    
    func parse(source: PropertyBag, context: BaseSerializationContext?) {
        let effectiveContext = context ?? getDefaultSerializationContext()
        
        // ... Parsing logic here ...
        
        if let afterParse = effectiveContext.onAfterObjectParsed {
            afterParse(self, source)
        }
    }
    
    func toJSON(context: BaseSerializationContext?) -> PropertyBag? {
        let effectiveContext: BaseSerializationContext
        
        if let ctx = context {
            effectiveContext = ctx
        } else {
            effectiveContext = getDefaultSerializationContext()
        }
        
        // ... Serialization logic here ...
        
        return [:]
    }
    
    func getDefaultSerializationContext() -> BaseSerializationContext {
        return SimpleSerializationContext()
    }
}

class PropertyDefinition {
    private static var _sequentialNumber = 0
    
    func getInternalName() -> String {
        return name
    }
    
    func parse(sender: SerializableObject, source: PropertyBag, context: BaseSerializationContext) -> Any? {
        return source[name]
    }
    
    func toJSON(_ sender: SerializableObject, target: PropertyBag, value: Any?, context: BaseSerializationContext) {
        // TODO
//        context.serializeValue(target: &target, name: name, value: value, defaultValue: defaultValue)
    }
    
    func preProcessValue(value: Any) -> Any {
        return value
    }
    
    let sequentialNumber: Int
    var isSerializationEnabled = true
    
    let targetVersion: Version
    let name: String
    let defaultValue: Any?
    let onGetInitialValue: ((SerializableObject) -> Any?)?
    
    init(targetVersion: Version, name: String, defaultValue: Any? = nil, onGetInitialValue: ((SerializableObject) -> Any?)? = nil) {
        self.targetVersion = targetVersion
        self.name = name
        self.defaultValue = defaultValue
        self.onGetInitialValue = onGetInitialValue
        
        self.sequentialNumber = PropertyDefinition._sequentialNumber
        PropertyDefinition._sequentialNumber += 1
    }
}

class StringProperty: PropertyDefinition {
    var treatEmptyAsUndefined: Bool
    var regEx: NSRegularExpression?
    
    init(targetVersion: Version, name: String, treatEmptyAsUndefined: Bool = true, regEx: String? = nil, defaultValue: String? = nil, onGetInitialValue: ((SerializableObject) -> String)? = nil) {
        self.treatEmptyAsUndefined = treatEmptyAsUndefined
        
        if let regexStr = regEx {
            self.regEx = try? NSRegularExpression(pattern: regexStr)
        }
        
        super.init(targetVersion: targetVersion, name: name, defaultValue: defaultValue, onGetInitialValue: onGetInitialValue)
    }
    
    override func parse(sender: SerializableObject, source: PropertyBag, context: BaseSerializationContext) -> Any? {
        guard let parsedValue = parseString(obj: source[name], defaultValue: defaultValue as? String) else { return nil }
        
        if parsedValue.isEmpty && treatEmptyAsUndefined {
            return nil
        }
        
        if let regEx = self.regEx {
            let matches = regEx.matches(in: parsedValue, options: [], range: NSRange(location: 0, length: parsedValue.count))
            if matches.isEmpty {
                // Log parse event, assuming the function has been defined elsewhere
//                context.logParseEvent(sender, event: .invalidPropertyValue, message: Strings.errors.invalidPropertyValue(parsedValue, name))
                return nil
            }
        }
        
        return parsedValue
    }
    
    override func toJSON(_ sender: SerializableObject, target: PropertyBag, value: Any?, context: BaseSerializationContext) {
        let stringValue = value as? String
//        context.serializeString(target, name, (stringValue?.isEmpty ?? false) && treatEmptyAsUndefined ? nil : stringValue, defaultValue as? String)
    }
}

class BoolProperty: PropertyDefinition {
    override func parse(sender: SerializableObject, source: PropertyBag, context: BaseSerializationContext) -> Any? {
        // Assuming the parseBool function has been defined elsewhere
        return parseBool(value: source[name] as? String, defaultValue: defaultValue as? Bool)
    }
    
    override func toJSON(_ sender: SerializableObject, target: PropertyBag, value: Any?, context: BaseSerializationContext) {
        if let boolValue = value as? Bool {
//            context.serializeBool(&target, name: name, value: boolValue, defaultValue: defaultValue as? Bool)
        }
    }
    
    init(targetVersion: Version, name: String, defaultValue: Bool? = nil, onGetInitialValue: ((SerializableObject) -> Any)? = nil) {
        super.init(targetVersion: targetVersion, name: name, defaultValue: defaultValue, onGetInitialValue: onGetInitialValue)
    }
}

class NumProperty: PropertyDefinition {
    override func parse(sender: SerializableObject, source: PropertyBag, context: BaseSerializationContext) -> Any? {
        // Assuming the parseNumber function has been defined elsewhere
        return parseNumber(obj: source[name] as? String, defaultValue: defaultValue as? Int)
    }
    
    override func toJSON(_ sender: SerializableObject, target: PropertyBag, value: Any?, context: BaseSerializationContext) {
        if let numValue = value as? Double {
//            context.serializeNumber(&target, name: name, value: numValue, defaultValue: defaultValue as? Double)
        }
    }
    
    init(targetVersion: Version, name: String, defaultValue: Double? = nil, onGetInitialValue: ((SerializableObject) -> Any)? = nil) {
        super.init(targetVersion: targetVersion, name: name, defaultValue: defaultValue, onGetInitialValue: onGetInitialValue)
    }
}

class PixelSizeProperty: PropertyDefinition {
    override func parse(sender: SerializableObject, source: PropertyBag, context: BaseSerializationContext) -> Any? {
        if let value = source[name] as? String {
            do {
                let size = try SizeAndUnit.parse(input: value, requireUnitSpecifier: true)
                if size.unit == .pixel {
                    return size.physicalSize
                }
            } catch {
                // Log parse error event
//                context.logParseEvent(sender: sender, event: .invalidPropertyValue, message: "Invalid property value for key: \(name)")
            }
        }
        return nil
    }
    
    override func toJSON(_ sender: SerializableObject, target: PropertyBag, value: Any?, context: BaseSerializationContext) {
        if let intValue = value as? Int {
//            context.serializeValue(target: &target, name: name, value: "\(intValue)px")
        }
    }
}

struct VersionedValue<T> {
    var value: T
    var targetVersion: Version?
}

class StringArrayProperty: PropertyDefinition {
    override func parse(sender: SerializableObject, source: PropertyBag, context: BaseSerializationContext) -> Any? {
        guard let sourceValue = source[name] as? [Any] else {
            return defaultValue as? [String]
        }
        
        var result: [String] = []
        
        for value in sourceValue {
            if let stringValue = value as? String {
                result.append(stringValue)
            } else {
                // Log the invalid array value event
                let valueString = String(describing: value)
//                context.logParseEvent(sender: sender, event: .invalidPropertyValue, message: "Invalid array value \"\(valueString)\" of type \"\(type(of: value))\" ignored for \"\(name)\".")
            }
        }
        
        return result
    }
    
    override func toJSON(_ sender: SerializableObject, target: PropertyBag, value: Any?, context: BaseSerializationContext) {
        if let valueArray = value as? [String] {
//            context.serializeArray(target: &target, name: name, value: valueArray)
        }
    }
    
    init(targetVersion: Version, name: String, defaultValue: [String]? = nil, onGetInitialValue: ((SerializableObject) -> [String]?)? = nil) {
        super.init(targetVersion: targetVersion, name: name, defaultValue: defaultValue, onGetInitialValue: onGetInitialValue)
    }
}

class ValueSetProperty: PropertyDefinition {
    
    private let values: [VersionedValue<String>]
    
    func isValidValue(value: String, context: BaseSerializationContext) -> Bool {
        for versionedValue in values {
            if value.lowercased() == versionedValue.value.lowercased() {
                let targetVersion = versionedValue.targetVersion ?? self.targetVersion
                return targetVersion < context.targetVersion || targetVersion == context.targetVersion
            }
        }
        return false
    }
    
    override func parse(sender: SerializableObject, source: PropertyBag, context: BaseSerializationContext) -> Any? {
        guard let sourceValue = source[name] as? String else {
            return defaultValue as? String
        }
        
        for versionedValue in values {
            if sourceValue.lowercased() == versionedValue.value.lowercased() {
                let targetVersion = versionedValue.targetVersion ?? self.targetVersion
                if targetVersion < context.targetVersion || targetVersion == context.targetVersion {
                    return versionedValue.value
                } else {
//                    context.logParseEvent(
//                        sender: sender,
//                        event: .invalidPropertyValue,
//                        message: Strings.errors.propertyValueNotSupported(
//                            sourceValue,
//                            name,
//                            targetVersion.toString(),
//                            context.targetVersion.toString()
//                        )
//                    )
                    return defaultValue as? String
                }
            }
        }
        
//        context.logParseEvent(
//            sender: sender,
//            event: .invalidPropertyValue,
//            message: Strings.errors.invalidPropertyValue(sourceValue, name)
//        )
        return defaultValue as? String
    }
    
    override func toJSON(_ sender: SerializableObject, target: PropertyBag, value: Any?, context: BaseSerializationContext) {
        var invalidValue = false
        
        if let stringValue = value as? String {
            invalidValue = true
            for versionedValue in values {
                if versionedValue.value == stringValue {
                    let targetVersion = versionedValue.targetVersion ?? self.targetVersion
                    if targetVersion < context.targetVersion || targetVersion == context.targetVersion {
                        invalidValue = false
                        break
                    } else {
//                        context.logEvent(
//                            sender: sender,
//                            phase: .toJSON,
//                            event: .invalidPropertyValue,
//                            message: Strings.errors.propertyValueNotSupported(
//                                stringValue,
//                                name,
//                                targetVersion.toString(),
//                                context.targetVersion.toString()
//                            )
//                        )
                    }
                }
            }
        }
        
        if !invalidValue {
//            context.serializeValue(target: &target, name: name, value: value as? String, defaultValue: defaultValue as? String, true)
        }
    }
    
    init(targetVersion: Version, name: String, values: [VersionedValue<String>], defaultValue: String? = nil, onGetInitialValue: ((SerializableObject) -> String)? = nil) {
        self.values = values
        super.init(targetVersion: targetVersion, name: name, defaultValue: defaultValue, onGetInitialValue: onGetInitialValue)
    }
}

typealias SerializableObjectType = SerializableObject.Type

class SerializableObjectProperty: PropertyDefinition {
    
    private let createInstance: (PropertyBag?) -> SerializableObject
    private let nullable: Bool
    
    override func parse(sender: SerializableObject, source: PropertyBag, context: BaseSerializationContext) -> Any? {
        guard let sourceValue = source[name] else {
            if let onGetInitialValue = onGetInitialValue {
                return onGetInitialValue(sender)
            }
            return defaultValue
        }
        
        let result = createInstance(source)
//        result.parse(from: sourceValue, context: context)
        
        return result
    }
    
    override func toJSON(_ sender: SerializableObject, target: PropertyBag, value: Any?, context: BaseSerializationContext) {
        var serializedValue: [String: Any]?
        
        if let validValue = value as? SerializableObject, !validValue.hasAllDefaultValues() {
            serializedValue = validValue.toJSON(context: context)
        }
        
        if let sValue = serializedValue, sValue.isEmpty {
            serializedValue = nil
        }
        
//        context.serializeValue(target: &target, name: name, value: serializedValue, defaultValue: defaultValue as? [String: Any], forceInclude: true)
    }
    
    init(targetVersion: Version, name: String, createInstance: @escaping (PropertyBag?) -> SerializableObject, nullable: Bool = false, defaultValue: SerializableObject? = nil) {
        self.createInstance = createInstance
        self.nullable = nullable
        super.init(targetVersion: targetVersion, name: name, defaultValue: defaultValue) { _ in
            return nullable ? nil : createInstance(nil)
        }
    }
}

class TypedSerializableObjectProperty: SerializableObjectProperty {
    var objectTypeName: String

    override func parse(sender: SerializableObject, source: PropertyBag, context: BaseSerializationContext) -> Any? {
        let sourceValue = source // assuming source is PropertyBag type
        if let typeValue = sourceValue["type"] as? String, typeValue == objectTypeName {
            return super.parse(sender: sender, source: source, context: context)
        }
        return nil
    }

    init(targetVersion: Version, name: String, objectTypeName: String, createInstance: @escaping (PropertyBag?) -> SerializableObject, nullable: Bool = false, defaultValue: SerializableObject?) {
        self.objectTypeName = objectTypeName
        super.init(targetVersion: targetVersion, name: name, createInstance: createInstance, nullable: nullable, defaultValue: defaultValue)
    }
}

class SerializableObjectCollectionProperty: PropertyDefinition {
    var createInstance: (PropertyBag?) -> SerializableObject?
    var onItemAdded: ((SerializableObject, SerializableObject) -> Void)?
    
    func parse(_ sender: SerializableObject, _ source: PropertyBag, _ context: BaseSerializationContext) -> Any? {
        var result: [SerializableObject] = []
        
        if let sourceCollection = source[name] as? [PropertyBag] {
            for sourceItem in sourceCollection {
                if let item = createInstance(sourceItem) {
                    item.parse(source: sourceItem, context: context)
                    result.append(item)
                    
                    onItemAdded?(sender, item)
                }
            }
        }
        
        return result.isEmpty ? (onGetInitialValue != nil ? onGetInitialValue!(sender) : nil) : result
    }
    
    func toJSON(_ sender: SerializableObject, _ target: PropertyBag, _ value: [SerializableObject]?, _ context: BaseSerializationContext) {
//        context.serializeArray(target: target, name: name, value: value)
    }
    
    init(targetVersion: Version, name: String, createInstance: @escaping (PropertyBag?) -> SerializableObject?, onItemAdded: ((SerializableObject, SerializableObject) -> Void)? = nil) {
        self.createInstance = createInstance
        self.onItemAdded = onItemAdded
        super.init(targetVersion: targetVersion, name: name, defaultValue: nil) { _ in return [] }
    }
}

class CustomProperty<T>: PropertyDefinition {
    var onParse: (SerializableObject, PropertyDefinition, PropertyBag, BaseSerializationContext) -> T
    var onToJSON: (SerializableObject, PropertyDefinition, PropertyBag, T, BaseSerializationContext) -> Void

    func parse(sender: SerializableObject, source: PropertyBag, context: BaseSerializationContext) -> T {
        return onParse(sender, self, source, context)
    }

    func toJSON(sender: SerializableObject, target: PropertyBag, value: T, context: BaseSerializationContext) {
        onToJSON(sender, self, target, value, context)
    }

    init(targetVersion: Version, name: String,
         onParse: @escaping (SerializableObject, PropertyDefinition, PropertyBag, BaseSerializationContext) -> T,
         onToJSON: @escaping (SerializableObject, PropertyDefinition, PropertyBag, T, BaseSerializationContext) -> Void,
         defaultValue: T? = nil,
         onGetInitialValue: ((SerializableObject) -> T)? = nil) {

        self.onParse = onParse
        self.onToJSON = onToJSON

        super.init(targetVersion: targetVersion, name: name, defaultValue: defaultValue as? Any, onGetInitialValue: onGetInitialValue)

        if self.onParse == nil {
            fatalError("CustomProperty instances must have an onParse handler.")
        }

        if self.onToJSON == nil {
            fatalError("CustomProperty instances must have an onToJSON handler.")
        }
    }
}

// TypedSerializableObject now conforms to a protocol to define its JSON type name
protocol JsonTypeRepresentable {
    func getJsonTypeName() -> String
}

class TypedSerializableObject: SerializableObject, JsonTypeRepresentable {
    static let typeNameProperty = StringProperty(targetVersion: Versions.v1_0, name: "type") { sender in
        // This requires sender to conform to JsonTypeRepresentable
        // We cast and then call the protocol's function
        if let senderAsTyped = sender as? JsonTypeRepresentable {
            return senderAsTyped.getJsonTypeName()
        } else {
            fatalError("Sender does not conform to JsonTypeRepresentable")
        }
    }

    override func getSchemaKey() -> String {
        return getJsonTypeName()
    }
    
    // Subclasses will provide their own implementations of this
    func getJsonTypeName() -> String {
        fatalError("Subclasses must override this")
    }
}
*/
