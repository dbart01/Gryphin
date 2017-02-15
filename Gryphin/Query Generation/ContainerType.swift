//
//  ContainerType.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-08.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

public protocol ContainerType: class, ReferenceType {
    var _children:   [ReferenceType]  { get set }
    var _parameters: [Parameter]      { get }
    
    func _add(children: [ReferenceType]) throws
}

extension ContainerType {
    
    // ----------------------------------
    //  MARK: - Children -
    //
    func _add(child: ReferenceType) throws {
        try _add(children: [child])
    }
    
    func _add(children: [ReferenceType]) throws {
        if !children.isEmpty {
            children.forEach {
                $0._parent = self
            }
            self._children.append(contentsOf: children)
        }
    }
}

public func ==(lhs: ContainerType, rhs: ContainerType) -> Bool {
    return lhs === rhs
}
