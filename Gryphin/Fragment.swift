//
//  Fragment.swift
//  HubCenter
//
//  Created by Dima Bart on 2016-12-12.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

final class Fragment: ContainerType {
    
    var name:          String
    var typeCondition: String?
    var parameters:    [Parameter]
    
    var parent:        ContainerType?
    var children:     [ReferenceType] = []
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(name: String, typeCondition: String? = nil, parameters: [Parameter] = [], children: [ReferenceType]? = nil) {
        self.name          = name
        self.parameters    = parameters
        self.typeCondition = typeCondition
        
        if let children = children {
            self.add(children: children)
        }
    }
}

// ----------------------------------
//  MARK: - ValueType -
//
extension Fragment {
    var stringRepresentation: String {
        var representation = "\(self.newline)\(self.indent)fragment \(self.name)"
        
        if let typeCondition = self.typeCondition {
            representation += " on \(typeCondition) "
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
