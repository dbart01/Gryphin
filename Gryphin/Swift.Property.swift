//
//  Swift.Property.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-29.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Swift {
    final class Property: Container {
        
        let visibility:  Visibility
        let name:        String
        let returnType:  String
        
        fileprivate(set) var comments: [Line]
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(visibility: Visibility = .internal, name: String, returnType: String, accessors: [Accessor]? = nil, body: [Line]? = nil, comments: [Line]? = nil) {
            
            self.visibility = visibility
            self.name       = name
            self.returnType = returnType
            self.comments   = comments ?? []
            
            super.init()
            
            /* ---------------------------------
             ** If accessors are provided, then
             ** the body will be ignored as it
             ** otherwise makes no sense.
             */
            if let accessors = accessors {
                self.add(children: accessors)
            } else if let body = body {
                self.add(children: body)
            }
        }
        
        // ----------------------------------
        //  MARK: - String Representable -
        //
        override var stringRepresentation: String {
            var string = ""
            
            let visibility = self.visibility == .none ? "" : "\(self.visibility.rawValue) "
            
            string += self.comments.commentStringIndentedBy(self.indent)
            string += "\(self.indent)\(visibility)var \(self.name): \(self.returnType) "
            
            /* ----------------------------------------
             ** Only append body and opening / closing
             ** braces if body is non-empty. Otherwise
             ** we'll treat this like a declaration.
             */
            if !self.children.isEmpty {
                string += "{\n"
                string += "\(super.stringRepresentation)\n"
                string += "\(self.indent)}\n"
            } else {
                string += "\n"
            }
            
            return string

        }
    }
}

extension Swift.Property {
    final class Accessor: Swift.Container {
        
        enum Kind: String {
            case get
            case set
            case didSet
            case willSet
        }
        
        let kind: Kind
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(kind: Kind, body: [Swift.Line]? = nil) {
            self.kind = kind
            
            super.init()
            
            if let body = body {
                self.add(children: body)
            }
        }
        
        override var stringRepresentation: String {
            var string: String = ""
            
            string += "\(self.indent)\(self.kind.rawValue) {\n"
            string += "\(super.stringRepresentation)\n"
            string += "\(self.indent)}"
            
            return string
        }
    }
}
