//
//  SchemaTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-24.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

import XCTest
@testable import Gryphin

class SchemaTests: XCTestCase {

    func testSchema() {
        let bundle = Bundle(for: self.classForCoder)
        let url    = bundle.url(forResource: "schema", withExtension: "json")!
        
        let generator = try! Swift.Generator(withSchemaAt: url)
        let document  = generator.generate()
        let string    = document.stringRepresentation
        
        let path = URL(fileURLWithPath: "/Users/dbart/Desktop/API.swift")
        try! string.write(to: path, atomically: true, encoding: .utf8)
        
        print("")
    }
}
