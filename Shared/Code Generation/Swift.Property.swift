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
        
        let kind:        Kind
        let visibility:  Visibility
        let override:    Bool
        let mutable:     Bool
        let name:        String
        let returnType:  String
        let annotations: [Annotation]?
        
        fileprivate(set) var comments: [Line]
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(kind: Kind = .instance, visibility: Visibility = .internal, override: Bool = false, mutable: Bool = true, name: String, returnType: String, annotations: [Annotation]? = nil, accessors: [Accessor]? = nil, body: [Line]? = nil, comments: [Line]? = nil) {
            
            precondition((!mutable && accessors == nil && body == nil) || mutable, "A mutable property cannot have accessors or a body.")
            
            self.kind        = kind
            self.override    = override
            self.visibility  = visibility
            self.mutable     = mutable
            self.name        = name
            self.returnType  = returnType
            self.comments    = comments ?? []
            self.annotations = annotations
            
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
            
            /* ---------------------------------
             ** Construct the method annotations
             */
            let annotations = self.annotations?.map {
                "\(self.indent)\($0.stringRepresentation)\n"
            }.joined(separator: "") ?? ""
            
            let visibility = self.visibility == .none ? "" : "\(self.visibility.rawValue) "
            let override   = self.override ? "override " : ""
            let mutability = self.mutable ? "var " : "let "
            let kind       = self.kind == .instance ? "" : "\(self.kind.rawValue) "
            
            string += self.comments.commentStringIndentedBy(self.indent)
            string += annotations
            string += "\(self.indent)\(visibility)\(kind)\(override)\(mutability)\(self.name): \(self.returnType)"
            
            /* ----------------------------------------
             ** Only append body and opening / closing
             ** braces if body is non-empty. Otherwise
             ** we'll treat this like a declaration.
             */
            if !self.children.isEmpty {
                string += " {\n"
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
    enum Kind: String {
        case `instance`
        case `class`
        case `static`
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
