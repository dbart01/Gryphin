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
        func generate() -> Container {
            
            let schemaData     = self.schemaJSON["data"]  as! JSON
            let jsonSchema     = schemaData["__schema"]   as! JSON
            let jsonTypes      = jsonSchema["types"]      as! [JSON]
            let jsonDirectives = jsonSchema["directives"] as! [JSON]
            
            let container = Container()
            
            /* -----------------------------
             ** Parse the schema types first
             */
            var types = jsonTypes.map {
                Schema.Object(json: $0)
            }
            
            types.sort { lhs, rhs in
                lhs.kind.rawValue < rhs.kind.rawValue
            }
            
            var generatedTypes: [String : Schema.Object] = [:]
            for type in types {
                generatedTypes[type.name] = type
                
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
                    self.generate(object: type, in: container)
                    
                case .interface:
                    self.generate(interface: type, generatedTypes: generatedTypes, in: container)
                    
                case .enum:
                    self.generate(enum: type, in: container)
                    
                case .inputObject:
                    self.generate(inputObject: type, in: container)
                    
                case .scalar:
                    self.generate(scalar: type, in: container)
                    
                case .union:
                    self.generate(union: type, in: container)
                    
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
            
            return container
        }
        
        // ----------------------------------
        //  MARK: - Type Generation -
        //
        private func generate(enum object: Schema.Object, in container: Container) {
            precondition(object.kind == .enum)
            
            let enumClass = Class(
                visibility: .none,
                kind:       .enum,
                name:       object.name,
                comments:   object.descriptionComments()
            )
            
            for value in object.enumValues! {
                enumClass.add(child: Enum.Case(
                    name:     value.name,
                    comments: value.descriptionComments()
                ))
            }
            
            container.add(child: enumClass)
        }
        
        private func generate(scalar: Schema.Object, in container: Container) {
            precondition(scalar.kind == .scalar)
            
            /* ----------------------------------------
             ** Ensure that we're not creating a type
             ** alias for a standard type (redundant).
             */
            guard !self.standardScalars.contains(scalar.name) else {
                return
            }
            
            container.add(child: Alias(
                name:    scalar.name,
                forType: "String"
            ))
        }
        
        private func generate(interface: Schema.Object, generatedTypes: [String : Schema.Object], in container: Container) {
            
            precondition(interface.kind == .interface)
            
            /* -----------------------------------------
             ** Initialize the class that will represent
             ** this object.
             */
            let swiftClass = Class(
                visibility:   .none,
                kind:         .protocol,
                name:         interface.name,
                inheritances: interface.inheritances(),
                comments:     interface.descriptionComments()
            )
            
            if let fields = interface.fields {
                self.generate(fields: fields, ofType: interface.name, appendingTo: swiftClass, isInterface: true)
            }
            
            container.add(child: swiftClass)
            
            /* ----------------------------------------
             ** Iterate over all possibleTypes and check 
             ** if any implemented interface properties 
             ** have arguments in the object implementation. 
             ** If so, we'll add a default implementation 
             ** with no arguments.
             */
            if let possibleTypes = interface.possibleTypes,
                let fields = interface.fields {
                
                /* -----------------------------------------
                 ** Create a set of field names contained in
                 ** this interface so we can query against it.
                 */
                let fieldNameDictionary = fields.keyedUsing { $0.name }
                
                for possibleType in possibleTypes where possibleType.leafName != nil {
                    if let object = generatedTypes[possibleType.leafName!] {
                        
                        /* ---------------------------------------
                         ** Filter out only the fields that have
                         ** arguments and correspond to the fields
                         ** declared in the interface.
                         */
                        let objectFields = object.fields!.filter {
                            if let interfaceField = fieldNameDictionary[$0.name] {
                                return interfaceField.arguments.count != $0.arguments.count
                            }
                            return false
                        }
                        
                        if !objectFields.isEmpty {
                            let swiftExtension = Class(
                                visibility: .none,
                                kind:       .extension,
                                name:       possibleType.name!,
                                comments:   [
                                    Swift.Line(content: "Auto-generated property for compatibility with `\(interface.name)`")
                                ]
                            )
                            
                            for objectField in objectFields {
                                self.generate(propertyFor: objectField, ofType: swiftExtension.name, appendingTo: swiftExtension, isInterface: false)
                            }
                            
                            container.add(child: swiftExtension)
                        }
                    }
                }
            }
        }
        
        private func generate(union: Schema.Object, in container: Container) {
            
            precondition(union.kind == .union)
            
            /* -----------------------------------------
             ** Initialize the class that will represent
             ** this object.
             */
            let swiftClass = Class(
                visibility:   .none,
                kind:         .protocol,
                name:         union.name,
                inheritances: union.inheritances(),
                comments:     union.descriptionComments()
            )
            
            container.add(child: swiftClass)
            
            if let possibleTypes = union.possibleTypes {
                possibleTypes.forEach {
                    
                    container.add(child: Class(
                        visibility:   .none,
                        kind:         .extension,
                        name:         $0.name!,
                        inheritances: [union.name]
                    ))
                }
            }
        }
        
        private func generate(object: Schema.Object, in container: Container) {
            
            precondition(object.kind == .object)

            /* -----------------------------------------
             ** Initialize the class that will represent
             ** this object.
             */
            let swiftClass = Class(
                visibility:   .none,
                kind:         .class(.final),
                name:         object.name,
                inheritances: object.inheritances(),
                comments:     object.descriptionComments()
            )
            
            if let fields = object.fields {
                self.generate(fields: fields, ofType: object.name, appendingTo: swiftClass, isInterface: false)
            }
            
            container.add(child: swiftClass)
        }
        
        private func generate(inputObject: Schema.Object, in container: Container) {
            
            precondition(inputObject.kind == .inputObject)
            
            /* -----------------------------------------
             ** Initialize the class that will represent
             ** this object.
             */
            let swiftClass = Class(
                visibility:   .none,
                kind:         .class(.final),
                name:         inputObject.name,
                inheritances: inputObject.inheritances(),
                comments:     inputObject.descriptionComments()
            )
            
            if let fields = inputObject.inputFields {
                for field in fields {
                    self.generate(propertyFor: field, ofType: inputObject.name, appendingTo: swiftClass, isInterface: false)
                }
            }
            
            container.add(child: swiftClass)
        }
        
        // ----------------------------------
        //  MARK: - Field Generation -
        //
        private func generate(fields: [Schema.Field], ofType name: String, appendingTo containerType: Swift.Class, isInterface: Bool) {
            
            for field in fields {
                
                /* -------------------------------------------
                 ** If the field is a scalar value and takes
                 ** no arguments (no need for a method), there's 
                 ** a gurantee that it cannot accept subfields
                 ** and will represented by a property rather
                 ** than a method with a `buildOn` parameter.
                 */
                if field.type.hasScalar && field.arguments.isEmpty {
                    self.generate(propertyFor: field, ofType: name, appendingTo: containerType, isInterface: isInterface)
                } else {
                    self.generate(methodFor: field, ofType: name, appendingTo: containerType, isInterface: isInterface)
                }
            }
        }
        
        private func generate(propertyFor field: DescribedType, ofType type: String, appendingTo containerType: Swift.Class, isInterface: Bool) {
            
            let body: [Line]
            if isInterface {
                body = [
                    "get"
                ]
            } else {
                body = [
                    "return self"
                ]
            }
            
            containerType.add(child: Property(
                visibility: .none,
                name:       field.name,
                returnType: isInterface ? "Self" : type,
                body:       body,
                comments:   field.descriptionComments()
            ))
        }
        
        private func generate(methodFor field: Schema.Field, ofType type: String, appendingTo containerType: Swift.Class, isInterface: Bool) {
            
            precondition(!field.arguments.isEmpty || !field.type.hasScalar)
            
            /* ----------------------------------------
             ** Build the parameters based on arguments
             ** accepted by this field.
             */
            var parameters = field.parameters(isInterface: isInterface)
            
            /* ----------------------------------------
             ** We append the `buildOn` closure only if
             ** the field type isn't a scalar type. We
             ** can't nest fields in scalar types.
             */
            if !field.type.hasScalar {
                
                let parameterType: Swift.Method.Parameter.ValueType
                if field.type.needsGenericConstraint {
                    
                    /* ------------------------------------------
                     ** The generic delaration has a few nuances.
                     ** We must first check how deeply nested the
                     ** the type is (how many arrays are holding
                     ** it). Then, the constraint must not include
                     ** the array contaiment but simply be the type
                     ** of the leaf-most type. The parameter type
                     ** should then include the number of arrays
                     ** that contain the scalar type.
                     */
                    let constraint = Swift.Method.Parameter.GenericConstraint(alias: "T", constraints: [field.type.leafName!], typeUsing: { type in
                        return "(\(type)) -> Void"
                    })
                    
                    parameterType = .constrained(constraint)
                    
                } else {
                    parameterType = .normal(
                        "(\(field.type.leafName!)) -> Void"
                    )
                }
                
                parameters.append(Method.Parameter(
                    unnamed: true,
                    name:    "buildOn",
                    type:    parameterType
                ))
            }
            
            var body: [Line] = []
            if !isInterface {
                body = [
                    "return self"
                ]
            }
            
            containerType.add(child: Method(
                visibility:  .none,
                name:        .func(field.name),
                returnType:  isInterface ? "Self" : type,
                parameters:  parameters,
                annotations: [.discardableResult],
                body:        body,
                comments:    field.parameterDocComments()
            ))
        }
    }
}

// ----------------------------------
//  MARK: - Extensions -
//
extension Array {
    
    func keyedUsing(block: (Element) -> String) -> [String : Element] {
        var dictionary: [String : Element] = [:]
        self.forEach {
            dictionary[block($0)] = $0
        }
        return dictionary
    }
}

// ----------------------------------
//  MARK: - Schema Type Extensions -
//
extension Schema.Object {
    
    func descriptionComments() -> [Swift.Line] {
        var commentLines = Swift.Line.linesWith(requiredContent: self.description ?? "")
        
        /* ----------------------------------------
         ** If this is an interface, we'll append
         ** additional comments about what possible 
         ** types implement this interface.
         */
        if let possibleTypes = self.possibleTypes, !possibleTypes.isEmpty {
            
            commentLines.append("")
            commentLines.append("## Implementing types:")
            
            for possibleType in possibleTypes {
                
                precondition(possibleType.name != nil)
                commentLines.append(Swift.Line(content: " - `\(possibleType.name!)`"))
            }
        }
        
        return commentLines
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

extension Schema.ObjectType {
    
    private static var typeMap: [String : String] = [
        "String"  : "String",
        "Boolean" : "Bool",
        "Int"     : "Int",
        "Float"   : "Float",
    ]
    
    var mappedName: String? {
        guard let name = self.name else {
            return nil
        }
        
        if let mappedType = Schema.ObjectType.typeMap[name] {
            return mappedType
        }
        return name
    }
    
    var needsGenericConstraint: Bool {
        let leafKind = self.leafKind
        return leafKind == .interface || leafKind == .union
    }
    
    func recursiveTypeString() -> String {
        return self.recursiveTypeString(nonNull: false)
    }
    
    private func recursiveTypeString(nonNull: Bool) -> String {
        let isNonNull = self.kind == .nonNull
        let childType = self.ofType?.recursiveTypeString(nonNull: isNonNull) ?? ""
        
        switch self.kind {
        case .enum:       fallthrough
        case .union:      fallthrough
        case .scalar:     fallthrough
        case .object:     fallthrough
        case .interface:  fallthrough
        case .inputObject:
            
            if nonNull {
                return "\(self.mappedName!)"
            } else {
                return "\(self.mappedName!)?"
            }
            
        case .list:
            
            if nonNull {
                return "[\(childType)]"
            } else {
                return "[\(childType)]?"
            }
            
        case .nonNull:
            return childType
        }
    }
}

extension DescribedType {
    
    func descriptionComments() -> [Swift.Line] {
        return Swift.Line.linesWith(requiredContent: self.description ?? "No documentation available for `\(self.name)`")
    }
}

extension Schema.Argument {
    
    func methodParameter(useDefaultValues: Bool) -> Swift.Method.Parameter {
        
        var defaultValue: Swift.Method.Parameter.Default?
        if self.type.kind != .nonNull && useDefaultValues {
            defaultValue = .nil
        }
        
        let typeString = self.type.recursiveTypeString()
        
        let type: Swift.Method.Parameter.ValueType
        if self.type.needsGenericConstraint {
            type = .constrained(Swift.Method.Parameter.GenericConstraint(alias: "T", constraints: [typeString]))
        } else {
            type = .normal(typeString)
        }
        
        return Swift.Method.Parameter(
            name:    self.name,
            type:    type,
            default: defaultValue
        )
    }
}

extension Schema.Field {
    
    func parameterDocComments() -> [Swift.Line] {
        var comments: [Swift.Line] = []
        comments.append(contentsOf: Swift.Line.linesWith(requiredContent: self.description ?? "No documentation available for `\(self.name)`"))
        
        if !self.arguments.isEmpty {
            comments.append("")
            comments.append("- parameters:")
            for arg in self.arguments {
                let description = arg.description ?? "No documentation"
                comments.append(Swift.Line(content: "    - \(arg.name): \(description)"))
            }
            comments.append("")
        }
        return comments
    }
    
    func parameters(isInterface: Bool) -> [Swift.Method.Parameter] {
        return self.arguments.map {
            $0.methodParameter(useDefaultValues: !isInterface)
        }
    }
}
