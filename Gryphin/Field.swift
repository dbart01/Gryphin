//
//  Field.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-12.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

class Field: ContainerType {
    
    var _name:       String
    var _alias:      String?
    var _parameters: [Parameter]
    
    var _parent:     ContainerType?
    var _children:  [ReferenceType] = []
    
    private var enquedAlias: String?
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(name: String, alias: String? = nil, parameters: [Parameter] = [], children: [ReferenceType]? = nil) {
        self._name       = name
        self._alias      = alias
        self._parameters = parameters
        
        if let children = children {
            self._add(children: children)
        }
    }
    
    // ----------------------------------
    //  MARK: - Alias -
    //
    func alias(_ alias: String) -> Self {
        self.enquedAlias = alias
        return self
    }
    
    private func insertAlias(children: [ReferenceType]) {
        if let field = children.first as? Field {
            field._alias = self.enquedAlias
        }
        self.enquedAlias = nil
    }
    
    // ----------------------------------
    //  MARK: - Children -
    //
    func _add(children: [ReferenceType]) {
        if !children.isEmpty {
            self.insertAlias(children: children)
            
            children.forEach {
                $0._parent = self
            }
            self._children.append(contentsOf: children)
        }
    }
}

// ----------------------------------
//  MARK: - ValueType -
//
extension Field {
    var _stringRepresentation: String {
        var representation: String
        
        if let alias = self._alias {
            representation = "\(self._newline)\(self._indent)\(alias): \(self._name)"
        } else {
            representation = "\(self._newline)\(self._indent)\(self._name)"
        }
        
        if !self._parameters.isEmpty {
            let keyValues      = self._parameters.map { "\($0._name): \($0._value._stringRepresentation)" }
            let keyValueString = keyValues.joined(separator: " ")
            representation    += "(\(keyValueString))"
        }
        
        if !self._children.isEmpty {
            let children       = self._children.map { $0._stringRepresentation }
            let joinedChildren = children.joined(separator: " ")
            representation    += "\(self._space){\(joinedChildren)\(self._newline)\(self._indent)}"
        }
        
        return representation
    }
}
