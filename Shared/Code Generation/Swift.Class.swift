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
            
            enum Attribute: String {
                case `final`
            }
            
            case `class`(Attribute?)
            case `struct`
            case `protocol`
            case `extension`
            case `enum`
            
            var string: String {
                switch self {
                case .class(let attribute):
                    
                    var attributeString = ""
                    if let a = attribute {
                        attributeString = "\(a) "
                    }
                    return "\(attributeString)class"
                    
                case .struct:    return "struct"
                case .protocol:  return "protocol"
                case .extension: return "extension"
                case .enum:      return "enum"
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
        init(visibility: Visibility = .internal, kind: Kind = .class(.final), name: String, inheritances: [String]? = nil, comments: [Line]? = nil, containables: [Containable]? = nil) {
            self.visibility   = visibility
            self.kind         = kind
            self.name         = name
            self.inheritances = inheritances
            self.comments     = comments ?? []
            
            super.init()
            
            if let containables = containables, !containables.isEmpty {
                self.add(children: containables)
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
            
            let visibility = self.visibility == .none ? "" : "\(self.visibility.rawValue) "
            
            string += comments
            string += "\(self.indent)\(visibility)\(kind) \(self.name)\(inheritanceString) {"
            
            let classBody = super.stringRepresentation
            if !classBody.isEmpty {
                string += "\n\n\(classBody)"
                string += "\(self.indent)"
            }
            string += "}\n"
            
            return string
        }
    }
}
