//
//  Swift.Namespace.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-27.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Swift {
    final class Namespace: Class {
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(name: String, comments: [Line]? = nil, items: [Containing]? = nil) {
            super.init(visibility: .public, kind: .struct, name: name, comments: comments)
            
            if let items = items {
                self.add(children: items)
            }
        }
    }
}
