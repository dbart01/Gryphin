//
//  Swift.VisibilityTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-29.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SwiftVisibilityTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Values -
    //
    func testValues() {
        XCTAssertEqual(Swift.Visibility.private.rawValue,     "private")
        XCTAssertEqual(Swift.Visibility.fileprivate.rawValue, "fileprivate")
        XCTAssertEqual(Swift.Visibility.internal.rawValue,    "internal")
        XCTAssertEqual(Swift.Visibility.public.rawValue,      "public")
        XCTAssertEqual(Swift.Visibility.open.rawValue,        "open")
        XCTAssertEqual(Swift.Visibility.none.rawValue,        "")
    }
}
