//
//  GraphModel.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-17.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

enum ModelError: Error {
    case KeyNotFound
    case AliasNotFound
}

class GraphModel: JsonCreatable {
    
    private var values:  JSON = [:]
    private var aliases: JSON = [:]
    
    // ----------------------------------
    //  MARK: - Init -
    //
    required init(json: JSON) {
        self.parseAliasesFrom(json)
    }
    
    // ----------------------------------
    //  MARK: - Subscript -
    //
    func hasValueFor(key: String) -> Bool {
        return self.values[key] != nil
    }
    
    func valueFor<T>(nullable key: String) throws -> T? {
        guard let value = self.values[key] else {
            throw ModelError.KeyNotFound
        }
        
        return value as? T
    }
    
    func valueFor<T>(nonnull key: String) throws -> T {
        guard let value: T? = try self.valueFor(nullable: key) else {
            throw ModelError.KeyNotFound
        }
        
        return value!
    }
    
    func set(_ value: Any, for key: String) {
        self.values[key] = value
    }
    
    func set(_ value: Any?, for key: String) {
        if let value = value {
            self.set(value, for: key)
        }
    }
    
    // ----------------------------------
    //  MARK: - Alias Management -
    //
    func aliasedWith<T: JsonCreatable>(_ key: String) -> T? {
        if let aliasJson = self.aliases["__alias_\(key)"] as? JSON {
            return T(json: aliasJson)
        }
        return nil
    }
    
    func aliasedWith<T: JsonCreatable>(_ key: String) throws -> T {
        if let value: T = self.aliasedWith(key) {
            return value
        }
        
        throw ModelError.AliasNotFound
    }
    
    private func parseAliasesFrom(_ json: JSON) {
        for (key, value) in json where key.hasPrefix("__alias_") {
            self.aliases[key] = value
        }
    }
}

extension Array where Element: GraphModel {
    
    static func from(_ json: [JSON]?) -> [Element]? {
        if let json = json {
            return Array.from(json)
        }
        return nil
    }
    
    static func from(_ json: [JSON]) -> [Element] {
        return json.map { Element(json: $0) }
    }
}
