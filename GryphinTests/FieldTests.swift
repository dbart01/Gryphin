//
//  FieldTests.swift
//  HubCenter
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
        
        XCTAssertEqual(node.name, "query")
        XCTAssertEqual(node.alias, nil)
        XCTAssertEqual(node.parameters.count, 0)
        XCTAssertEqual(node.children.count,   0)
    }
    
    func testFieldWithAlias() {
        let node = Field(name: "issues", alias: "someIssue")
        
        XCTAssertEqual(node.name, "issues")
        XCTAssertEqual(node.alias, "someIssue")
    }
    
    func testFieldWithParameters() {
        let parameter = Parameter(name: "first", value: 30)
        let node      = Field(name: "issues", parameters: [
            parameter,
        ])
        
        XCTAssertEqual(node.name, "issues")
        XCTAssertEqual(node.parameters[0], parameter)
    }
    
    func testFieldWithChildren() {
        let child = Field(name: "edges")
        let node  = Field(name: "issues", children: [
            child,
        ])
        
        XCTAssertEqual(node.name, "issues")
        let firstChild = node.children[0] as! Field
        XCTAssertTrue(firstChild == child)
    }
    
    func testParentWhenInitializingWithChild() {
        let child  = Field(name: "edges")
        let parent = Field(name: "issues", children: [child])
        
        XCTAssertNotNil(child.parent)
        XCTAssertTrue(parent == child.parent as! Field)
    }
    
    func testParentWhenAddingChild() {
        let child  = Field(name: "edges")
        let parent = Field(name: "issues")
        
        parent.add(child: child)
        
        XCTAssertNotNil(child.parent)
        XCTAssertTrue(parent == child.parent as! Field)
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
        
        let query = root.stringRepresentation
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
        
        let query = root.stringRepresentation
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
        
        let query = root.stringRepresentation
        XCTAssertEqual(query, "query{issues{edges{node{smallImage: image(size: 125) largeImage: image(size: 1024)}}}}")
    }
}
