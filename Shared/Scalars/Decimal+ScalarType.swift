//
//  Decimal+ScalarType.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-03-05.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

extension Decimal: ScalarType {
    
    public var string: String {
        return self.description
    }
    
    public init(from string: String) {
        self.init(string: string)!
    }
}
