//
//  Environment.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-10.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

class Environment {
    
    enum Key: String {
        case prettyPrint = "com.gryphin.prettyPrint"
    }
    
    static var prettyPrint: Bool = Environment.shared[Key.prettyPrint] != nil
    
    // ----------------------------------
    //  MARK: - Singleton -
    //
    static let shared = Environment()
    
    private init() {}
    
    // ----------------------------------
    //  MARK: - Subscript -
    //
    subscript(key: Key) -> String? {
        get {
            return ProcessInfo.processInfo.environment[key.rawValue]
        }
    }
}
