//
//  GraphModel.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-17.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

class GraphModel: JsonCreatable {
    
    private var aliases: [String : Any] = [:]
    
    // ----------------------------------
    //  MARK: - Init -
    //
    required init(json: JSON) {
        self.parseAliasesFrom(json)
    }
    
    // ----------------------------------
    //  MARK: - Alias Management -
    //
    func alias<T>(_ key: String) -> T {
        return aliases[key] as! T
    }
    
    private func parseAliasesFrom(_ json: JSON) {
        for (key, value) in json where key.hasPrefix("__alias_") {
            self.aliases[key] = value
        }
    }
}

extension Array where Element: GraphModel {
    
    static func from(_ json: [JSON]) -> [Element] {
        return json.map { Element(json: $0) }
    }
}
