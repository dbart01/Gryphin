//
//  String+CaseConversion.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-09.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

extension String {

    var snakeToCamel: String? {
        guard !self.isEmpty else {
            return nil
        }
        
        let components = self.components(separatedBy: "_")
        if components.count > 1 {
            var capitalized = components.map {
                $0.capitalized
            }
            capitalized[0] = capitalized[0].lowercased()
            
            return capitalized.joined()
        }
        
        return self.lowercased()
    }
    
    var lowercasedFirst: String {
        let index = self.index(after: self.startIndex)
        let first = self.substring(to: index)
        let last  = self.substring(from: index)
        
        return "\(first.lowercased())\(last)"
    }
}
