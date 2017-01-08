//
//  Object.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-23.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Schema {
    final class Object: JsonCreatable, Describeable {
        
        let kind:          Kind
        let name:          String
        let primitiveName: String
        let description:   String?
        let fields:        [Field]?
        let inputFields:   [InputField]?
        let interfaces:    [ObjectType]?
        let enumValues:    [EnumValue]?
        let possibleTypes: [ObjectType]?
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(json: JSON) {
            self.kind          = Kind(string: json["kind"] as! String)
            self.primitiveName = json["name"]              as! String
            self.description   = json["description"]       as? String
            
            self.fields        = Field.collectionWith(optionalJson:      json["fields"]        as? [JSON])
            self.inputFields   = InputField.collectionWith(optionalJson: json["inputFields"]   as? [JSON])
            self.interfaces    = ObjectType.collectionWith(optionalJson: json["interfaces"]    as? [JSON])
            self.enumValues    = EnumValue.collectionWith(optionalJson:  json["enumValues"]    as? [JSON])
            self.possibleTypes = ObjectType.collectionWith(optionalJson: json["possibleTypes"] as? [JSON])
            
            self.name          = Object.concreteNameFor(name: self.primitiveName, with: self.kind)!
        }
        
        static func concreteNameFor(name: String?, with kind: Kind) -> String? {
            guard let name = name else {
                return nil
            }
            
            guard kind == .interface || kind == .union else {
                return name
            }
            return "Concrete\(name)"
        }
    }
}
