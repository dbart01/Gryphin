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
        
        let visibility:  Visibility
        let name:        String
        let forType:     String
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(visibility: Visibility = .internal, name: String, forType: String) {
            self.visibility = visibility
            self.name       = name
            self.forType    = forType
        }
        
        // ----------------------------------
        //  MARK: - String Representation -
        //
        var stringRepresentation: String {
            let visibility = self.visibility == .none ? "" : "\(self.visibility.rawValue) "
            
            return "\(self.indent)\(visibility)typealias \(self.name) = \(self.forType)\n"
        }
    }
}
