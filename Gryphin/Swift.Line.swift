//
//  Swift.Line.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-27.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Swift {
    struct Line: ExpressibleByStringLiteral, CustomStringConvertible {
        
        typealias StringLiteralType                  = String
        typealias ExtendedGraphemeClusterLiteralType = String
        typealias UnicodeScalarLiteralType           = String
        
        private let content: String
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init?(content: String?) {
            guard let content = content else {
                return nil
            }
            
            self.init(content: content)
        }
        
        static func linesWith(requiredContent content: String) -> [Line] {
            guard !content.isEmpty else {
                return []
            }
            
            return content.components(separatedBy: "\n").map {
                Line(content: $0)
            }
        }
        
        static func linesWith(optionalContent content: String?) -> [Line]? {
            guard let content = content else {
                return nil
            }
            return self.linesWith(requiredContent: content)
        }
        
        // ----------------------------------
        //  MARK: - ExpressibleByStringLiteral -
        //
        init(content: String) {
            self.content = content
        }
        
        init(stringLiteral value: StringLiteralType) {
            self.content = value
        }
        
        init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
            self.content = value
        }
        
        init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
            self.content = value
        }
        
        // ----------------------------------
        //  MARK: - CustomStringConvertible -
        //
        var description: String {
            return self.content
        }
    }
}

extension Array where Element: CustomStringConvertible {
    
    func commentStringIndentedBy(_ indent: String) -> String {
        guard !self.isEmpty else {
            return ""
        }
        
        return self.map {
            "\(indent)/// \($0)\n"
        }.joined(separator: "")
    }
}
