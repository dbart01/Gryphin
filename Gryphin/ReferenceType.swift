//
//  ReferenceType.swift
//  HubCenter
//
//  Created by Dima Bart on 2016-12-12.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

protocol ReferenceType: class, ValueType {
    var name:   String         { get }
    var parent: ContainerType? { get set }
}

func ==(lhs: ReferenceType, rhs: ReferenceType) -> Bool {
    return lhs === rhs
}

#if DEBUG
extension ReferenceType {
    
    var newline: String {
        return "\n"
    }
    
    var space: String {
        return " "
    }
    
    var indent: String {
        return [String](repeating: " ", count: self.distanceToRoot * 4).joined(separator: "")
    }
    
    var distanceToRoot: Int {
        var distance = 0
        var parent   = self.parent
        
        while parent != nil {
            distance += 1
            parent = parent?.parent
        }
        return distance
    }
}
#else
extension ReferenceType {
    let newline = ""
    let space   = ""
    let indent  = ""
}
#endif
