//
//  URL+ScalarTypeTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-03-09.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class URL_ScalarTypeTests: XCTestCase {

    func testRemoteInit() {
        let url = URL(from: "https://www.google.com")
        XCTAssertNotNil(url)
    }
    
    func testRemoteSerialization() {
        let url = URL(from: "https://www.google.com")
        XCTAssertEqual(url.string, "https://www.google.com")
    }
}
