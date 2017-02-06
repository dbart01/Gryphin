//
//  ConcreteGraphModelTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-06.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class ConcreteGraphModelTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testNonnullJsonInit() {
        let json: JSON = [
            GraphQL.Key.typeName: "InvalidType",
            "\(GraphQL.Custom.aliasPrefix)name": "John",
        ]
        
        let model = ConcreteTestModel(json: Optional(json))
        
        XCTAssertNotNil(model)
        XCTAssertFalse(model!.hasAliasFor("name"))
    }
    
    func testNullJsonInit() {
        let model = ConcreteGraphModel(json: nil)
        XCTAssertNil(model)
    }
}

private class ConcreteTestModel: ConcreteGraphModel {
    
    static override var typeName: String {
        return "ConcreteTestModel"
    }
}
