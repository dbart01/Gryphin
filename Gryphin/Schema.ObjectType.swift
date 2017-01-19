//
//  Schema.ObjectType.swift
//  Gryphin
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
        
        var hasScalar: Bool {
            if let type = self.ofType {
                return type.hasScalar
            }
            return self.kind == .scalar || self.kind == .enum
        }
        
        var leafName: String? {
            if let childType = self.ofType {
                return childType.leafName
            } else {
                return Object.concreteNameFor(name: self.name, with: self.kind)
            }
        }
        
        var isTopLevelNullable: Bool {
            return self.kind != .nonNull
        }
        
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
