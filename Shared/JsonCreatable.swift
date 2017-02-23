//
//  JsonCreatable.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-24.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

public typealias JSON = [String : Any?]

public protocol JsonCreatable {
    init(json: JSON)
}

public extension JsonCreatable {
    
    /* ----------------------------------------
     ** Provide a failable initializer for all
     ** JsonCreatable types that return nil if
     ** the JSON object is nil.
     */
    public init?(json: JSON?) {
        guard let json = json else {
            return nil
        }
        self.init(json: json)
    }
    
    static func collectionWith(requiredJson json: [JSON]) -> [Self] {
        return json.map {
            Self(json: $0)
        }
    }
    
    static func collectionWith(optionalJson json: [JSON]?) -> [Self]? {
        guard let json = json else {
            return nil
        }
        return self.collectionWith(requiredJson: json)
    }
}

enum JsonError: Error {
    case readFailed
    case invalidFormat
    case invalidSchema
}

extension Dictionary where Value: Any {
   
    static func from(data: Data) throws -> Dictionary {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            throw JsonError.invalidFormat
        }
        
        guard let schemaJSON = json as? Dictionary else {
            throw JsonError.invalidSchema
        }
        
        return schemaJSON
    }
    
    static func from(fileAt url: URL) throws -> Dictionary {
        guard let data = try? Data(contentsOf: url) else {
            throw JsonError.readFailed
        }
        
        return try self.from(data: data)
    }
    
    func v<T>(_ key: Key) -> T? {
        return self[key] as? T
    }
}
