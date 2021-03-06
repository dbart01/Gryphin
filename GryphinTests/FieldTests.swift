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
    //  MARK: - Setup -
    //
    override func setUp() {
        super.setUp()
        
        precondition(Environment.prettyPrint, "Field tests require the \"com.gryphin.prettyPrint\" environment variable to be set.")
    }
    
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
    
    // ----------------------------------
    //  MARK: - Alias -
    //
    func testFieldWithAlias() {
        let node = Field(name: "issues", alias: "someIssue")
        
        XCTAssertEqual(node._name, "issues")
        XCTAssertEqual(node._alias, "someIssue".aliasPrefixed)
    }
    
    func testEnqueueAlias() {
        let node = Field(name: "query")
        let genericNode: ContainerType = node.alias("test")
            
        try! genericNode._add(children: [
            Field(name: "subfield"),
            Field(name: "anotherSubfield"),
        ])
        
        let firstChild  = genericNode._children[0] as! Field
        let secondChild = genericNode._children[1] as! Field
        
        XCTAssertEqual(firstChild._name, "subfield")
        XCTAssertNotNil(firstChild._alias)
        XCTAssertEqual(firstChild._alias, "test".aliasPrefixed)
        
        XCTAssertEqual(secondChild._name, "anotherSubfield")
        XCTAssertNil(secondChild._alias)
    }
    
    func testEnqueueInvalidAlias() {
        let node = Field(name: "query")
        
        _ = node.alias("test")
        
        XCTAssertThrowsError(
            try node._add(children: [
                InlineFragment(type: "subfield"),
            ])
            
        , "Adding aliases to inline fragments should throw an error.") { error in
            switch error {
            case FieldError.InvalidSyntax(_):
                break
            default:
                XCTFail()
            }
        }
    }
    
    // ----------------------------------
    //  MARK: - Parameters -
    //
    func testFieldWithParameters() {
        let parameter = Parameter(name: "first", value: 30)
        let node      = Field(name: "issues", parameters: [
            parameter,
        ])
        
        XCTAssertEqual(node._name, "issues")
        XCTAssertEqual(node._parameters[0], parameter)
    }
    
    // TODO: Test child -> parent relationship between children
    
    // ----------------------------------
    //  MARK: - Children -
    //
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
        
        try! parent._add(child: child)
        
        XCTAssertNotNil(child._parent)
        XCTAssertTrue(parent == child._parent as! Field)
    }
    
    // ----------------------------------
    //  MARK: - StringRepresentable -
    //
    func testFieldsWithChildren() {
        
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
        
        XCTAssertEqual(query, "" ~
            "query {" ~
            "    issues(first: 30) {" ~
            "        edges {" ~
            "            node {" ~
            "                id" ~
            "                title" ~
            "            }" ~
            "        }" ~
            "    }" ~
            "}" ~
            ""
        )
    }
    
    func testFieldsWithoutChildren() {
        
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
        
        XCTAssertEqual(query, "" ~
            "query {" ~
            "    issues {" ~
            "        edges {" ~
            "            node {" ~
            "                id" ~
            "                title" ~
            "                image(size: 1024)" ~
            "            }" ~
            "        }" ~
            "    }" ~
            "}" ~
            ""
        )
    }
    
    func testFieldAliases() {
        
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
        XCTAssertEqual(query, "" ~
            "query {" ~
            "    issues {" ~
            "        edges {" ~
            "            node {" ~
            "                \(GraphQL.Custom.aliasPrefix)smallImage: image(size: 125)" ~
            "                \(GraphQL.Custom.aliasPrefix)largeImage: image(size: 1024)" ~
            "            }" ~
            "        }" ~
            "    }" ~
            "}" ~
            ""
        )
    }
}
