//
//  URL+ScalarType.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-03-03.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

extension URL: ScalarType {
    
    public var string: String {
        return self.absoluteString
    }
    
    public init(from string: String) {
        self.init(string: string)!
    }
}
