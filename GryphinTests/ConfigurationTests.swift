//
//  ConfigurationTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-22.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class ConfigurationTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Configuration -
    //
    func testInitFromEmptyConfiguration() {
        let configuration = Configuration(with: Data())
        XCTAssertNil(configuration)
    }
    
    func testInitFromValidPath() {
        let url  = URL(fileURLWithPath: "/tmp/.gryphin")
        let data = " ".data(using: .utf8)!
        
        try! data.write(to: url)
        
        let configuration = Configuration(at: url)
        
        XCTAssertNotNil(configuration)
        
        try! FileManager.default.removeItem(at: url)
    }
    
    func testInitFromInvalidPath() {
        let url           = URL(fileURLWithPath: "/tmp/.some-invalid-file")
        let configuration = Configuration(at: url)
        
        XCTAssertNil(configuration)
    }
    
    func testInitFromValidConfiguration() {
        let url  = URL(string: "https://app.myshopify.io/services/ping/graphql_schema")!
        let path = URL(string: "file:///some/path/to/file")!
        
        let data = self.dataFor(
            "schemaURL: \(url.absoluteString) \n" +
            "invalidURL1: relative/file/path \n" +
            "invalidURL2: /absolute/file/path \n" +
            "invalidURL3: www.google.com \n" +
            "     prettyPrint : true       \n" +
            "networkDebug: false       \n" +
            "      \n" +
            "    schemaPath           :           \(path)          \n" +
            "    invalidKey:    \n" +
            "    retryCount: 3          \n" +
            "\n"
        )
        
        let configuration = Configuration(with: data)
        
        XCTAssertNotNil(configuration)
        XCTAssertEqual(configuration!.count, 8)
        
        XCTAssertTrue(configuration!.valueExistsFor("schemaURL"))
        XCTAssertTrue(configuration!.valueExistsFor("prettyPrint"))
        XCTAssertTrue(configuration!.valueExistsFor("networkDebug"))
        XCTAssertTrue(configuration!.valueExistsFor("schemaPath"))
        XCTAssertTrue(configuration!.valueExistsFor("retryCount"))
        XCTAssertTrue(configuration!.valueExistsFor("invalidURL1"))
        XCTAssertTrue(configuration!.valueExistsFor("invalidURL2"))
        XCTAssertTrue(configuration!.valueExistsFor("invalidURL3"))
        
        XCTAssertEqual(configuration!.valueFor("schemaURL"),    url)
        XCTAssertEqual(configuration!.valueFor("prettyPrint"),  true)
        XCTAssertEqual(configuration!.valueFor("networkDebug"), false)
        XCTAssertEqual(configuration!.valueFor("schemaPath"),   path)
        XCTAssertEqual(configuration!.valueFor("retryCount"),   3)
        XCTAssertEqual(configuration!.valueFor("invalidURL1"),  "relative/file/path")
        XCTAssertEqual(configuration!.valueFor("invalidURL2"),  "/absolute/file/path")
        XCTAssertEqual(configuration!.valueFor("invalidURL3"),  "www.google.com")
        
        let urlPath: String? = configuration!.valueFor("schemaURL")
        let count:   Data?   = configuration!.valueFor("retryCount")
        XCTAssertNil(urlPath)
        XCTAssertNil(count)
    }
    
    private func dataFor(_ string: String) -> Data {
        return string.data(using: .utf8)!
    }
}
