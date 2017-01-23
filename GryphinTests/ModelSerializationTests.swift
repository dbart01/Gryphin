//
//  ModelSerializationTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-23.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class ModelSerializationTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Test -
    //
    func testComprehensive() {
        let json  = self.jsonFromFile(named: "queryComprehensive")
        let query = Query(json: json["data"] as! JSON)
        let name  = query.repository!.name
        let issues = query.repository!.issues.edges!.flatMap { $0!.node!.assignees.edges!.map { $0!.node!.name } }
        
        print()
    }

    // ----------------------------------
    //  MARK: - Utilities -
    //
    private func jsonFromFile(named name: String) -> JSON {
        let bundle = Bundle(for: self.classForCoder)
        let url    = bundle.url(forResource: name, withExtension: "json")!
        let data   = try! Data(contentsOf: url)
        let json   = try! JSONSerialization.jsonObject(with: data, options: []) as! JSON
        
        return json
    }
}
