//
//  Swift.Container.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-23.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Swift {
    class Container: Containing {
        
        var parent:   Containing?
        var children: [Containable] = []
        
        // ----------------------------------
        //  MARK: - String Representation -
        //
        var stringRepresentation: String {
            return self.children.map {
                $0.stringRepresentation
            }.joined(separator: "\n")
        }
    }
}
