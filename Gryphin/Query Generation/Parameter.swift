//
//  Parameter.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-08.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

public struct Parameter: ValueType {
    
    fileprivate let _name:  String
    fileprivate let _value: String
    
    // ----------------------------------
    //  MARK: - Init -
    //
    private init(name: String, finalValue: String) {
        self._name  = name
        self._value = finalValue
    }
    
    init(name: String, value: ValueType) {
        self.init(name: name, finalValue: value._stringRepresentation)
    }
    
    init(name: String, value: [ValueType]) {
        let values      = value.map { $0._stringRepresentation }
        let valueString = values.joined(separator: ", ")
        
        self.init(name: name, finalValue: "[\(valueString)]")
    }
    
    init(name: String, value: ScalarType) {
        self.init(name: name, value: value.string)
    }
    
    init(name: String, value: [ScalarType]) {
        self.init(name: name, value: value.map { $0.string })
    }
    
    init<T>(name: String, value: T) where T: RawRepresentable, T.RawValue == String {
        self.init(name: name, finalValue: value.rawValue)
    }
    
    init<T>(name: String, value: [T]) where T: RawRepresentable, T.RawValue == String {
        let values      = value.map { $0.rawValue }
        let valueString = values.joined(separator: ", ")
        
        self.init(name: name, finalValue: "[\(valueString)]")
    }
    
    // ----------------------------------
    //  MARK: - ValueType -
    //
    public var _stringRepresentation: String {
        return "\(self._name): \(self._value)"
    }
}

// ----------------------------------
//  MARK: - Equatable -
//
extension Parameter: Equatable {}

public func ==(lhs: Parameter, rhs: Parameter) -> Bool {
    return lhs._name == rhs._name && lhs._value._stringRepresentation == rhs._value._stringRepresentation
}
