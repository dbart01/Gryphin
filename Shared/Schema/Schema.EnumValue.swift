//
//  Schema.EnumValue.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-28.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Schema {
    final class EnumValue: JsonCreatable, Describeable {
        
        let name:              String
        let description:       String?
        let isDeprecated:      Bool
        let deprecationReason: String?
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(json: JSON) {
            self.name              = json["name"]              as! String
            self.description       = json["description"]       as? String
            self.isDeprecated      = json["isDeprecated"]      as? Bool ?? false
            self.deprecationReason = json["deprecationReason"] as? String
        }
    }
}
