//
//  Gen.Line.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-27.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Gen {
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
