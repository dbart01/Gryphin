//
//  GraphError.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-21.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

public class QueryError: JsonCreatable {
    
    public struct Location: JsonCreatable {
        public let line:   Int
        public let column: Int
        
        // ----------------------------------
        //  MARK: - Init -
        //
        public init(json: JSON) {
            self.line   = json["line"]   as! Int
            self.column = json["column"] as! Int
        }
    }
    
    public let message:   String
    public let fields:    [String]?
    public let locations: [Location]?
    
    // ----------------------------------
    //  MARK: - Init -
    //
    public required init(json: JSON) {
        self.message = (json["message"] as? String) ?? "Uknown error"
        self.fields  = json["fields"]  as? [String]
        
        /* ---------------------------------
         ** Check to see if the error object
         ** contains `locations`, otherwise
         ** fallback to a flat location and
         ** then nil.
         */
        if let locations = json["locations"] as? [JSON] {
            self.locations = Location.collectionWith(optionalJson: locations)
            
        } else if json["line"] != nil && json["column"] != nil {
            
            self.locations = [
                Location(json: json),
            ]
            
        } else {
            self.locations = nil
        }
    }
}
