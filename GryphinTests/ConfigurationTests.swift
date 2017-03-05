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
                "url": "https://www.schema.com/graphql",
                "headers": [
                    "Authorization": "Bearer token",
                ]
            ],
            "scalars": [
                [
                    "name": "DateTime",
                    "alias": "Date",
                ],
                [
                    "name": "ID",
                    "file": ".scalars",
                ]
            ]
        ]
        
        let configuration = Configuration(json: json)
        
        XCTAssertNotNil(configuration)
        
        XCTAssertNotNil(configuration.schemaDescription)
        XCTAssertEqual(configuration.schemaDescription!.path, URL(fileURLWithPath: "schema.json"))
        XCTAssertEqual(configuration.schemaDescription!.url,  URL(string: "https://www.schema.com/graphql"))
        XCTAssertEqual(configuration.schemaDescription!.headers!, [
            "Authorization": "Bearer token",
        ])
        
        XCTAssertNotNil(configuration.scalarDescriptions)
        
        XCTAssertEqual(configuration.scalarDescriptions![0].name, "DateTime")
        XCTAssertTrue(self.equal(configuration.scalarDescriptions![0].source, expected: .aliasFor("Date")))
        
        XCTAssertEqual(configuration.scalarDescriptions![1].name, "ID")
        XCTAssertTrue(self.equal(configuration.scalarDescriptions![1].source, expected: .file(URL(fileURLWithPath: ".scalars"))))
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
    
    private func equal(_ source: Configuration.ScalarDescription.Source, expected: Configuration.ScalarDescription.Source) -> Bool {
        switch (source, expected) {
        case (.file(let lhs), .file(let rhs)) where lhs == rhs:
            return true
        case (.aliasFor(let lhs), .aliasFor(let rhs)) where lhs == rhs:
            return true
        default:
            return false
        }
    }
    
    // ----------------------------------
    //  MARK: - Loading Schema -
    //
    //TODO: Write loading schema tests
}
