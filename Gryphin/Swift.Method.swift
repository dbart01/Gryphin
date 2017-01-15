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
             ** and the generics constraints.
             */
            var genericsString    = ""
            var parameterString   = ""
            var whereClauseString = ""
            
            if let parameters = self.parameters {
                
                /* ----------------------------------------
                 ** Build all the parameter regardless of
                 ** whether they are normal or generic.
                 */
                parameterString = parameters.map {
                    $0.stringRepresentation
                }.joined(separator: ", ")

                /* -----------------------------------------
                 ** Construct aliases and constraints if any
                 ** of the parameters are generic.
                 */
                var aliases:     [String] = []
                var constraints: [String] = []
                
                let _ = parameters.forEach {
                    if case .constrained(let genericConstraint) = $0.type {
                        aliases.append(genericConstraint.alias)
                        
                        genericConstraint.constraints.forEach {
                            constraints.append("\(genericConstraint.alias): \($0)")
                        }
                    }
                }
                
                if !aliases.isEmpty {
                    let constraintsString = constraints.joined(separator: ", ")
                    let aliasesString     = aliases.joined(separator: ", ")
                    
                    genericsString        = "<\(aliasesString)>"
                    whereClauseString     = "where \(constraintsString) "
                }
            }
            
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
            string += "\(self.indent)\(visibility)\(self.name.string)\(genericsString)(\(parameterString)) \(returnType)\(whereClauseString)"
            
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

// ----------------------------------
//  MARK: - Name -
//
extension Swift.Method {
    enum Name {
        case `init`(InitializerType)
        case `func`(String)
        
        enum InitializerType: String {
            case none
            case required
            case convenience
        }
        
        var string: String {
            switch self {
            case .init(let type):
                let type = (type == .none) ? "" : "\(type.rawValue) "
                return "\(type)init"
                
            case .func(let title):
                return "func \(title)"
            }
        }
    }
}

// ----------------------------------
//  MARK: - Parameter -
//
extension Swift.Method {
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
        
        enum ValueType {
            case normal(String)
            case constrained(GenericConstraint)
        }
        
        struct GenericConstraint {
            let alias:       String
            let type:        String
            let constraints: [String]
            
            // ----------------------------------
            //  MARK: - Init -
            //
            init(alias: String, constraints: [String], typeUsing: (String) -> String) {
                self.init(alias: alias, type: typeUsing(alias), constraints: constraints)
            }
            
            init(alias: String, type: String? = nil, constraints: [String]) {
                self.alias       = alias
                self.type        = type ?? alias
                self.constraints = constraints
            }
        }
        
        let unnamed:   Bool
        let name:      String
        let type:      ValueType
        let `default`: Default?
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(unnamed: Bool = false, name: String, type: ValueType, default: Default? = nil) {
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
            
            /* -----------------------------------
             ** Composite the type to use for this
             ** parameter.
             */
            let type: String
            switch self.type {
            case .normal(let typeName):
                type = typeName
            case .constrained(let constraint):
                type = constraint.type
            }
            
            return "\(unnamed)\(self.name): \(type)\(assignment)"
        }
    }
}

func +=(lhs: Swift.Method, rhs: Swift.Line) {
    lhs.add(child: rhs)
}
