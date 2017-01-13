//
//  ContainerTypeTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-10.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class ContainerTypeTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Init -
    //
    func testInit() {
        let container = TestContainer(name: "1")
        
        XCTAssertEqual(container._children.count, 0)
        XCTAssertNil(container._parent)
    }

    // ----------------------------------
    //  MARK: - Children -
    //
    func testAddChild() {
        let container = TestContainer(name: "1")
        let child     = TestContainer(name: "2")
        
        container._add(child: child)
        
        XCTAssertEqual(container._children.count, 1)
        XCTAssertNil(container._parent)
        
        XCTAssertEqual(child._parent!._name, container._name)
    }
    
    func testAddChildren() {
        let container  = TestContainer(name: "1")
        let child2     = TestContainer(name: "2")
        let child3     = TestContainer(name: "3")
        
        container._add(children: [
            child2,
            child3,
        ])
        
        XCTAssertEqual(container._children.count, 2)
        XCTAssertNil(container._parent)
        
        XCTAssertEqual(child2._parent!._name, container._name)
        XCTAssertEqual(child3._parent!._name, container._name)
    }
    
    // ----------------------------------
    //  MARK: - Equality -
    //
    func testEquality() {
        let container1 = TestContainer(name: "container")
        let container2 = TestContainer(name: "container")
        let container3 = container1
        
        XCTAssertFalse(container1 === container2)
        XCTAssertFalse(container1 == container2)
        
        XCTAssertTrue(container1 == container3)
    }
}

// ----------------------------------
//  MARK: - TestContainer -
//
private final class TestContainer: ContainerType {
    
    let _name: String
    
    var _parent:     ContainerType?
    var _children:   [ReferenceType] = []
    var _parameters: [Parameter]     = []
    
    init(name: String) {
        self._name = name
    }
    
    var _stringRepresentation: String {
        return self._name
    }
}
