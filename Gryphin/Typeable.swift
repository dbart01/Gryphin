//
//  Typeable.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-08.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

protocol Typeable: Nameable {
    var type: Schema.ObjectType { get }
}
