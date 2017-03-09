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
    //  MARK: - Json Parsing -
    //
    func testJsonParseFromInvalidData() {
        let invalidData = self.dataFor("{\"name\": \"John}")
        
        do {
            _ = try JSON.from(data: invalidData)
            XCTFail()
        } catch JsonError.invalidFormat {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }
    
    func testJsonParseFromInvalidSchema() {
        let invalidSchema = self.dataFor("[\"Alex\", \"John\"]")
        
        do {
            _ = try JSON.from(data: invalidSchema)
            XCTFail()
        } catch JsonError.invalidSchema {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }
    
    func testJsonParseFromValidData() {
        let validData = self.dataFor("{\"name\": \"John\"}")
        
        do {
            let json = try JSON.from(data: validData)
            XCTAssertEqual(json["name"] as! String, "John")
        } catch {
            XCTFail()
        }
    }
    
    func testJsonParseFromInaccessibleFile() {
        do {
            let url = URL(fileURLWithPath: "/nonexistent_file.json")
            _ = try JSON.from(fileAt: url)
            XCTFail()
        } catch JsonError.readFailed {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }
    
    func testJsonParseFromValidFile() {
        let validData = self.dataFor("{\"name\": \"John\"}")
        let tempURL   = URL(fileURLWithPath: "/tmp/com_gryphin_test.json")
        
        try! validData.write(to: tempURL)
        
        do {
            let json = try JSON.from(fileAt: tempURL)
            XCTAssertEqual(json["name"] as! String, "John")
        } catch {
            XCTFail()
        }
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
    
    private func dataFor(_ json: JSON) -> Data {
        return try! JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    private func dataFor(_ jsonString: String) -> Data {
        return jsonString.data(using: .utf8)!
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
