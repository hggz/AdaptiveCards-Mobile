import XCTest
import SwiftMaestroDriver
@testable import SwiftMaestroAppium

final class AppiumCapabilitiesTests: XCTestCase {
    func testLoadsArbitraryCapabilitiesJSON() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("swiftmaestro-appium-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let path = directory.appendingPathComponent("test-caps.json")
        try #"{"platformName":"Android","appium:noReset":true,"appium:newCommandTimeout":120,"nested":{"items":[1,"two"]}}"#
            .write(to: path, atomically: false, encoding: .utf8)

        let capabilities = try AppiumCapabilities.load(path: path.path)
        XCTAssertEqual(capabilities["platformName"], .string("Android"))
        XCTAssertEqual(capabilities["appium:noReset"], .bool(true))
        XCTAssertEqual(capabilities["appium:newCommandTimeout"], .int(120))
        XCTAssertEqual(capabilities["nested"], .object(["items": .array([.int(1), .string("two")])]))
    }

    func testAllCloudProviderShapesAndSecureDefaults() {
        let credentials = CloudCredentials(username: "cloud-user", accessKey: "cloud-secret")
        let metadata = CloudSessionMetadata(project: "swiftmaestro", build: "build-1", name: "login")

        for provider in CloudProvider.allCases {
            let capabilities = CloudCapabilities.make(provider: provider,
                                                        platform: .ios,
                                                        deviceName: "iPhone 16",
                                                        platformVersion: "18",
                                                        app: "storage:filename=Example.ipa",
                                                        credentials: credentials,
                                                        metadata: metadata)
            XCTAssertEqual(capabilities["platformName"], .string("iOS"))
            XCTAssertEqual(capabilities["appium:automationName"], .string("XCUITest"))
            XCTAssertEqual(capabilities["appium:deviceName"], .string("iPhone 16"))
            guard case .object(let options)? = capabilities[provider.namespace] else {
                return XCTFail("missing \(provider.namespace) options")
            }
            XCTAssertFalse(options.isEmpty)
            XCTAssertTrue(provider.defaultHubURL.hasPrefix("https://"))
            XCTAssertFalse(capabilities.redactedJSON().contains("cloud-secret"))
            XCTAssertTrue(capabilities.redactedJSON().contains("***"))
        }
    }

    func testProviderCredentialKeyConventions() {
        let credentials = CloudCredentials(username: "u", accessKey: "k")
        func options(_ provider: CloudProvider) -> [String: CapabilityValue] {
            let caps = CloudCapabilities.make(provider: provider, platform: .android,
                                              deviceName: "Pixel", credentials: credentials)
            guard case .object(let values)? = caps[provider.namespace] else { return [:] }
            return values
        }
        XCTAssertEqual(options(.browserStack)["userName"], .string("u"))
        XCTAssertEqual(options(.browserStack)["accessKey"], .string("k"))
        XCTAssertEqual(options(.sauceLabs)["username"], .string("u"))
        XCTAssertEqual(options(.lambdaTest)["w3c"], .bool(true))
        XCTAssertEqual(options(.testingBot)["key"], .string("u"))
        XCTAssertEqual(options(.testingBot)["secret"], .string("k"))
    }

    func testCloudProviderParsesCLIShapes() {
        XCTAssertEqual(CloudProvider.parse("browserstack"), .browserStack)
        XCTAssertEqual(CloudProvider.parse("Sauce-Labs"), .sauceLabs)
        XCTAssertEqual(CloudProvider.parse("lambda_test"), .lambdaTest)
        XCTAssertEqual(CloudProvider.parse("Testing Bot"), .testingBot)
        XCTAssertNil(CloudProvider.parse("unknown"))
    }

    func testRemoteHTTPRejectedAndLoopbackAllowed() throws {
        XCTAssertThrowsError(try AppiumClient(baseURL: "http://hub.example.test/wd/hub")) { error in
            guard case AppiumError.insecureRemoteURL(let value) = error else {
                return XCTFail("expected insecureRemoteURL, got \(error)")
            }
            XCTAssertFalse(value.contains("user"))
        }
        _ = try AppiumClient(baseURL: "http://127.0.0.1:4723")
        _ = try AppiumClient(baseURL: "http://localhost:4723/wd/hub")
        _ = try AppiumClient(baseURL: "https://hub.example.test/wd/hub")
    }
}
