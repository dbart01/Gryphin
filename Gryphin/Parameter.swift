//
//  Parameter.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-08.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

struct Parameter {
    
    var _name:  String
    var _value: ValueType
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(name: String, value: ValueType) {
        self._name  = name
        self._value = value
    }
}

// ----------------------------------
//  MARK: - Equatable -
//
extension Parameter: Equatable {}

func ==(lhs: Parameter, rhs: Parameter) -> Bool {
    return lhs._name == rhs._name && lhs._value._stringRepresentation == rhs._value._stringRepresentation
}
