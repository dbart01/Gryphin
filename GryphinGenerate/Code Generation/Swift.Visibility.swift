//
//  Swift.Visibility.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-23.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Swift {
    enum Visibility: String {
        case `private`
        case `fileprivate`
        case `internal`
        case `public`
        case `open`
        case none = ""
    }
}
