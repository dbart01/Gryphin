//
//  Gen.Document.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-27.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Gen {
    final class Document: Container {
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(classes: [Class]) {
            super.init()
            
            self.add(children: classes)
        }
    }
}
