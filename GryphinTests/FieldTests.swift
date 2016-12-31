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
    
    // ----------------------------------
    //  MARK: - Serialization -
    //
    func testParametersWithChildren() {
        
        let root = Field(name: "query", children: [
            Field(name: "issues", parameters: [
                Parameter(name: "first", value: 30),
            ], children: [
                Field(name: "edges", children: [
                    Field(name: "node", children: [
                        Field(name: "id"),
                        Field(name: "title"),
                    ])
                ])
            ])
        ])
        
        let query = root._stringRepresentation
        XCTAssertEqual(query, "query{issues(first: 30){edges{node{id title}}}}")
    }
    
    func testParametersWithoutChildren() {
        
        let root = Field(name: "query", children: [
            Field(name: "issues", children: [
                Field(name: "edges", children: [
                    Field(name: "node", children: [
                        Field(name: "id"),
                        Field(name: "title"),
                        Field(name: "image", parameters: [
                            Parameter(name: "size", value: 1024),
                        ])
                    ])
                ])
            ])
        ])
        
        let query = root._stringRepresentation
        XCTAssertEqual(query, "query{issues{edges{node{id title image(size: 1024)}}}}")
    }
    
    func testAliases() {
        
        let root = Field(name: "query", children: [
            Field(name: "issues", children: [
                Field(name: "edges", children: [
                    Field(name: "node", children: [
                        Field(name: "image", alias: "smallImage", parameters: [
                            Parameter(name: "size", value: 125),
                        ]),
                        Field(name: "image", alias: "largeImage", parameters: [
                            Parameter(name: "size", value: 1024),
                        ]),
                    ])
                ])
            ])
        ])
        
        let query = root._stringRepresentation
        XCTAssertEqual(query, "query{issues{edges{node{smallImage: image(size: 125) largeImage: image(size: 1024)}}}}")
    }
}
