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
        
//        let query = Query { $0
//            .viewer { $0
//                .repositories(first: 30) { $0
//                    .id()
//                    .name()
//                }
//            }
//        }
//        
//        let q1 = Query  { $0
//            .viewer { $0
//                
//            }
//        }
        
        let someClass = Gen.Class(name: "Query", superclass: "Field")
        someClass.add(children: [
            
            Gen.Method(visibility: .public, name: .init(.required), parameters: [
                Gen.Method.Parameter(name: "_ buildOn", type: "(Query) -> Void")
            ], body: [
                "super.init(name: \"query\")",
                "",
                "buildOn(self)",
            ]),
            
            Gen.Method(visibility: .public, name: .func("viewer"), returnType: "Query", parameters: [
                Gen.Method.Parameter(name: "_ buildOn", type: "(User) -> Void"),
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
            
            Gen.Method(visibility: .public, name: .func("viewer"), returnType: "Query", parameters: [
                Gen.Method.Parameter(name: "_ buildOn", type: "(User) -> Void"),
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
        
        let otherClass = Gen.Class(name: "Query", superclass: "Field")
        otherClass.add(children: [
            
            Gen.Method(visibility: .public, name: .init(.required), parameters: [
                Gen.Method.Parameter(name: "_ buildOn", type: "(Query) -> Void")
                ], body: [
                    "super.init(name: \"query\")",
                    "",
                    "buildOn(self)",
                    ]),
            
            Gen.Method(visibility: .public, name: .func("viewer"), returnType: "Query", parameters: [
                Gen.Method.Parameter(name: "_ buildOn", type: "(User) -> Void"),
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
            
            Gen.Method(visibility: .public, name: .func("viewer"), returnType: "Query", parameters: [
                Gen.Method.Parameter(name: "_ buildOn", type: "(User) -> Void"),
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
        
        let document = Gen.Document(classes: [
            someClass,
            otherClass,
        ])
        
        print(document.stringRepresentation)
        print("")
    }
}

final class Query: Field {
    
    required init(_ buildOn: (Query) -> Void) {
        super.init(name: "query")
        
        buildOn(self)
    }
    
    @discardableResult
    func viewer(_ buildOn: (User) -> Void) -> Query {
        let viewer = User(name: "viewer")
        self.add(child: viewer)
        
        buildOn(viewer)
        
        return self
    }
}

final class User: Field {
    
    @discardableResult
    func repositories(first: Int = 25, buildOn: (Repository) -> Void) -> User {
        let repo = Repository(name: "repositories", parameters: [
            Parameter(name: "first", value: first),
        ])
        self.add(child: repo)
        
        buildOn(repo)
        
        return self
    }
}

final class Repository: Field {
    
    @discardableResult
    func id() -> Repository {
        self.add(child: Field(name: "id"))
        return self
    }
    
    @discardableResult
    func name() -> Repository {
        self.add(child: Field(name: "name"))
        return self
    }
}

