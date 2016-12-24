//
//  Parameter.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-08.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

struct Parameter {
    
    var name:  String
    var value: ValueType
}

// ----------------------------------
//  MARK: - Equatable -
//
extension Parameter: Equatable {}

func ==(lhs: Parameter, rhs: Parameter) -> Bool {
    return lhs.name == rhs.name && lhs.value.stringRepresentation == rhs.value.stringRepresentation
}
