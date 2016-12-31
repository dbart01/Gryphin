//
//  FragmentReference.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-12.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

final class FragmentReference: ReferenceType {
    
    var _name:   String
    var _parent: ContainerType?
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(name: String, parent: ContainerType?) {
        self._name   = name
        self._parent = parent
    }
}

// ----------------------------------
//  MARK: - Fragment -
//
extension Fragment {
        
    typealias ReferencingType = FragmentReference
    
    var _reference: ReferencingType {
        return FragmentReference(
            name:   self._name,
            parent: self._parent
        )
    }
}

// ----------------------------------
//  MARK: - ValueType -
//
extension FragmentReference {
    var _stringRepresentation: String {
        return "...\(self._name)"
    }
}
