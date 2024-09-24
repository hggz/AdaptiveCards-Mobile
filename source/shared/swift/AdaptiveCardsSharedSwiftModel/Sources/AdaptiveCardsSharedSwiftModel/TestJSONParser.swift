import Foundation

class TestJSONParser {
    
    // Set of files to exclude from parsing
    var setOfExcludedFiles: Set<String> = []
    
    // Set of files expected to fail parsing
    var setOfExpectedToFailFiles: Set<String> = []
    
    // Public function to initiate the parsing and rendering process
    func parseAllJSONFiles(in directory: String) {
        let fileManager = FileManager.default
        parseAndRenderDFS(rootPath: directory, fileManager: fileManager)
    }

    // Recursive DFS function to parse and render
    private func parseAndRenderDFS(rootPath: String, fileManager: FileManager) {
        do {
            // Get directory contents (files and directories)
            let directoryContents = try fileManager.contentsOfDirectory(atPath: rootPath)
            
            // Files list
            var filesList: [String] = []
            
            // Iterate through contents and recurse if directory, otherwise add to files list
            for path in directoryContents {
                let resourcePath = (rootPath as NSString).appendingPathComponent(path)
                var isDirectory: ObjCBool = false
                
                if fileManager.fileExists(atPath: resourcePath, isDirectory: &isDirectory) {
                    let displayName = (path as NSString).lastPathComponent
                    // Skip certain directories
                    if isDirectory.boolValue && !(displayName == "HostConfig" || displayName == "Templates") {
                        parseAndRenderDFS(rootPath: resourcePath, fileManager: fileManager)
                    } else if (resourcePath as NSString).pathExtension == "json" {
                        filesList.append(resourcePath)
                    }
                }
            }
            
            // Test files in the current directory
            for filePath in filesList {
                do {
                    let fileContent = try String(contentsOfFile: filePath, encoding: .utf8)
                    let fileName = (filePath as NSString).lastPathComponent
                    
                    if !setOfExcludedFiles.contains(fileName) {
                        if let cardParseResult = parseJSON(fileContent: fileContent, fileName: fileName, filePath: filePath) {
                            if setOfExpectedToFailFiles.contains(fileName) {
                                // Handle expected failure cases
                                print("Expected failure: \(fileName)")
                            } else {
                                assertParsing(parseResult: cardParseResult, fileName: fileName)
                                do {
                                    if let renderResult = renderCard(cardParseResult.card) {
                                        assertRendering(renderResult: renderResult, fileName: fileName)
                                    }
                                } catch {
                                    print("Rendering Exception in \(fileName): \(error)")
                                }
                            }
                        }
                    }
                } catch {
                    print("Failed to read file at path \(filePath): \(error)")
                }
            }
            
        } catch {
            print("Failed to list directory contents at \(rootPath): \(error)")
        }
    }
    
    // JSON Parsing function (dummy placeholder, replace with your actual JSON parser)
    func parseJSON(fileContent: String, fileName: String, filePath: String) -> CardParseResult? {
        do {
            guard let payloadData = fileContent.data(using: .utf8) else {
                debugPrint("DATA PARSE ERROR: \(fileName)\n\(filePath)")
                return CardParseResult(isValid: false, card: fileName, parseErrors: [NSError(domain: "invalid parse: \(filePath)", code: 999)])
            }
            let adaptiveCard = try JSONDecoder().decode(AdaptiveCard.self, from: payloadData)
            return CardParseResult(isValid: true, card: fileName)
        } catch {
            debugPrint("PARSE ERROR: \(fileName)\n\(filePath)\n\(error)")
            return CardParseResult(isValid: false, card: fileName, parseErrors: [error as NSError])
        }
    }
    
    // Rendering function (dummy placeholder, replace with your actual renderer)
    func renderCard(_ card: String) -> RenderResult? {
        // Replace this with actual rendering logic
        return RenderResult(renderedCard: "renderedCard") // Example placeholder result
    }
    
    // Asserting parsing (can be customized or omitted)
    func assertParsing(parseResult: CardParseResult, fileName: String) {
        if !parseResult.isValid {
            let errorMessages = parseResult.parseErrors.map { $0.localizedDescription }
            let errorMessage = errorMessages.joined(separator: ", ")
            print("Parsing failed for \(fileName): \(errorMessage)")
        } else {
            print("Parsing succeeded for \(fileName)")
        }
    }
    
    // Asserting rendering (dummy, replace with actual assertion logic)
    func assertRendering(renderResult: RenderResult, fileName: String) {
        // Add your rendering assertions here
        print("Rendering succeeded for \(fileName)")
    }
}

// Placeholder structs for parsed results and render results (replace with actual types)
struct CardParseResult {
    var isValid: Bool
    var card: String
    var parseErrors: [NSError] = []
}

struct RenderResult {
    var renderedCard: String
}
