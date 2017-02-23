//
//  ConfigurationTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-22.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class ConfigurationTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testCompleteInit() {
        let json: JSON = [
            "schema": [
                "path": "schema.json",
                "url": "https://www.schema.com/graphql"
            ]
        ]
        
        let configuration = Configuration(json: json)
        
        XCTAssertNotNil(configuration)
        XCTAssertEqual(configuration.schemaDescription!.path, URL(fileURLWithPath: "schema.json"))
        XCTAssertEqual(configuration.schemaDescription!.url, URL(string: "https://www.schema.com/graphql"))
    }
    
    func testIncompleteInit() {
        let json: JSON = [
            "schema": [:]
        ]
        
        let configuration = Configuration(json: json)
        
        XCTAssertNotNil(configuration)
        XCTAssertNil(configuration.schemaDescription!.path)
        XCTAssertNil(configuration.schemaDescription!.url)
    }
    
    // ----------------------------------
    //  MARK: - Loading Schema -
    //
    //TODO: Write loading schema tests
}
