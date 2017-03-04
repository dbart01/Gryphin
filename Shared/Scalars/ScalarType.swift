//
//  ScalarType.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-03-02.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

public protocol ScalarType {
    
    var string: String { get }
    
    init(from string: String)
}
