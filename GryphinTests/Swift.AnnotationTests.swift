//
//  Swift.AnnotationTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-30.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SwiftAnnotationTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Values -
    //
    func testValues() {
        XCTAssertEqual(Swift.Annotation.discardableResult.stringRepresentation, "@discardableResult")
        
        XCTAssertEqual(Swift.Annotation.available([
            .init(platform: .tvOS),
        ]).stringRepresentation, "@available(tvOS)")
        
        
        XCTAssertEqual(Swift.Annotation.available([
            .init(platform: .macOS),
            .init(name: .deprecated),
        ]).stringRepresentation, "@available(macOS, deprecated)")
        
        XCTAssertEqual(Swift.Annotation.available([
            .init(platform: .any),
            .init(name: .deprecated, value: .default("7.0")),
            .init(name: .obsolete,   value: .default("9.0")),
            .init(name: .message,    value: .quoted("There's a good reason."))
        ]).stringRepresentation, "@available(*, deprecated: 7.0, obsolete: 9.0, message: \"There's a good reason.\")")
    }
    
    // ----------------------------------
    //  MARK: - Equality -
    //
    func testValueEquality() {
        let param1 = Swift.Annotation.Parameter.Value.default("10.0")
        let param2 = Swift.Annotation.Parameter.Value.default("10.0")
        
        XCTAssertEqual(param1, param2)
        
        let param3 = Swift.Annotation.Parameter.Value.quoted("10.0")
        
        XCTAssertNotEqual(param1, param3)
    }
    
    func testParameterEquality() {
        let param1 = Swift.Annotation.Parameter(platform: .iOS)
        let param2 = Swift.Annotation.Parameter(platform: .iOS)
        
        XCTAssertEqual(param1, param2)
        
        let param3 = Swift.Annotation.Parameter(platform: .macOS)
        
        XCTAssertNotEqual(param1, param3)
    }
    
    func testAnnotationEquality() {
        let param1 = Swift.Annotation.available([
            .init(platform: .iOS)
        ])
        let param2 = Swift.Annotation.available([
            .init(platform: .iOS)
        ])
        
        XCTAssertEqual(param1, param2)
        
        let param3 = Swift.Annotation.available([
            .init(platform: .macOS)
        ])
        
        XCTAssertNotEqual(param1, param3)
        
        let param4 = Swift.Annotation.discardableResult
        
        XCTAssertNotEqual(param1, param4)
    }
}
