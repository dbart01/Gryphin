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
        
        private struct SchemaKey {
            static let data             = "data"
            static let schema           = "__schema"
            static let types            = "types"
            static let directives       = "directives"
            static let queryType        = "queryType"
            static let mutationType     = "mutationType"
            static let subscriptionType = "subscriptionType"
        }
        
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
            
            let schemaData     = self.schemaJSON[SchemaKey.data]  as! JSON
            let jsonSchema     = schemaData[SchemaKey.schema]     as! JSON
            let jsonTypes      = jsonSchema[SchemaKey.types]      as! [JSON]
            let jsonDirectives = jsonSchema[SchemaKey.directives] as! [JSON]
            
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
                    container += self.generate(object: type)
                    
                case .interface:
                    container += self.generate(interface: type, parsedTypes: generatedTypes)
                    container += self.generate(concreteInterface: type)
                    
                case .enum:
                    container += self.generate(enum: type)
                    
                case .inputObject:
                    container += self.generate(inputObject: type)
                    
                case .scalar:
                    if let alias = self.generate(scalar: type) {
                        container += alias
                    }
                    
                case .union:
                    container += self.generate(union: type)
                    container += self.generate(concreteInterface: type)
                    
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
        private func generate(enum object: Schema.Object) -> Class {
            precondition(object.kind == .enum)
            
            let enumClass = Class(
                visibility:   .none,
                kind:         .enum,
                name:         object.name,
                inheritances: ["String"],
                comments:     object.descriptionComments()
            )
            
            for value in object.enumValues! {
                enumClass.add(child: Enum.Case(
                    name:     value.name,
                    comments: value.descriptionComments()
                ))
            }
            
            return enumClass
        }
        
        private func generate(scalar: Schema.Object) -> Alias? {
            precondition(scalar.kind == .scalar)
            
            /* ----------------------------------------
             ** Ensure that we're not creating a type
             ** alias for a standard type (redundant).
             */
            guard !self.standardScalars.contains(scalar.name) else {
                return nil
            }
            
            return Alias(
                name:    scalar.name,
                forType: "String"
            )
        }
        
        private func generate(interface: Schema.Object, parsedTypes: [String : Schema.Object]) -> [Class] {
            
            precondition(interface.kind == .interface)
            
            var container: [Class] = []
            
            /* -------------------------------------------
             ** Initialize the abstract protocol. It will
             ** also have a concrete class of similar name
             */
            let swiftInterface = Class(
                visibility:   .none,
                kind:         .protocol,
                name:         interface.primitiveName,
                inheritances: interface.inheritances(isInterface: true),
                comments:     interface.descriptionComments()
            )
            
            if let fields = interface.fields {
                self.generate(fields: fields, ofType: "Self", appendingTo: swiftInterface, isInterface: true)
            }
            
            container.append(swiftInterface)
            
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
                    if let object = parsedTypes[possibleType.leafName!] {
                        
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
                            
                            container.append(swiftExtension)
                        }
                    }
                }
            }
            
            return container
        }
        
        private func generate(concreteInterface: Schema.Object) -> Class {
            
            precondition(concreteInterface.kind == .interface || concreteInterface.kind == .union)
            
            /* ---------------------------------------------
             ** Initialize a concrete class for the protocol
             ** since we cannot execute builder methods on
             ** an abstract protocol type.
             */
            let swiftClass = Class(
                visibility:   .none,
                kind:         .class(.final),
                name:         concreteInterface.name,
                inheritances: ["Field", concreteInterface.primitiveName],
                comments:     [
                    Swift.Line(content: "Concrete type aut-generated for `\(concreteInterface.primitiveName)`")
                ]
            )
            
            if let fields = concreteInterface.fields {
                self.generate(fields: fields, ofType: swiftClass.name, appendingTo: swiftClass, isInterface: false)
            }
            
            if let possibleTypes = concreteInterface.possibleTypes {
                for possibleType in possibleTypes where possibleType.leafName != nil {
                    
                    let type      = possibleType.leafName!
                    let closure   = self.closureNameWith(type: type)
                    let parameter = Method.Parameter(
                        unnamed: true,
                        name:    closure.name,
                        type:    .normal(closure.type)
                    )
                    
                    let method = Method(
                        visibility: .none,
                        name:        .func("fragmentOn\(type)"),
                        returnType:  swiftClass.name,
                        parameters:  [parameter],
                        body:        self.inlineFragmentContentWith(type: type),
                        comments:    [
                            Line(content: "Use an inline fragment to query specific fields of `\(type)`")
                        ]
                    )
                    
                    swiftClass.add(child: method)
                }
            }
            
            return swiftClass
        }
        
        private func generate(union: Schema.Object) -> [Class] {
            
            precondition(union.kind == .union)
            
            var container: [Class] = []
            
            /* -----------------------------------------
             ** Initialize the class that will represent
             ** this object.
             */
            let swiftClass = Class(
                visibility:   .none,
                kind:         .protocol,
                name:         union.primitiveName,
                inheritances: union.inheritances(isInterface: true),
                comments:     union.descriptionComments()
            )
            
            container.append(swiftClass)
            
            if let possibleTypes = union.possibleTypes {
                possibleTypes.forEach {
                    
                    container.append(Class(
                        visibility:   .none,
                        kind:         .extension,
                        name:         $0.name!,
                        inheritances: [union.primitiveName]
                    ))
                }
            }
            
            return container
        }
        
        private func generate(object: Schema.Object) -> Class {
            
            precondition(object.kind == .object)

            /* -----------------------------------------
             ** Initialize the class that will represent
             ** this object.
             */
            let swiftClass = Class(
                visibility:   .none,
                kind:         .class(.final),
                name:         object.name,
                inheritances: object.inheritances(isInterface: false),
                comments:     object.descriptionComments()
            )
            
            if let fields = object.fields {
                self.generate(fields: fields, ofType: object.name, appendingTo: swiftClass, isInterface: false)
            }
            
            return swiftClass
        }
        
        private func generate(inputObject: Schema.Object) -> Class {
            
            precondition(inputObject.kind == .inputObject)
            
            /* -----------------------------------------
             ** Initialize the class that will represent
             ** this object.
             */
            let swiftClass = Class(
                visibility:   .none,
                kind:         .class(.final),
                name:         inputObject.name,
                inheritances: inputObject.inheritances(isInterface: false),
                comments:     inputObject.descriptionComments()
            )
            
            if let fields = inputObject.inputFields {
                for field in fields {
                    self.generate(propertyFor: field, ofType: inputObject.name, appendingTo: swiftClass, isInterface: false)
                }
            }
            
            return swiftClass
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
                    self.generate(methodFor: field, ofType: name, appendingTo: containerType, isInterface: isInterface, buildable: !field.type.hasScalar)
                }
            }
        }
        
        private func generate<T>(propertyFor field: T, ofType type: String, appendingTo containerType: Swift.Class, isInterface: Bool) where T: Typeable, T: Describeable {
            
            let isScalar = field.type.hasScalar
            
            let body: [Line]
            if isInterface {
                body = ["get"]
            } else {
                body = self.subfieldBodyWith(name: field.name, type: field.type.leafName!, buildable: false, isObject: !isScalar)
            }
            
            var comments = field.descriptionComments()
            
            if isScalar {
                comments.append(Line(content: " - Value Type: `\(field.type.recursiveTypeString())`"))
            }
            
            containerType.add(child: Property(
                visibility: .none,
                name:       field.name,
                returnType: isInterface ? "Self" : type,
                body:       body,
                comments:   comments
            ))
        }
        
        private func generate(methodFor field: Schema.Field, ofType type: String, appendingTo containerType: Swift.Class, isInterface: Bool, buildable: Bool) {
            
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
            let fieldType = field.type.leafName!
            let closure   = self.closureNameWith(type: fieldType)
            
            if buildable {
                parameters.append(Method.Parameter(
                    unnamed: true,
                    name:    closure.name,
                    type:    .normal(closure.type)
                ))
            }
            
            var body: [Line] = []
            if !isInterface {
                body = self.subfieldBodyWith(name: field.name, type: fieldType, buildable: buildable, isObject: !field.type.hasScalar, arguments: field.arguments)
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
        
        // ----------------------------------
        //  MARK: - Content -
        //
        private func baseClassName() -> String {
            return "Field"
        }
        
        private func closureNameWith(type: String) -> (name: String, type: String) {
            return (
                name: "buildOn",
                type: "(\(type)) -> Void"
            )
        }
        
        private func subfieldBodyWith(name: String, type: String, buildable: Bool, isObject: Bool, arguments: [Schema.Argument]? = nil) -> [Line] {
            var lines: [Line] = []
            
            let closure = self.closureNameWith(type: "")
            
            /* ----------------------------------------
             ** If this field accepts arguments, we'll
             ** need to add logic for appending only
             ** non-nil parameters (those that are set).
             */
            var paramVariable = "[]"
            if let arguments = arguments, !arguments.isEmpty {
                
                lines += "var parameters: [Parameter] = []"
                lines += ""
                
                paramVariable = "parameters"
                
                /* -----------------------------
                 ** Append non-null values first
                 */
                let nonNullArguments = arguments.filter { !$0.type.isTopLevelNullable }
                if !nonNullArguments.isEmpty {
                    
                    for argument in nonNullArguments where argument.name != closure.name {
                        lines += Line(content: "parameters.append(Parameter(name: \"\(argument.name)\", value: \(argument.name)))")
                    }
                    lines += ""
                }
                
                /* -----------------------------
                 ** Append nullable values after
                 */
                let nullableArguments = arguments.filter { $0.type.isTopLevelNullable }
                if !nullableArguments.isEmpty {
                    
                    for argument in nullableArguments where argument.name != closure.name {
                        lines += Line(content: "if let arg = \(argument.name) { parameters.append(Parameter(name: \"\(argument.name)\", value: arg)) }")
                    }
                    lines += ""
                }
            }
            
            /* ----------------------------------------
             ** Ensure that we aren't creating field
             ** subclass instances of scalar types but
             ** only object types.
             */
            let objectType: String
            if isObject {
                objectType = type
            } else {
                objectType = self.baseClassName()
            }
            
            lines += Line(content: "let field = \(objectType)(name: \"\(name)\", parameters: \(paramVariable))")
            lines += Line(content: "self._add(child: field)")
            lines += Line(content: "")
            
            if buildable {
                lines += Line(content: "buildOn(field)")
                lines += Line(content: "")
            }
            
            lines += Line(content: "return self")
            
            return lines
        }
        
        private func inlineFragmentContentWith(type: String) -> [Line] {
            var lines: [Line] = []
            
            lines += Line(content: "let field    = \(type)(name: \"\", parameters: [])")
            lines += Line(content: "let fragment = InlineFragment(type: \"\(type)\")")
            lines += Line(content: "")
            lines += Line(content: "self._add(child: fragment)")
            lines += Line(content: "")
            lines += Line(content: "buildOn(field)")
            lines += Line(content: "fragment._add(children: field._children)")
            lines += Line(content: "")
            lines += Line(content: "return self")
            
            
            return lines
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

func +=<T>(lhs: inout [T], rhs: T) {
    lhs.append(rhs)
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
    
    func inheritances(isInterface: Bool) -> [String] {
        
        /* ----------------------------------------
         ** Build all interfaces and superclasses
         ** that this object will inherit from. It
         ** will always inherit from `Field` to
         ** facilitate the generation of queries.
         */
        var inheritances: [String] = []
        
        if !isInterface {
            inheritances.append("Field")
        }
        
        if let interfaces = self.interfaces, !interfaces.isEmpty {
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

extension Describeable {
    
    func descriptionComments() -> [Swift.Line] {
        return Swift.Line.linesWith(requiredContent: self.description ?? "No documentation available for `\(self.name)`")
    }
}

extension Schema.Argument {
    
    func methodParameter(useDefaultValues: Bool) -> Swift.Method.Parameter {
        
        var defaultValue: Swift.Method.Parameter.Default?
        if self.type.isTopLevelNullable && useDefaultValues {
            defaultValue = .nil
        }
        
        let typeString = self.type.recursiveTypeString()
        
        let type: Swift.Method.Parameter.ValueType
        if self.type.needsGenericConstraint {
            // TODO: Remove
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
