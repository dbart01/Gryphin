//
//  InlineFragment.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-08.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

final class InlineFragment: ContainerType {
    
    var _name:          String
    var _typeCondition: String
    var _parameters:    [Parameter]
    
    var _parent:        ContainerType?
    var _children:      [ReferenceType] = []
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(type: String) {
        self._name          = ""
        self._typeCondition = type
        self._parameters    = []
    }
    
    // ----------------------------------
    //  MARK: - ValueType -
    //
    var _stringRepresentation: String {
        var string = "\(self._indent)... on \(self._typeCondition)"
        
        if !self._children.isEmpty {
            let children       = self._children.map { $0._stringRepresentation }
            let joinedChildren = children.joined()
            
            string += "\(self._space){\(self._newline)"
            string += joinedChildren
            string += "\(self._indent)}"
        }
        
        string += self._newline
        
        return string
    }
}
