//
//  Swift.ClassTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-30.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SwiftClassTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testClassInitComplete() {
        let container  = Swift.Container()
        let modelClass = Swift.Class(
            visibility:   .none,
            kind:         .class(.final),
            name:         "Model",
            inheritances: ["Supermodel"],
            comments:     ["This is a model subclass"],
            containables: [
                Swift.Method(
                    visibility: .none,
                    name:       .init(.none, false),
                    body: [
                        "// initialize",
                    ]
                )
            ]
        )
        
        container.add(child: modelClass)
        
        XCTAssertNotNil(modelClass)
        XCTAssertEqual(modelClass.stringRepresentation, "" ~
            "/// This is a model subclass" ~
            "final class Model: Supermodel {" ~
            "" ~
            "    init() {" ~
            "        // initialize" ~
            "    }" ~
            "}" ~
            ""
        )
    }
    
    func testStructInitPartial() {
        let container  = Swift.Container()
        let modelClass = Swift.Class(
            visibility:   .public,
            kind:         .struct,
            name:         "Model",
            inheritances: nil,
            comments:     nil,
            containables: nil
        )
        
        container.add(child: modelClass)
        
        XCTAssertNotNil(modelClass)
        XCTAssertEqual(modelClass.stringRepresentation, "" ~
            "public struct Model {}" ~
            ""
        )
    }
    
    // ----------------------------------
    //  MARK: - Class Kind -
    //
    func testKindValues() {
        XCTAssertEqual(Swift.Class.Kind.class(nil).string,    "class")
        XCTAssertEqual(Swift.Class.Kind.class(.final).string, "final class")
        XCTAssertEqual(Swift.Class.Kind.struct.string,        "struct")
        XCTAssertEqual(Swift.Class.Kind.protocol.string,      "protocol")
        XCTAssertEqual(Swift.Class.Kind.extension.string,     "extension")
        XCTAssertEqual(Swift.Class.Kind.enum.string,          "enum")
    }
}
