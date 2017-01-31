//
//  Swift.ContainerTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-29.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SwiftContainerTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testInit() {
        let container = Swift.Container()
        
        XCTAssertNil(container.parent)
        XCTAssertEqual(container.children.count, 0)
    }
    
    // ----------------------------------
    //  MARK: - StringRepresentable -
    //
    func testStringRepresentation() {
        let container = Swift.Container()
        
        container.add(child: Swift.Line(content: "line1"))
        container.add(child: Swift.Line(content: "line2"))
        container.add(child: Swift.Line(content: "line3"))
        
        XCTAssertEqual(container.stringRepresentation, "" ~
            "line1" ~
            "line2" ~
            "line3"
        )
        
        let superContainer = Swift.Container()
        superContainer.add(child: container)
        
        XCTAssertEqual(container.stringRepresentation, "" ~
            "    line1" ~
            "    line2" ~
            "    line3"
        )
    }
}
