//
//  Containing.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-23.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

protocol Containing: Containable {
    var children: [Containable] { get set }
}

extension Containing {
    
    // ----------------------------------
    //  MARK: - Children -
    //
    func add(child: Containable) {
        self.add(children: [child])
    }
    
    func add(children: [Containable]) {
        children.forEach {
            $0.parent = self
        }
        self.children.append(contentsOf: children)
    }
    
    func prepend(child: Containable) {
        self.prepend(children: [child])
    }
    
    func prepend(children: [Containable]) {
        children.forEach {
            $0.parent = self
        }
        self.children.insert(contentsOf: children, at: 0)
    }
}


// ----------------------------------
//  MARK: - Operators -
//
func +=<T: Containing>(lhs: T, rhs: Containable) {
    lhs.add(child: rhs)
}

func +=<T: Containing>(lhs: T, rhs: [Containable]) {
    lhs.add(children: rhs)
}

extension Array where Element: Containing {
    
    var stringRepresentation: String {
        return self
            .map {
                $0.stringRepresentation
            }
            .joined(separator: "\n\n")
    }
}
