import Foundation

struct AdaptiveBase64Util {
    
    private static let base64EncodeTable: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")
    
    private static let base64DecodeTable: [UInt8] = {
        var table = [UInt8](repeating: 0xFF, count: 128)
        for (i, c) in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".enumerated() {
            table[Int(c.asciiValue!)] = UInt8(i)
        }
        return table
    }()
    
    static func decodedLength(of input: String) -> Int {
        let numEq = input.reversed().prefix { $0 == "=" }.count
        return ((6 * input.count) / 8) - numEq
    }
    
    static func encodedLength(of length: Int) -> Int {
        return ((length + 2 - ((length + 2) % 3)) / 3) * 4
    }
    
    static func stripPadding(_ input: inout String) {
        input = input.trimmingCharacters(in: CharacterSet(charactersIn: "="))
    }
    
    private static func a3ToA4(_ a3: [UInt8]) -> [UInt8] {
        return [
            (a3[0] & 0xfc) >> 2,
            ((a3[0] & 0x03) << 4) + ((a3[1] & 0xf0) >> 4),
            ((a3[1] & 0x0f) << 2) + ((a3[2] & 0xc0) >> 6),
            a3[2] & 0x3f
        ]
    }
    
    private static func a4ToA3(_ a4: [UInt8]) -> [UInt8] {
        return [
            (a4[0] << 2) + ((a4[1] & 0x30) >> 4),
            ((a4[1] & 0x0f) << 4) + ((a4[2] & 0x3c) >> 2),
            ((a4[2] & 0x03) << 6) + a4[3]
        ]
    }
    
    private static func b64Lookup(_ c: Character) -> UInt8 {
        guard let asciiValue = c.asciiValue, asciiValue < base64DecodeTable.count else {
            return 0xFF
        }
        return base64DecodeTable[Int(asciiValue)]
    }
    
    static func encode(_ input: [UInt8]) -> String {
        var output = ""
        var a3 = [UInt8](repeating: 0, count: 3)
        var a4 = [UInt8](repeating: 0, count: 4)
        
        var inputIndex = 0
        while inputIndex < input.count {
            let remaining = min(3, input.count - inputIndex)
            a3[0..<remaining] = input[inputIndex..<inputIndex+remaining]
            a3.replaceSubrange(remaining..<3, with: repeatElement(0, count: 3 - remaining))
            inputIndex += remaining
            
            a4 = a3ToA4(a3)
            for i in 0..<4 {
                output.append(base64EncodeTable[Int(a4[i])])
            }
            
            if remaining < 3 {
                output.replaceSubrange(output.index(output.endIndex, offsetBy: -(3 - remaining))..<output.endIndex, with: repeatElement("=", count: 3 - remaining))
                break
            }
        }
        
        return output
    }
    
    static func decode(_ input: String) -> [UInt8]? {
        var output: [UInt8] = []
        var a4 = [UInt8](repeating: 0, count: 4)
        var a3 = [UInt8](repeating: 0, count: 3)
        
        var inputIndex = 0
        while inputIndex < input.count {
            let remaining = min(4, input.count - inputIndex)
            let substring = input[input.index(input.startIndex, offsetBy: inputIndex)..<input.index(input.startIndex, offsetBy: inputIndex+remaining)]
            a4 = substring.map { b64Lookup($0) }
            inputIndex += remaining
            
            if a4.contains(0xFF) {
                return nil
            }
            
            a3 = a4ToA3(a4)
            output.append(contentsOf: a3.prefix(remaining - 1))
        }
        
        return output
    }
    
    static func extractData(fromUri dataUri: String) -> String {
        guard let commaIndex = dataUri.lastIndex(of: ",") else {
            return dataUri
        }
        return String(dataUri[dataUri.index(after: commaIndex)...])
    }
}
