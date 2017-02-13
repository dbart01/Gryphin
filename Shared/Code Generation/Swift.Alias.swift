//
//  Swift.Alias.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-29.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Swift {
    final class Alias: Containable {
        
        var parent: Containing?
        
        let name:    String
        let forType: String
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(name: String, forType: String) {
            self.name    = name
            self.forType = forType
        }
        
        // ----------------------------------
        //  MARK: - String Representation -
        //
        var stringRepresentation: String {
            return "\(self.indent)typealias \(self.name) = \(self.forType)\n"
        }
    }
}
