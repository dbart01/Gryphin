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
        case prettyPrint  = "com.gryphin.prettyPrint"
        case networkDebug = "com.gryphin.networkDebug"
    }
    
    static var prettyPrint: Bool {
        return Environment.shared[.prettyPrint] != nil
    }
    
    static var networkDebug: Bool {
        return Environment.shared[.networkDebug] != nil
    }
    
    // ----------------------------------
    //  MARK: - Singleton -
    //
    static let shared = Environment()
    
    private init() {}
    
    // ----------------------------------
    //  MARK: - Subscript -
    //
    subscript(key: Key) -> String? {
        set {
            if let newValue = newValue {
                setenv(key.rawValue, newValue, 1)
            } else {
                unsetenv(key.rawValue)
            }
        }
        get {
            if let cString = getenv(key.rawValue) {
                return String(cString: cString)
            }
            return nil
        }
    }
}
