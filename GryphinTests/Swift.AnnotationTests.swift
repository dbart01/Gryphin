//
//  Swift.AnnotationTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-30.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SwiftAnnotationTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Values -
    //
    func testValues() {
        XCTAssertEqual(Swift.Annotation.discardableResult.rawValue, "@discardableResult")
    }
}
