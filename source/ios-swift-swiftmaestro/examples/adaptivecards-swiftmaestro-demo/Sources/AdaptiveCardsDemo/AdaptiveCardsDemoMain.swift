import Foundation
import SwiftMaestroDriver
import SwiftMaestroFlow
import SwiftMaestroReport
import SwiftMaestroRunner

@main
struct AdaptiveCardsDemoMain {
    static func main() async throws {
        do {
            try await run()
        } catch {
            FileHandle.standardError.write(Data("FAIL adaptivecards-swiftmaestro-runtime: \(error)\n".utf8))
            throw error
        }
    }

    private static func run() async throws {
        let element = try SampleCard.firstElement()
        guard element == .init(type: "TextBlock", text: "Hello, World!") else {
            throw DemoError.assertion("unexpected canonical card element: \(element)")
        }

        let driver = AdaptiveCardDriver(element: element)
        let hierarchy = try await driver.viewHierarchy()
        let match = ElementFinder().findFirst(
            Selector(text: element.text), in: hierarchy, requireVisible: true
        )
        guard match?.node.className == element.type else {
            throw DemoError.assertion("ElementFinder did not resolve the canonical TextBlock")
        }

        let yaml = """
        appId: dev.swiftmaestro.adaptivecards.demo
        name: canonical-adaptive-card
        tags: [adaptivecards, smoke]
        ---
        - assertVisible: "Hello, World!"
        - tapOn: "Hello, World!"
        - evalScript: "${output.cardType = 'TextBlock'}"
        - assertTrue: "${output.cardType === 'TextBlock'}"
        """
        let flow = try FlowParser.parse(yaml, sourcePath: "canonical-card.yaml")
        let result = await FlowExecutor().execute(
            flow,
            on: driver,
            device: "adaptivecard-fixture",
            options: .init(commandTimeoutMs: 1_000, waitForIdleTimeoutMs: 0)
        )

        let expectedCommands = ["assertVisible", "tapOn", "evalScript", "assertTrue"]
        guard result.status == .passed,
              result.steps.map(\.command) == expectedCommands,
              result.steps.allSatisfy({ $0.status == .passed }) else {
            throw DemoError.assertion("flow failed: \(result)")
        }

        let actions = await driver.actions
        guard actions.contains("tap(170,60)") else {
            throw DemoError.assertion("expected TextBlock center tap, actions=\(actions)")
        }

        let report = TestReport(flows: [result], startedAtEpochMs: 0)
        let reportJSON = JSONReportGenerator().generate(report)
        guard
            let document = try JSONSerialization.jsonObject(with: Data(reportJSON.utf8)) as? [String: Any],
            let summary = document["summary"] as? [String: Any],
            summary["success"] as? Bool == true,
            summary["passed"] as? Int == 1
        else {
            throw DemoError.assertion("generated report did not record one passing flow")
        }

        print("card body[0].type=\(element.type); steps=\(result.steps.count); tap=170,60; report=success")
        print("PASS adaptivecards-swiftmaestro-runtime")
    }
}
