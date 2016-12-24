//
//  ValueType.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-08.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

protocol ValueType {
    var stringRepresentation: String { get }
}

// ----------------------------------
//  MARK: - Hashable & Equatable -
//
extension ValueType {
    var hashValue: Int {
        return self.stringRepresentation.hashValue
    }
}

func ==(lhs: ValueType, rhs: ValueType) -> Bool {
    return lhs.stringRepresentation == rhs.stringRepresentation
}

// ----------------------------------
//  MARK: - Foundation -
//
extension String: ValueType {
    var stringRepresentation: String {
        return "\"\(self)\""
    }
}

extension Int: ValueType {
    var stringRepresentation: String {
        return "\(self)"
    }
}

extension Float: ValueType {
    var stringRepresentation: String {
        return "\(self)"
    }
}

extension Double: ValueType {
    var stringRepresentation: String {
        return "\(self)"
    }
}
