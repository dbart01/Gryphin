//
//  Configuration.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-22.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

enum ConfigurationError: Error {
    case noSchemaLocation
}

class Configuration: JsonCreatable {
    
    struct SchemaDescription: JsonCreatable {
        let path:    URL?
        let url:     URL?
        let headers: Headers?
        
        init(json: JSON) {
            if let path = json["path"] as? String {
                self.path = URL(fileURLWithPath: path)
            } else {
                self.path = nil
            }
            
            if let url = json["url"] as? String {
                self.url = URL(string: url)
            } else {
                self.url = nil
            }
            
            self.headers = json["headers"] as? Headers
        }
    }
    
    struct ScalarDescription: JsonCreatable {
        
        enum Source: JsonCreatable {
            case file(URL)
            case aliasFor(String)
            
            init(json: JSON) {
                if let file = json["file"] as? String {
                    self = .file(URL(fileURLWithPath: file))
                } else if let name = json["alias"] as? String {
                    self = .aliasFor(name)
                } else {
                    fatalError("Scalar description must contain a `source` or `alias` value.")
                }
            }
        }
        
        let name:   String
        let source: Source
        
        init(json: JSON) {
            self.name   = json["name"] as! String
            self.source = Source(json: json)
        }
    }
    
    let schemaDescription:  SchemaDescription?
    let scalarDescriptions: [ScalarDescription]?
    
    // ----------------------------------
    //  MARK: - Init -
    //
    required init(json: JSON) {
        self.schemaDescription  = SchemaDescription(json: json["schema"] as? JSON)
        self.scalarDescriptions = ScalarDescription.collectionWith(optionalJson: json["scalars"] as? [JSON])
    }
    
    // ----------------------------------
    //  MARK: - Schema -
    //
    func loadSchema() throws -> JSON {
        if let localURL = self.schemaDescription?.path {
            
            print("Local schema specified. Loading from file...")
            return try JSON.from(fileAt: localURL)
            
        } else if let remoteURL = self.schemaDescription?.url {
            
            print("Remote schema URL specified. Sending introspection...")
            if let headers = self.schemaDescription?.headers {
                print("Additional header specified: \(headers)")
            }
            
            return try IntrospectionCoordinator.introspectAt(remoteURL, additionalHeaders: self.schemaDescription?.headers)
            
        } else {
            throw ConfigurationError.noSchemaLocation
        }
    }
}
