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
        
        struct File {
            var name:      String
            var container: Container
        }
        
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
        init(withSchema schema: JSON) {
            self.schemaJSON = schema
        }
        
        convenience init(withSchemaAt url: URL) throws {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let schemaJSON = json as? JSON else {
                throw GeneratorError.invalidFormat
            }
            
            self.init(withSchema: schemaJSON)
        }
        
        // ----------------------------------
        //  MARK: - Generation -
        //
        func generate() -> [File] {
            
            let schemaData     = self.schemaJSON[SchemaKey.data] as! JSON
            let jsonSchema     = schemaData[SchemaKey.schema]    as! JSON
            let jsonTypes      = jsonSchema[SchemaKey.types]     as! [JSON]
            
            let queryType      = (jsonSchema[SchemaKey.queryType]    as! JSON)["name"] as! String
            let mutationType   = (jsonSchema[SchemaKey.mutationType] as! JSON)["name"] as! String
            
            let scalarsFile = File(name: "Scalars", container: Container())
            let enumsFile   = File(name: "Enums",   container: Container())
            let queriesFile = File(name: "Queries", container: Container())
            let modelsFile  = File(name: "Models",  container: Container())
            let inputsFile  = File(name: "Inputs",  container: Container())
            
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
                    let objectClass = self.generate(object: type)
                    
                    /* ---------------------------------
                     ** Specific logic for root Query
                     ** and Mutation types.
                     */
                    switch type.name {
                    case queryType:
                        objectClass.prepend(child: self.generate(initNamed: "query", type: objectClass.name))
                    case mutationType:
                        objectClass.prepend(child: self.generate(initNamed: "mutation", type: objectClass.name))
                    default: break
                    }
                    
                    queriesFile.container += objectClass
                    modelsFile.container += self.generate(objectModel: type)
                    
                case .interface:
                    queriesFile.container += self.generate(interface: type, parsedTypes: generatedTypes)
                    queriesFile.container += self.generate(concreteInterface: type)
                    
                    // TODO: generate(interfaceModel: type)
                    modelsFile.container += self.generate(concreteInterfaceModel: type)
                    
                case .enum:
                    enumsFile.container += self.generate(enum: type)
                    
                case .inputObject:
                    inputsFile.container += self.generate(inputObject: type)
                    
                case .scalar:
                    if let alias = self.generate(scalar: type) {
                        scalarsFile.container += alias
                    }
                    
                case .union:
                    queriesFile.container += self.generate(union: type)
                    queriesFile.container += self.generate(concreteInterface: type)
                    
                    modelsFile.container  += self.generate(concreteInterfaceModel: type)
                    
                case .list:
                    break
                case .nonNull:
                    break
                }
            }
            
            return [
                scalarsFile,
                enumsFile,
                queriesFile,
                modelsFile,
                inputsFile,
            ]
        }
        
        // ----------------------------------
        //  MARK: - (Query) Type Generation -
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
                enumClass.add(child: EnumCase(
                    name:     "`\(value.name.snakeToCamel ?? value.name)`",
                    value:    .quoted(value.name),
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
                name:         interface.queryTypeName,
                inheritances: interface.inheritances(),
                comments:     interface.descriptionComments()
            )
            
            if let fields = interface.fields {
                swiftInterface += self.generate(fields: fields, ofType: "Self", isInterface: true)
            }
            
            container += swiftInterface
            
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
                
                for possibleType in possibleTypes {
                    
                    /* ----------------------------------------
                     ** We assume that all possible types have
                     ** a non-null name property that is it's type.
                     */
                    if let object = parsedTypes[possibleType.possibleName!] {
                        
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
                                name:       possibleType.queryTypeName,
                                comments:   [
                                    Swift.Line(content: "Auto-generated property for compatibility with `\(interface.queryTypeName)`")
                                ]
                            )
                            
                            for objectField in objectFields {
                                swiftExtension += self.generate(propertyFor: objectField, ofType: swiftExtension.name, isInterface: false)
                            }
                            
                            container += swiftExtension
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
                name:         concreteInterface.queryConcreteTypeName,
                inheritances: ["TypedField", concreteInterface.queryTypeName],
                comments:     [
                    Swift.Line(content: "Concrete type auto-generated for `\(concreteInterface.queryTypeName)`")
                ]
            )
            
            if let fields = concreteInterface.fields {
                swiftClass += self.generate(fields: fields, ofType: swiftClass.name, isInterface: false)
            }
            
            if let possibleTypes = concreteInterface.possibleTypes {
                for possibleType in possibleTypes {
                    
                    let fieldName = possibleType.name
                    let typeName  = possibleType.queryTypeName
                    
                    let closure   = self.closureNameWith(type: typeName)
                    let parameter = Method.Parameter(
                        unnamed: true,
                        name:    closure.name,
                        type:    closure.type
                    )
                    
                    let method = Method(
                        visibility: .none,
                        name:        .func("fragmentOn\(fieldName)"),
                        returnType:  swiftClass.name,
                        parameters:  [parameter],
                        annotations: [.discardableResult],
                        body:        self.inlineFragmentContentWith(type: typeName, field: fieldName),
                        comments:    [
                            Line(content: "Use an inline fragment to query specific fields of `\(typeName)`")
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
                name:         union.queryTypeName,
                inheritances: union.inheritances(),
                comments:     union.descriptionComments()
            )
            
            container += swiftClass
            
            if let possibleTypes = union.possibleTypes {
                possibleTypes.forEach {
                    
                    container += Class(
                        visibility:   .none,
                        kind:         .extension,
                        name:         $0.queryTypeName,
                        inheritances: [union.queryTypeName]
                    )
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
                name:         object.queryTypeName,
                inheritances: object.inheritances(from: [self.fieldClassName()]),
                comments:     object.descriptionComments()
            )
            
            if let fields = object.fields {
                swiftClass += self.generate(fields: fields, ofType: object.queryTypeName, isInterface: false)
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
                kind:         .struct,
                name:         inputObject.queryTypeName,
                inheritances: inputObject.inheritances(from: [self.inputClassName()]),
                comments:     inputObject.descriptionComments()
            )
            
            if let fields = inputObject.inputFields {
                
                /* -----------------------------------
                 ** First we create stored  properties
                 ** that will be set by the caller.
                 */
                for field in fields {
                    swiftClass += self.generate(inputPropertyFor: field)
                }
                
                var initParams: [Method.Parameter] = []
                for field in fields {
                    initParams += Method.Parameter(
                        unnamed: false,
                        name:    field.name,
                        type:    field.type.recursiveQueryInputType(unmodified: field.type.hasScalar),
                        default: field.type.isTopLevelNullable ? .nil : nil
                    )
                }
                
                var initBody: [Line] = []
                for field in fields {
                    initBody += Line(content: "self.\(field.name) = \(field.name)")
                }
                
                swiftClass += Method(
                    visibility: .none,
                    name:       .init(.none, false),
                    parameters: initParams,
                    body:       initBody,
                    comments:   [
                        "Auto-generate initialier that provides default values for nullable parameters"
                    ]
                )
                
                /* ------------------------------------------
                 ** We then create a conformance to InputType
                 ** by declaring and implementing the following
                 ** method, appending only parameters that
                 ** have been set (ignoring nil params).
                 */
                var body: [Line] = []
                
                body += "var parameters: [Parameter] = []"
                body += ""
                
                /* -----------------------------
                 ** Append non-null values first
                 */
                let nonNullFields = fields.filter { !$0.type.isTopLevelNullable }
                if !nonNullFields.isEmpty {
                    
                    for field in nonNullFields {
                        body += Line(content: "parameters += Parameter(name: \"\(field.name)\", value: self.\(field.name))")
                    }
                    body += ""
                }
                
                /* -----------------------------
                 ** Append nullable values after
                 */
                let nullableFields = fields.filter { $0.type.isTopLevelNullable }
                if !nullableFields.isEmpty {
                    
                    for field in nullableFields {
                        body += Line(content: "if let v = self.\(field.name) { parameters += Parameter(name: \"\(field.name)\", value: v) }")
                    }
                    body += ""
                }
                
                body += "return parameters"
                
                swiftClass += Method(
                    visibility:  .none,
                    name:        .func("_representationParameters"),
                    returnType:  "[Parameter]",
                    body:        body,
                    comments:    ["Auto-generated method for conformance to InputType"]
                )
            }
            
            return swiftClass
        }
        
        // ----------------------------------
        //  MARK: - (Model) Type Generation -
        //
        private func generate(concreteInterfaceModel concreteInterface: Schema.Object) -> Class {
            
            precondition(concreteInterface.kind == .interface || concreteInterface.kind == .union)
            
            let swiftClass = Class(
                visibility:   .none,
                kind:         .class(.final),
                name:         concreteInterface.modelConcreteTypeName,
                inheritances: [self.modelConcreteClassName()],
                comments:     [
                    Line(content: "Auto-generated concrete model for interface `\(concreteInterface.modelTypeName)`"),
                ]
            )
            
            swiftClass += self.generate(typeNamePropertyWith: concreteInterface.name)
            
            if let possibleTypes = concreteInterface.possibleTypes {
                for possibleType in possibleTypes {
                    
                    swiftClass += Property(
                        visibility: .none,
                        name:       possibleType.name.lowercasedFirst,
                        returnType: possibleType.modelTypeName.implicitNullable,
                        accessors:  [
                            Property.Accessor(kind: .get, body: [
                                Line(content: "return try! self.valueFor(nullable: \"\(possibleType.name.lowercasedFirst)\")")
                            ]),
                            Property.Accessor(kind: .set, body: [
                                Line(content: "self.set(newValue, for: \"\(possibleType.name.lowercasedFirst)\")")
                            ]),
                        ],
                        comments: [
                            Line(content: "Auto-generated property for fragment on `\(possibleType.modelTypeName)`"),
                        ]
                    )
                }
                
                swiftClass += self.generate(initializerWith: possibleTypes)
            }
            
            
            return swiftClass
        }
        
        private func generate(objectModel object: Schema.Object) -> Class {
            
            precondition(object.kind == .object)
            
            /* -----------------------------------------
             ** Initialize the class that will represent
             ** this object.
             */
            let swiftClass = Class(
                visibility:   .none,
                kind:         .class(.final),
                name:         object.modelTypeName,
                inheritances: [self.modelClassName()],
                comments:     object.descriptionComments()
            )
            
            swiftClass += self.generate(typeNamePropertyWith: object.name.mapped)
            
            if let fields = object.fields {
                
                /* ---------------------------------
                 ** Generate the properties of this
                 ** model object.
                 */
                for field in fields {
                    
                    let nullability = field.type.isTopLevelNullable ? "nullable" : "nonnull"
                    
                    swiftClass += Property(
                        visibility: .none,
                        name:       field.name,
                        returnType: field.type.recursiveType(queryKind: .model, concrete: true, unmodified: field.type.hasScalar),
                        accessors:  [
                            Property.Accessor(kind: .get, body: [
                                Line(content: "return try! self.valueFor(\(nullability): \"\(field.name)\")")
                            ]),
                            Property.Accessor(kind: .set, body: [
                                Line(content: "self.set(newValue, for: \"\(field.name)\")")
                            ]),
                        ],
                        comments: field.descriptionComments()
                    )
                }
                
                swiftClass += self.generate(initializerWith: fields)
                
                /* ----------------------------------
                 ** Generate the alias accessors that
                 ** can convert JSON response object
                 ** into valid models on demand. This
                 ** only applies to non-scalars, tho.
                 */
                for field in fields where !field.type.hasScalar && !field.type.isCollection {
                    
                    let fieldType = field.type.recursiveType(queryKind: .model, concrete: true, unmodified: field.type.hasScalar)
                        
                    swiftClass += Method(
                        visibility: .none,
                        name:       .func(field.name),
                        returnType: fieldType,
                        parameters: [
                            Method.Parameter(
                                unnamed: true,
                                name:    "alias",
                                type:    "String"
                            )
                        ],
                        body:  [
                            Line(content: "return try! self.aliasedWith(alias)"),
                        ],
                        comments: field.descriptionComments()
                    )
                }
            }
            
            return swiftClass
        }
        
        // ----------------------------------
        //  MARK: - (Model) Member Generation -
        //
        private func generate(typeNamePropertyWith name: String) -> Property {
            return Property(
                kind:       .static,
                visibility: .none,
                override:   true,
                name:       "typeName",
                returnType: "String",
                body:       [
                    Line(content: "return \"\(name)\""),
                ]
            )
        }
        
        private func generate(initializerWith fields: [Schema.Field]) -> Method {
            var initBody: [Line] = []
            
            initBody += "super.init(json: json)"
            
            let scalarFields = fields.filter { $0.type.hasScalar }
            if !scalarFields.isEmpty {
                initBody += ""
                
                for field in scalarFields {
                    initBody += self.generate(propertyAssignmentNamed: field.name, isFragment: false)
                }
            }
            
            let objectFields = fields.filter { !$0.type.hasScalar }
            if !objectFields.isEmpty {
                initBody += ""
                
                for field in objectFields {
                    let type  = field.type.recursiveType(queryKind: .model, unmodified: field.type.hasScalar, ignoreNull: true)
                    initBody += self.generate(propertyAssignmentNamed: field.name, type: type, isFragment: false, isCollection: field.type.isCollection)
                }
            }
            
            return Method(
                visibility: .none,
                name:       .init(.required, true),
                parameters: [
                    Method.Parameter(name: "json", type: "JSON"),
                ],
                body: initBody
            )
        }
        
        private func generate(initializerWith types: [Schema.ObjectType]) -> Method {
            var initBody: [Line] = []
            initBody += "super.init(json: json)"
            initBody += ""
            
            for type in types {
                
                precondition(!type.hasScalar) // These should always be possible object types
                
                let name  = type.recursiveType(queryKind: .model, unmodified: false, ignoreNull: true)
                initBody += self.generate(propertyAssignmentNamed: type.name.lowercasedFirst, type: name, isFragment: true, isCollection: type.isCollection)
            }
            
            return Method(
                visibility: .none,
                name:       .init(.required, true),
                parameters: [
                    Method.Parameter(name: "json", type: "JSON"),
                ],
                body: initBody
            )
        }
        
        private func generate(propertyAssignmentNamed name: String, type: String? = nil, isFragment: Bool, isCollection: Bool = false) -> Line {
            if let type = type {
                
                let value: String
                if isFragment {
                    value = "json"
                } else {
                    value = "json.v(\"\(name)\")"
                }
                
                if isCollection {
                    return Line(content: "self.set(\(type).from(\(value)), for: \"\(name)\")")
                } else {
                    return Line(content: "self.set(\(type)(json: \(value)), for: \"\(name)\")")
                }
                
            } else {
                return Line(content: "self.set(json.v(\"\(name)\"), for: \"\(name)\")")
            }
        }
        
        // ----------------------------------
        //  MARK: - (Query) Field Generation -
        //
        private func generate(initNamed name: String, type: String) -> Method {
            let closure = self.closureNameWith(type: type)
            
            return Method(
                visibility:  .none,
                name:        .init(.convenience, false),
                parameters:  [
                    Method.Parameter(
                        unnamed: true,
                        name: closure.name,
                        type: closure.type
                    )
                ],
                body:        [
                    Line(content: "self.init(name: \"\(name)\", parameters: [])"),
                    Line(content: "\(closure.name)(self)"),
                ],
                comments:    [
                    "Auto-generated convenience initializer"
                ]
            )
        }
        
        private func generate(inputPropertyFor field: Schema.InputField) -> Property {
            return Property(
                visibility: .none,
                name:       field.name,
                returnType: field.type.recursiveQueryInputType(unmodified: field.type.hasScalar),
                comments:   field.descriptionComments()
            )
        }
        
        private func generate(fields: [Schema.Field], ofType name: String, isInterface: Bool) -> [Container] {
            
            var containers: [Container] = []
            
            for field in fields {
                
                /* -------------------------------------------
                 ** If the field is a scalar value and takes
                 ** no arguments (no need for a method), there's 
                 ** a gurantee that it cannot accept subfields
                 ** and will represented by a property rather
                 ** than a method with a `buildOn` parameter.
                 */
                if field.type.hasScalar && field.arguments.isEmpty {
                    containers += self.generate(propertyFor: field, ofType: name, isInterface: isInterface)
                } else {
                    containers += self.generate(methodFor: field, ofType: name, isInterface: isInterface, buildable: !field.type.hasScalar)
                }
            }
            
            return containers
        }
        
        private func generate<T>(propertyFor field: T, ofType type: String, isInterface: Bool) -> Property where T: Typeable, T: Describeable {
            
            let isScalar = field.type.hasScalar
            
            let body: [Line]
            if isInterface {
                body = ["get"]
            } else {
                let type = field.type.recursiveType(queryKind: .query, unmodified: field.type.hasScalar)
                body     = self.subfieldBodyWith(name: field.name, type: type, buildable: false, isObject: !isScalar)
            }
            
            var comments = field.descriptionComments()
            
            if isScalar {
                comments += Line(content: " - Value Type: `\(field.type.recursiveQueryType(unmodified: field.type.hasScalar))`")
            }
            
            return Property(
                visibility: .none,
                name:       field.name,
                returnType: isInterface ? "Self" : type,
                body:       body,
                comments:   comments
            )
        }
        
        private func generate(methodFor field: Schema.Field, ofType type: String, isInterface: Bool, buildable: Bool) -> Method {
            
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
            let fieldType = field.type.leaf.recursiveType(queryKind: .query, unmodified: field.type.hasScalar, ignoreNull: true)
            
            if buildable {
                let closure = self.closureNameWith(type: fieldType)
                
                parameters += Method.Parameter(
                    unnamed: true,
                    name:    closure.name,
                    type:    closure.type
                )
            }
            
            var body: [Line] = []
            if !isInterface {
                body = self.subfieldBodyWith(name: field.name, type: fieldType, buildable: buildable, isObject: !field.type.hasScalar, arguments: field.arguments)
            }
            
            return Method(
                visibility:  .none,
                name:        .func(field.name),
                returnType:  isInterface ? "Self" : type,
                parameters:  parameters,
                annotations: [.discardableResult],
                body:        body,
                comments:    field.parameterDocComments()
            )
        }
        
        // ----------------------------------
        //  MARK: - Content -
        //
        private func modelNamespace() -> String {
            return "Model"
        }
        
        private func modelClassName() -> String {
            return "GraphModel"
        }
        
        private func modelConcreteClassName() -> String {
            return "ConcreteGraphModel"
        }
        
        private func fieldClassName() -> String {
            return "Field"
        }
        
        private func inputClassName() -> String {
            return "InputType"
        }
        
        private func closureNameWith(type: String) -> (name: String, type: String) {
            return (
                name: "buildOn",
                type: "(\(type)) -> Void"
            )
        }
        
        private func subfieldBodyWith(name: String, type: String, buildable: Bool, isObject: Bool, arguments: [Schema.Argument]? = nil) -> [Line] {
            var lines: [Line] = []
            
            /* ----------------------------------------
             ** If this field accepts arguments, we'll
             ** need to add logic for appending only
             ** non-nil parameters (those that are set).
             */
            var paramVariable = "[]"
            if let arguments = arguments, !arguments.isEmpty {
                
                let closure = self.closureNameWith(type: "")
                
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
                objectType = self.fieldClassName()
            }
            
            lines += Line(content: "let field = \(objectType)(name: \"\(name)\", parameters: \(paramVariable))")
            lines += Line(content: "try! self._add(child: field)")
            lines += Line(content: "")
            
            if buildable {
                lines += Line(content: "buildOn(field)")
                lines += Line(content: "")
            }
            
            lines += Line(content: "return self")
            
            return lines
        }
        
        private func inlineFragmentContentWith(type: String, field: String) -> [Line] {
            var lines: [Line] = []
            
            lines += Line(content: "let field    = \(type)(name: \"\", parameters: [])")
            lines += Line(content: "let fragment = InlineFragment(type: \"\(field)\")")
            lines += Line(content: "")
            lines += Line(content: "try! self._add(child: fragment)")
            lines += Line(content: "")
            lines += Line(content: "buildOn(field)")
            lines += Line(content: "try! fragment._add(children: field._children)")
            lines += Line(content: "")
            lines += Line(content: "return self")
            
            
            return lines
        }
    }
}

// ----------------------------------
//  MARK: - Extensions -
//
fileprivate extension Array {
    
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
fileprivate extension Schema.Object {
    
    func descriptionComments() -> [Swift.Line] {
        var commentLines = Swift.Line.linesWith(requiredContent: self.description ?? "")
        
        /* ----------------------------------------
         ** If this is an interface, we'll append
         ** additional comments about what possible 
         ** types implement this interface.
         */
        if let possibleTypes = self.possibleTypes, !possibleTypes.isEmpty {
            
            commentLines += ""
            commentLines += "## Implementing types:"
            
            for possibleType in possibleTypes {
                commentLines += Swift.Line(content: " - `\(possibleType.queryTypeName)`")
            }
        }
        
        return commentLines
    }
    
    func inheritances(from: [String]? = nil) -> [String] {
        
        /* ----------------------------------------
         ** Build all interfaces and superclasses
         ** that this object will inherit from.
         */
        var inheritances: [String] = from ?? []
        
        if let interfaces = self.interfaces, !interfaces.isEmpty {
            inheritances += interfaces.map {
                $0.queryTypeName
            }
        }
        
        return inheritances
    }
}

// ----------------------------------
//  MARK: - String Extension -
//
fileprivate extension String {
    
    private static var __TypeMap: [String : String] = [
        "String"  : "String",
        "Boolean" : "Bool",
        "Int"     : "Int",
        "Float"   : "Float",
    ]
    
    var mapped: String {
        if let type = String.__TypeMap[self] {
            return type
        }
        return self
    }
    
    var nullable: String {
        return "\(self)?"
    }
    
    var implicitNullable: String {
        return "\(self)!"
    }
}

// ----------------------------------
//  MARK: - Nameable Extension -
//
fileprivate extension Nameable {
    
    var queryConcreteTypeName: String {
        return "QConcrete\(self.name.mapped)"
    }
    
    var queryTypeName: String {
        return "Q\(self.name.mapped)"
    }
    
    var modelConcreteTypeName: String {
        return "Concrete\(self.name.mapped)"
    }
    
    var modelTypeName: String {
        return "\(self.name.mapped)"
    }
}

// ----------------------------------
//  MARK: - ObjectType Extension -
//
fileprivate extension Schema.ObjectType {
    
    enum RecursiveKind {
        case query
        case model
    }
    
    func recursiveQueryInputType(unmodified: Bool) -> String {
        let type = self.recursiveType(queryKind: .query, unmodified: unmodified, ignoreNull: true)
        return self.isTopLevelNullable ? type.implicitNullable : type
    }
    
    func recursiveModelInputType(unmodified: Bool) -> String {
        let type = self.recursiveType(queryKind: .model, unmodified: unmodified, ignoreNull: true)
        return self.isTopLevelNullable ? type.implicitNullable : type
    }
    
    func recursiveQueryType(unmodified: Bool) -> String {
        return self.recursiveType(queryKind: .query, unmodified: unmodified)
    }
    
    func recursiveModelType(unmodified: Bool) -> String {
        return self.recursiveType(queryKind: .model, unmodified: unmodified)
    }
    
    func recursiveQueryConcreteType() -> String {
        return self.recursiveType(queryKind: .query)
    }
    
    func recursiveModelConcreteType() -> String {
        return self.recursiveType(queryKind: .model)
    }
    
    func recursiveType(queryKind: RecursiveKind, concrete: Bool? = nil, unmodified: Bool = false, ignoreNull: Bool = false) -> String {
        return self.recursiveType(queryKind: queryKind, nonNull: false, withinList: false, concrete: concrete ?? self.isAbstract, unmodified: unmodified, ignoreNull: ignoreNull)
    }
    
    private func recursiveType(queryKind: RecursiveKind, nonNull: Bool, withinList: Bool, concrete: Bool, unmodified: Bool, ignoreNull: Bool, level: Int = 0) -> String {
        
        let isNonNull    = self.kind == .nonNull
        let isWithinList = withinList || self.kind == .list // Persist flag through recursion
        let childType    = self.ofType?.recursiveType(queryKind: queryKind, nonNull: isNonNull, withinList: isWithinList, concrete: concrete, unmodified: unmodified, ignoreNull: ignoreNull, level: level + 1) ?? ""
        
        switch self.kind {
        case .enum:       fallthrough
        case .union:      fallthrough
        case .scalar:     fallthrough
        case .object:     fallthrough
        case .interface:  fallthrough
        case .inputObject:
            
            let modifiedType: (Void) -> String = {
                switch queryKind {
                case .query: return self.isAbstract ? self.queryConcreteTypeName : self.queryTypeName
                case .model: return self.isAbstract ? self.modelConcreteTypeName : self.modelTypeName
                }
            }
            
            if nonNull || ignoreNull {
                return unmodified ? self.name.mapped : modifiedType()
            } else {
                let type = unmodified ? self.name.mapped : modifiedType()
                return isWithinList ? type.nullable : type.implicitNullable
            }
            
        case .list:
            
            if nonNull || ignoreNull {
                return "[\(childType)]"
            } else {
                return "[\(childType)]".implicitNullable
            }
            
        case .nonNull:
            return childType
        }
    }
}

// ----------------------------------
//  MARK: - Describeable Extension -
//
fileprivate extension Describeable {
    
    func descriptionComments() -> [Swift.Line] {
        return Swift.Line.linesWith(requiredContent: self.description ?? "No documentation available for `\(self.name)`")
    }
}

// ----------------------------------
//  MARK: - Argument Extension -
//
fileprivate extension Schema.Argument {
    
    func methodParameter(useDefaultValues: Bool) -> Swift.Method.Parameter {
        
        var defaultValue: Swift.Method.Parameter.Default?
        if self.type.isTopLevelNullable && useDefaultValues {
            defaultValue = .nil
        }
        
        let typeString = self.type.recursiveQueryType(unmodified: self.type.hasScalar)
        
        return Swift.Method.Parameter(
            name:    self.name,
            type:    typeString,
            default: defaultValue
        )
    }
}

// ----------------------------------
//  MARK: - Field Extension -
//
fileprivate extension Schema.Field {
    
    func parameterDocComments() -> [Swift.Line] {
        var comments: [Swift.Line] = []
        comments += Swift.Line.linesWith(requiredContent: self.description ?? "No documentation available for `\(self.name)`")
        
        if !self.arguments.isEmpty {
            comments += ""
            comments += "- parameters:"
            for arg in self.arguments {
                let description = arg.description ?? "No documentation"
                comments += Swift.Line(content: "    - \(arg.name): \(description)")
            }
            comments += ""
        }
        return comments
    }
    
    func parameters(isInterface: Bool) -> [Swift.Method.Parameter] {
        return self.arguments.map {
            $0.methodParameter(useDefaultValues: !isInterface)
        }
    }
}
