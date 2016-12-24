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
        let description:       String?
        let type:              ObjectType
        let arguments:         [Argument]
        let isDeprecated:      Bool
        let deprecationReason: String?
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(json: JSON) {
            self.name              = json["name"]                  as! String
            self.description       = json["description"]           as? String
            self.isDeprecated      = json["isDeprecated"]          as? Bool ?? false
            self.deprecationReason = json["deprecationReason"]     as? String
            self.type              = ObjectType(json: json["type"] as! JSON)
            self.arguments         = Argument.collectionWith(requiredJson: json["args"] as! [JSON])
        }
    }
}
