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
    case TypeConversionFailed
    case AliasNotFound
}

class GraphModel {
    
    private var values:  JSON = [:]
    private var aliases: JSON = [:]
    
    class var typeName: String {
        fatalError("Subclasses must override `typeName`.")
    }
    
    // ----------------------------------
    //  MARK: - Init -
    //
    required init?(json: JSON) {
        if let typeName = json[GraphQL.Key.typeName] as? String, typeName != type(of: self).typeName {
            return nil
        }
        
        self.parseAliasesFrom(json)
    }
    
    convenience init?(json: JSON?) {
        guard let json = json else {
            return nil
        }
        
        self.init(json: json)
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
            throw ModelError.TypeConversionFailed
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
    func aliasedWith<T: GraphModel>(_ key: String) -> T? {
        if let aliasJson = self.aliases[key.aliasPrefixed] as? JSON {
            return T(json: aliasJson)
        }
        return nil
    }
    
    func aliasedWith<T: GraphModel>(_ key: String) throws -> T {
        if let value: T = self.aliasedWith(key) {
            return value
        }
        
        throw ModelError.AliasNotFound
    }
    
    private func parseAliasesFrom(_ json: JSON) {
        for (key, value) in json where key.hasAliasPrefix {
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
        var container = [Element]()
        for jsonValue in json {
            if let element = Element(json: jsonValue) {
                container.append(element)
            }
        }
        return container
    }
}
