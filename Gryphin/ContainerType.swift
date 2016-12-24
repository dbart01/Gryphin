//
//  ContainerType.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-08.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

protocol ContainerType: class, ReferenceType {
    var children:   [ReferenceType]  { get set }
    var parameters: [Parameter] { get }
}

extension ContainerType {
    
    // ----------------------------------
    //  MARK: - Children -
    //
    func add(child: ReferenceType) {
        child.parent = self
        self.children.append(child)
    }
    
    func add(children: [ReferenceType]) {
        children.forEach {
            $0.parent = self
        }
        self.children.append(contentsOf: children)
    }
}

func ==(lhs: ContainerType, rhs: ContainerType) -> Bool {
    return lhs === rhs
}
