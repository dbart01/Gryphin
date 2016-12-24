//
//  Class.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-23.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

final class Class: Container {
    
    let visibility: Visibility
    let name:       String
    let superclass: String?
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(visibility: Visibility = .internal, name: String, superclass: String? = nil) {
        self.visibility = visibility
        self.name       = name
        self.superclass = superclass
    }
    
    // ----------------------------------
    //  MARK: - String Representation -
    //
    override var stringRepresentation: String {
        var string = ""
        
        let superclass = self.superclass != nil ? ": \(self.superclass!)" : ""
        
        string += "\(self.indent)\(self.visibility.rawValue) final class \(self.name)\(superclass) {\n\n"
        string += super.stringRepresentation
        string += "\(self.indent)}\n"
        
        return string
    }
}
