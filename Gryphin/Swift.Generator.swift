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
            
            precondition(interface.kind == .interface)
            
            /* -----------------------------------------
             ** Initialize the class that will represent
             ** this object.
             */
            let swiftClass = Class(
                visibility:   .public,
                kind:         .protocol,
                name:         interface.name,
                inheritances: interface.inheritances(),
                comments:     interface.commentLines()
            )
            
            /* ----------------------------------------
             ** Build the fields which will be methods
             ** of this class.
             */
            if let fields = interface.fields {
                self.generate(fields: fields, inObjectNamed: interface.name, appendingTo: swiftClass, isInterface: true)
            }
            
            namespace.add(child: swiftClass)
            
            /* -------------------------------------------
             ** If the object is an interface, we'll have
             ** conform all possible types to the interface
             ** via an extension on that object.
             */
            if let possibleTypes = interface.possibleTypes, !possibleTypes.isEmpty {
                for possibleType in possibleTypes {
                    
                    precondition(possibleType.name != nil)
                    
                    let swiftExtension = Class(
                        visibility:   .public,
                        kind:         .extension,
                        name:         possibleType.name!,
                        inheritances: [interface.name]
                    )
                    
                    if let fields = interface.fields {
                        self.generate(fields: fields, inObjectNamed: possibleType.name!, appendingTo: swiftExtension, isInterface: false)
                    }
                    
                    namespace.add(child: swiftExtension)
                }
            }
        }
        
        private func generate(object: Schema.Object, in namespace: Namespace) {
            
            precondition(object.kind == .object)

            /* -----------------------------------------
             ** Initialize the class that will represent
             ** this object.
             */
            let swiftClass = Class(
                visibility:   .public,
                kind:         .class(.final),
                name:         object.name,
                inheritances: object.inheritances(),
                comments:     object.commentLines()
            )
            
            if let fields = object.fields {
                self.generate(fields: fields, inObjectNamed: object.name, appendingTo: swiftClass, isInterface: false)
            }
            
            namespace.add(child: swiftClass)
        }
        
        // ----------------------------------
        //  MARK: - Field Generation -
        //
        private func generate(fields: [Schema.Field], inObjectNamed name: String, appendingTo containerType: Swift.Class, isInterface: Bool) {
            
            for field in fields {
                
                /* -------------------------------------------
                 ** If the field doesn't have arguments, it'll
                 ** be represented by a property, not a method.
                 */
                if field.arguments.isEmpty {
                    self.generate(propertyFor: field, inObjectNamed: name, appendingTo: containerType, isInterface: isInterface)
                } else {
                    self.generate(methodFor: field, inObjectNamed: name, appendingTo: containerType, isInterface: isInterface)
                }
            }
        }
        
        private func generate(propertyFor field: Schema.Field, inObjectNamed name: String, appendingTo containerType: Swift.Class, isInterface: Bool) {
            
            precondition(field.arguments.isEmpty)
            
            var body: [Line] = []
            if !isInterface {
                body = [
                    "return self"
                ]
            }
            
            containerType.add(child: Property(
                visibility:  .public,
                name:        field.name,
                returnType:  isInterface ? "Self" : name,
                annotations: [.discardableResult],
                body:        body,
                comments:    field.commentLines()
            ))
        }
        
        private func generate(methodFor field: Schema.Field, inObjectNamed name: String, appendingTo containerType: Swift.Class, isInterface: Bool) {
            
            precondition(!field.arguments.isEmpty)
            
            /* ----------------------------------------
             ** Build the parameters based on arguments
             ** accepted by this field.
             */
            var parameters = field.parameters()
            
            /* ----------------------------------------
             ** If the object isn't a leaf, we'll need
             ** a `buildOn` closure so the caller can
             ** append additional fields to it.
             */
            let buildType = field.type.recursiveTypeString()
            
            /* ----------------------------------------
             ** We append the `buildOn` closure only if
             ** the field type isn't a scalar type. We
             ** can't nest fields in scalar types.
             */
            if !field.type.hasScalar {
                parameters.append(Method.Parameter(
                    unnamed: true,
                    name:    "buildOn",
                    type:    "(\(buildType)) -> Void"
                ))
            }
            
            var body: [Line] = []
            if !isInterface {
                body = [
                    "return self"
                ]
            }
            
            containerType.add(child: Method(
                visibility:  .public,
                name:        .func(field.name),
                returnType:  isInterface ? "Self" : name,
                parameters:  parameters,
                annotations: [.discardableResult],
                body:        body,
                comments:    field.commentLines()
            ))
        }
    }
}

// ----------------------------------
//  MARK: - Schema Type Extensions -
//
private extension Schema.Object {
    
    func commentLines() -> [Swift.Line] {
        return Swift.Line.linesWith(requiredContent: self.description ?? "")
    }
    
    func inheritances() -> [String] {
        
        /* ----------------------------------------
         ** Build all interfaces and superclasses
         ** that this object will inherit from. It
         ** will always inherit from `Field` to
         ** facilitate the generation of queries.
         */
        var inheritances: [String] = []
        if let interfaces = self.interfaces, !interfaces.isEmpty {
            inheritances.insert("Field", at: 0)
            inheritances.append(contentsOf: interfaces.map {
                $0.name!
            })
        }
        return inheritances
    }
}

private extension Schema.ObjectType {
    
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

private extension Schema.Field {
    
    func commentLines() -> [Swift.Line] {
        var comments: [Swift.Line] = []
        comments.append(contentsOf: Swift.Line.linesWith(requiredContent: self.description ?? "No documentation available for `\(self.name)`"))
        
        if !self.arguments.isEmpty {
            comments.append("")
            for arg in self.arguments {
                let description = arg.description ?? "No documentation"
                comments.append(Swift.Line(content: ":\(arg.name): \(description)"))
            }
        }
        comments.append("")
        return comments
    }
    
    func parameters() -> [Swift.Method.Parameter] {
        return self.arguments.map {
            Swift.Method.Parameter(name: $0.name, type: $0.type.recursiveTypeString())
        }
    }
}
