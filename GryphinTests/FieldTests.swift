//
//  FieldTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-09.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class FieldTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testBasicField() {
        let node = Field(name: "query")
        
        XCTAssertEqual(node._name, "query")
        XCTAssertEqual(node._alias, nil)
        XCTAssertEqual(node._parameters.count, 0)
        XCTAssertEqual(node._children.count,   0)
    }
    
    func testFieldWithAlias() {
        let node = Field(name: "issues", alias: "someIssue")
        
        XCTAssertEqual(node._name, "issues")
        XCTAssertEqual(node._alias, "someIssue")
    }
    
    func testEnqueueAlias() {
        let node = Field(name: "query")
        
        node.alias("test")._add(children: [
            Field(name: "subfield"),
            Field(name: "anotherSubfield"),
        ])
        
        let firstChild  = node._children[0] as! Field
        let secondChild = node._children[1] as! Field
        
        XCTAssertEqual(firstChild._name, "subfield")
        XCTAssertEqual(firstChild._alias, "test")
        
        XCTAssertEqual(secondChild._name, "anotherSubfield")
        XCTAssertNil(secondChild._alias)
    }
    
    func testFieldWithParameters() {
        let parameter = Parameter(name: "first", value: 30)
        let node      = Field(name: "issues", parameters: [
            parameter,
        ])
        
        XCTAssertEqual(node._name, "issues")
        XCTAssertEqual(node._parameters[0], parameter)
    }
    
    func testFieldWithChildren() {
        let child = Field(name: "edges")
        let node  = Field(name: "issues", children: [
            child,
        ])
        
        XCTAssertEqual(node._name, "issues")
        let firstChild = node._children[0] as! Field
        XCTAssertTrue(firstChild == child)
    }
    
    func testParentWhenInitializingWithChild() {
        let child  = Field(name: "edges")
        let parent = Field(name: "issues", children: [child])
        
        XCTAssertNotNil(child._parent)
        XCTAssertTrue(parent == child._parent as! Field)
    }
    
    func testParentWhenAddingChild() {
        let child  = Field(name: "edges")
        let parent = Field(name: "issues")
        
        parent._add(child: child)
        
        XCTAssertNotNil(child._parent)
        XCTAssertTrue(parent == child._parent as! Field)
    }
}
