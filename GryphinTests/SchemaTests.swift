//
//  SchemaTests.swift
//  HubCenter
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
        let data   = try! Data(contentsOf: url)
        let json   = try! JSONSerialization.jsonObject(with: data, options: [])
        
        print("")
    }
}
