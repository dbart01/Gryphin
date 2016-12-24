//
//  Schema.Argument.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-24.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Schema {
    final class Argument: JsonCreatable {
        
        let name:         String
        let description:  String?
        let ofType:       ObjectType
        let defaultValue: String?
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(json: JSON) {
            self.name         = json["name"]                  as! String
            self.description  = json["description"]           as? String
            self.ofType       = ObjectType(json: json["type"] as! JSON)
            self.defaultValue = json["defaultValue"]          as? String
        }
    }
}
