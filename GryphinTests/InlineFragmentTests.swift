//
//  InlineFragmentTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-29.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class InlineFragmentTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Setup -
    //
    override func setUp() {
        super.setUp()
        
        precondition(Environment.prettyPrint, "Inline fragment tests require the \"com.gryphin.prettyPrint\" environment variable to be set.")
    }
    
    // ----------------------------------
    //  MARK: - Init -
    //
    func testInit() {
        let fragment = InlineFragment(type: "User")
        
        XCTAssertNotNil(fragment)
        XCTAssertEqual(fragment._name,          "")
        XCTAssertEqual(fragment._typeCondition, "User")
        XCTAssertEqual(fragment._parameters,    [])
    }
    
    // TODO: Test child -> parent relationship between children
    
    // ----------------------------------
    //  MARK: - StringRepresentable -
    //
    func testStringRepresentable() {
        
        let fragment = InlineFragment(type: "User", children: [
            Field(name: "subfield1"),
            Field(name: "subfield2"),
        ])
        
        try! fragment._add(child: Field(name: "subfield3"))
        
        XCTAssertEqual(fragment._stringRepresentation, "" ~
            "... on User {" ~
            "    subfield1" ~
            "    subfield2" ~
            "    subfield3" ~
            "}" ~
            ""
        )
    }
}
