//
//  Swift.PropertyTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-31.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SwiftPropertyTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Init -
    //
    func testCompleteInit() {
        let property = self.completePropertyWithAccessors()
        
        XCTAssertEqual(property.kind,       .instance)
        XCTAssertEqual(property.visibility, .public)
        XCTAssertEqual(property.override,   true)
        XCTAssertEqual(property.mutable,    true)
        XCTAssertEqual(property.name,       "date")
        XCTAssertEqual(property.returnType, "Date")
        
        let annotations = property.annotations!
        
        XCTAssertEqual(annotations[0], .discardableResult)
        
        let accessors = property.children as! [Swift.Property.Accessor]
        
        XCTAssertEqual(accessors[0].kind, .get)
        XCTAssertEqual(accessors[0].children.count, 1)
        
        XCTAssertEqual(accessors[1].kind, .set)
        XCTAssertEqual(accessors[1].children.count, 1)
        
        XCTAssertEqual(property.comments.count, 1)
        XCTAssertEqual(property.comments[0], Swift.Line(content: "This is a date accessor"))
        
        let property2 = self.completePropertyWithBody()
        
        XCTAssertEqual(property2.children.count, 1)
    }
    
    func testPartialInit() {
        let property = self.partialProperty()
        
        XCTAssertEqual(property.kind,       .static)
        XCTAssertEqual(property.visibility, .none)
        XCTAssertEqual(property.override,   false)
        XCTAssertEqual(property.mutable,    false)
        XCTAssertEqual(property.name,       "time")
        XCTAssertEqual(property.returnType, "Time")
        
        XCTAssertEqual(property.children.count, 0)
    }
    
    private func partialProperty() -> Swift.Property {
        return Swift.Property(
            kind:       .static,
            visibility: .none,
            override:   false,
            mutable:    false,
            name:       "time",
            returnType: "Time",
            accessors:  nil,
            body:       nil,
            comments:   nil
        )
    }
    
    private func completePropertyWithAccessors() -> Swift.Property {
        return Swift.Property(
            kind: .instance,
            visibility: .public,
            override:   true,
            mutable:    true,
            name:       "date",
            returnType: "Date",
            annotations: [
                .discardableResult
            ],
            accessors: [
                Swift.Property.Accessor(kind: .get, body: [
                    "return Date()"
                    ]),
                Swift.Property.Accessor(kind: .set, body: [
                    "_date = newValue"
                    ]),
                ],
            body:     nil,
            comments: [
                "This is a date accessor"
            ]
        )
    }
    
    
    
    private func completePropertyWithBody() -> Swift.Property {
        return Swift.Property(
            kind: .instance,
            visibility: .public,
            override:   true,
            mutable:    true,
            name:       "date",
            returnType: "Date",
            accessors:  nil,
            body: [
                "_date = newValue"
            ],
            comments: [
                "This is a date accessor"
            ]
        )
    }
    
    // ----------------------------------
    //  MARK: - StringRepresentation -
    //
    func testCompleteStringRepresentation() {
        let property     = self.completePropertyWithAccessors()
        
        let container    = Swift.Container()
        let subcontainer = Swift.Container()
        
        container.add(child: subcontainer)
        subcontainer.add(child: property)
        
        XCTAssertEqual(property.stringRepresentation, "" ~
            "    /// This is a date accessor" ~
            "    @discardableResult" ~
            "    public override var date: Date {" ~
            "        get {" ~
            "            return Date()" ~
            "        }" ~
            "        set {" ~
            "            _date = newValue" ~
            "        }" ~
            "    }" ~
            ""
        )
    }
    
    func testPartialStringRepresentation() {
        let property  = self.partialProperty()
        let container = Swift.Container()
        
        container.add(child: property)
        
        XCTAssertEqual(property.stringRepresentation, "" ~
            "static let time: Time" ~
            ""
        )
    }
    
    // ----------------------------------
    //  MARK: - Property.Accessor -
    //
    func testAccessorInit() {
        let accessor1 = Swift.Property.Accessor(kind: .get, body: ["return self"])
        XCTAssertEqual(accessor1.kind, .get)
        XCTAssertEqual(accessor1.children.count, 1)
        
        let accessor2 = Swift.Property.Accessor(kind: .set, body: ["return self"])
        XCTAssertEqual(accessor2.kind, .set)
        
        let accessor3 = Swift.Property.Accessor(kind: .willSet, body: ["return self"])
        XCTAssertEqual(accessor3.kind, .willSet)
        
        let accessor4 = Swift.Property.Accessor(kind: .didSet, body: ["return self"])
        XCTAssertEqual(accessor4.kind, .didSet)
    }
    
    func testAccessorKindValues() {
        XCTAssertEqual(Swift.Property.Accessor.Kind.get.rawValue,     "get")
        XCTAssertEqual(Swift.Property.Accessor.Kind.set.rawValue,     "set")
        XCTAssertEqual(Swift.Property.Accessor.Kind.willSet.rawValue, "willSet")
        XCTAssertEqual(Swift.Property.Accessor.Kind.didSet.rawValue,  "didSet")
    }
    
    func testAccessorStringRepresentation() {
        let accessor  = Swift.Property.Accessor(kind: .get, body: ["return self"])
        let container = Swift.Container()
        
        container.add(child: accessor)
        
        XCTAssertEqual(accessor.stringRepresentation, "" ~
            "get {" ~
            "    return self" ~
            "}"
        )
    }
}
