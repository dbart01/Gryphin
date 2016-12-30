//
//  Swift.Generator.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-28.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Swift {
    final class Generator {
        
        enum GeneratorError: Error {
            case invalidFormat
        }
        
        let schemaURL:  URL
        let schemaJSON: JSON
        
        private let standardScalars: Set<String> = [
            "Int",
            "Boolean",
            "Float",
            "String",
            
            // "ID",
            
            /* -----------------------
             ** We don't include ID
             ** as the standard scalar
             ** because we still need a
             ** type definition for it.
             */
        ]
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(withSchemaAt url: URL) throws {
            self.schemaURL  = url
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let schemaJSON = json as? JSON else {
                throw GeneratorError.invalidFormat
            }
            
            self.schemaJSON = schemaJSON
        }
        
        // ----------------------------------
        //  MARK: - Generation -
        //
        func generate() -> Namespace {
            
            let schemaData     = self.schemaJSON["data"]  as! JSON
            let jsonSchema     = schemaData["__schema"]   as! JSON
            let jsonTypes      = jsonSchema["types"]      as! [JSON]
            let jsonDirectives = jsonSchema["directives"] as! [JSON]
            
            let namespace = Namespace(items: [])
            
            /* -----------------------------
             ** Parse the schema types first
             */
            let types = jsonTypes.map {
                Schema.Object(json: $0)
            }
            
            for type in types {
                
                /* ---------------------------------
                 ** Ignore the GraphQL private types
                 */
                guard !type.name.hasPrefix("__") else {
                    continue
                }
                
                /* -----------------------------------------
                 ** Generate the appropriate source for each
                 ** type declared in the schema.
                 */
                switch type.kind {
                case .object:
                    self.generate(object: type, in: namespace)
                    
                case .interface:
                    self.generate(interface: type, in: namespace)
                    
                case .enum:
                    break
                case .inputObject:
                    break
                case .scalar:
                    self.generate(scalar: type, in: namespace)
                    
                case .union:
                    break
                case .list:
                    break
                case .nonNull:
                    break
                }
            }
            
            /* ----------------------------
             ** Parse the schema directives
             */
            let directives = jsonDirectives.map {
                Schema.Directive(json: $0)
            }
            
            return namespace
        }
        
        // ----------------------------------
        //  MARK: - Type Generation -
        //
        private func generate(scalar: Schema.Object, in namespace: Namespace) {
            precondition(scalar.kind == .scalar)
            
            /* ----------------------------------------
             ** Ensure that we're not creating a type
             ** alias for a standard type (redundant).
             */
            guard !self.standardScalars.contains(scalar.name) else {
                return
            }
            
            namespace.add(child: Alias(
                name:    scalar.name,
                forType: "String"
            ))
        }
        
        private func generate(interface: Schema.Object, in namespace: Namespace) {
            self.generate(object: interface, in: namespace)
        }
        
        private func generate(object: Schema.Object, in namespace: Namespace) {
            
            precondition(object.kind == .object || object.kind == .interface)
            
            /* ----------------------------------------
             ** Build all interfaces and superclasses
             ** that this object will inherit from. It
             ** will always inherit from `Field` to
             ** facilitate the generation of queries.
             */
            var inheritances: [String] = []
            if let interfaces = object.interfaces, !interfaces.isEmpty {
                inheritances.insert("Field", at: 0)
                inheritances.append(contentsOf: interfaces.map {
                    $0.name!
                })
            }
            
            /* ----------------------------------------
             ** Dtermine if we're generating a class or
             ** a protocol (i.e. Interface).
             */
            let classKind: Class.Kind
            switch object.kind {
            case .object:
                classKind = .class(.final)
                
            case .interface: fallthrough
            default:
                classKind = .protocol
            }

            /* -----------------------------------------
             ** Initialize the class that will represent
             ** this object.
             */
            let swiftClass = Class(
                visibility:   .public,
                kind:         classKind,
                name:         object.name,
                inheritances: inheritances,
                comments:     Line.linesWith(requiredContent: object.description ?? "")
            )
            
            /* ----------------------------------------
             ** Build the fields which will be methods
             ** of this class.
             */
            if let fields = object.fields {
                for field in fields {
                    
                    /* -------------------------------------
                     ** Build the documentation comments for
                     ** this field, including the parameters
                     */
                    var comments: [Line] = []
                    comments.append(contentsOf: Line.linesWith(requiredContent: field.description ?? "No documentation available for `\(field.name)`"))
                    
                    if !field.arguments.isEmpty {
                        comments.append("")
                        for arg in field.arguments {
                            let description = arg.description ?? "No documentation"
                            comments.append(Line(content: ":\(arg.name): \(description)"))
                        }
                    }
                    comments.append("")
                    
                    /* ----------------------------------------
                     ** Build the parameters based on arguments
                     ** accepted by this field.
                     */
                    let parameters = field.arguments.map {
                        Method.Parameter(name: $0.name, type: $0.type.recursiveTypeString())
                    }
                    
                    /* -------------------------------------------
                     ** The type of method we construct depends on
                     ** whether or not the field is a scalar (leaf)
                     ** of an object type. Object types will have
                     ** a `buildOn:` closure, scalars will not.
                     */
                    if field.type.hasScalar {
                        swiftClass.add(child: Property(
                            visibility:  .public,
                            name:        field.name,
                            returnType:  object.name,
                            annotations: [.discardableResult],
                            body:        [
                                "let container: [String] = []"
                            ],
                            comments: comments
                        ))
                        
                    } else {
                        swiftClass.add(child: Method(
                            visibility:  .public,
                            name:        .func(field.name),
                            returnType:  object.name, //field.type.recursiveTypeString(),
                            parameters:  parameters,
                            annotations: [.discardableResult],
                            body: [
                                "let container: [String] = []"
                            ],
                            comments: comments
                        ))
                    }
                }
            }
            
            namespace.add(child: swiftClass)
            
            /* -------------------------------------------
             ** If the object is an interface, we'll have
             ** conform all possible types to the interface 
             ** via an extension on that object.
             */
            if let possibleTypes = object.possibleTypes, !possibleTypes.isEmpty {
                for possibleType in possibleTypes {
                    
                    let swiftExtension = Class(visibility: .public, kind: .extension, name: possibleType.name!, inheritances: [object.name])
                    namespace.add(child: swiftExtension)
                }
            }
        }
    }
}

extension Schema.ObjectType {
    
    func recursiveTypeString() -> String {
        let childType = self.ofType?.recursiveTypeString() ?? ""
        
        switch self.kind {
        case .enum:       fallthrough
        case .union:      fallthrough
        case .scalar:     fallthrough
        case .object:     fallthrough
        case .interface:  fallthrough
        case .inputObject:
            return self.name!
        case .list:
            return "[\(childType)]"
        case .nonNull:
            return "\(childType)!"
        }
    }
}
