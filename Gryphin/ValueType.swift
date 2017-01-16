//
//  ValueType.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-08.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

protocol ValueType {
    var _stringRepresentation: String { get }
}

// ----------------------------------
//  MARK: - Hashable & Equatable -
//
extension ValueType {
    var hashValue: Int {
        return self._stringRepresentation.hashValue
    }
}

func ==<T: ValueType>(lhs: T, rhs: T) -> Bool {
    return lhs._stringRepresentation == rhs._stringRepresentation
}

// ----------------------------------
//  MARK: - Foundation -
//
extension String: ValueType {
    var _stringRepresentation: String {
        return "\"\(self)\""
    }
}

extension Int: ValueType {
    var _stringRepresentation: String {
        return "\(self)"
    }
}

extension Float: ValueType {
    var _stringRepresentation: String {
        return "\(self)"
    }
}

extension Double: ValueType {
    var _stringRepresentation: String {
        return "\(self)"
    }
}

extension Bool: ValueType {
    var _stringRepresentation: String {
        return self ? "true" : "false"
    }
}

extension RawRepresentable where RawValue == String {
    var _stringRepresentation: String {
        return "\(self.rawValue)"
    }
}
