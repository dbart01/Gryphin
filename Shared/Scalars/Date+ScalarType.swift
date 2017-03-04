//
//  Date+ScalarType.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-03-03.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

extension Date: ScalarType {
    
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return f
    }()
    
    public var string: String {
        return type(of: self).formatter.string(from: self)
    }
    
    public init(from string: String) {
        self.init(timeIntervalSince1970: type(of: self).formatter.date(from: string)!.timeIntervalSince1970)
    }
}
