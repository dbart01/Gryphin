//
//  Swift.EnumCaseTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-31.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SwiftEnumCaseTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testDefaultCase() {
        let enumCase = Swift.EnumCase(name: "dog")
        
        XCTAssertNotNil(enumCase)
        XCTAssertEqual(enumCase.stringRepresentation, "" ~
            "case dog" ~
            ""
        )
    }
    
    func testRawQuotedCase() {
        let enumCase = Swift.EnumCase(
            name:     "standard",
            value:    .quoted("standard"),
            comments: [
                "This is a standard case"
            ]
        )
        
        XCTAssertNotNil(enumCase)
        XCTAssertEqual(enumCase.stringRepresentation, "" ~
            "/// This is a standard case" ~
            "case standard = \"standard\"" ~
            ""
        )
    }
    
    func testRawUnquotedCase() {
        let enumCase = Swift.EnumCase(
            name:     "value",
            value:    .default("1234"),
            comments: [
                "This is an integer case"
            ]
        )
        
        XCTAssertNotNil(enumCase)
        XCTAssertEqual(enumCase.stringRepresentation, "" ~
            "/// This is an integer case" ~
            "case value = 1234" ~
            ""
        )
    }
}
