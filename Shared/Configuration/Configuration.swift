//
//  Configuration.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-22.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

class Configuration: JsonCreatable {
    
    struct SchemaDescription: JsonCreatable {
        let path: URL?
        let url:  URL?
        
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
        }
    }
    
    struct ScalarDescription: JsonCreatable {
        let name:   String
        let alias:  String
        let source: URL
        
        init(json: JSON) {
            self.name   = json["name"] as! String
            self.alias  = json["alias"] as! String
            self.source = URL(string: json["source"] as! String)!
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
            
        } else if let _ = self.schemaDescription?.url {
            
            // TODO: POST introspection query to endpoint
            print("Remote schema URL specified. Sending introspection...")
            return [:]
            
        } else {
            throw ConfigurationError.noSchemaLocation
        }
    }
}
