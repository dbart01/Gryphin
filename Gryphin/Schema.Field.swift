//
//  Schema.Field.swift
//  HubCenter
//
//  Created by Dima Bart on 2016-12-23.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Schema {
    final class Field: JsonCreatable {
        
        let name:              String
        let description:       String
        let isDeprecated:      Bool
        let deprecationReason: String?
        let arguments:         [Argument]
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(json: JSON) {
            self.name              = json["name"]              as! String
            self.description       = json["description"]       as! String
            self.isDeprecated      = json["isDeprecated"]      as? Bool ?? false
            self.deprecationReason = json["deprecationReason"] as? String
            self.arguments         = Argument.collectionWith(json: json["args"] as! [JSON])
        }
    }
}
