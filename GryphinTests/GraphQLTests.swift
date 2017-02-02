//
//  GraphQLTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-02.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class GraphQLTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Values -
    //
    func testGraphQLValues() {
        XCTAssertEqual(GraphQL.Key.typeName,       "__typename")
        XCTAssertEqual(GraphQL.Custom.aliasPrefix, "__alias_")
    }
    
    // ----------------------------------
    //  MARK: - Extensions -
    //
    func testAliasPrefix() {
        let string = "user".aliasPrefixed
        XCTAssertEqual(string, "\(GraphQL.Custom.aliasPrefix)user")
    }
    
    func testHasAliasPrefix() {
        let stringWithPrefix = "\(GraphQL.Custom.aliasPrefix)repo"
        XCTAssertTrue(stringWithPrefix.hasAliasPrefix)
        
        let stringWithoutPrefix = "__some_repo"
        XCTAssertFalse(stringWithoutPrefix.hasAliasPrefix)
    }
}
