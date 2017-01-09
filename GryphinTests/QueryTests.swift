//
//  QueryTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-21.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class QueryTests: XCTestCase {

    func testQuery() {
        
        let someClass = Swift.Class(name: "Query", inheritances: ["Field"])
        someClass.add(children: [
            
            Swift.Method(visibility: .public, name: .init(.required), parameters: [
                Swift.Method.Parameter(name: "_ buildOn", type: .normal("(Query) -> Void"))
            ], body: [
                "super.init(name: \"query\")",
                "",
                "buildOn(self)",
            ]),
            
            Swift.Method(visibility: .public, name: .func("viewer"), returnType: "Query", parameters: [
                Swift.Method.Parameter(name: "_ buildOn", type: .normal("(User) -> Void")),
            ], annotations: [.discardableResult], body: [
                "let viewer = User(name: \"viewer\")",
                "self.add(child: viewer)",
                "",
                "buildOn(viewer)",
                "",
                "return self"
            ], comments: [
                "The viewer for the thing that does stuff",
            ]),
            
            Swift.Method(visibility: .public, name: .func("viewer"), returnType: "Query", parameters: [
                Swift.Method.Parameter(name: "_ buildOn", type: .normal("(User) -> Void")),
            ], body: [
                "let viewer = User(name: \"viewer\")",
                "self.add(child: viewer)",
                "",
                "buildOn(viewer)",
                "",
                "return self"
            ], comments: [
                "The viewer for the thing that does stuff",
            ]),
        ])
        
        let otherClass = Swift.Class(name: "Query", inheritances: ["Field"])
        otherClass.add(children: [
            
            Swift.Method(visibility: .public, name: .init(.required), parameters: [
                Swift.Method.Parameter(name: "_ buildOn", type: .normal("(Query) -> Void"))
                ], body: [
                    "super.init(name: \"query\")",
                    "",
                    "buildOn(self)",
                    ]),
            
            Swift.Method(visibility: .public, name: .func("viewer"), returnType: "Query", parameters: [
                Swift.Method.Parameter(name: "_ buildOn", type: .normal("(User) -> Void")),
                ], annotations: [.discardableResult], body: [
                    "let viewer = User(name: \"viewer\")",
                    "self.add(child: viewer)",
                    "",
                    "buildOn(viewer)",
                    "",
                    "return self"
                ], comments: [
                    "The viewer for the thing that does stuff",
                    ]),
            
            Swift.Method(visibility: .public, name: .func("viewer"), returnType: "Query", parameters: [
                Swift.Method.Parameter(name: "_ buildOn", type: .normal("(User) -> Void")),
                ], body: [
                    "let viewer = User(name: \"viewer\")",
                    "self.add(child: viewer)",
                    "",
                    "buildOn(viewer)",
                    "",
                    "return self"
                ], comments: [
                    "The viewer for the thing that does stuff",
                    ]),
            ])
        
        let namespace = Swift.Namespace(items: [
            someClass,
            otherClass,
        ])
        
        print(namespace.stringRepresentation)
        print("")
    }
}
