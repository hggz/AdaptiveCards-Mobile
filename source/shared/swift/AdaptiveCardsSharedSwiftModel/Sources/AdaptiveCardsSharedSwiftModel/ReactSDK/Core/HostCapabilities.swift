/*
class HostCapabilities: SerializableObject {
    private var capabilities: [String: TargetVersion] = [:]

    override func getSchemaKey() -> String {
        return "HostCapabilities"
    }

    override func internalParse(source: PropertyBag, context: BaseSerializationContext) {
        super.internalParse(source: source, context: context)

        guard let sourceDict = source as? [String: Any] else {
            return
        }

        for (name, jsonVersion) in sourceDict {
            if let jsonVersionStr = jsonVersion as? String {
                if jsonVersionStr == "*" {
                    self.addCapability(name: name, version: .anyVersion)
                } else {
                    let version = Version.parse(versionString: jsonVersionStr, context: context)
                    if version?.isValid == true {
                        self.addCapability(name: name, version: .version(version!))
                    }
                }
            }
        }
    }

    override func internalToJSON(target: inout PropertyBag, context: BaseSerializationContext) {
        super.internalToJSON(target: &target, context: context)

        for (key, value) in capabilities {
            target[key] = value
        }
    }

    func addCapability(name: String, version: TargetVersion) {
        capabilities[name] = version
    }

    func removeCapability(name: String) {
        capabilities[name] = nil
    }

    func clear() {
        capabilities = [:]
    }

    func hasCapability(name: String, version: TargetVersion) -> Bool {
        guard let knownVersion = capabilities[name] else {
            return false
        }
        var knownVersionVal: Version? = nil
        switch knownVersion {
        case .version(let version):
            knownVersionVal = version
        case .anyVersion:
            break
        }
        
        switch version {
        case .version(let version):
            guard let knownVersionVal = knownVersionVal else { return false }
            return version < knownVersionVal || version == knownVersionVal
        case .anyVersion:
            return true
        }

    }

    func areAllMet(hostCapabilities: HostCapabilities) -> Bool {
        for (capabilityName, capabilityVersion) in capabilities {
            if !hostCapabilities.hasCapability(name: capabilityName, version: capabilityVersion) {
                return false
            }
        }

        return true
    }
}
*/
