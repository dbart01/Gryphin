//
//  Schema.InputField.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-01.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

extension Schema {
    final class InputField: JsonCreatable, Describeable, Typeable {
        
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
