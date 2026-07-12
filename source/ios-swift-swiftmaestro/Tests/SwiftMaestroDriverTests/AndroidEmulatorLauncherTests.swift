import XCTest
@testable import SwiftMaestroDriver

final class AndroidEmulatorLauncherTests: XCTestCase {
    func testConfigurationDerivesSerialAndArguments() {
        let configuration = AndroidEmulatorConfiguration(
            avdName: "Pixel_API_35", port: 5556, emulatorPath: "custom-emulator",
            headless: true, startupTimeoutMs: 90_000
        )
        XCTAssertEqual(configuration.serial, "emulator-5556")
        XCTAssertEqual(AndroidEmulatorLauncher.arguments(configuration), [
            "-avd", "Pixel_API_35", "-port", "5556", "-no-audio",
            "-no-boot-anim", "-gpu", "swiftshader_indirect", "-no-window",
        ])
    }

    func testVisibleConfigurationOmitsNoWindow() {
        let configuration = AndroidEmulatorConfiguration(avdName: "Pixel", headless: false)
        XCTAssertFalse(AndroidEmulatorLauncher.arguments(configuration).contains("-no-window"))
    }
}
