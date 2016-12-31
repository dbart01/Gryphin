//
//  FragmentTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-12.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class FragmentTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testBasicFragment() {
        let frag = Fragment(name: "allFields", typeCondition: "User")
        
        XCTAssertEqual(frag._name, "allFields")
        XCTAssertEqual(frag._typeCondition, "User")
    }
    
    func testWithParameters() {
        let parameter = Parameter(name: "if", value: "$admin")
        let frag      = Fragment(name: "someFields", parameters: [parameter])
        
        XCTAssertEqual(frag._parameters[0], parameter)
    }
    
    // ----------------------------------
    //  MARK: - Serialization -
    //
    func testFragmentDeclaration() {
        let name       = "AllTheFields"
        let type       = "User"
        let parameters = [
            Parameter(name: "$if", value: "admin")
        ]
        let nodes      = [
            Field(name: "firstName"),
            Field(name: "lastName"),
            Field(name: "email"),
            Field(name: "friends", children: [
                Field(name: "id"),
            ])
        ]
        let fragment = Fragment(name: name, typeCondition: type, parameters: parameters, children: nodes)
        let query    = fragment._stringRepresentation
        
        let expected = "" ~
        "fragment AllTheFields on User ($if: \"admin\") {" ~
        "    firstName" ~
        "    lastName"  ~
        "    email"     ~
        "    friends {" ~
        "        id"    ~
        "    }"         ~
        "}"
        XCTAssertEqual(query, expected)
    }
}
