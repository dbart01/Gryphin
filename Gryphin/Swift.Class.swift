//
//  Swift.Class.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-23.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Swift {
    class Class: Container {
        
        enum Kind {
            case `class`
            case `struct`
            
            var string: String {
                switch self {
                case .class:  return "final class"
                case .struct: return "struct"
                }
            }
        }
        
        let visibility:   Visibility
        let kind:         Kind
        let name:         String
        let inheritances: [String]?
        
        fileprivate(set) var comments: [Line]
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(visibility: Visibility = .internal, kind: Kind = .class, name: String, inheritances: [String]? = nil, comments: [Line]? = nil, methods: [Method]? = nil) {
            self.visibility   = visibility
            self.kind         = kind
            self.name         = name
            self.inheritances = inheritances
            self.comments     = comments ?? []
            
            super.init()
            
            if let methods = methods, !methods.isEmpty {
                self.add(children: methods)
            }
        }
        
        // ----------------------------------
        //  MARK: - String Representation -
        //
        override var stringRepresentation: String {
            var string = ""
            
            var inheritanceString = ""
            if let inheritances = self.inheritances, !inheritances.isEmpty {
                let interfaces    = inheritances.joined(separator: ", ")
                inheritanceString = ": \(interfaces)"
            }
            let comments = self.comments.commentStringIndentedBy(self.indent)
            let kind     = self.kind.string
            
            string += comments
            string += "\(self.indent)\(self.visibility.rawValue) \(kind) \(self.name)\(inheritanceString) {\n\n"
            string += super.stringRepresentation
            string += "\(self.indent)}\n"
            
            return string
        }
    }
}
