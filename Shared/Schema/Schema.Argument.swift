//
//  Schema.Argument.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-24.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Schema {
    final class Argument: JsonCreatable, Describeable, Typeable {
        
        let name:         String
        let description:  String?
        let defaultValue: String?
        let type:         ObjectType
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(json: JSON) {
            self.name         = json["name"]                  as! String
            self.description  = json["description"]           as? String
            self.defaultValue = json["defaultValue"]          as? String
            self.type         = ObjectType(json: json["type"] as! JSON)
        }
    }
}
