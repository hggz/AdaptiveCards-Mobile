import XCTest
import Foundation
@testable import SwiftMaestroDriver
import SwiftMaestroProcess

final class AdbTests: XCTestCase {

    func testDevicesParsingExcludesNonReady() async throws {
        let mock = MockCommandRunner { _, args in
            if args == ["devices"] {
                let out = "List of devices attached\nemulator-5554\tdevice\n0a1b2c3d\toffline\n\n"
                return ProcessResult(exitCode: 0, stdout: Data(out.utf8), stderr: Data())
            }
            return ProcessResult(exitCode: 0, stdout: Data(), stderr: Data())
        }
        let devices = try await Adb(runner: mock).devices()
        XCTAssertEqual(devices, ["emulator-5554"])
    }

    func testCommandConstructionIsSerialScoped() async throws {
        let mock = MockCommandRunner()
        let adb = Adb(runner: mock, serial: "emulator-5554")
        try await adb.inputTap(x: 100, y: 200)
        try await adb.forceStop("com.example")
        try await adb.forward(hostPort: 6790, devicePort: 6790)
        try await adb.clearData("com.example")

        let calls = await mock.calls
        XCTAssertEqual(calls[0].executable, "adb")
        XCTAssertEqual(calls[0].arguments, ["-s", "emulator-5554", "shell", "input", "tap", "100", "200"])
        XCTAssertEqual(calls[1].arguments, ["-s", "emulator-5554", "shell", "am", "force-stop", "com.example"])
        XCTAssertEqual(calls[2].arguments, ["-s", "emulator-5554", "forward", "tcp:6790", "tcp:6790"])
        XCTAssertEqual(calls[3].arguments, ["-s", "emulator-5554", "shell", "pm", "clear", "com.example"])
    }

    func testNoSerialOmitsFlag() async throws {
        let mock = MockCommandRunner()
        try await Adb(runner: mock).inputTap(x: 1, y: 2)
        let calls = await mock.calls
        XCTAssertEqual(calls[0].arguments, ["shell", "input", "tap", "1", "2"])
    }

    func testInputTextEscaping() async throws {
        let mock = MockCommandRunner()
        try await Adb(runner: mock).inputText("hello world & more")
        let calls = await mock.calls
        XCTAssertEqual(calls[0].arguments, ["shell", "input", "text", "hello%sworld%s\\&%smore"])
    }

    func testScreencapReturnsRawBytes() async throws {
        let pngMagic: [UInt8] = [0x89, 0x50, 0x4E, 0x47]
        let mock = MockCommandRunner { _, args in
            if args.contains("screencap") {
                return ProcessResult(exitCode: 0, stdout: Data(pngMagic), stderr: Data())
            }
            return ProcessResult(exitCode: 0, stdout: Data(), stderr: Data())
        }
        let bytes = try await Adb(runner: mock).screencap()
        XCTAssertEqual(Array(bytes), pngMagic)
    }

    func testKeyEventArgMapping() {
        XCTAssertEqual(UIAutomator2Driver.keyEventArg(.enter), "66")
        XCTAssertEqual(UIAutomator2Driver.keyEventArg(.back), "4")
        XCTAssertEqual(UIAutomator2Driver.keyEventArg(.backspace), "67")
        XCTAssertEqual(UIAutomator2Driver.keyEventArg(.other("KEYCODE_CAMERA")), "KEYCODE_CAMERA")
    }
}
