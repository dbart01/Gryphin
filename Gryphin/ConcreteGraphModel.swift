//
//  ConcreteGraphModel.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-27.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

class ConcreteGraphModel: GraphModel {
    
    // ----------------------------------
    //  MARK: - Init -
    //
    required init?(json: JSON) {
        super.init(json: [:])
    }
    
    convenience init?(json: JSON?) {
        guard let json = json else {
            return nil
        }
        self.init(json: json)
    }
}
