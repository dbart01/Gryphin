//
//  ValueTypeTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-16.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class ValueTypeTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Primitives -
    //
    func testString() {
        let value = "someValue"
        XCTAssertEqual(value._stringRepresentation, "\"someValue\"")
    }
    
    func testInt() {
        let value = 13
        XCTAssertEqual(value._stringRepresentation, "13")
    }
    
    func testFloat() {
        let value: Float = 13.0
        XCTAssertEqual(value._stringRepresentation, "13.0")
    }
    
    func testDouble() {
        let value: Double = 13.0
        XCTAssertEqual(value._stringRepresentation, "13.0")
    }
    
    func testBool() {
        let value = true
        XCTAssertEqual(value._stringRepresentation, "true")
        
        let anotherValue = false
        XCTAssertEqual(anotherValue._stringRepresentation, "false")
    }
    
    func testRawStringEnum() {
        
        enum Dog: String {
            case husky
            case rottweiler
            case dachshund
        }
        
        let value = Dog.husky
        XCTAssertEqual(value._stringRepresentation, "husky")
    }
    
    // ----------------------------------
    //  MARK: - Equality -
    //
    func testEquality() {
        
        let value1 = TestValue(name: "value")
        let value2 = TestValue(name: "value")
        
        XCTAssertFalse(value1 === value2)
        XCTAssertTrue(value1 == value2)
        XCTAssertTrue(value1._stringRepresentation == value2._stringRepresentation)
        XCTAssertTrue(value1.hashValue == value2.hashValue)
    }
}

// ----------------------------------
//  MARK: - TestValue -
//
class TestValue: ValueType {
    
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    var _stringRepresentation: String {
        return self.name._stringRepresentation
    }
}
