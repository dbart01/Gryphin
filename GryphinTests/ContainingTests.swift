//
//  ContainingTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-02.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class ContainingTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testInit() {
        let container = TestContainer()
        
        XCTAssertNil(container.parent)
        XCTAssertTrue(container.children.isEmpty)
    }
    
    // ----------------------------------
    //  MARK: - Indentation -
    //
    func testAbsoluteIndentation() {
        let container = TestContainer()
        XCTAssertEqual(container.tabWidth, 4)
        XCTAssertEqual(container.indentFor(distanceToRoot: 1), "    ")
        XCTAssertEqual(container.indentFor(distanceToRoot: 2), "        ")
        XCTAssertEqual(container.indentFor(distanceToRoot: 3), "            ")
    }
    
    func testIndentation() {
        let container1 = TestContainer()
        
        XCTAssertEqual(container1.indent, "")
        XCTAssertEqual(container1.distanceToRoot, 0)
        
        let container2 = TestContainer()
        container2.add(child: container1)
        
        XCTAssertEqual(container1.indent, "")
        XCTAssertEqual(container1.distanceToRoot, 1)
        
        let container3 = TestContainer()
        container3.add(child: container2)
        
        XCTAssertEqual(container2.indent, "")
        XCTAssertEqual(container2.distanceToRoot, 1)
        
        XCTAssertEqual(container1.indent, "    ")
        XCTAssertEqual(container1.distanceToRoot, 2)
        
        let container4 = TestContainer()
        container4.add(child: container3)
        
        XCTAssertEqual(container3.indent, "")
        XCTAssertEqual(container3.distanceToRoot, 1)
        
        XCTAssertEqual(container2.indent, "    ")
        XCTAssertEqual(container2.distanceToRoot, 2)
        
        XCTAssertEqual(container1.indent, "        ")
        XCTAssertEqual(container1.distanceToRoot, 3)
    }
    
    // ----------------------------------
    //  MARK: - Operations -
    //
    func testAdding() {
        let container1 = TestContainer()
        let container2 = TestContainer()
        
        container1.add(child: container2)
        
        XCTAssertEqual(container1.children.count, 1)
        XCTAssertTrue(container1.children[0] === container2)
        
        XCTAssertTrue(container2.parent! === container1)
        
        let container3 = TestContainer()
        let container4 = TestContainer()
        
        container1.add(children: [
            container3,
            container4,
        ])
        
        XCTAssertEqual(container1.children.count, 3)
        XCTAssertTrue(container1.children[1] === container3)
        XCTAssertTrue(container1.children[2] === container4)
        
        XCTAssertTrue(container3.parent! === container1)
        XCTAssertTrue(container4.parent! === container1)
    }
    
    func testPrepending() {
        let container1 = TestContainer()
        let container2 = TestContainer()
        
        container1.prepend(child: container2)
        
        XCTAssertEqual(container1.children.count, 1)
        XCTAssertTrue(container1.children[0] === container2)
        
        XCTAssertTrue(container2.parent! === container1)
        
        let container3 = TestContainer()
        let container4 = TestContainer()
        
        container1.prepend(children: [
            container3,
            container4,
        ])
        
        XCTAssertEqual(container1.children.count, 3)
        XCTAssertTrue(container1.children[0] === container3)
        XCTAssertTrue(container1.children[1] === container4)
        XCTAssertTrue(container1.children[2] === container2)
        
        XCTAssertTrue(container3.parent! === container1)
        XCTAssertTrue(container4.parent! === container1)
    }
    
    // ----------------------------------
    //  MARK: - Operators -
    //
    func testAppendOperatorSingle() {
        let container1 = TestContainer()
        let container2 = TestContainer()
        
        container1 += container2
        
        XCTAssertEqual(container1.children.count, 1)
        XCTAssertTrue(container1.children[0] === container2)
        
        XCTAssertTrue(container2.parent! === container1)
    }
    
    func testAppendOperatorCollection() {
        let container1 = TestContainer()
        let container2 = TestContainer()
        let container3 = TestContainer()
        
        container1 += [container2, container3]
        
        XCTAssertEqual(container1.children.count, 2)
        XCTAssertTrue(container1.children[0] === container2)
        XCTAssertTrue(container1.children[1] === container3)
        
        XCTAssertTrue(container2.parent! === container1)
        XCTAssertTrue(container3.parent! === container1)
    }
    
    // --------------------------------------------
    //  MARK: - Collection StringRepresentation -
    //
    func testCollectionStringRepresentation() {
        let containers = [
            TestContainer(),
            TestContainer(),
            TestContainer(),
        ]
        
        let string = containers.stringRepresentation
        
        XCTAssertEqual(string, "" ~
            "test" ~
            "" ~
            "test" ~
            "" ~
            "test"
        )
    }
}

// ----------------------------------
//  MARK: - TestContainer -
//
private class TestContainer: Containing {
    
    var parent:   Containing?
    var children: [Containable] = []
    
    var stringRepresentation: String {
        return "test"
    }
    
    init() {
        
    }
}
