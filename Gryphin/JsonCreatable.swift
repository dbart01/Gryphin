//
//  JsonCreatable.swift
//  HubCenter
//
//  Created by Dima Bart on 2016-12-24.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation


typealias JSON = [String : Any]

protocol JsonCreatable {
    init(json: JSON)
}

extension JsonCreatable {
    
    /* ----------------------------------------
     ** Provide a failable initializer for all
     ** JsonCreatable types that return nil if
     ** the JSON object is nil.
     */
    init?(json: JSON?) {
        guard let json = json else { return nil }
        self.init(json: json)
    }
    
    static func collectionWith(json: [JSON]) -> [Self] {
        return json.map {
            Self(json: $0)
        }
    }
}
