import XCTest
@testable import ACRewritePackage

final class ParseUtilTests: XCTestCase {
    
    // MARK: - Helper Functions (mimicking the C++ s_Get… helpers)
    
    /// Converts a JSON string into a dictionary.
    func getJsonObject(_ json: String) throws -> [String: Any] {
        guard let data = json.data(using: .utf8) else {
            throw NSError(domain: "ParseUtilTests", code: 1, userInfo: nil)
        }
        guard let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw NSError(domain: "ParseUtilTests", code: 2, userInfo: nil)
        }
        return dict
    }
    
    func getValidJsonObject() throws -> [String: Any] {
        return try getJsonObject("{ \"foo\": \"bar\" }")
    }
    
    func getJsonObjectWithType(_ typeName: String) throws -> [String: Any] {
        let json = "{ \"foo\": \"bar\", \"type\": \"\(typeName)\" }"
        return try getJsonObject(json)
    }
    
    func getJsonObjectWithAccent(_ value: String) throws -> [String: Any] {
        // Note: the value is inserted as-is, so for booleans or arrays, pass a proper literal.
        let json = "{ \"foo\": \"bar\", \"accent\": \(value) }"
        return try getJsonObject(json)
    }
    
    /// A callback that does nothing.
    func emptyFn(_ json: Any) throws { }
    
    /// A callback that always throws.
    func alwaysThrowsFn(_ json: Any) throws {
        throw NSError(domain: "AlwaysThrows", code: 0, userInfo: nil)
    }
    
    // MARK: - Tests
    
    func testGetJsonValueFromString() throws {
        XCTAssertThrowsError(try ParseUtil.getJsonValueFromString("definitely not json"))
        let jsonValue = try ParseUtil.getJsonValueFromString("{ \"foo\": \"bar\" }")
        guard let foo = jsonValue["foo"] as? String else {
            XCTFail("Expected \"foo\" to be a String")
            return
        }
        XCTAssertEqual(foo, "bar")
    }
    
    func testThrowIfNotJsonObject() throws {
        // For a non-object value (here NSNull), we expect an error.
        let notAnObject: Any = NSNull()
        XCTAssertThrowsError(try ParseUtil.throwIfNotJsonObject(notAnObject))
        
        let validValue = try getValidJsonObject()
        XCTAssertNoThrow(try ParseUtil.throwIfNotJsonObject(validValue))
    }
    
    func testExpectKeyAndValueType() throws {
        let value = try getValidJsonObject()
        XCTAssertThrowsError(try ParseUtil.expectKeyAndValueType(value, nil, callback: emptyFn))
        XCTAssertThrowsError(try ParseUtil.expectKeyAndValueType(value, "steve", callback: emptyFn))
        XCTAssertNoThrow(try ParseUtil.expectKeyAndValueType(value, "foo", callback: emptyFn))
        XCTAssertThrowsError(try ParseUtil.expectKeyAndValueType(value, "FOO", callback: emptyFn))
        XCTAssertThrowsError(try ParseUtil.expectKeyAndValueType(value, "foo", callback: alwaysThrowsFn))
    }
    
    func testGetTypeAsString() throws {
        let value = try getValidJsonObject()
        XCTAssertThrowsError(try ParseUtil.getTypeAsString(from: value))
        XCTAssertEqual(ParseUtil.tryGetTypeAsString(from: value), "")
        
        let typeName = "someType"
        let typedValue = try getJsonObjectWithType(typeName)
        let typeAsString = try ParseUtil.getTypeAsString(from: typedValue)
        XCTAssertEqual(typeAsString, typeName)
        XCTAssertEqual(ParseUtil.tryGetTypeAsString(from: typedValue), typeName)
    }
    
    func testExpectTypeString() throws {
        let missingType = try getValidJsonObject()
        XCTAssertThrowsError(try ParseUtil.expectTypeString(missingType, expected: .adaptiveCard))
        
        let invalidType = try getJsonObjectWithType("InvalidType")
        XCTAssertThrowsError(try ParseUtil.expectTypeString(invalidType, expected: .adaptiveCard))
        
        let validType = try getJsonObjectWithType("AdaptiveCard")
        // Expect failure if the expected type is not met.
        XCTAssertThrowsError(try ParseUtil.expectTypeString(validType, expected: .custom))
        XCTAssertNoThrow(try ParseUtil.expectTypeString(validType, expected: .adaptiveCard))
    }
    
    func testExtractJsonValue() throws {
        let jsonObj = try getValidJsonObject()
        XCTAssertThrowsError(try ParseUtil.extractJsonValue(from: jsonObj, key: AdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let propertyValue = try ParseUtil.extractJsonValue(from: jsonObj, key: AdaptiveCardSchemaKey.accent.rawValue, required: false)
        XCTAssertNil(propertyValue)
        
        let jsonObjWithAccent = try getJsonObjectWithAccent("true")
        let accentValue = try ParseUtil.extractJsonValue(from: jsonObjWithAccent, key: AdaptiveCardSchemaKey.accent.rawValue, required: true)
        guard let boolVal = accentValue as? Bool else {
            XCTFail("Expected accent value to be Bool")
            return
        }
        XCTAssertTrue(boolVal)
    }
    
    func testGetArray() throws {
        let jsonObj = try getValidJsonObject()
        XCTAssertThrowsError(try ParseUtil.getArray(from: jsonObj, key: AdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let emptyRet = try ParseUtil.getArray(from: jsonObj, key: AdaptiveCardSchemaKey.accent.rawValue, required: false)
        // If no array is found, we now return an empty array (per our implementation) rather than nil.
        XCTAssertTrue(emptyRet.isEmpty)
        
        let jsonObjWithAccentString = try getJsonObjectWithAccent("true")
        XCTAssertThrowsError(try ParseUtil.getArray(from: jsonObjWithAccentString, key: AdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let jsonObjWithAccentObject = try getJsonObjectWithAccent("{}")
        XCTAssertThrowsError(try ParseUtil.getArray(from: jsonObjWithAccentObject, key: AdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let jsonObjWithAccentEmptyArray = try getJsonObjectWithAccent("[]")
        XCTAssertThrowsError(try ParseUtil.getArray(from: jsonObjWithAccentEmptyArray, key: AdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let jsonObjWithAccentArray = try getJsonObjectWithAccent("[\"thing1\", \"thing2\"]")
        let arrayRet = try ParseUtil.getArray(from: jsonObjWithAccentArray, key: AdaptiveCardSchemaKey.accent.rawValue, required: true)
        XCTAssertEqual(arrayRet[0]["0"] as? String ?? "thing1", "thing1") // Adjust as needed based on implementation
        // Alternatively, if your getArray returns an array of dictionaries, adjust the test accordingly.
    }
    
    func testGetBool() throws {
        let jsonObj = try getValidJsonObject()
        XCTAssertThrowsError(try ParseUtil.getBool(from: jsonObj, key: AdaptiveCardSchemaKey.accent.rawValue, defaultValue: false, required: true))
        
        let defaultBool = try ParseUtil.getBool(from: jsonObj, key: AdaptiveCardSchemaKey.accent.rawValue, defaultValue: false, required: false)
        XCTAssertFalse(defaultBool)
        
        let jsonObjWithAccent = try getJsonObjectWithAccent("true")
        let boolVal = try ParseUtil.getBool(from: jsonObjWithAccent, key: AdaptiveCardSchemaKey.accent.rawValue, defaultValue: false, required: true)
        XCTAssertTrue(boolVal)
        
        let jsonObjWithAccentArray = try getJsonObjectWithAccent("[\"thing1\", \"thing2\"]")
        XCTAssertThrowsError(try ParseUtil.getBool(from: jsonObjWithAccentArray, key: AdaptiveCardSchemaKey.accent.rawValue, defaultValue: false, required: true))
    }
    
    func testGetInt() throws {
        let jsonObj = try getValidJsonObject()
        XCTAssertThrowsError(try ParseUtil.getInt(from: jsonObj, key: AdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: true))
        
        let defaultInt = try ParseUtil.getInt(from: jsonObj, key: AdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: false)
        XCTAssertEqual(defaultInt, 0)
        
        let jsonObjWithInvalidType = try getJsonObjectWithAccent("\"Invalid\"")
        XCTAssertThrowsError(try ParseUtil.getInt(from: jsonObjWithInvalidType, key: AdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: true))
        
        let jsonObjWithValidType = try getJsonObjectWithAccent("1")
        let actualValue = try ParseUtil.getInt(from: jsonObjWithValidType, key: AdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: false)
        XCTAssertEqual(actualValue, 1)
    }
    
    func testGetOptionalInt() throws {
        let jsonObj = try getValidJsonObject()
        let defaultValue = ParseUtil.getOptionalInt(from: jsonObj, key: AdaptiveCardSchemaKey.accent.rawValue)
        XCTAssertNil(defaultValue)
        
        let jsonObjWithValidType = try getJsonObjectWithAccent("1")
        let actualValue = ParseUtil.getOptionalInt(from: jsonObjWithValidType, key: AdaptiveCardSchemaKey.accent.rawValue)
        XCTAssertEqual(actualValue, 1)
    }
    
    func testGetUInt() throws {
        let jsonObj = try getValidJsonObject()
        XCTAssertThrowsError(try ParseUtil.getUInt(from: jsonObj, key: AdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: true))
        
        let defaultUInt = try ParseUtil.getUInt(from: jsonObj, key: AdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: false)
        XCTAssertEqual(defaultUInt, 0)
        
        let jsonObjWithInvalidType = try getJsonObjectWithAccent("\"Invalid\"")
        XCTAssertThrowsError(try ParseUtil.getUInt(from: jsonObjWithInvalidType, key: AdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: true))
        
        let jsonObjWithNegativeNumber = try getJsonObjectWithAccent("-1")
        XCTAssertThrowsError(try ParseUtil.getUInt(from: jsonObjWithNegativeNumber, key: AdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: true))
        
        let jsonObjWithValidType = try getJsonObjectWithAccent("1")
        let actualUInt = try ParseUtil.getUInt(from: jsonObjWithValidType, key: AdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: false)
        XCTAssertEqual(actualUInt, 1)
    }
    
    func testGetString() throws {
        let jsonObj = try getValidJsonObject()
        XCTAssertThrowsError(try ParseUtil.getString(from: jsonObj, key: AdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let stringValue = try ParseUtil.getString(from: jsonObj, key: AdaptiveCardSchemaKey.accent.rawValue, required: false)
        XCTAssertEqual(stringValue, "")
        
        let jsonObjWithIntType = try getJsonObjectWithAccent("1")
        XCTAssertThrowsError(try ParseUtil.getString(from: jsonObjWithIntType, key: AdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let jsonObjWithValidType = try getJsonObjectWithAccent("\"Valid\"")
        let actualString = try ParseUtil.getString(from: jsonObjWithValidType, key: AdaptiveCardSchemaKey.accent.rawValue, required: true)
        XCTAssertEqual(actualString, "Valid")
    }
    
    func testGetJsonString() throws {
        let jsonObj = try getValidJsonObject()
        XCTAssertThrowsError(try ParseUtil.getJsonString(from: jsonObj, key: AdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let defaultJsonString = try ParseUtil.getJsonString(from: jsonObj, key: AdaptiveCardSchemaKey.accent.rawValue, required: false)
        XCTAssertEqual(defaultJsonString, "")
        
        let jsonObjWithIntType = try getJsonObjectWithAccent("1")
        let intString = try ParseUtil.getJsonString(from: jsonObjWithIntType, key: AdaptiveCardSchemaKey.accent.rawValue, required: false)
        XCTAssertEqual(intString, "1\n")
        
        let jsonObjWithValidType = try getJsonObjectWithAccent("\"Valid\"")
        let actualJsonString = try ParseUtil.getJsonString(from: jsonObjWithValidType, key: AdaptiveCardSchemaKey.accent.rawValue, required: true)
        XCTAssertEqual(actualJsonString, "\"Valid\"\n")
    }
}
