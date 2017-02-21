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
        let line:   Int
        let column: Int
        
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
        self.message   = (json["message"] as? String) ?? "The error message is not provided."
        self.fields    = json["fields"]  as? [String]
        self.locations = Location.collectionWith(optionalJson: json["locations"] as? [JSON])
    }
}
