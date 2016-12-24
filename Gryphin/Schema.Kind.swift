//
//  Schema.Kind.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-24.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Schema {
    enum Kind {
        case scalar
        case object
        case interface
        case union
        case `enum`
        case inputObject
        case list
        case nonNull
        
        init(string: String) {
            switch string {
            case "SCALAR":       self = .scalar
            case "OBJECT":       self = .object
            case "INTERFACE":    self = .interface
            case "UNION":        self = .union
            case "ENUM":         self = .enum
            case "INPUT_OBJECT": self = .inputObject
            case "LIST":         self = .list
            case "NON_NULL":     self = .nonNull
            default:
                fatalError("Failed to parse `Kind` string. Invalid input: '\(string)'.")
            }
        }
    }
}
