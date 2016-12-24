//
//  String+Newline.swift
//  HubCenter
//
//  Created by Dima Bart on 2016-12-14.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

precedencegroup Concatenation {
    associativity: left
}

infix operator ~: Concatenation

func ~(lhs: String, rhs: String) -> String {
    return "\(lhs)\n\(rhs)"
}
