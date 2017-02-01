//
//  Schema.EnumValueTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-01.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SchemaEnumValueTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testCompleteInit() {
        let json: JSON = [
            "name": "COMMENTED",
            "description": "An informational review.",
            "isDeprecated": true,
            "deprecationReason": "No reason provided"
        ]
        
        let value = Schema.EnumValue(json: json)
        
        XCTAssertEqual(value.name, "COMMENTED")
        XCTAssertEqual(value.description, "An informational review.")
        XCTAssertEqual(value.isDeprecated, true)
        XCTAssertEqual(value.deprecationReason, "No reason provided")
    }
    
    func testPartialInit() {
        let json: JSON = [
            "name": "COMMENTED",
        ]
        
        let value = Schema.EnumValue(json: json)
        
        XCTAssertEqual(value.name, "COMMENTED")
        XCTAssertNil(value.description)
        XCTAssertEqual(value.isDeprecated, false)
        XCTAssertNil(value.deprecationReason)
    }
}
