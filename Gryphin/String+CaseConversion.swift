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
        
        guard !components.isEmpty else {
            return nil
        }
        
        if components.count > 1 {
            var capitalized = components.map {
                $0.capitalized
            }
            capitalized[0] = capitalized[0].lowercased()
            
            return capitalized.joined()
        } else {
            return self.lowercased()
        }
    }
}

private extension UInt8 {
    var character: Character {
        return Character(UnicodeScalar(self))
    }
}
