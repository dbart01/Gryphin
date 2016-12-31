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

#if DEBUG
extension ReferenceType {
    
    var _newline: String {
        return "\n"
    }
    
    var _space: String {
        return " "
    }
    
    var _indent: String {
        return [String](repeating: " ", count: self._distanceToRoot * 4).joined(separator: "")
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
#else
extension ReferenceType {
    let _newline = ""
    let _space   = ""
    let _indent  = ""
}
#endif
