//
//  Swift.Method.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-23.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Swift {
    final class Method: Container {
        
        let visibility:  Visibility
        let name:        Name
        let returnType:  String?
        let parameters:  [Parameter]?
        let annotations: [Annotation]?
        
        fileprivate(set) var comments: [Line]
        fileprivate(set) var body:     [Line]
        
        enum Name {
            case `init`(InitializerType)
            case `func`(String)
            
            enum InitializerType: String {
                case none = ""
                case required
                case convenience
            }
            
            var string: String {
                switch self {
                case .init(let type):
                    let type   = "\(type)"
                    let spaced = type.isEmpty ? "" : "\(type) "
                    return "\(spaced)init"
                    
                case .func(let title):
                    return "func \(title)"
                }
            }
        }
        
        enum Annotation: String {
            case discardableResult = "@discardableResult"
        }
        
        struct Parameter: StringRepresentable {
            let name:  String
            let type:  String
            
            // ----------------------------------
            //  MARK: - Init -
            //
            init(name: String, type: String) {
                self.name  = name
                self.type  = type
            }
            
            // ----------------------------------
            //  MARK: - String Representation -
            //
            var stringRepresentation: String {
                return "\(self.name): \(self.type)"
            }
        }
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(visibility: Visibility = .internal, name: Name, returnType: String? = nil, parameters: [Method.Parameter]? = nil, annotations: [Annotation]? = nil, body: [Line]? = nil, comments: [Line]? = nil) {
            self.visibility  = visibility
            self.name        = name
            self.returnType  = returnType
            self.parameters  = parameters
            self.annotations = annotations
            self.body        = body     ?? []
            self.comments    = comments ?? []
            
            super.init()
        }
        
        // ----------------------------------
        //  MARK: - String Representation -
        //
        override var stringRepresentation: String {
            var string = ""
            
            /* ----------------------------------------
             ** Construct the documentation comments
             */
            let comments = self.comments.map {
                "\(self.indent)/// \($0)\n"
            }.joined(separator: "")
            
            /* ---------------------------------
             ** Construct the method parameters
             */
            let parameters = self.parameters?.map {
                $0.stringRepresentation
            }.joined(separator: ", ") ?? ""
            
            /* ---------------------------------
             ** Construct the method annotations
             */
            let annotations = self.annotations?.map {
                "\(self.indent)\($0.rawValue)\n"
            }.joined(separator: "") ?? ""
            
            /* ---------------------------------
             ** Construct the return type
             */
            var returnType = ""
            if let type = self.returnType, !type.isEmpty {
                returnType = "-> \(type) "
            }
            
            /* ---------------------------------
             ** Construct the method body
             */
            let bodyIndent = self.indentFor(distanceToRoot: self.distanceToRoot + 1)
            let body       = self.body.map {
                "\(bodyIndent)\($0)\n"
            }.joined(separator: "")
            
            string += comments
            string += annotations
            string += "\(self.indent)\(self.visibility) \(self.name.string)(\(parameters)) \(returnType)"
            
            /* ----------------------------------------
             ** Only append body and opening / closing
             ** braces if body is non-empty. Otherwise
             ** we'll treat this like a declaration.
             */
            if !self.body.isEmpty {
                string += "{\n"
                string += body
                string += "\(self.indent)}\n"
            } else {
                string += "\n"
            }
            
            return string
        }
    }
}

func +=(lhs: Swift.Method, rhs: Swift.Line) {
    lhs.body.append(rhs)
}
