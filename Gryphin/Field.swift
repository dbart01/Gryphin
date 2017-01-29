//
//  Field.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-12.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

enum FieldError: Error {
    case InvalidSyntax(String)
}

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
        self._alias      = alias?.aliasPrefixed
        self._parameters = parameters
        
        if let children = children {
            try! self._add(children: children)
        }
    }
    
    // ----------------------------------
    //  MARK: - Alias -
    //
    func alias(_ alias: String) -> Self {
        self.enquedAlias = alias.aliasPrefixed
        return self
    }
    
    private func applyEnqueuedAliasTo(_ child: ReferenceType) throws {
        guard let alias = self.enquedAlias else {
            return
        }
        
        guard let field = child as? Field else {
            throw FieldError.InvalidSyntax("Alias can only be applied to Field types.")
        }
        
        field._alias = alias
        
        self.enquedAlias = nil
    }
    
    // ----------------------------------
    //  MARK: - Children -
    //
    func _add(children: [ReferenceType]) throws {
        if !children.isEmpty {
            
            if let child = children.first {
                try self.applyEnqueuedAliasTo(child)
            }
            
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
            representation = "\(self._indent)\(alias): \(self._name)"
        } else {
            representation = "\(self._indent)\(self._name)"
        }
        
        if !self._parameters.isEmpty {
            let keyValues      = self._parameters.map { $0._stringRepresentation }
            let keyValueString = keyValues.joined(separator: " ")
            representation    += "(\(keyValueString))"
        }
        
        if !self._children.isEmpty {
            let children       = self._children.map { $0._stringRepresentation }
            let joinedChildren = children.joined()
            
            representation += "\(self._space){\(self._newline)"
            representation += joinedChildren
            representation += "\(self._indent)}"
        }
        
        representation += self._newline
        
        return representation
    }
}
