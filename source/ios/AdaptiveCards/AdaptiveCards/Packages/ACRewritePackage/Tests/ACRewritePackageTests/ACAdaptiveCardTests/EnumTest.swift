import XCTest
@testable import ACRewritePackage  // Change to your module name

/// Helper function for a basic enum test.
func assertEnumConversion<T: Equatable>(
    toString: (T) -> String,
    fromString: (String) -> T?,
    value: T,
    expectedString: String,
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssertEqual(toString(value), expectedString, file: file, line: line)
    XCTAssertEqual(fromString(expectedString), value, file: file, line: line)
    XCTAssertNil(fromString("This is invalid"), "Invalid string should return nil", file: file, line: line)
}

/// For enums with additional reverse mapping (i.e. alternate strings mapping to the same value).
func assertEnumConversionWithReverse<T: Equatable>(
    toString: (T) -> String,
    fromString: (String) -> T?,
    value: T,
    expectedString: String,
    reverseMap: [String: T],
    file: StaticString = #file,
    line: UInt = #line
) {
    assertEnumConversion(toString: toString, fromString: fromString, value: value, expectedString: expectedString, file: file, line: line)
    for (altString, expectedValue) in reverseMap {
        XCTAssertEqual(fromString(altString), expectedValue, "Reverse mapping failed for \(altString)", file: file, line: line)
    }
}

class EnumTests: XCTestCase {

    func testActionAlignment() {
        // Expected: ActionAlignment.Center -> "Center"
        assertEnumConversion(
            toString: ActionAlignment.toString,
            fromString: ActionAlignment.fromString,
            value: .center,
            expectedString: "Center"
        )
    }

    func testActionMode() {
        // Expected: ActionMode.Popup -> "Popup"
        assertEnumConversion(
            toString: ActionMode.toString,
            fromString: ActionMode.fromString,
            value: .popup,
            expectedString: "Popup"
        )
    }

    func testActionsOrientation() {
        // Expected: ActionsOrientation.Vertical -> "Vertical"
        assertEnumConversion(
            toString: ActionsOrientation.toString,
            fromString: ActionsOrientation.fromString,
            value: .vertical,
            expectedString: "Vertical"
        )
    }

    func testActionType() {
        // Expected: ActionType.OpenUrl -> "Action.OpenUrl"
        assertEnumConversion(
            toString: ActionType.toString,
            fromString: ActionType.fromString,
            value: .openUrl,
            expectedString: "Action.OpenUrl"
        )
    }

    func testAdaptiveCardSchemaKey() {
        // Expected: AdaptiveCardSchemaKey.Accent -> "accent"
        assertEnumConversion(
            toString: AdaptiveCardSchemaKey.toString,
            fromString: AdaptiveCardSchemaKey.fromString,
            value: .accent,
            expectedString: "accent"
        )
    }

    func testCardElementType() {
        // Expected: CardElementType.AdaptiveCard -> "AdaptiveCard"
        assertEnumConversion(
            toString: CardElementType.toString,
            fromString: CardElementType.fromString,
            value: .adaptiveCard,
            expectedString: "AdaptiveCard"
        )
    }

    func testChoiceSetStyle() {
        // Expected: ChoiceSetStyle.Filtered -> "Filtered"
        assertEnumConversion(
            toString: ChoiceSetStyle.toString,
            fromString: ChoiceSetStyle.fromString,
            value: .filtered,
            expectedString: "Filtered"
        )
    }

    func testContainerStyle() {
        // Expected: ContainerStyle.Emphasis -> "Emphasis"
        assertEnumConversion(
            toString: ContainerStyle.toString,
            fromString: ContainerStyle.fromString,
            value: .emphasis,
            expectedString: "Emphasis"
        )
    }

    func testFontType() {
        // Expected: FontType.Monospace -> "Monospace"
        assertEnumConversion(
            toString: FontType.toString,
            fromString: FontType.fromString,
            value: .monospace,
            expectedString: "Monospace"
        )
    }

    func testForegroundColor() {
        // Expected: ForegroundColor.Accent -> "Accent"
        assertEnumConversion(
            toString: ForegroundColor.toString,
            fromString: ForegroundColor.fromString,
            value: .accent,
            expectedString: "Accent"
        )
    }

    func testHeightType() {
        // Expected: HeightType.Auto -> "Auto"
        assertEnumConversion(
            toString: HeightType.toString,
            fromString: HeightType.fromString,
            value: .auto,
            expectedString: "Auto"
        )
    }

    func testHorizontalAlignment() {
        // Expected: HorizontalAlignment.Center -> "center" (note lowercase expected)
        assertEnumConversion(
            toString: HorizontalAlignment.toString,
            fromString: HorizontalAlignment.fromString,
            value: .center,
            expectedString: "center"
        )
    }

    func testIconPlacement() {
        // Expected: IconPlacement.LeftOfTitle -> "LeftOfTitle"
        assertEnumConversion(
            toString: IconPlacement.toString,
            fromString: IconPlacement.fromString,
            value: .leftOfTitle,
            expectedString: "LeftOfTitle"
        )
    }

    func testImageSize() {
        // Expected: ImageSize.Large -> "Large"
        assertEnumConversion(
            toString: ImageSize.toString,
            fromString: ImageSize.fromString,
            value: .large,
            expectedString: "Large"
        )
    }

    func testImageStyle() {
        // Expected: ImageStyle.Person -> "person"
        assertEnumConversion(
            toString: ImageStyle.toString,
            fromString: ImageStyle.fromString,
            value: .person,
            expectedString: "person"
        )
    }

    func testSeparatorThickness() {
        // Expected: SeparatorThickness.Thick -> "thick"
        assertEnumConversion(
            toString: SeparatorThickness.toString,
            fromString: SeparatorThickness.fromString,
            value: .thick,
            expectedString: "thick"
        )
    }

    func testSpacing() {
        // Expected: Spacing.None -> "none"
        assertEnumConversion(
            toString: Spacing.toString,
            fromString: Spacing.fromString,
            value: .none,
            expectedString: "none"
        )
    }

    func testTextInputStyle() {
        // Expected: TextInputStyle.Password -> "Password"
        assertEnumConversion(
            toString: TextInputStyle.toString,
            fromString: TextInputStyle.fromString,
            value: .password,
            expectedString: "Password"
        )
    }

    func testTextSize() {
        // Expected: TextSize.Large -> "Large"
        // Additional reverse mapping: "Normal" should return .default
        assertEnumConversionWithReverse(
            toString: TextSize.toString,
            fromString: TextSize.fromString,
            value: .large,
            expectedString: "Large",
            reverseMap: ["Normal": .defaultSize]
        )
    }

    func testTextWeight() {
        // Expected: TextWeight.Bolder -> "Bolder"
        // Additional reverse mapping: "Normal" should return .defaultWeight
        assertEnumConversionWithReverse(
            toString: TextWeight.toString,
            fromString: TextWeight.fromString,
            value: .bolder,
            expectedString: "Bolder",
            reverseMap: ["Normal": .defaultWeight]
        )
    }

    func testVerticalContentAlignment() {
        // Expected: VerticalContentAlignment.Center -> "Center"
        assertEnumConversion(
            toString: VerticalContentAlignment.toString,
            fromString: VerticalContentAlignment.fromString,
            value: .center,
            expectedString: "Center"
        )
    }
}
