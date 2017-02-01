//
//  Schema.InputFieldTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-01.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SchemaInputFieldTests: XCTestCase {

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
        
        let field = Schema.InputField(json: json)
        
        XCTAssertEqual(field.name,         "field")
        XCTAssertEqual(field.description,  "The field in which to order projects by.")
        XCTAssertEqual(field.type.kind,    .nonNull)
        XCTAssertEqual(field.defaultValue, "value")
    }
    
    func testPartialInit() {
        let json: JSON = [
            "name": "field",
            "description": nil,
            "type": self.objectType(),
            "defaultValue": nil
        ]
        
        let field = Schema.InputField(json: json)
        
        XCTAssertEqual(field.name,      "field")
        XCTAssertEqual(field.type.kind, .nonNull)
        
        XCTAssertNil(field.description)
        XCTAssertNil(field.defaultValue)
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
