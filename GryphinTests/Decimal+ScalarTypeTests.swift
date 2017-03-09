//
//  Decimal+ScalarTypeTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-03-09.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class Decimal_ScalarTypeTests: XCTestCase {
    
    func testRemoteInit() {
        let value1 = Decimal(from: "6.568930")
        XCTAssertEqual(value1, 6.568930 as Decimal)
        
        let value2 = Decimal(from: "3")
        XCTAssertEqual(value2, 3 as Decimal)
        
        let value3 = Decimal(from: "0.000000000123")
        XCTAssertEqual(value3, Decimal(string: "0.000000000123")!)
    }
    
    func testRemoteSerialization() {
        let value = Decimal(from: "6.568933")
        XCTAssertEqual(value.string, "6.568933")
    }
}
