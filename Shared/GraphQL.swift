//
//  GraphQL.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-24.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

struct GraphQL {
    
    struct Key {
        static let typeName = "__typename"
    }
    
    struct Custom {
        static let aliasPrefix = "__alias_"
    }
}

extension String {
    
    var aliasPrefixed: String {
        return "\(GraphQL.Custom.aliasPrefix)\(self)"
    }
    
    var hasAliasPrefix: Bool {
        return self.hasPrefix(GraphQL.Custom.aliasPrefix)
    }
}
