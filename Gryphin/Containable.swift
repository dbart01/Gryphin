//
//  Containable.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-29.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

protocol Containable: class, StringRepresentable {
    var parent: Containing? { get set }
}

extension Containable {
    
    // ----------------------------------
    //  MARK: - Indentation -
    //
    var tabWidth: Int {
        return 4
    }
    
    var indent: String {
        return self.indentFor(distanceToRoot: max(self.distanceToRoot - 1, 0))
    }
    
    var distanceToRoot: Int {
        var distance = 0
        var parent   = self.parent
        
        while parent != nil {
            distance += 1
            parent = parent?.parent
        }
        return distance
    }
    
    func indentFor(distanceToRoot: Int) -> String {
        return [String](repeating: " ", count: distanceToRoot * self.tabWidth).joined(separator: "")
    }
}
