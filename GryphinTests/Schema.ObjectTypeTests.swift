//
//  Schema.ObjectTypeTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-31.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SchemaObjectTypeTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Init -
    //
    func testInitNonNullScalar() {
        let json: JSON = [
            "kind": "NON_NULL",
            "name": nil,
            "ofType": [
                "kind": "SCALAR",
                "name": "String",
                "ofType": nil
            ]
        ]
        
        let type   = Schema.ObjectType(json: json)
        let ofType = type.ofType!
        
        XCTAssertTrue(type.hasScalar)
        XCTAssertFalse(type.isAbstract)
        XCTAssertFalse(type.isCollection)
        XCTAssertFalse(type.isTopLevelNullable)
        XCTAssertFalse(type.isLeafNullable)
        
        XCTAssertTrue(type.leaf === ofType)
        
        XCTAssertEqual(type.kind, .nonNull)
        XCTAssertNil(type.possibleName)
        
        XCTAssertEqual(ofType.kind, .scalar)
        XCTAssertEqual(ofType.possibleName, "String")
        XCTAssertNil(ofType.ofType)
    }
    
    func testInitNullableScalar() {
        let json: JSON = [
            "kind": "SCALAR",
            "name": "String",
            "ofType": nil
        ]
        
        let type = Schema.ObjectType(json: json)
        
        XCTAssertTrue(type.hasScalar)
        XCTAssertFalse(type.isAbstract)
        XCTAssertFalse(type.isCollection)
        XCTAssertTrue(type.isTopLevelNullable)
        XCTAssertTrue(type.isLeafNullable)
        
        XCTAssertTrue(type.leaf === type)
        
        XCTAssertEqual(type.kind, .scalar)
        XCTAssertEqual(type.possibleName, "String")
        XCTAssertEqual(type.name,         "String")
        XCTAssertNil(type.ofType)
    }
    
    func testInitNonNullObjectCollection() {
        let json: JSON = [
            "kind": "LIST",
            "name": nil,
            "ofType": [
                "kind": "OBJECT",
                "name": "Issue",
                "ofType": nil
            ]
        ]
        
        let type   = Schema.ObjectType(json: json)
        let ofType = type.ofType!
        
        XCTAssertFalse(type.hasScalar)
        XCTAssertFalse(type.isAbstract)
        XCTAssertTrue(type.isCollection)
        XCTAssertTrue(type.isTopLevelNullable)
        XCTAssertTrue(type.isLeafNullable)
        
        XCTAssertTrue(type.leaf === ofType)
        
        XCTAssertEqual(type.kind, .list)
        XCTAssertNil(type.possibleName)
        
        XCTAssertEqual(ofType.kind, .object)
        XCTAssertEqual(ofType.possibleName, "Issue")
        XCTAssertEqual(ofType.name,         "Issue")
        XCTAssertNil(ofType.ofType)
    }
}
