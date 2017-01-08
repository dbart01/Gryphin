//
//  Fragment.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-12.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

final class Fragment: ContainerType {
    
    var _name:          String
    var _typeCondition: String?
    var _parameters:    [Parameter]
    
    var _parent:        ContainerType?
    var _children:     [ReferenceType] = []
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(name: String, typeCondition: String? = nil, parameters: [Parameter] = [], children: [ReferenceType]? = nil) {
        self._name          = name
        self._parameters    = parameters
        self._typeCondition = typeCondition
        
        if let children = children {
            self._add(children: children)
        }
    }
}

// ----------------------------------
//  MARK: - ValueType -
//
extension Fragment {
    var _stringRepresentation: String {
        var representation = "\(self._newline)\(self._indent)fragment \(self._name)"
        
        if let typeCondition = self._typeCondition {
            representation += " on \(typeCondition) "
        }
        
        if !self._parameters.isEmpty {
            let keyValues      = self._parameters.map { $0._stringRepresentation }
            let keyValueString = keyValues.joined(separator: " ")
            representation    += "(\(keyValueString))"
        }
        
        if !self._children.isEmpty {
            let children       = self._children.map { $0._stringRepresentation }
            let joinedChildren = children.joined(separator: " ")
            
            representation += "\(self._space){"
            representation += joinedChildren
            representation += "\(self._newline)\(self._indent)}"
        }
        
        return representation
    }
}
