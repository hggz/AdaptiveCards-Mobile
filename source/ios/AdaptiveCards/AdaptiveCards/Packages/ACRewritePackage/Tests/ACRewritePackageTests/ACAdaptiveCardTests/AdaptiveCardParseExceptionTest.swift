import XCTest
@testable import ACRewritePackage

class AdaptiveCardParseExceptionTests: XCTestCase {

    func testAdaptiveCardParseException() {
        let errorMessage = "error message"
        // Assuming the Swift initializer matches the C++ constructor:
        let parseException = AdaptiveCardParseException(statusCode: .invalidJson, message: errorMessage)
        
        // Assuming these methods/properties exist on the Swift side:
        XCTAssertEqual(parseException.what(), errorMessage)
        XCTAssertEqual(parseException.getStatusCode(), .invalidJson)
        XCTAssertEqual(parseException.getReason(), errorMessage)
    }
    
    func testAdaptiveCardParseWarning() {
        let errorMessage = "error message"
        let parseWarning = AdaptiveCardParseWarning(statusCode: .assetLoadFailed, message: errorMessage)
        
        XCTAssertEqual(parseWarning.getStatusCode(), .assetLoadFailed)
        XCTAssertEqual(parseWarning.getReason(), errorMessage)
    }
}
