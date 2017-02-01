//
//  String+CaseConversionTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-09.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class String_CaseConversionTests: XCTestCase {

    func testSnakeToCamel() {
        
        XCTAssertEqual("SNAKE_CASE".snakeToCamel, "snakeCase")
        XCTAssertEqual("snake_case".snakeToCamel, "snakeCase")
        XCTAssertEqual("sNaKe_CaSe".snakeToCamel, "snakeCase")
        XCTAssertEqual("snake_CASE".snakeToCamel, "snakeCase")
        
        XCTAssertEqual("SNAKE".snakeToCamel, "snake")
        XCTAssertEqual("snake".snakeToCamel, "snake")
        XCTAssertEqual("sNaKe".snakeToCamel, "snake")
    }
    
    func testSnakeToCamelNil() {
        XCTAssertNil("".snakeToCamel)
    }
    
    func testLowerCasedFirst() {
        XCTAssertEqual("SomeClass".lowercasedFirst, "someClass")
        XCTAssertEqual("SOMECLASS".lowercasedFirst, "sOMECLASS")
        XCTAssertEqual("someclass".lowercasedFirst, "someclass")
    }
}
