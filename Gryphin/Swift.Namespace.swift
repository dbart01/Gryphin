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
        init(items: [Containing]) {
            super.init(visibility: .public, kind: .struct, name: "API", comments: [
                "Automatically generated API schema using Gryphin. Do not modify."
            ])
            
            self.add(children: items)
        }
    }
}
