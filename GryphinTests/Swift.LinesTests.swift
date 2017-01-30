//
//  Swift.LinesTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-30.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class SwiftLineTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testInit() {
        let line = Swift.Line(content: "something")
        
        XCTAssertNotNil(line)
        XCTAssertEqual(line.content, "something")
    }
    
    func testOptionalInit() {
        let content = Optional("something")
        let line    = Swift.Line(content: content)
        
        XCTAssertNotNil(line)
        XCTAssertEqual(line?.content, content)
        
        let nullableLine = Swift.Line(content: nil)
        
        XCTAssertNil(nullableLine)
    }
    
    func testLiteralInit() {
        let line1:  Swift.Line = "something"
        let line2 = Swift.Line(content: "something")
        
        XCTAssertEqual(line1.content, "something")
        XCTAssertEqual(line1.content, line2.content)
    }
    
    func testGraphemeClusterLiteralInit() {
        let line: Swift.Line = Swift.Line(extendedGraphemeClusterLiteral: "❄︎")
        XCTAssertEqual(line.content, "❄︎")
    }
    
    func testUnicodeLiteralInit() {
        let line: Swift.Line = Swift.Line(unicodeScalarLiteral: "\u{2022}")
        XCTAssertEqual(line.content, "\u{2022}")
    }
    
    // ----------------------------------
    //  MARK: - Lines Factory -
    //
    func testParagraph() {
        let content = self.multilineContent()
        let lines   = Swift.Line.linesWith(requiredContent: content.content)
        
        XCTAssertEqual(lines.count, content.lines.count)
        XCTAssertEqual(lines[0].content, content.lines[0])
        XCTAssertEqual(lines[1].content, content.lines[1])
        XCTAssertEqual(lines[2].content, content.lines[2])
        
        let emptyLines = Swift.Line.linesWith(requiredContent: "")
        
        XCTAssertNotNil(emptyLines)
        XCTAssertEqual(emptyLines.count, 0)
    }
    
    func testOptionalParagraph() {
        let content = self.multilineContent()
        let lines   = Swift.Line.linesWith(optionalContent: content.content)
        
        XCTAssertNotNil(lines)
        XCTAssertEqual(lines!.count, content.lines.count)
        XCTAssertEqual(lines![0].content, content.lines[0])
        XCTAssertEqual(lines![1].content, content.lines[1])
        XCTAssertEqual(lines![2].content, content.lines[2])
        
        let nullableLines = Swift.Line.linesWith(optionalContent: nil)
        
        XCTAssertNil(nullableLines)
    }
    
    private func multilineContent() -> (lines: [String], content: String) {
        
        let line1            = "An example documentation"
        let line2            = "comment that has 3 lines"
        let line3            = "as the content of the comment"
        let multilineContent = "\(line1)\n\(line2)\n\(line3)"
        
        return ([line1, line2, line3], multilineContent)
    }
    
    // ----------------------------------
    //  MARK: - StringRepresentable -
    //
    func testStringRepresentation() {
        let content = "let array = []"
        let line    = Swift.Line(content: content)
        
        XCTAssertEqual(line.stringRepresentation, content)
        
        let container    = Swift.Container()
        let subcontainer = Swift.Container()
        
        container.add(child: subcontainer)
        subcontainer.add(child: line)
        
        XCTAssertEqual(line.stringRepresentation, "    \(content)")
    }
    
    // ----------------------------------
    //  MARK: - Containable -
    //
    func testCommentGenerationWhenEmpty() {
        let lines: [Swift.Line] = []
        let comments = lines.commentStringIndentedBy("  ")
        
        XCTAssertEqual(comments, "")
    }
    
    func testCommentGeneration() {
        let indent = "  "
        let lines: [Swift.Line] = [
            "line1",
            "line2",
            "line3",
        ]
        
        let comments = lines.commentStringIndentedBy(indent)
        
        XCTAssertEqual(comments, "" ~
            "\(indent)/// \(lines[0].content)" ~
            "\(indent)/// \(lines[1].content)" ~
            "\(indent)/// \(lines[2].content)" ~
            ""
        )
    }
}
