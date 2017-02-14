//
//  Swift.AliasTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-31.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SwiftAliasTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testInit() {
        let alias = Swift.Alias(name: "SuperString", forType: "String")
        
        XCTAssertNil(alias.parent)
        XCTAssertEqual(alias.name,    "SuperString")
        XCTAssertEqual(alias.forType, "String")
    }
    
    func testStringRepresentationDefault() {
        let alias = Swift.Alias(visibility: .none, name: "SuperString", forType: "String")
        
        let container    = Swift.Container()
        let subcontainer = Swift.Container()
        
        container.add(child: subcontainer)
        subcontainer.add(child: alias)
        
        XCTAssertEqual(alias.stringRepresentation, "" ~
            "    typealias SuperString = String" ~
            ""
        )
    }
    
    func testStringRepresentationPublic() {
        let alias = Swift.Alias(visibility: .public, name: "SuperString", forType: "String")
        
        let container    = Swift.Container()
        let subcontainer = Swift.Container()
        
        container.add(child: subcontainer)
        subcontainer.add(child: alias)
        
        XCTAssertEqual(alias.stringRepresentation, "" ~
            "    public typealias SuperString = String" ~
            ""
        )
    }
}
