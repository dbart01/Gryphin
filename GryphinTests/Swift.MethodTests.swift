//
//  Swift.MethodTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-31.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SwiftMethodTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testCompleteInit() {
        let result    = self.completeMethod()
        let method    = result.method
        let parameter = result.parameter
        
        XCTAssertEqual(method.visibility,   .public)
        XCTAssertEqual(method.name,         Swift.Method.Name.func("render"))
        XCTAssertEqual(method.returnType,   "Void")
        XCTAssertEqual(method.annotations!, [Swift.Annotation.discardableResult])
        
        XCTAssertEqual(method.parameters!.count, 1)
        XCTAssertEqual(method.parameters![0], parameter)
        
        let body = method.children as! [Swift.Line]
        XCTAssertEqual(body.count, 1)
        XCTAssertEqual(body[0], Swift.Line(content: "let array = [String]()"))
        
        XCTAssertEqual(method.comments.count, 1)
        XCTAssertEqual(method.comments[0], Swift.Line(content: "A method that renders"))
    }
    
    func testPartialInit() {
        let method = self.partialMethod()
        
        XCTAssertEqual(method.visibility, .none)
        XCTAssertEqual(method.name, Swift.Method.Name.func("render"))
        
        XCTAssertNil(method.returnType)
        XCTAssertNil(method.parameters)
        XCTAssertNil(method.annotations)
        
        XCTAssertTrue(method.comments.isEmpty)
        XCTAssertTrue(method.children.isEmpty)
    }
    
    func testMethodCompleteStringRepresentation() {
        let method    = self.completeMethod().method
        let container = Swift.Container()
        container.add(child: method)
        
        XCTAssertEqual(method.stringRepresentation, "" ~
            "/// A method that renders" ~
            "@discardableResult" ~
            "public func render(image: Image) -> Void {" ~
            "    let array = [String]()" ~
            "}" ~
            ""
        )
    }
    
    func testMethodPartialStringRepresentation() {
        let method    = self.partialMethod()
        let container = Swift.Container()
        container.add(child: method)
        
        XCTAssertEqual(method.stringRepresentation, "" ~
            "func render()" ~
            ""
        )
    }
    
    func testMethodEquality() {
        let method1 = self.partialMethod()
        let method2 = self.partialMethod()
        
        XCTAssertEqual(method1, method2)
        XCTAssertFalse(method1 === method2)
        
        let method3 = self.completeMethod().method
        let method4 = self.completeMethod().method
        
        XCTAssertEqual(method3, method4)
        XCTAssertFalse(method3 === method4)
    }
    
    func testAppendingMethodContent() {
        let method = self.partialMethod()
        
        XCTAssertEqual(method.children.count, 0)
        
        method += "let array = [String]()"
        
        XCTAssertEqual(method.children.count, 1)
        
        method += ""
        
        XCTAssertEqual(method.children.count, 2)
        
        method += "return array"
        
        XCTAssertEqual(method.children.count, 3)
    }
    
    private func partialMethod() -> Swift.Method {
        return Swift.Method(
            visibility:  .none,
            name:        .func("render"),
            returnType:  nil,
            parameters:  nil,
            annotations: nil,
            body:        nil,
            comments:    nil
        )
    }
    
    private func completeMethod() -> (method: Swift.Method, parameter: Swift.Method.Parameter) {
        let parameter = Swift.Method.Parameter(name: "image", type: "Image")
        let method    = Swift.Method(
            visibility:  .public,
            name:        .func("render"),
            returnType:  "Void",
            parameters:  [parameter],
            annotations: [Swift.Annotation.discardableResult],
            body:        [
                "let array = [String]()"
            ],
            comments:    [
                "A method that renders"
            ]
        )
        
        return (method, parameter)
    }
    
    // ----------------------------------
    //  MARK: - Method.Name -
    //
    func testMethodNameInit() {
        let init1 = Swift.Method.Name.init(.required, true)
        XCTAssertEqual(init1.string, "required init?")
        
        let init2 = Swift.Method.Name.init(.convenience, false)
        XCTAssertEqual(init2.string, "convenience init")
        
        let init3 = Swift.Method.Name.init(.none, false)
        XCTAssertEqual(init3.string, "init")
        
        let function = Swift.Method.Name.func("render")
        XCTAssertEqual(function.string, "func render")
    }
    
    func testMethodNameInitializerEquality() {
        let init1 = Swift.Method.Name.init(.required, true)
        let init2 = Swift.Method.Name.init(.required, true)
        
        XCTAssertEqual(init1, init2)
        
        let init3 = Swift.Method.Name.init(.required, false)
        let init4 = Swift.Method.Name.init(.none, true)
        
        XCTAssertNotEqual(init2, init3)
        XCTAssertNotEqual(init2, init4)
    }
    
    func testMethodNameFunctionEquality() {
        let func1 = Swift.Method.Name.func("render")
        let func2 = Swift.Method.Name.func("render")
        
        XCTAssertEqual(func1, func2)
        
        let func3 = Swift.Method.Name.func("rendering")
        
        XCTAssertNotEqual(func2, func3)
    }
    
    // ----------------------------------
    //  MARK: - Method.Parameter -
    //
    func testParameterInit() {
        let param = Swift.Method.Parameter(
            unnamed: false,
            name:    "image",
            type:    "Image",
            default: .value("Image()")
        )
        
        XCTAssertEqual(param.unnamed,  false)
        XCTAssertEqual(param.name,     "image")
        XCTAssertEqual(param.type,     "Image")
        XCTAssertEqual(param.default!, Swift.Method.Parameter.Default.value("Image()"))
    }
    
    func testParameterStringRepresentation() {
        let param1 = Swift.Method.Parameter(
            unnamed: false,
            name:    "image",
            type:    "Image",
            default: .value("Image()")
        )
        
        XCTAssertEqual(param1.stringRepresentation, "" ~
            "image: Image = Image()"
        )
        
        let param2 = Swift.Method.Parameter(
            unnamed: true,
            name:    "character",
            type:    "Character",
            default: nil
        )
        
        XCTAssertEqual(param2.stringRepresentation, "" ~
            "_ character: Character"
        )
        
        let param3 = Swift.Method.Parameter(
            unnamed: true,
            name:    "animal",
            type:    "Animal?",
            default: .nil
        )
        
        XCTAssertEqual(param3.stringRepresentation, "" ~
            "_ animal: Animal? = nil"
        )
    }
}
