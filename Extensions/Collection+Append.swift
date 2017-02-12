//
//  Collection+Append.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-12.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

public func +=<T>(lhs: inout [T], rhs: T) {
    lhs.append(rhs)
}

public func +=<T>(lhs: inout [T], rhs: [T]) {
    lhs.append(contentsOf: rhs)
}
