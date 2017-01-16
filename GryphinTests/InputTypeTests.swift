//
//  InputTypeTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-16.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

import XCTest
@testable import Gryphin

class InputTypeTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Init -
    //
    func testInit() {
        let input = TestInput(name: "name")
        
        XCTAssertNotNil(input.name)
        XCTAssertNil(input.email)
        XCTAssertNil(input.child)
    }
    
    // ----------------------------------
    //  MARK: - Serialization -
    //
    func testSerialization() {
        let input = TestInput(name: "John", email: "john@smith.com")
        
        let params = input._representationParameters()
        
        XCTAssertEqual(params.count, 2)
        
        let string = input._stringRepresentation
        
        XCTAssertEqual(string, "{name: \"John\", email: \"john@smith.com\"}")
    }
    
    func testSerializationWithChildInput() {
        let child = TestChildInput(name: "Torry", email: "torry@smith.com")
        let input = TestInput(name: "John", email: "john@smith.com", child: child)
        
        let params = input._representationParameters()
        
        XCTAssertEqual(params.count, 3)
        
        let string = input._stringRepresentation
        
        XCTAssertEqual(string, "{name: \"John\", email: \"john@smith.com\", child: {name: \"Torry\", email: \"torry@smith.com\"}}")
    }
}

// ----------------------------------
//  MARK: - TestInput -
//
private final class TestInput: InputType {
    
    let name:  String
    let email: String?
    let child: TestChildInput?
    
    init(name: String, email: String? = nil, child: TestChildInput? = nil) {
        self.name  = name
        self.email = email
        self.child = child
    }
    
    func _representationParameters() -> [Parameter] {
        var parameters: [Parameter] = []
        
        parameters += Parameter(name: "name", value: self.name)
        
        if let email = self.email {
            parameters += Parameter(name: "email", value: email)
        }
        
        if let child = self.child {
            parameters += Parameter(name: "child", value: child)
        }
        
        return parameters
    }
}

private final class TestChildInput: InputType {
    
    let name:  String
    let email: String?
    
    init(name: String, email: String? = nil) {
        self.name  = name
        self.email = email
    }
    
    func _representationParameters() -> [Parameter] {
        var parameters: [Parameter] = []
        
        parameters += Parameter(name: "name", value: self.name)
        
        if let email = self.email {
            parameters += Parameter(name: "email", value: email)
        }
        
        return parameters
    }
}
