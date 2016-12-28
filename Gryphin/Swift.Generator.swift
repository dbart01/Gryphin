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
        func generate() -> Document {
            
            let schemaData     = self.schemaJSON["data"]  as! JSON
            let jsonSchema     = schemaData["__schema"]   as! JSON
            let jsonTypes      = jsonSchema["types"]      as! [JSON]
            let jsonDirectives = jsonSchema["directives"] as! [JSON]
            
            let document = Document(classes: [])
            
            /* -----------------------------
             ** Parse the schema types first
             */
            let types = jsonTypes.map {
                Schema.Object(json: $0)
            }
            
            for type in types {
                
                switch type.kind {
                case .object:
                    self.generate(object: type, in: document)
                case .enum:
                    break
                case .interface:
                    break
                case .inputObject:
                    break
                case .list:
                    break
                case .nonNull:
                    break
                case .scalar:
                    break
                case .union:
                    break
                }
            }
            
            /* ----------------------------
             ** Parse the schema directives
             */
            let directives = jsonDirectives.map {
                Schema.Directive(json: $0)
            }
            
            return document
        }
        
        // ----------------------------------
        //  MARK: - Type Generation -
        //
        private func generate(object: Schema.Object, in document: Document) {
            let inheritances = object.interfaces?.map { $0.name! }
            let swiftClass   = Class(
                visibility:   .public,
                name:         object.name,
                inheritances: inheritances,
                comments:     Line.linesWith(requiredContent: object.description ?? "")
            )
            
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
                    
                    /* ------------------------------------------
                     ** Build the Method that will return a typed
                     ** value for this field.
                     */
                    swiftClass.add(child: Method(
                        visibility:  .public,
                        name:        .func(field.name),
                        returnType:  field.type.recursiveTypeString(),
                        parameters:  parameters,
                        annotations: [.discardableResult],
                        body: [
                            
                        ],
                        comments: comments
                    ))
                }
            }
            
            document.add(child: swiftClass)
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
