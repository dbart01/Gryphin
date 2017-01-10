//
//  QueryGenerationTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-21.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class QueryGenerationTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Setup -
    //
    override func setUp() {
        super.setUp()
        
        precondition(Environment.prettyPrint, "Query generation requires the \"com.gryphin.prettyPrint\" environment variable to be set.")
    }

    // ----------------------------------
    //  MARK: - Tests -
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
            "                image(size: 125)" ~
            "                largeImage: image(size: 1024)" ~
            "            }" ~
            "        }" ~
            "    }" ~
            "}" ~
            ""
        )
    }
}
