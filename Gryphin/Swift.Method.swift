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
        
        struct Parameter: StringRepresentable {
            
            enum Default: StringRepresentable {
                case `nil`
                case value(String)
                
                var stringRepresentation: String {
                    switch self {
                    case .nil:               return "nil"
                    case .value(let string): return string
                    }
                }
            }
            
            let unnamed:   Bool
            let name:      String
            let type:      String
            let `default`: Default?
            
            // ----------------------------------
            //  MARK: - Init -
            //
            init(unnamed: Bool = false, name: String, type: String, default: Default? = nil) {
                self.unnamed = unnamed
                self.name    = name
                self.type    = type
                self.default = `default`
            }
            
            // ----------------------------------
            //  MARK: - String Representation -
            //
            var stringRepresentation: String {
                let unnamed    = self.unnamed ? "_ " : ""
                let assignment = self.default != nil ? " = \(self.default!.stringRepresentation)" : ""
                
                return "\(unnamed)\(self.name): \(self.type)\(assignment)"
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
            self.comments    = comments ?? []
            
            super.init()
            
            if let body = body {
                self.add(children: body)
            }
        }
        
        // ----------------------------------
        //  MARK: - String Representation -
        //
        override var stringRepresentation: String {
            var string = ""
            
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
            
            let visibility = self.visibility == .none ? "" : "\(self.visibility.rawValue) "
            
            string += self.comments.commentStringIndentedBy(self.indent)
            string += annotations
            string += "\(self.indent)\(visibility)\(self.name.string)(\(parameters)) \(returnType)"
            
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

func +=(lhs: Swift.Method, rhs: Swift.Line) {
    lhs.add(child: rhs)
}
