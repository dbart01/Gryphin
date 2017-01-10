//
//  Environment.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-10.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

struct Environment {
    static var prettyPrint: Bool = ProcessInfo.processInfo.environment["com.gryphin.prettyPrint"] != nil
}
