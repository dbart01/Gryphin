//
//  Schema.ObjectTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-01.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SchemaObjectTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testInit() {
        let field: JSON = [
            "name": "node",
            "description": "The item at the end of the edge.",
            "args": [],
            "type": [
                "kind": "OBJECT",
                "name": "Project",
                "ofType": nil
            ],
            "isDeprecated": false,
            "deprecationReason": nil
        ]
        
        let json: JSON = [
            "kind": "OBJECT",
            "name": "ProjectEdge",
            "description": "An edge in a connection.",
            "fields": [field],
            "inputFields": [],
            "interfaces": [],
            "enumValues": [],
            "possibleTypes": []
            
        ]
        
        let object = Schema.Object(json: json)
        
        XCTAssertEqual(object.kind,        .object)
        XCTAssertEqual(object.name,        "ProjectEdge")
        XCTAssertEqual(object.description, "An edge in a connection.")
        
        XCTAssertNotNil(object.fields)
        XCTAssertNotNil(object.inputFields)
        XCTAssertNotNil(object.interfaces)
        XCTAssertNotNil(object.enumValues)
        XCTAssertNotNil(object.possibleTypes)
    }
}
