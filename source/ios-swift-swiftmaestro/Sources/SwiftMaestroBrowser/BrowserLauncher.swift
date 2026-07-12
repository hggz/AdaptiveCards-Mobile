// Port of: pkg/browser (launch + discovery) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import AsyncHTTPClient
import NIOCore
import SwiftMaestroDriver
import SwiftMaestroProcess

/// How to start a headless browser for the CDP driver.
public struct BrowserLaunchConfig: Sendable {
    /// Explicit browser binary; when nil, `BrowserLauncher.findBrowserExecutable()`
    /// probes the common Chrome/Chromium/Edge locations for the host OS.
    public var executablePath: String?
    public var headless: Bool
    /// 0 lets the browser choose a free debugging port (read back from
    /// `DevToolsActivePort`); a fixed port is honored when non-zero.
    public var remoteDebuggingPort: Int
    /// Profile directory; when nil a throwaway temp dir is created.
    public var userDataDir: String?
    public var initialURL: String
    public var extraArguments: [String]
    public var startupTimeoutMs: Int

    public init(executablePath: String? = nil,
                headless: Bool = true,
                remoteDebuggingPort: Int = 0,
                userDataDir: String? = nil,
                initialURL: String = "about:blank",
                extraArguments: [String] = [],
                startupTimeoutMs: Int = 20_000) {
        self.executablePath = executablePath
        self.headless = headless
        self.remoteDebuggingPort = remoteDebuggingPort
        self.userDataDir = userDataDir
        self.initialURL = initialURL
        self.extraArguments = extraArguments
        self.startupTimeoutMs = startupTimeoutMs
    }
}

/// The result of launching a browser: the running process and its browser-level
/// CDP WebSocket URL.
public struct BrowserEndpoint: Sendable {
    public let browserWebSocketURL: String
    public let process: LaunchedProcess?
    public let userDataDir: String?
}

/// Launches a Chromium-family browser headless and discovers its CDP endpoint.
public struct BrowserLauncher: Sendable {
    private let runner: ProcessRunner
    private let http: HTTPClient

    public init(runner: ProcessRunner = ProcessRunner(), http: HTTPClient = .shared) {
        self.runner = runner
        self.http = http
    }

    public func launch(_ config: BrowserLaunchConfig) async throws -> BrowserEndpoint {
        guard let executable = config.executablePath ?? Self.findBrowserExecutable() else {
            throw DriverError.notSupported("no Chrome/Chromium/Edge executable found for the web (CDP) driver")
        }
        let dataDir = config.userDataDir ?? Self.makeTempProfileDir()

        var arguments: [String] = []
        if config.headless { arguments.append("--headless=new") }
        arguments.append(contentsOf: [
            "--disable-gpu",
            "--remote-debugging-address=127.0.0.1",
            "--remote-debugging-port=\(config.remoteDebuggingPort)",
            "--user-data-dir=\(dataDir)",
            "--no-first-run",
            "--no-default-browser-check",
            "--disable-extensions",
            "--disable-background-networking",
            "--disable-sync",
        ])
        arguments.append(contentsOf: config.extraArguments)
        arguments.append(config.initialURL)

        let process = try await runner.spawn(executable, arguments: arguments)
        let wsURL = try await discoverBrowserWebSocket(dataDir: dataDir, deadlineMs: config.startupTimeoutMs)
        return BrowserEndpoint(browserWebSocketURL: wsURL, process: process, userDataDir: dataDir)
    }

    // MARK: - Discovery

    /// Prefer the `DevToolsActivePort` file the browser writes into its profile
    /// (`<port>\n<ws-path>`): it appears exactly when the endpoint is ready and
    /// avoids a port race. Fall back to the `/json/version` HTTP endpoint if the
    /// file only carries a port.
    ///
    /// We deliberately do NOT treat launcher-process exit as failure: on Windows
    /// the spawned browser binary routinely hands off to a detached browser
    /// process and exits 0 immediately, while the real browser keeps running and
    /// publishes the endpoint. Discovery is therefore purely file/HTTP driven.
    private func discoverBrowserWebSocket(dataDir: String, deadlineMs: Int) async throws -> String {
        let portFile = URL(fileURLWithPath: dataDir).appendingPathComponent("DevToolsActivePort").path
        let start = Date()

        while Date().timeIntervalSince(start) * 1000 < Double(deadlineMs) {
            if let raw = try? String(contentsOfFile: portFile, encoding: .utf8) {
                let normalized = raw.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
                let lines = normalized.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
                if let first = lines.first, let port = Int(first.trimmingCharacters(in: .whitespaces)) {
                    if lines.count > 1 {
                        let path = lines[1].trimmingCharacters(in: .whitespaces)
                        return "ws://127.0.0.1:\(port)\(path.hasPrefix("/") ? path : "/" + path)"
                    }
                    // Only a port — ask /json/version for the exact ws URL.
                    if let wsURL = try? await fetchWebSocketURL(port: port) { return wsURL }
                }
            }
            await cdpNap(ms: 100)
        }
        throw DriverError.toolFailure("CDP endpoint (DevToolsActivePort) not ready within \(deadlineMs)ms")
    }

    private func fetchWebSocketURL(port: Int) async throws -> String {
        var request = HTTPClientRequest(url: "http://127.0.0.1:\(port)/json/version")
        request.method = .GET
        let response = try await http.execute(request, timeout: .seconds(2))
        guard response.status == .ok else {
            throw DriverError.toolFailure("/json/version returned HTTP \(response.status.code)")
        }
        let buffer = try await response.body.collect(upTo: 1 << 20)
        let data = Data(buffer: buffer)
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let url = object["webSocketDebuggerUrl"] as? String else {
            throw DriverError.toolFailure("/json/version had no webSocketDebuggerUrl")
        }
        return url
    }

    // MARK: - Browser discovery

    /// Locate a Chromium-family browser. Honors `SWIFTMAESTRO_BROWSER` /
    /// `CHROME_PATH` / `CHROMIUM_PATH`, then probes well-known install paths, then
    /// falls back to a PATH lookup.
    public static func findBrowserExecutable() -> String? {
        let environment = ProcessInfo.processInfo.environment
        for key in ["SWIFTMAESTRO_BROWSER", "CHROME_PATH", "CHROMIUM_PATH"] {
            if let path = environment[key], !path.isEmpty, FileManager.default.fileExists(atPath: path) {
                return path
            }
        }

        #if os(Windows)
        let candidates = [
            "C:/Program Files/Google/Chrome/Application/chrome.exe",
            "C:/Program Files (x86)/Google/Chrome/Application/chrome.exe",
            "C:/Program Files/Microsoft/Edge/Application/msedge.exe",
            "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe",
        ]
        let names = ["chrome", "msedge", "chromium"]
        #elseif os(macOS)
        let candidates = [
            "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
            "/Applications/Chromium.app/Contents/MacOS/Chromium",
            "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
        ]
        let names = ["google-chrome", "chromium", "microsoft-edge"]
        #else
        let candidates = [
            "/usr/bin/google-chrome",
            "/usr/bin/google-chrome-stable",
            "/usr/bin/chromium",
            "/usr/bin/chromium-browser",
            "/usr/bin/microsoft-edge",
            "/snap/bin/chromium",
        ]
        let names = ["google-chrome", "google-chrome-stable", "chromium", "chromium-browser", "microsoft-edge"]
        #endif

        for candidate in candidates where FileManager.default.fileExists(atPath: candidate) {
            return candidate
        }
        for name in names {
            if let resolved = ProcessRunner.resolveExecutable(name) { return resolved }
        }
        return nil
    }

    private static func makeTempProfileDir() -> String {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("swiftmaestro-browser-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.path
    }
}
