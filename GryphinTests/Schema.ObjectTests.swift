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
        let json   = self.jsonForObject(named: "ProjectEdge", withField: "node", type: "Project")
        let object = Schema.Object(json: json)
        
        XCTAssertEqual(object.kind,        .object)
        XCTAssertEqual(object.name,        "ProjectEdge")
        XCTAssertEqual(object.description, "An object description")
        
        XCTAssertNotNil(object.fields)
        XCTAssertNotNil(object.inputFields)
        XCTAssertNotNil(object.interfaces)
        XCTAssertNotNil(object.enumValues)
        XCTAssertNotNil(object.possibleTypes)
    }
    
    // ----------------------------------
    //  MARK: - Edges / Node -
    //
    func testEdgesField() {
        
        let json   = self.jsonForObject(named: "ProjectConnection", withField: "edges", type: "ProjectEdge")
        let object = Schema.Object(json: json)
        
        XCTAssertNotNil(object.edgesField)
        XCTAssertNil(object.nodeField)
    }
    
    func testNodeField() {
        
        let json   = self.jsonForObject(named: "ProjectEdge", withField: "node", type: "Project")
        let object = Schema.Object(json: json)
        
        XCTAssertNil(object.edgesField)
        XCTAssertNotNil(object.nodeField)
    }
    
    func testEmptyFields() {
        let json   = self.jsonForObject(named: "Project")
        let object = Schema.Object(json: json)
        
        XCTAssertNil(object.edgesField)
        XCTAssertNil(object.nodeField)
    }
    
    // ----------------------------------
    //  MARK: - Object Generation -
    //
    private func jsonForObject(named name: String, withField fieldName: String, type: String) -> JSON {
        let field: JSON = [
            "name": fieldName,
            "description": "A field description",
            "args": [],
            "type": [
                "kind": "OBJECT",
                "name": type,
                "ofType": nil
            ],
            "isDeprecated": false,
            "deprecationReason": nil
        ]
        
        return self.jsonForObject(named: name, field: field)
    }
    
    private func jsonForObject(named name: String, field: JSON? = nil) -> JSON {
        return [
            "kind": "OBJECT",
            "name": name,
            "description": "An object description",
            "fields": field != nil ? [field!] : nil,
            "inputFields": [],
            "interfaces": [],
            "enumValues": [],
            "possibleTypes": []
        ]
    }
}
