//
//  ReferenceTypeTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-12.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class ReferenceTypeTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Init -
    //
    func testInit() {
        let reference = TestReference(name: "test")
        
        XCTAssertNil(reference._parent)
        XCTAssertEqual(reference._name, "test")
    }
    
    // ----------------------------------
    //  MARK: - Indentation -
    //
    func testIndentationCompact() {
        Environment.shared[.prettyPrint] = nil
        
        let reference = TestReference(name: "test")
        
        XCTAssertEqual(reference._newline, "")
        XCTAssertEqual(reference._space, "")
        XCTAssertEqual(reference._indent, "")
    }
    
    func testIndentationPrettyPrinted() {
        Environment.shared[.prettyPrint] = "true"
        
        let reference = TestReference(name: "test")
        
        XCTAssertEqual(reference._newline, "\n")
        XCTAssertEqual(reference._space, " ")
        
        let field1 = Field(name: "field1")
        field1._add(child: reference)
        
        XCTAssertEqual(reference._indent, self.indentationStringFor(reference: reference, depth: 1))
        
        let field2 = Field(name: "field2")
        field2._add(child: field1)
        
        XCTAssertEqual(reference._indent, self.indentationStringFor(reference: reference, depth: 2))
        
        let field3 = Field(name: "field3")
        field3._add(child: field2)
        
        XCTAssertEqual(reference._indent, self.indentationStringFor(reference: reference, depth: 3))
    }
    
    // ----------------------------------
    //  MARK: - Equality -
    //
    func testEquality() {
        let reference1 = TestReference(name: "reference")
        let reference2 = TestReference(name: "reference")
        let reference3 = reference1
        
        XCTAssertFalse(reference1 === reference2)
        XCTAssertFalse(reference1 == reference2)
        
        XCTAssertTrue(reference1 == reference3)
    }
    
    // ----------------------------------
    //  MARK: - Utilities -
    //
    private func indentationStringFor(reference: ReferenceType, depth: Int) -> String {
        return [String](repeating: reference._indentUnit, count: depth * reference._indentUnitCount).joined()
    }
}

// ----------------------------------
//  MARK: - TestReference -
//
private final class TestReference: ReferenceType {
    
    let _name:   String
    var _parent: ContainerType?
    
    init(name: String) {
        self._name = name
    }
    
    var _stringRepresentation: String {
        return self._name
    }
}
