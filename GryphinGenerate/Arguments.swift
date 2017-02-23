//
//  Arguments.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-10.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

struct Arguments {
    
    private let arguments: [String : String] = {
        
        let all = ProcessInfo.processInfo.arguments
        if all.count > 1 {
            let args      = Array(all[1...all.count - 1])
            var container = [String : String]()
            
            var i = 0;
            while i < args.count {
                container[args[i]] = (i + 1 < args.count) ? args[i + 1] : ""
                i += 2
            }
            return container
        }
        return [:]
    }()
    
    var count: Int {
        return self.arguments.count
    }
    
    var rootPath: String? {
        return self.args("-r", "--root")
    }
    
    var destinationPath: String? {
        return self.args("-d", "--destination")
    }
    
    // ----------------------------------
    //  MARK: - Arguments -
    //
    private func arg(_ keys: [String]) -> String? {
        var value: String?
        for key in keys where value == nil {
            value = self.arguments[key]
        }
        return value
    }
    
    private func args(_ keys: String ...) -> String? {
        return self.arg(keys)
    }
    
    private func argi(_ keys: String ...) -> Int? {
        if let arg = self.arg(keys),
            let int = Int(arg) {
            return int
        }
        return nil
    }
}
