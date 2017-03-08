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

public class GraphModel: CustomDebugStringConvertible {
    
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
    //  MARK: - Debug -
    //
    public var debugDescription: String {
        return [
            "value": self.values,
            "aliases": self.aliases,
        ].debugDescription
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
    
    // ----------------------------------
    //  MARK: - Property Setter -
    //
    func set(_ value: Any?, for key: String) {
        if let value = value {
            self.values[key] = value
        } else {
            self.values[key] = nil as Any?
        }
    }
    
    // ----------------------------------
    //  MARK: - Deserialization Setters -
    //
    func set<T: ScalarType>(valueFrom json: JSON, for key: String, type: T.Type) throws {

        try self.set(any: json[key], for: key, convertUsing: { value in
            guard let scalarString = value as? String else {
                throw ModelError.InconsistentSchema
            }
            return T(from: scalarString)
        })
    }
    
    func set<T>(valueFrom json: JSON, for key: String, type: T.Type) throws {

        try self.set(any: json[key], for: key, convertUsing: { value in
            guard let typed = value as? T else {
                throw ModelError.InconsistentSchema
            }
            return typed
        })
    }
    
    func set<T: GraphModel>(modelFrom json: JSON, for key: String, type: T.Type) throws {

        try self.set(any: json[key], for: key, convertUsing: { value in
            guard let json = value as? JSON else {
                throw ModelError.InconsistentSchema
            }
            return T(json: json)
        })
    }
    
    func set<T: GraphModel>(modelCollectionFrom json: JSON, for key: String, type: [T].Type) throws {

        try self.set(any: json[key], for: key, convertUsing: { value in
            guard let json = value as? [JSON] else {
                throw ModelError.InconsistentSchema
            }
            return [T].from(json)
        })
    }
    
    private func set(any: Any??, for key: String, convertUsing converter: (Any) throws -> Any?) throws {
        if let anyContainer = any {
            
            if let anyValue = anyContainer, let convertedValue = try converter(anyValue) {
                self.values[key] = convertedValue
            } else {
                self.values[key] = nil as Any?
            }
            
        } else {
            self.values[key] = nil
        }
    }
    
    func set<T: GraphModel>(json: JSON, for key: String, type: T.Type) throws {
        if let model = T(json: json) {
            self.values[key] = model
        } else {
            self.values[key] = nil
        }
    }
    
    // ----------------------------------
    //  MARK: - Alias Management -
    //
    func hasAliasFor(_ key: String) -> Bool {
        return self.aliases[key.aliasPrefixed] != nil
    }
    
    func aliasedWith<T: GraphModel>(_ key: String) throws -> T? {
        guard let value = self.aliases[key.aliasPrefixed] else {
            throw ModelError.AliasNotFound
        }
        
        guard let json = value else {
            return nil
        }
        
        return T(json: json)
    }
    
    func aliasedWith<T: GraphModel>(_ key: String) throws -> T {
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
