//
//  Field.swift
//  HubCenter
//
//  Created by Dima Bart on 2016-12-12.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

class Field: ContainerType {
    
    var name:       String
    var alias:      String?
    var parameters: [Parameter]
    
    var parent:     ContainerType?
    var children:  [ReferenceType] = []
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(name: String, alias: String? = nil, parameters: [Parameter] = [], children: [ReferenceType]? = nil) {
        self.name       = name
        self.alias      = alias
        self.parameters = parameters
        
        if let children = children {
            self.add(children: children)
        }
    }
}

// ----------------------------------
//  MARK: - ValueType -
//
extension Field {
    var stringRepresentation: String {
        var representation: String
        
        if let alias = self.alias {
            representation = "\(self.newline)\(self.indent)\(alias): \(self.name)"
        } else {
            representation = "\(self.newline)\(self.indent)\(self.name)"
        }
        
        if !self.parameters.isEmpty {
            let keyValues      = self.parameters.map { "\($0.name): \($0.value.stringRepresentation)" }
            let keyValueString = keyValues.joined(separator: " ")
            representation    += "(\(keyValueString))"
        }
        
        if !self.children.isEmpty {
            let children       = self.children.map { $0.stringRepresentation }
            let joinedChildren = children.joined(separator: " ")
            representation    += "\(self.space){\(joinedChildren)\(self.newline)\(self.indent)}"
        }
        
        return representation
    }
}
