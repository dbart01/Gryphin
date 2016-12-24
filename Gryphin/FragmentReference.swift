//
//  FragmentReference.swift
//  HubCenter
//
//  Created by Dima Bart on 2016-12-12.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

final class FragmentReference: ReferenceType {
    
    var name:   String
    var parent: ContainerType?
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(name: String, parent: ContainerType?) {
        self.name   = name
        self.parent = parent
    }
}

// ----------------------------------
//  MARK: - Fragment -
//
extension Fragment {
        
    typealias ReferencingType = FragmentReference
    
    var reference: ReferencingType {
        return FragmentReference(name: self.name, parent: self.parent)
    }
}

// ----------------------------------
//  MARK: - ValueType -
//
extension FragmentReference {
    var stringRepresentation: String {
        return "...\(name)"
    }
}
