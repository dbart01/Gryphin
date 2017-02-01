//
//  Schema.ArgumentTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-01.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SchemaArgumentTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testCompleteInit() {
        let json: JSON = [
            "name": "field",
            "description": "The field in which to order projects by.",
            "type": self.objectType(),
            "defaultValue": "value"
        ]
        
        let arg = Schema.Argument(json: json)
        
        XCTAssertEqual(arg.name,         "field")
        XCTAssertEqual(arg.description,  "The field in which to order projects by.")
        XCTAssertEqual(arg.type.kind,    .nonNull)
        XCTAssertEqual(arg.defaultValue, "value")
    }
    
    func testPartialInit() {
        let json: JSON = [
            "name": "field",
            "description": nil,
            "type": self.objectType(),
            "defaultValue": nil
        ]
        
        let arg = Schema.Argument(json: json)
        
        XCTAssertEqual(arg.name,      "field")
        XCTAssertEqual(arg.type.kind, .nonNull)
        
        XCTAssertNil(arg.description)
        XCTAssertNil(arg.defaultValue)
    }
    
    private func objectType() -> JSON {
        return [
            "kind": "NON_NULL",
            "name": nil,
            "ofType": [
                "kind": "ENUM",
                "name": "ProjectOrderField",
                "ofType": nil
            ]
        ]
    }
}
