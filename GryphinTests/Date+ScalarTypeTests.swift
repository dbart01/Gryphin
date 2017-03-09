//
//  Date+ScalarTypeTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-03-09.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class Date_ScalarTypeTests: XCTestCase {
    
    func testRemoteInit() {
        let date = Date(from: "2017-07-13T06:22:37-05:00")
        XCTAssertEqual(date, Date(timeIntervalSince1970: 1499944957))
    }
    
    func testRemoteSerialization() {
        let date = Date(from: "2017-07-13T06:22:37Z")
        XCTAssertEqual(date.string, "2017-07-13T06:22:37Z")
    }
}
