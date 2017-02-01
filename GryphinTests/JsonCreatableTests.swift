//
//  JsonCreatableTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-01.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class JsonCreatableTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Failable -
    //
    func testFailableInit() {
        let json = self.singleJSON()
        let test = TestJson(json: Optional(json))!
        
        XCTAssertNotNil(test)
        XCTAssertEqual(test.name,  "John")
        XCTAssertEqual(test.email, "john.smith@gmail.com")
    }
    
    func testFailableInitWithNil() {
        let test = TestJson(json: nil)
        XCTAssertNil(test)
    }
    
    // ----------------------------------
    //  MARK: - Collections -
    //
    func testCollections() {
        let collections = self.collectionsJSON()
        let objects     = TestJson.collectionWith(requiredJson: collections)
        
        XCTAssertEqual(objects.count, 2)
        XCTAssertEqual(objects[1].name,  "John")
        XCTAssertEqual(objects[1].email, "john.smith@gmail.com")
    }
    
    func testFailableCollections() {
        let collections = self.collectionsJSON()
        let objects     = TestJson.collectionWith(optionalJson: Optional(collections))
        
        XCTAssertNotNil(objects)
        XCTAssertEqual(objects!.count, 2)
        XCTAssertEqual(objects![1].name,  "John")
        XCTAssertEqual(objects![1].email, "john.smith@gmail.com")
    }
    
    func testFailableCollectionsWithNil() {
        let objects = TestJson.collectionWith(optionalJson: nil)
        XCTAssertNil(objects)
    }
    
    // ----------------------------------
    //  MARK: - JSON Accessor -
    //
    func testJsonAccessor() {
        let json = self.singleJSON()
        
        let name:  String? = json.v("name")
        let email: String? = json.v("email")
        
        XCTAssertNotNil(name)
        XCTAssertNotNil(email)
        
        let object: TestJson? = json.v("fictionalObject")
        
        XCTAssertNil(object)
    }
    
    // ----------------------------------
    //  MARK: - Utilities -
    //
    private func singleJSON() -> JSON {
        return [
            "name"  : "John",
            "email" : "john.smith@gmail.com"
        ]
    }
    
    private func collectionsJSON() -> [JSON] {
        return [
            self.singleJSON(),
            self.singleJSON(),
        ]
    }
}

private class TestJson: JsonCreatable {
    
    let name:  String
    let email: String
    
    required init(json: JSON) {
        self.name  = json["name"]  as! String
        self.email = json["email"] as! String
    }
}
