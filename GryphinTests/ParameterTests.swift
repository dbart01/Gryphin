//
//  ParameterTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-29.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class ParameterTests: XCTestCase {
    
    private enum TestEnum: String {
        case one   = "1one"
        case two   = "2two"
        case three = "3three"
    }
    
    // ----------------------------------
    //  MARK: - Init -
    //
    func testValueTypeInit() {
        self.assert(parameter: Parameter(name: "string", value: "value"),
                    equals:    "string: \"value\"")
    }
    
    func testValueTypeCollectionInit() {
        self.assert(parameter: Parameter(name: "numbers", value: [123, 234]),
                    equals:    "numbers: [123, 234]")
    }
    
    func testScalarTypeInit() {
        self.assert(parameter: Parameter(name: "id", value: TestID(from: "123")),
                    equals:    "id: \"123\"")
    }
    
    func testScalarTypeCollectionInit() {
        let values = [
            TestID(from: "123"),
            TestID(from: "234"),
        ]
        self.assert(parameter: Parameter(name: "ids", value: values),
                    equals:    "ids: [\"123\", \"234\"]")
    }
    
    func testEnumInit() {
        self.assert(parameter: Parameter(name: "enum", value: TestEnum.two),
                    equals:    "enum: 2two")
    }
    
    func testEnumCollectionInit() {
        self.assert(parameter: Parameter(name: "enums", value: [TestEnum.two, TestEnum.three]),
                    equals:    "enums: [2two, 3three]")
    }
    
    private func assert(parameter: Parameter, equals value: String) {
        let string = parameter._stringRepresentation
        XCTAssertEqual(string, value)
    }
    
    // ----------------------------------
    //  MARK: - Equality -
    //
    func testEquality() {
        let param1 = Parameter(name: "number", value: 123)
        let param2 = Parameter(name: "number", value: 123)
        
        XCTAssertEqual(param1, param2)
        
        let param3 = Parameter(name: "number", value: "123")
        
        XCTAssertNotEqual(param2, param3)
    }
}

// ----------------------------------
//  MARK: - Test Scalar -
//
private struct TestID: ScalarType {
    
    let string: String
    
    init(from string: String) {
        self.string = string
    }
}
