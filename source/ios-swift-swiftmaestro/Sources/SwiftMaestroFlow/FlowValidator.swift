// Port of: pkg/validator (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// A single problem found by the pre-flight validator.
public struct ValidationIssue: Sendable, Equatable, CustomStringConvertible {
    public enum Kind: String, Sendable, Equatable {
        case syntax
        case missingFile
        case circularDependency
    }

    public var kind: Kind
    public var message: String
    public var flowPath: String?

    public init(kind: Kind, message: String, flowPath: String? = nil) {
        self.kind = kind
        self.message = message
        self.flowPath = flowPath
    }

    public var description: String {
        let location = flowPath.map { "\($0): " } ?? ""
        return "[\(kind.rawValue)] \(location)\(message)"
    }
}

/// The outcome of validating one flow file or a directory of flows.
public struct ValidationResult: Sendable, Equatable {
    public var issues: [ValidationIssue]
    public init(issues: [ValidationIssue] = []) { self.issues = issues }
    /// True when no issues were found.
    public var isValid: Bool { issues.isEmpty }
    /// Convenience filter by issue kind.
    public func issues(ofKind kind: ValidationIssue.Kind) -> [ValidationIssue] {
        issues.filter { $0.kind == kind }
    }
}

/// Pre-flight validation, run before any device work: flow syntax errors,
/// circular `runFlow` dependencies, and missing referenced files
/// (`runFlow`/`runScript`/`addMedia`).
public struct FlowValidator {
    public init() {}

    /// Validate a single flow file or every `*.yaml`/`*.yml` under a directory.
    public func validate(path: String) -> ValidationResult {
        var issues: [ValidationIssue] = []

        let files = Self.flowFiles(at: path)
        if files.isEmpty {
            issues.append(ValidationIssue(kind: .missingFile,
                                          message: "no flow files (*.yaml/*.yml) found",
                                          flowPath: path))
            return ValidationResult(issues: issues)
        }

        var parsed: [(path: String, flow: Flow)] = []
        for file in files {
            do {
                let flow = try FlowParser.parse(contentsOf: file)
                parsed.append((file, flow))
            } catch {
                issues.append(ValidationIssue(kind: .syntax,
                                              message: String(describing: error),
                                              flowPath: file))
            }
        }

        for entry in parsed {
            checkReferences(flow: entry.flow, file: entry.path, into: &issues)
        }

        detectCycles(startFiles: parsed.map { $0.path }, into: &issues)

        issues.sort { lhs, rhs in
            if (lhs.flowPath ?? "") != (rhs.flowPath ?? "") { return (lhs.flowPath ?? "") < (rhs.flowPath ?? "") }
            if lhs.kind.rawValue != rhs.kind.rawValue { return lhs.kind.rawValue < rhs.kind.rawValue }
            return lhs.message < rhs.message
        }
        return ValidationResult(issues: issues)
    }

    // MARK: - Missing-file checks

    private func checkReferences(flow: Flow, file: String, into issues: inout [ValidationIssue]) {
        let baseDir = (file as NSString).deletingLastPathComponent
        walk(flow.steps, baseDir: baseDir, file: file, into: &issues)
    }

    private func walk(_ steps: [MaestroStep], baseDir: String, file: String, into issues: inout [ValidationIssue]) {
        for step in steps {
            switch step {
            case .runFlow(let s):
                if let ref = s.file, !fileExists(ref, baseDir) {
                    issues.append(ValidationIssue(kind: .missingFile,
                                                  message: "runFlow references missing file: \(ref)",
                                                  flowPath: file))
                }
                walk(s.commands, baseDir: baseDir, file: file, into: &issues)
            case .runScript(let s):
                if !fileExists(s.file, baseDir) {
                    issues.append(ValidationIssue(kind: .missingFile,
                                                  message: "runScript references missing file: \(s.file)",
                                                  flowPath: file))
                }
            case .addMedia(let files, _):
                for ref in files where !fileExists(ref, baseDir) {
                    issues.append(ValidationIssue(kind: .missingFile,
                                                  message: "addMedia references missing file: \(ref)",
                                                  flowPath: file))
                }
            case .`repeat`(let s):
                walk(s.commands, baseDir: baseDir, file: file, into: &issues)
            case .retry(let s):
                walk(s.commands, baseDir: baseDir, file: file, into: &issues)
            default:
                break
            }
        }
    }

    // MARK: - Circular runFlow detection

    private func detectCycles(startFiles: [String], into issues: inout [ValidationIssue]) {
        var cache: [String: Flow] = [:]
        func load(_ path: String) -> Flow? {
            if let f = cache[path] { return f }
            guard FileManager.default.fileExists(atPath: path),
                  let f = try? FlowParser.parse(contentsOf: path) else { return nil }
            cache[path] = f
            return f
        }

        var fullyProcessed = Set<String>()
        var reported = Set<String>()

        func dfs(_ path: String, stack: inout [String], onStack: inout Set<String>) {
            onStack.insert(path)
            stack.append(path)
            defer {
                stack.removeLast()
                onStack.remove(path)
                fullyProcessed.insert(path)
            }
            guard let flow = load(path) else { return }
            let baseDir = (path as NSString).deletingLastPathComponent
            for ref in Self.runFlowFileRefs(flow.steps, baseDir: baseDir) {
                if onStack.contains(ref) {
                    let cycle = Array(stack.drop(while: { $0 != ref })) + [ref]
                    let key = Set(cycle).sorted().joined(separator: "|")
                    if !reported.contains(key) {
                        reported.insert(key)
                        let names = cycle.map { ($0 as NSString).lastPathComponent }.joined(separator: " -> ")
                        issues.append(ValidationIssue(kind: .circularDependency,
                                                      message: "circular runFlow dependency: \(names)",
                                                      flowPath: path))
                    }
                } else if !fullyProcessed.contains(ref) {
                    dfs(ref, stack: &stack, onStack: &onStack)
                }
            }
        }

        for file in startFiles where !fullyProcessed.contains(file) {
            var stack: [String] = []
            var onStack: Set<String> = []
            dfs(file, stack: &stack, onStack: &onStack)
        }
    }

    /// Absolute, resolved `runFlow` file references reachable from these steps
    /// (following inline `runFlow`/`repeat`/`retry` command lists).
    static func runFlowFileRefs(_ steps: [MaestroStep], baseDir: String) -> [String] {
        var refs: [String] = []
        for step in steps {
            switch step {
            case .runFlow(let s):
                if let file = s.file { refs.append(resolve(file, baseDir)) }
                refs.append(contentsOf: runFlowFileRefs(s.commands, baseDir: baseDir))
            case .`repeat`(let s):
                refs.append(contentsOf: runFlowFileRefs(s.commands, baseDir: baseDir))
            case .retry(let s):
                refs.append(contentsOf: runFlowFileRefs(s.commands, baseDir: baseDir))
            default:
                break
            }
        }
        return refs
    }

    // MARK: - Filesystem helpers

    private func fileExists(_ ref: String, _ baseDir: String) -> Bool {
        FileManager.default.fileExists(atPath: Self.resolve(ref, baseDir))
    }

    public static func resolve(_ ref: String, _ baseDir: String) -> String {
        if (ref as NSString).isAbsolutePath { return (ref as NSString).standardizingPath }
        // Windows drive-absolute paths ("C:\...") are not caught by isAbsolutePath.
        if ref.count >= 2, ref[ref.index(ref.startIndex, offsetBy: 1)] == ":" { return ref }
        if baseDir.isEmpty { return ref }
        return URL(fileURLWithPath: baseDir).appendingPathComponent(ref).standardizedFileURL.path
    }

    public static func flowFiles(at path: String) -> [String] {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: path, isDirectory: &isDir) else { return [] }
        if !isDir.boolValue {
            return [path]
        }
        guard let enumerator = fm.enumerator(atPath: path) else { return [] }
        var out: [String] = []
        for case let rel as String in enumerator where rel.hasSuffix(".yaml") || rel.hasSuffix(".yml") {
            out.append(URL(fileURLWithPath: path).appendingPathComponent(rel).path)
        }
        return out.sorted()
    }
}
