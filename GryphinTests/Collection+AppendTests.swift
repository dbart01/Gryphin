//
//  Collection+AppendTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-03-08.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

import XCTest
@testable import Gryphin

class Collection_AppendTests: XCTestCase {

    func testAppendElement() {
        var collection: [String] = []
        
        XCTAssertEqual(collection.count, 0)
        
        collection += "Alex"
        collection += "John"
        
        XCTAssertEqual(collection.count, 2)
    }
    
    func testAppendCollection() {
        var collection: [String] = []
        
        XCTAssertEqual(collection.count, 0)
        
        collection += ["Alex", "John"]
        
        XCTAssertEqual(collection.count, 2)
    }
}
