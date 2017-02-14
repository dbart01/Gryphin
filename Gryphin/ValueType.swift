//
//  ValueType.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-08.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

public protocol ValueType {
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

public func ==<T: ValueType>(lhs: T, rhs: T) -> Bool {
    return lhs._stringRepresentation == rhs._stringRepresentation
}

// ----------------------------------
//  MARK: - Foundation -
//
extension String: ValueType {
    public var _stringRepresentation: String {
        return "\"\(self)\""
    }
}

extension Int: ValueType {
    public var _stringRepresentation: String {
        return "\(self)"
    }
}

extension Float: ValueType {
    public var _stringRepresentation: String {
        return "\(self)"
    }
}

extension Double: ValueType {
    public var _stringRepresentation: String {
        return "\(self)"
    }
}

extension Bool: ValueType {
    public var _stringRepresentation: String {
        return self ? "true" : "false"
    }
}

extension RawRepresentable where RawValue == String {
    public var _stringRepresentation: String {
        return "\(self.rawValue)"
    }
}
