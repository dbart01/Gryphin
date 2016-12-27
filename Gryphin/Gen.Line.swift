//
//  Gen.Line.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-27.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Gen {
    struct Line: ExpressibleByStringLiteral {
        
        typealias StringLiteralType = String
        typealias ExtendedGraphemeClusterLiteralType = String
        typealias UnicodeScalarLiteralType = String
        
        let content: String
        
        // ----------------------------------
        //  MARK: - Init -
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
    }
}
