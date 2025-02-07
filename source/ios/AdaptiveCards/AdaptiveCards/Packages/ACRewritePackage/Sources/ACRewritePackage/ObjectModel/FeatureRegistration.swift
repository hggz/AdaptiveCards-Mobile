import Foundation

struct FeatureRegistration {
    private var supportedFeatures: [String: String]

    init() {
        self.supportedFeatures = [FeatureRegistration.adaptiveCardsFeature: FeatureRegistration.sharedModelVersion]
    }

    mutating func addFeature(featureName: String, featureVersion: String) throws {
        // Validate the version string. We only support "*" or a semantic version string (e.g., "1.0", "1.2.3.4")
        if featureVersion != "*" {
            _ = try SemanticVersion(featureVersion) // Throws if invalid
        }

        if let existingVersion = supportedFeatures[featureName] {
            if existingVersion != featureVersion {
                throw AdaptiveCardParseException(
                    statusCode: .invalidPropertyValue,
                    message: "Attempting to add a feature with a differing version"
                )
            }
        } else {
            supportedFeatures[featureName] = featureVersion
        }
    }

    mutating func removeFeature(featureName: String) throws {
        if featureName == FeatureRegistration.adaptiveCardsFeature {
            throw AdaptiveCardParseException(
                statusCode: .unsupportedParserOverride,
                message: "Removing the Adaptive Cards feature is unsupported"
            )
        }
        supportedFeatures.removeValue(forKey: featureName)
    }

    func getAdaptiveCardsVersion() throws -> SemanticVersion {
        return try SemanticVersion(getFeatureVersion(featureName: FeatureRegistration.adaptiveCardsFeature))
    }

    func getFeatureVersion(featureName: String) -> String {
        return supportedFeatures[featureName] ?? ""
    }

    // Static Constants
    static let adaptiveCardsFeature = "adaptiveCards"
    static let sharedModelVersion = "1.0.0" // Placeholder for the actual shared model version
}
