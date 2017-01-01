//
//  Schema.Directive.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-24.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Schema {
    final class Directive: JsonCreatable, DescribedType {
        
        enum Location {
            case query
            case mutation
            case field
            case fragmentDefinition
            case fragmentSpread
            case inlineFragment
            case enumValue
            
            init(string: String) {
                switch string {
                case "QUERY":               self = .query
                case "MUTATION":            self = .mutation
                case "FIELD_DEFINITION":    fallthrough
                case "FIELD":               self = .field
                case "FRAGMENT_DEFINITION": self = .fragmentDefinition
                case "FRAGMENT_SPREAD":     self = .fragmentSpread
                case "INLINE_FRAGMENT":     self = .inlineFragment
                case "ENUM_VALUE":          self = .enumValue
                default:
                    fatalError("Failed to parse `Directive.Location` string. Invalid input: '\(string)'.")
                }
            }
            
            static func collectionWith(strings: [String]) -> [Location] {
                return strings.map {
                    Location(string: $0)
                }
            }
        }
        
        let name:        String
        let description: String?
        let locations:   [Location]
        let arguments:   [Argument]
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(json: JSON) {
            self.name         = json["name"]        as! String
            self.description  = json["description"] as? String
            
            self.locations    = Location.collectionWith(strings:      json["locations"] as! [String])
            self.arguments    = Argument.collectionWith(requiredJson: json["args"]      as! [JSON])
        }
    }
}
