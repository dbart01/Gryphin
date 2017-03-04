//
//  GraphModelTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-03.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class GraphModelTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testSuccessfulInit() {
        let model = TestModel(json: [:])
        XCTAssertNotNil(model)
    }
    
    func testFailedInit() {
        let model = TestModel(json: [
            GraphQL.Key.typeName: "AnotherModel"
        ])
        XCTAssertNil(model)
    }
    
    func testInvalidTypeNameInit() {
        let model = TestModel(json: [
            GraphQL.Key.typeName: 123
        ])
        XCTAssertNil(model)
    }
    
    func testOptionalJsonNilInit() {
        let model = TestModel(json: nil)
        XCTAssertNil(model)
    }
    
    func testOptionalJsonNonnullInit() {
        let model = TestModel(json: Optional([:]))
        XCTAssertNotNil(model)
    }
    
    // ----------------------------------
    //  MARK: - Collection Init -
    //
    func testCollectionInitWithNonnull() {
        let collection: [JSON] = [
            [:],
            [:],
            [:],
        ]
        
        let models = [TestModel].from(collection)
        
        XCTAssertNotNil(models)
        XCTAssertEqual(models.count, 3)
    }
    
    func testCollectionInitContainingNull() {
        let collection: [JSON] = [
            [:],
            [GraphQL.Key.typeName: "AnotherModel"],
            [GraphQL.Key.typeName: "AnotherModel"],
            [:],
            ]
        
        let models = [TestModel].from(collection)
        
        XCTAssertNotNil(models)
        XCTAssertEqual(models.count, 2)
    }
    
    func testCollectionInitWithNull() {
        let collection: [JSON]? = nil
        
        let models = [TestModel].from(collection)
        
        XCTAssertNil(models)
    }
    
    func testCollectionInitWithNullable() {
        let collection: [JSON]? = [
            [:],
            [:],
        ]
        
        let models = [TestModel].from(collection)
        
        XCTAssertNotNil(models)
        XCTAssertEqual(models?.count, 2)
    }
    
    // ----------------------------------
    //  MARK: - Accessors -
    //
    func testSetters() {
        let model = TestModel(json: [:])
        
        try! model!.set("John", for: "name",     type: String.self)
        try! model!.set(3,      for: "children", type: Int.self)
        
        XCTAssertTrue(model!.hasValueFor("name"))
        XCTAssertTrue(model!.hasValueFor("children"))
        
        XCTAssertEqual(try! model!.valueFor(nonnull: "name"), "John")
        XCTAssertEqual(try! model!.valueFor(nonnull: "children"), 3)
    }
    
    func testScalarSetters() {
        let model = TestModel(json: [:])
        
        try! model!.set("123",  for: "id1", type: TestID.self)
        try! model!.set(nil,    for: "id2", type: TestID.self)
        
        XCTAssertTrue(model!.hasValueFor("id1"))
        XCTAssertFalse(model!.hasValueFor("id2"))
        
        let id: TestID = try! model!.valueFor(nonnull: "id1")
        XCTAssertEqual(id.string, "123")
        
        do {
            try model!.set(Data(), for: "id3", type: TestID.self)
            XCTFail()
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    func testNullSetters() {
        let model = TestModel(json: [:])
        
        try! model!.set(nil, for: "name", type: String.self)
        
        XCTAssertFalse(model!.hasValueFor("name"))
        
        try! model!.set(Optional("John"), for: "name", type: String.self)
        
        XCTAssertTrue(model!.hasValueFor("name"))
        XCTAssertEqual(try! model!.valueFor(nonnull: "name"), "John")
    }
    
    func testInvalidSchemaSetters() {
        let model = TestModel(json: [:])
        
        do {
            try model!.set(13, for: "name", type: String.self)
            XCTFail()
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    func testNonnullGetters() {
        
        let model = TestModel(json: [:])
        
        try! model!.set("John", for: "name", type: String.self)
        
        do {
            let name: String = try model!.valueFor(nonnull: "name")
            XCTAssertEqual(name, "John")
        } catch {
            XCTFail()
        }
        
        do {
            let _: Int = try model!.valueFor(nonnull: "name")
            XCTFail()
        } catch ModelError.TypeConversionFailed {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
        
        do {
            let _: String = try model!.valueFor(nonnull: "invalid")
            XCTFail()
        } catch ModelError.KeyNotFound {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }
    
    func testNullableGetters() {
        let model = TestModel(json: [:])
        
        try! model!.set("John", for: "name", type: String.self)
        
        do {
            let name: String? = try model!.valueFor(nullable: "name")
            XCTAssertNotNil(name)
            XCTAssertEqual(name, "John")
        } catch {
            XCTFail()
        }
        
        do {
            let _: String? = try model!.valueFor(nullable: "invalid")
            XCTFail()
        } catch ModelError.KeyNotFound {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }
    
    // ----------------------------------
    //  MARK: - Aliases -
    //
    func testNullableAliases() {
        let child: JSON = [
            "id": 123,
            "name": "John",
        ]
        
        let json: JSON = [
            "\(GraphQL.Custom.aliasPrefix)nonnull_child" : child,
            "\(GraphQL.Custom.aliasPrefix)null_child" : nil,
        ]
        let model = TestModel(json: json)
        
        XCTAssertNotNil(model)
        XCTAssertTrue(model!.hasAliasFor("nonnull_child"))
        XCTAssertTrue(model!.hasAliasFor("null_child"))
        XCTAssertFalse(model!.hasAliasFor("invalid"))
        
        do {
            let nonnullResult: TestModel? = try model!.aliasedWith("nonnull_child")
            XCTAssertNotNil(nonnullResult)
            
            let nullResult: TestModel? = try model!.aliasedWith("null_child")
            XCTAssertNil(nullResult)
            
        } catch {
            XCTFail()
        }
        
        do {
            let _: TestModel? = try model!.aliasedWith("invalid")
            XCTFail()
        } catch ModelError.AliasNotFound {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }
    
    func testNonnullAliases() {
        let child: JSON = [
            "id": 123,
            "name": "John",
        ]
        
        let json: JSON = [
            "\(GraphQL.Custom.aliasPrefix)child" : child,
            "\(GraphQL.Custom.aliasPrefix)nil_child" : nil,
            ]
        let model = TestModel(json: json)
        
        XCTAssertNotNil(model)
        XCTAssertTrue(model!.hasAliasFor("child"))
        XCTAssertTrue(model!.hasAliasFor("nil_child"))
        
        do {
            let result: TestModel = try model!.aliasedWith("child")
            XCTAssertNotNil(result)
        } catch {
            XCTFail()
        }
        
        do {
            let _: TestModel = try model!.aliasedWith("nil_child")
            XCTFail()
        } catch ModelError.InconsistentSchema {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }
}

// ----------------------------------
//  MARK: - Test Model -
//
private class TestModel: GraphModel {
    static override var typeName: String { return "TestModel" }
}

// ----------------------------------
//  MARK: - Test Scalar -
//
private struct TestID: ScalarType {
    
    let string: String
    
    init(from string: String) {
        self.string = string
    }
}
