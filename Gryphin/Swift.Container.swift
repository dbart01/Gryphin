//
//  Swift.Container.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-23.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Swift {
    class Container: Generatable {
        
        var parent:    Generatable?
        var children: [Generatable] = []
        
        // ----------------------------------
        //  MARK: - String Representation -
        //
        var stringRepresentation: String {
            return self.children.map {
                $0.stringRepresentation
            }.joined(separator: "\n")
        }
        
        // ----------------------------------
        //  MARK: - Indentation -
        //
        var tabWidth: Int {
            return 4
        }
        
        var indent: String {
            return self.indentFor(distanceToRoot: self.distanceToRoot)
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
}