//
//  DescribedType.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-01.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

protocol DescribedType: NamedType {
    var description: String? { get }
}
