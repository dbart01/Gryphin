//
//  GraphErrorTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-21.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class GraphErrorTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testInitComplete() {
        let json: JSON = [
            "message": "Syntax error",
            "locations": [
                [
                    "line": 12,
                    "column": 1,
                ]
            ],
            "fields": [
                "id",
                "name",
            ]
        ]
        
        let error = QueryError(json: json)
        
        XCTAssertNotNil(error)
        XCTAssertEqual(error.message, "Syntax error")
        
        let locations = error.locations
        XCTAssertNotNil(locations)
        XCTAssertEqual(locations![0].line,   12)
        XCTAssertEqual(locations![0].column, 1)
        
        let fields = error.fields
        XCTAssertNotNil(fields)
        XCTAssertEqual(fields![0], "id")
        XCTAssertEqual(fields![1], "name")
    }
    
    func testInitCompleteShallow() {
        let json: JSON = [
            "message": "Syntax error",
            "line": 12,
            "column": 1,
        ]
        
        let error = QueryError(json: json)
        
        XCTAssertNotNil(error)
        XCTAssertEqual(error.message, "Syntax error")
        
        let locations = error.locations
        XCTAssertNotNil(locations)
        XCTAssertEqual(locations![0].line,   12)
        XCTAssertEqual(locations![0].column, 1)
        
        XCTAssertNil(error.fields)
    }
    
    func testInitIncomplete() {
        let json: JSON = [
            "message": "Syntax error",
        ]
        
        let error = QueryError(json: json)
        
        XCTAssertNotNil(error)
        XCTAssertEqual(error.message, "Syntax error")
        
        XCTAssertNil(error.locations)
        XCTAssertNil(error.fields)
    }
    
    
    
    func testInitWithouMessage() {
        let error = QueryError(json: [:])
        
        XCTAssertNotNil(error)
        XCTAssertEqual(error.message, "Uknown error")
        
        XCTAssertNil(error.locations)
        XCTAssertNil(error.fields)
    }
}
