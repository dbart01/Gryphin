//
//  String+Newline.swift
//  Gryphin
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
    guard !lhs.isEmpty || !rhs.isEmpty else {
        return ""
    }
    
    if lhs.isEmpty && !rhs.isEmpty {
        return rhs
        
    } else {
        return "\(lhs)\n\(rhs)"
    }
}
