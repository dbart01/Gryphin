//
//  Schema.ObjectType.swift
//  HubCenter
//
//  Created by Dima Bart on 2016-12-24.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Schema {
    final class ObjectType: JsonCreatable {
        
        let kind:   Kind
        let name:   String?
        let ofType: ObjectType?
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(json: JSON) {
            self.kind   = Kind(string: json["kind"]       as! String)
            self.name   = json["name"]                    as? String
            self.ofType = ObjectType(json: json["ofType"] as? JSON)
        }
    }
}
