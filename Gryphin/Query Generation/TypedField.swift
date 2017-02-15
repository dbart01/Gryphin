//
//  TypedField.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-16.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

public class TypedField: Field {

    // ----------------------------------
    //  MARK: - Init -
    //
    public override init(name: String, alias: String? = nil, parameters: [Parameter] = [], children: [ReferenceType]? = nil) {
        var modifiedChildren: [ReferenceType] = children ?? []
        
        /* ------------------------------------
         ** A typed field automatically appends
         ** the type meta field. Often used in
         ** fragments where a heterogeneous
         ** collection is returned.
         */
        modifiedChildren.insert(Field(name: GraphQL.Key.typeName), at: 0)
        
        super.init(name: name, alias: alias, parameters: parameters, children: modifiedChildren)
    }
}
