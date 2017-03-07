//
//  Schema.Field.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-23.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Schema {
    final class Field: JsonCreatable, Describeable, Typeable {
        
        let name:              String
        let description:       String?
        let type:              ObjectType
        let arguments:         [Argument]
        let isDeprecated:      Bool
        let deprecationReason: String?
        
        // ----------------------------------
        //  MARK: - Init -
        //
        convenience init(json: JSON) {
            let name              = json["name"]                  as! String
            let description       = json["description"]           as? String
            let isDeprecated      = json["isDeprecated"]          as? Bool ?? false
            let deprecationReason = json["deprecationReason"]     as? String
            let type              = ObjectType(json: json["type"] as! JSON)
            let arguments         = Argument.collectionWith(requiredJson: json["args"] as! [JSON])
            
            self.init(
                name:              name,
                description:       description,
                type:              type,
                arguments:         arguments,
                isDeprecated:      isDeprecated,
                deprecationReason: deprecationReason
            )
        }
        
        private init(name: String, description: String?, type: ObjectType, arguments: [Argument], isDeprecated: Bool, deprecationReason: String?) {
            self.name              = name
            self.description       = description
            self.type              = type
            self.arguments         = arguments
            self.isDeprecated      = isDeprecated
            self.deprecationReason = deprecationReason
        }
        
        // ----------------------------------
        //  MARK: - Copy -
        //
        func changing(name: String) -> Field {
            return Field(
                name:              name,
                description:       self.description,
                type:              self.type,
                arguments:         self.arguments,
                isDeprecated:      self.isDeprecated,
                deprecationReason: self.deprecationReason
            )
        }
    }
}
