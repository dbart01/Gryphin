//
//  ReferenceType.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-12.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

protocol ReferenceType: class, ValueType {
    var _name:   String         { get }
    var _parent: ContainerType? { get set }
}

func ==(lhs: ReferenceType, rhs: ReferenceType) -> Bool {
    return lhs === rhs
}

extension ReferenceType {
    
    var _indentUnit: String {
        return " "
    }
    
    var _indentUnitCount: Int {
        return 4
    }
    
    var _newline: String {
        if Environment.prettyPrint {
            return "\n"
        }
        return ""
    }
    
    var _space: String {
        if Environment.prettyPrint {
            return " "
        }
        return ""
    }
    
    var _indent: String {
        if Environment.prettyPrint {
            
            return [String](
                repeating: self._indentUnit,
                count:     self._distanceToRoot * self._indentUnitCount
            ).joined()
            
        }
        return ""
    }
    
    var _distanceToRoot: Int {
        var distance = 0
        var parent   = self._parent
        
        while parent != nil {
            distance += 1
            parent = parent?._parent
        }
        return distance
    }
}
