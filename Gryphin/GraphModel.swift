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
    case TypeNameNotProvider
    case InconsistentSchema
}

public class GraphModel {
    
    private var values:  JSON            = [:]
    private var aliases: [String: JSON?] = [:]
    
    class var typeName: String {
        fatalError("Subclasses must override `typeName`.")
    }
    
    // ----------------------------------
    //  MARK: - Init -
    //
    public required init?(json: JSON) {
        if let typeName = json[GraphQL.Key.typeName],
            (typeName as? String) ?? "" != type(of: self).typeName {
            return nil
        }
        
        self.parseAliasesFrom(json)
    }
    
    public convenience init?(json: JSON?) {
        guard let json = json else {
            return nil
        }
        
        self.init(json: json)
    }
    
    // ----------------------------------
    //  MARK: - Subscript -
    //
    func hasValueFor(_ key: String) -> Bool {
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
    public func hasAliasFor(_ key: String) -> Bool {
        return self.aliases[key.aliasPrefixed] != nil
    }
    
    public func aliasedWith<T: GraphModel>(_ key: String) throws -> T? {
        guard let value = self.aliases[key.aliasPrefixed] else {
            throw ModelError.AliasNotFound
        }
        
        guard let json = value else {
            return nil
        }
        
        return T(json: json)
    }
    
    public func aliasedWith<T: GraphModel>(_ key: String) throws -> T {
        guard let model: T = try self.aliasedWith(key) else {
            throw ModelError.InconsistentSchema
        }
        
        return model
    }
    
    private func parseAliasesFrom(_ json: JSON) {
        for (key, value) in json where key.hasAliasPrefix {
            self.aliases[key] = (value as? JSON)
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
        return json.flatMap {
            Element(json: $0)
        }
    }
}
