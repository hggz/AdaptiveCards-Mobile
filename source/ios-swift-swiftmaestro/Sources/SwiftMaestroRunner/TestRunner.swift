// Port of: pkg/executor + pkg/core (run orchestration) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import SwiftMaestroFlow
import SwiftMaestroDriver
import SwiftMaestroReport

/// Discovers flows at a path, filters by tags, executes them against one driver
/// or a pool of drivers, and (optionally) writes reports. The pool path uses one
/// shared work queue so faster devices take more flows (dynamic distribution, not
/// static sharding).
public struct TestRunner: Sendable {
    public struct Options: Sendable {
        public var formats: [String]
        public var outputDir: String?
        public var appFile: String?
        public var tags: [String]
        public var excludeTags: [String]
        public var device: String?
        public var executorOptions: FlowExecutor.Options

        public init(formats: [String] = ["json"],
                    outputDir: String? = nil,
                    appFile: String? = nil,
                    tags: [String] = [],
                    excludeTags: [String] = [],
                    device: String? = nil,
                    executorOptions: FlowExecutor.Options = .init()) {
            self.formats = formats
            self.outputDir = outputDir
            self.appFile = appFile
            self.tags = tags
            self.excludeTags = excludeTags
            self.device = device
            self.executorOptions = executorOptions
        }
    }

    public init() {}

    /// Run flows against a single driver (one worker; sequential).
    public func run(path: String, driver: any Driver, options: Options = .init()) async throws -> TestReport {
        try await run(path: path, drivers: [driver], deviceLabels: nil, options: options)
    }

    /// Run flows across a pool of drivers with dynamic work distribution: every
    /// driver pulls from one shared queue, so faster devices take more flows and
    /// none sits idle. Reports preserve the original flow order.
    public func run(path: String,
                    drivers: [any Driver],
                    deviceLabels: [String?]? = nil,
                    options: Options = .init()) async throws -> TestReport {
        guard !drivers.isEmpty else { throw ExecutionError.missingFile("no devices in the pool") }

        let files = FlowValidator.flowFiles(at: path)
        guard !files.isEmpty else { throw ExecutionError.missingFile(path) }

        var flows: [Flow] = []
        for file in files {
            let flow = try FlowParser.parse(contentsOf: file)
            if matchesTags(flow.tags, options: options) { flows.append(flow) }
        }

        let labels = deviceLabels ?? Array(repeating: options.device, count: drivers.count)

        // Track each driver before setup so teardown can also clean a backend
        // whose setup partially starts host resources and then throws.
        var initialized: [any Driver] = []
        var collected: [(index: Int, result: FlowResult)] = []
        do {
            for driver in drivers {
                initialized.append(driver)
                try await driver.setUp()
            }
            if let appFile = options.appFile {
                for driver in drivers { try await driver.installApp(appFile) }
            }

            let queue = WorkQueue(flows)
            let executor = FlowExecutor()
            await withTaskGroup(of: [(Int, FlowResult)].self) { group in
                for (worker, driver) in drivers.enumerated() {
                    let device = worker < labels.count ? labels[worker] : options.device
                    let executorOptions = options.executorOptions
                    group.addTask {
                        var local: [(Int, FlowResult)] = []
                        while let item = await queue.next() {
                            let result = await executor.execute(item.flow, on: driver,
                                                                device: device, options: executorOptions)
                            local.append((item.index, result))
                        }
                        return local
                    }
                }
                for await batch in group { collected.append(contentsOf: batch) }
            }
        } catch {
            await tearDown(initialized)
            throw error
        }

        await tearDown(initialized)

        let ordered = collected.sorted { $0.index < $1.index }.map { $0.result }
        let report = TestReport(flows: ordered, startedAtEpochMs: Int64(Date().timeIntervalSince1970 * 1000))
        if let outputDir = options.outputDir {
            try writeReports(report, formats: options.formats, to: outputDir)
        }
        return report
    }

    /// Best-effort teardown in reverse startup order, mirroring stack unwinding
    /// for layered host resources.
    private func tearDown(_ drivers: [any Driver]) async {
        for driver in drivers.reversed() { try? await driver.tearDown() }
    }

    private func matchesTags(_ tags: [String], options: Options) -> Bool {
        let tagSet = Set(tags)
        if !options.excludeTags.isEmpty && !tagSet.isDisjoint(with: Set(options.excludeTags)) { return false }
        if !options.tags.isEmpty && tagSet.isDisjoint(with: Set(options.tags)) { return false }
        return true
    }

    private func writeReports(_ report: TestReport, formats: [String], to dir: String) throws {
        try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        for format in formats {
            switch format.lowercased() {
            case "json":
                try write(JSONReportGenerator().generate(report), to: dir, name: "report.json")
            case "junit", "xml":
                try write(JUnitReportGenerator().generate(report), to: dir, name: "report.xml")
            case "html":
                try write(HTMLReportGenerator().generate(report), to: dir, name: "report.html")
            case "allure":
                for file in AllureReportGenerator().resultFiles(report) {
                    try write(file.content, to: dir, name: file.name)
                }
            default:
                break
            }
        }
    }

    private func write(_ content: String, to dir: String, name: String) throws {
        // Non-atomic: String.write(atomically:) can route through the unimplemented
        // FileManager.replaceItemAt on Windows swift-corelibs.
        let url = URL(fileURLWithPath: dir).appendingPathComponent(name)
        try content.write(to: url, atomically: false, encoding: .utf8)
    }
}

/// A shared, thread-safe queue that hands out each flow exactly once. Pool workers
/// pull from it concurrently, which is what makes the distribution dynamic.
private actor WorkQueue {
    private let flows: [Flow]
    private var index = 0
    init(_ flows: [Flow]) { self.flows = flows }
    func next() -> (index: Int, flow: Flow)? {
        guard index < flows.count else { return nil }
        defer { index += 1 }
        return (index, flows[index])
    }
}
