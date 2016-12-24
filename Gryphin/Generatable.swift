//
//  Generatable.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-23.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

protocol Generatable: class, StringRepresentable {
    
    var parent:    Generatable? { get set }
    var children: [Generatable] { get set }
}

extension Generatable {
    
    // ----------------------------------
    //  MARK: - Children -
    //
    func add(child: Generatable) {
        child.parent = self
        self.children.append(child)
    }
    
    func add(children: [Generatable]) {
        children.forEach {
            $0.parent = self
        }
        self.children.append(contentsOf: children)
    }
}

extension Array where Element: Generatable {
    
    var stringRepresentation: String {
        return self
            .map {
                $0.stringRepresentation
            }
            .joined(separator: "\n\n")
    }
}
