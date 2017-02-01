//
//  Schema.KindTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-31.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SchemaKindTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Init -
    //
    func testInitSingle() {
        XCTAssertEqual(Schema.Kind(string: "SCALAR"),       .scalar)
        XCTAssertEqual(Schema.Kind(string: "OBJECT"),       .object)
        XCTAssertEqual(Schema.Kind(string: "INTERFACE"),    .interface)
        XCTAssertEqual(Schema.Kind(string: "UNION"),        .union)
        XCTAssertEqual(Schema.Kind(string: "ENUM"),         .enum)
        XCTAssertEqual(Schema.Kind(string: "INPUT_OBJECT"), .inputObject)
        XCTAssertEqual(Schema.Kind(string: "LIST"),         .list)
        XCTAssertEqual(Schema.Kind(string: "NON_NULL"),     .nonNull)
    }
    
    func testInitCollection() {
        let strings = [
            "SCALAR",
            "OBJECT",
            "invalidValue",
            "INTERFACE",
        ]
        
        let kinds = Schema.Kind.collectionWith(strings: strings)
        
        XCTAssertEqual(kinds.count, 3)
        
        XCTAssertEqual(kinds[0], .scalar)
        XCTAssertEqual(kinds[1], .object)
        XCTAssertEqual(kinds[2], .interface)
    }
}
