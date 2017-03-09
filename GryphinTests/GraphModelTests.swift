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
    //  MARK: - Any Setter -
    //
    func testAnySetterWithNonnull() {
        let model      = TestModel(json: [:])!
        let json: JSON = [
            "name": "John",
        ]
        
        do {
            try model.set(any: json["name"], for: "name", convertUsing: { $0 })
        } catch {
            XCTFail()
        }
        
        XCTAssertTrue(model.hasValueFor("name"))
        XCTAssertEqual(try! model.valueFor(nonnull: "name"), "John")
    }
    
    func testAnySetterWithNull() {
        let model      = TestModel(json: [:])!
        let json: JSON = [
            "name": nil,
        ]
        
        do {
            try model.set(any: json["name"], for: "name", convertUsing: { value in
                XCTFail("Any setter should not call converter if value is nil.")
                return value
            })
        } catch {
            XCTFail()
        }
        
        XCTAssertTrue(model.hasValueFor("name"))
        XCTAssertNil(try! model.valueFor(nullable: "name"))
    }
    
    func testAnySetterWithEmpty() {
        let model      = TestModel(json: [:])!
        let json: JSON = [:]
        
        do {
            try model.set(any: json["name"], for: "name", convertUsing: { value in
                XCTFail("Any setter should not call converter if value is empty.")
                return value
            })
        } catch {
            XCTFail()
        }
        
        XCTAssertFalse(model.hasValueFor("name"))
        
        do {
            let _: String? = try model.valueFor(nullable: "name")
            XCTFail()
        } catch let error {
            XCTAssertEqual(error as! ModelError, ModelError.KeyNotFound)
        }
    }
    
    // ----------------------------------
    //  MARK: - Scalar Setters -
    //
    func testValidScalarSetter() {
        let model      = TestModel(json: [:])!
        let json: JSON = [
            "id": "123456",
        ]
        
        do {
            try model.set(valueFrom: json, for: "id", type: TestID.self)
        } catch {
            XCTFail()
        }
        
        XCTAssertTrue(model.hasValueFor("id"))
        XCTAssertEqual(try! model.valueFor(nonnull: "id"), TestID("123456"))
    }
    
    func testInvalidScalarSetter() {
        let model      = TestModel(json: [:])!
        let json: JSON = [
            "id": 123456,
        ]
        
        do {
            try model.set(valueFrom: json, for: "id", type: TestID.self)
            XCTFail()
        } catch let error {
            XCTAssertEqual(error as! ModelError, ModelError.InconsistentSchema)
        }
    }
    
    // ----------------------------------
    //  MARK: - Plain Typed Setters -
    //
    func testValidTypedSetter() {
        let model      = TestModel(json: [:])!
        let json: JSON = [
            "count": 836,
        ]
        
        do {
            try model.set(valueFrom: json, for: "count", type: Int.self)
        } catch {
            XCTFail()
        }
        
        XCTAssertTrue(model.hasValueFor("count"))
        XCTAssertEqual(try! model.valueFor(nonnull: "count"), 836)
    }
    
    func testInvalidTypedSetter() {
        let model      = TestModel(json: [:])!
        let json: JSON = [
            "count": "836",
        ]
        
        do {
            try model.set(valueFrom: json, for: "count", type: Int.self)
            XCTFail()
        } catch let error {
            XCTAssertEqual(error as! ModelError, ModelError.InconsistentSchema)
        }
    }
    
    // ----------------------------------
    //  MARK: - Model Setters -
    //
    func testValidModelSetter() {
        let model      = TestModel(json: [:])!
        let json: JSON = [
            "submodel": [
                "id": 123,
            ],
        ]
        
        do {
            try model.set(modelFrom: json, for: "submodel", type: TestModel.self)
        } catch {
            XCTFail()
        }
        
        XCTAssertTrue(model.hasValueFor("submodel"))
        
        let submodel: TestModel? = try? model.valueFor(nonnull: "submodel")
        
        XCTAssertNotNil(submodel)
        XCTAssertTrue(type(of: submodel!) == TestModel.self)
    }
    
    func testInvalidModelSetter() {
        let model      = TestModel(json: [:])!
        let json: JSON = [
            "wrongType": 123,
        ]
        
        do {
            try model.set(modelFrom: json, for: "wrongType", type: TestModel.self)
            XCTFail()
        } catch let error {
            XCTAssertEqual(error as! ModelError, ModelError.InconsistentSchema)
        }
    }
    
    func testValidModelCollectionSetter() {
        let model      = TestModel(json: [:])!
        let json: JSON = [
            "submodels": [
                [
                    "id": 123,
                ],
                [
                    "id": 234,
                ],
            ],
        ]
        
        do {
            try model.set(modelCollectionFrom: json, for: "submodels", type: [TestModel].self)
        } catch {
            XCTFail()
        }
        
        XCTAssertTrue(model.hasValueFor("submodels"))
        
        let submodels: [TestModel]? = try? model.valueFor(nonnull: "submodels")
        
        XCTAssertNotNil(submodels)
        XCTAssertTrue(type(of: submodels!) == [TestModel].self)
    }
    
    func testInvalidModelCollectionSetter() {
        let model      = TestModel(json: [:])!
        let json: JSON = [
            "submodels": [
                123,
                234,
            ],
        ]
        
        do {
            try model.set(modelCollectionFrom: json, for: "submodels", type: [TestModel].self)
            XCTFail()
        } catch let error {
            XCTAssertEqual(error as! ModelError, ModelError.InconsistentSchema)
        }
    }
    
    // ----------------------------------
    //  MARK: - Passthrough Setter -
    //
    func testNonnullPassthroughSetter() {
        let model      = TestModel(json: [:])!
        let json: JSON = [
            "id": 123,
        ]
        
        do {
            try model.set(json: json, for: "submodel", type: TestModel.self)
        } catch {
            XCTFail()
        }
        
        XCTAssertTrue(model.hasValueFor("submodel"))
        
        let submodel: TestModel? = try? model.valueFor(nonnull: "submodel")
        
        XCTAssertNotNil(submodel)
        XCTAssertTrue(type(of: submodel!) == TestModel.self)
    }
    
    func testNullPassthroughSetter() {
        let model      = TestModel(json: [:])!
        let json: JSON = [
            GraphQL.Key.typeName: "SomeType",
            "id": 123,
        ]
        
        do {
            try model.set(json: json, for: "submodel", type: TestModel.self)
        } catch {
            XCTFail()
        }
        
        XCTAssertFalse(model.hasValueFor("submodel"))
        
        let submodel: TestModel? = try? model.valueFor(nonnull: "submodel")
        
        XCTAssertNil(submodel)
    }

    // ----------------------------------
    //  MARK: - Property Setters -
    //
    func testSetters() {
        let model = TestModel(json: [:])!
        
        model.set("John", for: "name")
        model.set(3,      for: "children")
        model.set(nil,    for: "parent")
        
        XCTAssertTrue(model.hasValueFor("name"))
        XCTAssertTrue(model.hasValueFor("children"))
        XCTAssertTrue(model.hasValueFor("parent"))
        XCTAssertFalse(model.hasValueFor("invalidKey"))
        
        XCTAssertEqual(try! model.valueFor(nonnull: "name"), "John")
        XCTAssertEqual(try! model.valueFor(nonnull: "children"), 3)
        XCTAssertEqual(try! model.valueFor(nullable: "parent"), Optional<String>.none)
    }
    
    // ----------------------------------
    //  MARK: - Getters -
    //
    func testNonnullGetters() {
        
        let model = TestModel(json: [:])!
        
        model.set("John", for: "name")
        
        do {
            let name: String = try model.valueFor(nonnull: "name")
            XCTAssertEqual(name, "John")
        } catch {
            XCTFail()
        }
        
        do {
            let _: Int = try model.valueFor(nonnull: "name")
            XCTFail()
        } catch ModelError.TypeConversionFailed {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
        
        do {
            let _: String = try model.valueFor(nonnull: "invalid")
            XCTFail()
        } catch ModelError.KeyNotFound {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }
    
    func testNullableGetters() {
        let model = TestModel(json: [:])!
        
        model.set("John", for: "name")
        
        do {
            let name: String? = try model.valueFor(nullable: "name")
            XCTAssertNotNil(name)
            XCTAssertEqual(name, "John")
        } catch {
            XCTFail()
        }
        
        do {
            let _: String? = try model.valueFor(nullable: "invalid")
            XCTFail()
        } catch ModelError.KeyNotFound {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }
    
    // ----------------------------------
    //  MARK: - Has Value -
    //
    func testHasValue() {
        let model = TestModel(json: [:])!
        
        XCTAssertFalse(model.hasValueFor("name"))
        
        model.set("John", for: "name")
        
        XCTAssertTrue(model.hasValueFor("name"))
        
        model.set(nil, for: "name")
        
        XCTAssertTrue(model.hasValueFor("name"))
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
private struct TestID: ScalarType, Equatable {
    
    let string: String
    
    init(_ string: String) {
        self.string = string
    }
    
    init(from string: String) {
        self.init(string)
    }
    
    static func ==(lhs: TestID, rhs: TestID) -> Bool {
        return lhs.string == rhs.string
    }
}
