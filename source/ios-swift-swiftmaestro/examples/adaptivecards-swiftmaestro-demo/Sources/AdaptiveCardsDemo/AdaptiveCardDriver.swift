import Foundation
import SwiftMaestroDriver
import SwiftMaestroFlow

/// Minimal host adapter that exposes the decoded Adaptive Card as a normalized
/// hierarchy. Real embedders provide the same `Driver` contract over UIKit,
/// WebDriverAgent, Appium, CDP, or another transport.
actor AdaptiveCardDriver: Driver {
    nonisolated let platform: Platform = .ios

    private let hierarchy: ViewHierarchy
    private(set) var actions: [String] = []

    init(element: SampleCard.FirstElement) {
        hierarchy = ViewHierarchy(
            root: ViewNode(
                className: "AdaptiveCard",
                bounds: Bounds(x: 0, y: 0, width: 360, height: 200),
                visible: true,
                children: [
                    ViewNode(
                        text: element.text,
                        resourceId: "adaptivecards.body.0",
                        className: element.type,
                        bounds: Bounds(x: 20, y: 30, width: 300, height: 60),
                        clickable: true,
                        visible: true
                    ),
                ]
            ),
            platform: .ios
        )
    }

    func setUp() async throws { actions.append("setUp") }
    func tearDown() async throws { actions.append("tearDown") }
    func installApp(_ path: String) async throws { throw unsupported("installApp") }
    func launchApp(_ appId: String, arguments: [String: String]) async throws {
        actions.append("launchApp(\(appId))")
    }
    func stopApp(_ appId: String) async throws { throw unsupported("stopApp") }
    func clearState(_ appId: String) async throws { throw unsupported("clearState") }
    func viewHierarchy() async throws -> ViewHierarchy {
        actions.append("viewHierarchy")
        return hierarchy
    }
    func tap(_ point: Point) async throws { actions.append("tap(\(point.x),\(point.y))") }
    func longPress(_ point: Point) async throws { throw unsupported("longPress") }
    func inputText(_ text: String) async throws { throw unsupported("inputText") }
    func eraseText(_ count: Int) async throws { throw unsupported("eraseText") }
    func swipe(from: Point, to: Point, durationMs: Int) async throws { throw unsupported("swipe") }
    func scroll(_ direction: Direction) async throws { throw unsupported("scroll") }
    func pressKey(_ key: DeviceKey) async throws { throw unsupported("pressKey") }
    func openLink(_ url: String) async throws { throw unsupported("openLink") }
    func screenshot() async throws -> Data { throw unsupported("screenshot") }
    func startRecording(_ path: String) async throws { throw unsupported("startRecording") }
    func stopRecording() async throws { throw unsupported("stopRecording") }
    func setLocation(latitude: Double, longitude: Double) async throws { throw unsupported("setLocation") }

    private func unsupported(_ operation: String) -> DriverError {
        .notSupported(operation)
    }
}
