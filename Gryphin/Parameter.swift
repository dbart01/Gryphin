//
//  Parameter.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-08.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

struct Parameter: ValueType {
    
    var _name:  String
    var _value: ValueType
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(name: String, value: ValueType) {
        self._name  = name
        self._value = value
    }
    
    init(name: String, value: [ValueType]) {
        self.init(name: name, value: value.map { $0._stringRepresentation }.joined(separator: ", "))
    }
    
    init<T>(name: String, value: T) where T: RawRepresentable, T.RawValue == String {
        self.init(name: name, value: value.rawValue)
    }
    
    init<T>(name: String, value: [T]) where T: RawRepresentable, T.RawValue == String {
        self.init(name: name, value: value.map { $0.rawValue }.joined(separator: ", "))
    }
    
    // ----------------------------------
    //  MARK: - ValueType -
    //
    var _stringRepresentation: String {
        return "\(self._name): \(self._value)"
    }
}

// ----------------------------------
//  MARK: - Equatable -
//
extension Parameter: Equatable {}

func ==(lhs: Parameter, rhs: Parameter) -> Bool {
    return lhs._name == rhs._name && lhs._value._stringRepresentation == rhs._value._stringRepresentation
}
