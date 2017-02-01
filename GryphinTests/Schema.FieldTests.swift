//
//  Schema.FieldTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-01.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SchemaFieldTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testCompleteInit() {
        let arg: JSON = [
            "name": "first",
            "description": "Returns the first _n_ elements from the list.",
            "type": [
                "kind": "SCALAR",
                "name": "Int",
                "ofType": nil
            ],
            "defaultValue": nil
        ]
        
        let json: JSON = [
            "name": "comments",
            "description": "A list of comments associated with the pull request.",
            "args": [arg],
            "type": self.objectType(),
            "isDeprecated": true,
            "deprecationReason": "No reason",
        ]
        
        let field = Schema.Field(json: json)
        
        XCTAssertEqual(field.name,              "comments")
        XCTAssertEqual(field.description,       "A list of comments associated with the pull request.")
        XCTAssertEqual(field.arguments.count,   1)
        XCTAssertEqual(field.type.kind,         .nonNull)
        XCTAssertEqual(field.isDeprecated,      true)
        XCTAssertEqual(field.deprecationReason, "No reason")
    }
    
    func testPartialInit() {
        let json: JSON = [
            "name": "comments",
            "description": nil,
            "args": [],
            "type": self.objectType(),
        ]
        
        let field = Schema.Field(json: json)
        
        XCTAssertEqual(field.name,            "comments")
        XCTAssertEqual(field.arguments.count, 0)
        XCTAssertEqual(field.type.kind,       .nonNull)
        XCTAssertEqual(field.isDeprecated,    false)
        
        XCTAssertNil(field.deprecationReason)
        XCTAssertNil(field.description)
    }
    
    private func objectType() -> JSON {
        return [
            "kind": "NON_NULL",
            "name": nil,
            "ofType": [
                "kind": "OBJECT",
                "name": "IssueCommentConnection",
                "ofType": nil
            ]
        ]
    }
}
