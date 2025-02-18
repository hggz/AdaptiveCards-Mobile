import XCTest
@testable import ACRewritePackage

class TableTests: XCTestCase {
    
    func testTableCellParse() throws {
        let tableCellFragment = """
        {
            "type": "TableCell",
            "items": [
                {
                    "type": "TextBlock",
                    "text": "flim"
                },
                {
                    "type": "TextBlock",
                    "text": "iz-us"
                }
            ],
            "rtl": true
        }
        """

        let context = ParseContext()
        // Use the throwing version that returns a TableCell.
        let tableCell = try TableCell.deserialize(from: tableCellFragment, context: context)
        
        // Ensure no additional properties exist.
        XCTAssertNil(tableCell.additionalProperties, "This TableCell shouldn't have any additionalProperties")
        
        // Ensure RTL is set.
        XCTAssertNotNil(tableCell.rtl)
        XCTAssertEqual(tableCell.rtl, true)
        
        // Ensure we get 2 items and that each item is a TextBlock.
        XCTAssertEqual(tableCell.items.count, 2, "This TableCell should have 2 items")
        for item in tableCell.items {
            // (If needed, qualify with the enum type:)
            XCTAssertEqual(item.elementTypeString, "TextBlock", "Each item in this cell should be a TextBlock")
        }
        
        // Ensure correct serialization.
        let serializedResult = try tableCell.serialize()
        let expected = "{\"items\":[{\"text\":\"flim\",\"type\":\"TextBlock\"},{\"text\":\"iz-us\",\"type\":\"TextBlock\"}],\"rtl\":true,\"type\":\"TableCell\"}\n"
        XCTAssertEqual(serializedResult, expected, "TableCell should roundtrip correctly")
    }

    func testTableEmptyParseTests() throws {
        let fragments = [
            "{\"type\":\"TableRow\"}\n",
            "{\"type\":\"Table\"}\n",
            "{\"items\":[],\"type\":\"TableCell\"}\n" // note: Container auto-emits items
        ]
        
        let context = ParseContext()
        
        for fragment in fragments {
            // Assume ParseUtil.getJsonValue(from:) and BaseCardElement.parse(json:context:) exist.
            let jsonValue = ParseUtil.getJsonValue(from: fragment)
            guard let element = BaseCardElement.parse(json: jsonValue, context: context) else {
                XCTFail("Failed to parse BaseCardElement")
                continue
            }
            let serializedObject = try element.serialize()
            XCTAssertEqual(serializedObject, fragment)
        }
    }
    
    func testTableRowParse() throws {
        let tableRowFragment = """
        {
            "type": "TableRow",
            "horizontalCellContentAlignment": "center",
            "verticalCellContentAlignment": "bottom",
            "style": "accent",
            "cells": [
                {
                    "type": "TableCell",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": "the first"
                        },
                        {
                            "type": "TextBlock",
                            "text": "the first part deux"
                        }
                    ],
                    "rtl": true
                },
                {
                    "type": "TableCell",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": "the second"
                        }
                    ],
                    "rtl": true
                }
            ]
        }
        """
        
        let context = ParseContext()
        let tableRow = try TableRow.deserialize(from: tableRowFragment, context: context)
        
        XCTAssertNil(tableRow.additionalProperties, "This TableRow shouldn't have any additionalProperties")
        XCTAssertEqual(tableRow.cells.count, 2, "This TableRow should have 2 cells")
        XCTAssertEqual(tableRow.style, .accent)
        XCTAssertEqual(tableRow.horizontalCellContentAlignment, .center)
        XCTAssertEqual(tableRow.verticalCellContentAlignment, .bottom)
        
        let serializedResult = try tableRow.serialize()
        let expected = "{\"cells\":[{\"items\":[{\"text\":\"the first\",\"type\":\"TextBlock\"},{\"text\":\"the first part deux\",\"type\":\"TextBlock\"}],\"rtl\":true,\"type\":\"TableCell\"},{\"items\":[{\"text\":\"the second\",\"type\":\"TextBlock\"}],\"rtl\":true,\"type\":\"TableCell\"}],\"horizontalCellContentAlignment\":\"center\",\"style\":\"Accent\",\"type\":\"TableRow\",\"verticalCellContentAlignment\":\"Bottom\"}\n"
        XCTAssertEqual(serializedResult, expected)
    }
    
    func testTableElementsParserRegistration() throws {
        let context = ParseContext()
        XCTAssertNotNil(context.elementParserRegistration?.getParser(for: "Table"), "Should be a registered parser for Table")
        XCTAssertNil(context.elementParserRegistration?.getParser(for: "TableRow"), "Should not be a registered parser for TableRow")
        XCTAssertNil(context.elementParserRegistration?.getParser(for: "TableCell"), "Should not be a registered parser for TableCell")
    }
    
    func testTableColumnDefinitionSimpleParse() throws {
        let columnDefinitionFragment = """
        {
            "horizontalCellContentAlignment": "center",
            "verticalCellContentAlignment": "bottom",
            "width": 1
        }
        """
        
        let context = ParseContext()
        guard let columnDefinition = try? TableColumnDefinition.deserialize(context: context, from: columnDefinitionFragment) else {
            XCTFail("Failed to deserialize TableColumnDefinition")
            return
        }
        
        XCTAssertEqual(columnDefinition.width, 1)
        XCTAssertNil(columnDefinition.pixelWidth, "if we have a width, we shouldn't have a pixel width")
        XCTAssertEqual(columnDefinition.horizontalCellContentAlignment, .center)
        XCTAssertEqual(columnDefinition.verticalCellContentAlignment, .bottom)
        
        let serializedResult = try columnDefinition.serialize()
        let expected = "{\"horizontalCellContentAlignment\":\"center\",\"verticalCellContentAlignment\":\"Bottom\",\"width\":1}\n"
        XCTAssertEqual(serializedResult, expected)
    }
    
    func testTableColumnDefinitionPixelParse() throws {
        let columnDefinitionFragment = """
        {
            "horizontalCellContentAlignment": "right",
            "verticalCellContentAlignment": "center",
            "width": "100px"
        }
        """
        
        let context = ParseContext()
        guard let columnDefinition = try? TableColumnDefinition.deserialize(context: context, from: columnDefinitionFragment) else {
            XCTFail("Failed to deserialize TableColumnDefinition")
            return
        }
        
        XCTAssertNil(columnDefinition.width, "if we have a pixel width, we shouldn't have a width")
        XCTAssertEqual(columnDefinition.pixelWidth, 100)
        XCTAssertEqual(columnDefinition.horizontalCellContentAlignment, .right)
        XCTAssertEqual(columnDefinition.verticalCellContentAlignment, .center)
        
        let serializedResult = try columnDefinition.serialize()
        let expected = "{\"horizontalCellContentAlignment\":\"right\",\"verticalCellContentAlignment\":\"Center\",\"width\":\"100px\"}\n"
        XCTAssertEqual(serializedResult, expected)
    }
    
    func testTableColumnDefinitionMissingUnitParse() throws {
        let columnDefinitionFragment = """
        {
            "width": "10"
        }
        """
        
        let context = ParseContext()
        guard let columnDefinition = try? TableColumnDefinition.deserialize(context: context, from: columnDefinitionFragment) else {
            XCTFail("Failed to deserialize TableColumnDefinition")
            return
        }
        
        XCTAssertNil(columnDefinition.width, "A string width with no units should not result in width getting set")
        XCTAssertNil(columnDefinition.pixelWidth, "A string width with no units should not result in pixel width getting set")
        XCTAssertFalse(context.warnings.isEmpty, "Parsing a string with no units should yield warnings")
    }
    
    func testTableColumnDefinitionInvalidParse() throws {
        let columnDefinitionInvalidUnitFragment = """
        {
            "width": "10pixels"
        }
        """
        
        let context = ParseContext()
        guard let columnDefinition = try? TableColumnDefinition.deserialize(context: context, from: columnDefinitionInvalidUnitFragment) else {
            XCTFail("Failed to deserialize TableColumnDefinition")
            return
        }
        
        XCTAssertNil(columnDefinition.width)
        XCTAssertFalse(context.warnings.isEmpty, "Parsing a string with no units should yield warnings")
    }
    
    func testTableFragmentParseValid() throws {
        let tableFragment = """
        {
            "type": "Table",
            "gridStyle": "accent",
            "firstRowAsHeaders": true,
            "columns": [
                {
                    "width": 1
                },
                {
                    "width": 1
                },
                {
                    "width": 3
                }
            ],
            "rows": [
                {
                    "type": "TableRow",
                    "cells": [
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Name",
                                    "wrap": true,
                                    "weight": "Bolder"
                                }
                            ]
                        },
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Type",
                                    "wrap": true,
                                    "weight": "Bolder"
                                }
                            ]
                        },
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Description",
                                    "wrap": true,
                                    "weight": "Bolder"
                                }
                            ]
                        }
                    ],
                    "style": "accent"
                },
                {
                    "type": "TableRow",
                    "cells": [
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "columns",
                                    "wrap": true
                                }
                            ]
                        },
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "ColumnDefinition[]",
                                    "wrap": true
                                }
                            ]
                        },
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Defines the table's columns (number of columns, and column sizes).",
                                    "wrap": true
                                }
                            ]
                        }
                    ]
                },
                {
                    "type": "TableRow",
                    "cells": [
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "rows",
                                    "wrap": true
                                }
                            ]
                        },
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "TableRow[]",
                                    "wrap": true
                                }
                            ]
                        },
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Defines the rows of the Table, each being a collection of cells. Rows are not required, which allows empty Tables to be generated via templating without breaking the rendering of the whole card.",
                                    "wrap": true
                                }
                            ]
                        }
                    ]
                }
            ]
        }
        """
        
        let context = ParseContext()
        // Assume a TableParser exists with a deserialize(from:context:) method.
        let tableParser = TableParser()
        guard let tableAny = try? tableParser.deserialize(from: tableFragment, context: context),
              let table = tableAny as? Table else {
            XCTFail("Failed to deserialize Table")
            return
        }
        
        XCTAssertNil(table.additionalProperties)
        XCTAssertEqual(table.columns.count, 3)
        
        let column0 = table.columns[0]
        XCTAssertNotNil(column0.width)
        XCTAssertNil(column0.pixelWidth)
        XCTAssertEqual(column0.width, 1)
        
        let column1 = table.columns[1]
        XCTAssertNotNil(column1.width)
        XCTAssertNil(column1.pixelWidth)
        XCTAssertEqual(column1.width, 1)
        
        let column2 = table.columns[2]
        XCTAssertNotNil(column2.width)
        XCTAssertNil(column2.pixelWidth)
        XCTAssertEqual(column2.width, 3)
        
        XCTAssertEqual(table.rows.count, 3)
        for row in table.rows {
            XCTAssertEqual(row.cells.count, table.columns.count)
        }
        
        let serializedResult = try table.serialize()
        let expected = "{\"columns\":[{\"width\":1},{\"width\":1},{\"width\":3}],\"gridStyle\":\"Accent\",\"rows\":[{\"cells\":[{\"items\":[{\"text\":\"Name\",\"type\":\"TextBlock\",\"weight\":\"Bolder\",\"wrap\":true}],\"type\":\"TableCell\"},{\"items\":[{\"text\":\"Type\",\"type\":\"TextBlock\",\"weight\":\"Bolder\",\"wrap\":true}],\"type\":\"TableCell\"},{\"items\":[{\"text\":\"Description\",\"type\":\"TextBlock\",\"weight\":\"Bolder\",\"wrap\":true}],\"type\":\"TableCell\"}],\"style\":\"Accent\",\"type\":\"TableRow\"},{\"cells\":[{\"items\":[{\"text\":\"columns\",\"type\":\"TextBlock\",\"wrap\":true}],\"type\":\"TableCell\"},{\"items\":[{\"text\":\"ColumnDefinition[]\",\"type\":\"TextBlock\",\"wrap\":true}],\"type\":\"TableCell\"},{\"items\":[{\"text\":\"Defines the table's columns (number of columns, and column sizes).\",\"type\":\"TextBlock\",\"wrap\":true}],\"type\":\"TableCell\"}],\"type\":\"TableRow\"},{\"cells\":[{\"items\":[{\"text\":\"rows\",\"type\":\"TextBlock\",\"wrap\":true}],\"type\":\"TableCell\"},{\"items\":[{\"text\":\"TableRow[]\",\"type\":\"TextBlock\",\"wrap\":true}],\"type\":\"TableCell\"},{\"items\":[{\"text\":\"Defines the rows of the Table, each being a collection of cells. Rows are not required, which allows empty Tables to be generated via templating without breaking the rendering of the whole card.\"}],\"type\":\"TableCell\"}],\"type\":\"TableRow\"}],\"type\":\"Table\"}\n"
        XCTAssertEqual(serializedResult, expected)
    }
    
    func testTableCardParseValid() throws {
        let tableCard = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                {
                    "type": "Table",
                    "gridStyle": "accent",
                    "firstRowAsHeaders": true,
                    "columns": [
                        {
                            "width": 1
                        },
                        {
                            "width": 1
                        },
                        {
                            "width": 3
                        }
                    ],
                    "rows": [
                        {
                            "type": "TableRow",
                            "cells": [
                                {
                                    "type": "TableCell",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "Name",
                                            "wrap": true,
                                            "weight": "Bolder"
                                        }
                                    ]
                                },
                                {
                                    "type": "TableCell",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "Type",
                                            "wrap": true,
                                            "weight": "Bolder"
                                        }
                                    ]
                                },
                                {
                                    "type": "TableCell",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "Description",
                                            "wrap": true,
                                            "weight": "Bolder"
                                        }
                                    ]
                                }
                            ],
                            "style": "accent"
                        },
                        {
                            "type": "TableRow",
                            "cells": [
                                {
                                    "type": "TableCell",
                                    "style": "good",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "columns",
                                            "wrap": true
                                        }
                                    ]
                                },
                                {
                                    "type": "TableCell",
                                    "style": "warning",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "some text",
                                            "wrap": true
                                        }
                                    ]
                                },
                                {
                                    "type": "TableCell",
                                    "style": "accent",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "some text #2",
                                            "wrap": true
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            ]
        }
        """
        
        // Assume AdaptiveCard.deserialize(from:version:) returns a result with an adaptiveCard property.
        let result = try AdaptiveCard.deserializeFromString(tableCard, version: "1.5")
        let card = result.adaptiveCard
        let body = card.body
        XCTAssertEqual(body.count, 1)
        let bodyElem = body.first!
        XCTAssertEqual(bodyElem.elementTypeString, "Table")
        
        let serializedCard = try card.serialize()
        let expected = "{\"actions\":[],\"body\":[{\"columns\":[{\"width\":1},{\"width\":1},{\"width\":3}],\"gridStyle\":\"Accent\",\"rows\":[{\"cells\":[{\"items\":[{\"text\":\"Name\",\"type\":\"TextBlock\",\"weight\":\"Bolder\",\"wrap\":true}],\"type\":\"TableCell\"},{\"items\":[{\"text\":\"Type\",\"type\":\"TextBlock\",\"weight\":\"Bolder\",\"wrap\":true}],\"type\":\"TableCell\"},{\"items\":[{\"text\":\"Description\",\"type\":\"TextBlock\",\"weight\":\"Bolder\",\"wrap\":true}],\"type\":\"TableCell\"}],\"style\":\"Accent\",\"type\":\"TableRow\"},{\"cells\":[{\"items\":[{\"text\":\"columns\",\"type\":\"TextBlock\",\"wrap\":true}],\"style\":\"Good\",\"type\":\"TableCell\"},{\"items\":[{\"text\":\"some text\",\"type\":\"TextBlock\",\"wrap\":true}],\"style\":\"Warning\",\"type\":\"TableCell\"},{\"items\":[{\"text\":\"some text #2\",\"type\":\"TextBlock\",\"wrap\":true}],\"style\":\"Accent\",\"type\":\"TableCell\"}],\"type\":\"TableRow\"}],\"type\":\"Table\"}],\"type\":\"AdaptiveCard\",\"version\":\"1.5\"}\n"
        XCTAssertEqual(serializedCard, expected)
    }
    
    func testTableCardParseOrphanedTableRow() throws {
        let tableCard = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                {
                    "type": "TableRow",
                    "cells": [
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "..."
                                }
                            ]
                        }
                    ]
                }
            ]
        }
        """
        
        let result = try AdaptiveCard.deserializeFromString(tableCard, version: "1.5")
        let card = result.adaptiveCard
        let body = card.body
        XCTAssertEqual(body.count, 1)
        let bodyElem = body.first!
        XCTAssertEqual(bodyElem.elementTypeString, "TableRow", "An orphaned TableRow should deserialize with its type string intact")
        XCTAssertEqual(bodyElem.elementTypeVal, .unknown, "An orphaned TableRow should be implemented as UnknownElement")
        
        let serializedCard = try card.serialize()
        let expected = "{\"actions\":[],\"body\":[{\"cells\":[{\"items\":[{\"text\":\"...\",\"type\":\"TextBlock\"}],\"type\":\"TableCell\"}],\"type\":\"TableRow\"}],\"type\":\"AdaptiveCard\",\"version\":\"1.5\"}\n"
        XCTAssertEqual(serializedCard, expected)
    }
    
    func testTableCardParseOrphanedTableCell() throws {
        let tableCard = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                {
                    "type": "TableCell",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": "Name",
                            "wrap": true,
                            "weight": "Bolder"
                        }
                    ]
                }
            ]
        }
        """
        
        let result = try AdaptiveCard.deserializeFromString(tableCard, version: "1.5")
        let card = result.adaptiveCard
        let body = card.body
        XCTAssertEqual(body.count, 1)
        let bodyElem = body.first!
        XCTAssertEqual(bodyElem.elementTypeString, "TableCell", "An orphaned TableCell should deserialize with its type string intact")
        XCTAssertEqual(bodyElem.elementTypeVal, .unknown, "An orphaned TableCell should be implemented as UnknownElement")
        
        let serializedCard = try card.serialize()
        let expected = "{\"actions\":[],\"body\":[{\"items\":[{\"text\":\"Name\",\"type\":\"TextBlock\",\"weight\":\"Bolder\",\"wrap\":true}],\"type\":\"TableCell\"}],\"type\":\"AdaptiveCard\",\"version\":\"1.5\"}\n"
        XCTAssertEqual(serializedCard, expected)
    }
    
    func testTableCardParseWithImpliedTypes() throws {
        let tableCard = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                {
                    "type": "Table",
                    "columns": [
                        {
                            "width": 1
                        }
                    ],
                    "rows": [
                        {
                            "cells": [
                                {
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "Text goes here."
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            ]
        }
        """
        
        let result = try AdaptiveCard.deserializeFromString(tableCard, version: "1.5")
        let card = result.adaptiveCard
        let body = card.body
        XCTAssertEqual(body.count, 1)
        let bodyElem = body.first!
        XCTAssertEqual(bodyElem.elementTypeVal, .table, "Only item in the body should be a Table")
        
        guard let table = bodyElem as? Table else {
            XCTFail("Expected body element to be a Table")
            return
        }
        
        XCTAssertEqual(table.columns.count, 1, "Should be only one column")
        XCTAssertEqual(table.rows.count, 1, "Should be only one row")
        
        let row = table.rows.first!
        XCTAssertEqual(row.elementTypeVal, .tableRow, "Should be a real TableRow")
        XCTAssertEqual(row.cells.count, 1, "Should be only one cell")
        
        let cell = row.cells.first!
        XCTAssertEqual(cell.elementTypeVal, .tableCell, "Should be a real TableCell")
    }
}
