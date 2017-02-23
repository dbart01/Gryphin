//
//  Configuration.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-22.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

typealias Options = [String : Any]

class Configuration {
    
    static private let valueSeparator: String = ":"
    
    private let options: Options
    
    // ----------------------------------
    //  MARK: - Init -
    //
    required init(with data: Data) throws {
        guard !data.isEmpty else {
            throw ConfigurationError.emptyFile
        }
        
        let string   = String(data: data, encoding: .utf8)!
        self.options = Configuration.parse(string)
    }
    
    convenience init(at url: URL) throws {
        if let data = try? Data(contentsOf: url) {
            try self.init(with: data)
        } else {
            throw ConfigurationError.readFailed
        }
    }
    
    // ----------------------------------
    //  MARK: - Accessors -
    //
    var count: Int {
        return self.options.count
    }
    
    func valueExistsFor(_ key: String) -> Bool {
        return self.options[key] != nil
    }
    
    func valueFor<T>(_ key: String) -> T? {
        if let value = self.options[key] as? T {
            return value
        }
        return nil
    }
    
    // ----------------------------------
    //  MARK: - Parsing -
    //
    private static func parse(_ string: String) -> Options {
        var options: Options = [:]
        
        guard !string.isEmpty else {
            return options
        }
        
        let lines = string.components(separatedBy: CharacterSet.newlines)
        for line in lines {
            
            var components = line.components(separatedBy: self.valueSeparator)
            guard components.count >= 2 else {
                continue
            }

            /* ----------------------------------
             ** If there were any components that
             ** contained the separator after the
             ** first instance, join them back.
             */
            while components.count > 2 {
                components[components.endIndex - 2] = [
                    components[components.endIndex - 2],
                    components[components.endIndex - 1]
                ].joined(separator: self.valueSeparator)
                
                components.removeLast()
            }
            
            let key = self.parsedKeyFor(components[0])
            
            if let value = self.parsedValueFor(components[1]) {
                options[key] = value
            }
            
            // Skip over any values that are zero-length
        }
        
        return options
    }
    
    private static func parsedKeyFor(_ string: String) -> String {
        return string.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    private static func parsedValueFor(_ string: String) -> Any? {
        
        let value = string.trimmingCharacters(in: CharacterSet.whitespaces)
        
        /* ---------------------------------
         ** Ensure that we don't treat zero
         ** length strings as values.
         */
        guard !value.isEmpty else {
            return nil
        }
        
        /* ---------------------------------
         ** Check if it's a boolean
         */
        switch value {
            
        case "true":  return true
        case "false": return false
            
        default:
            break
        }
        
        /* ---------------------------------
         ** Check if it's a number
         */
        if let number = Int(value) {
            return number
        }
        
        /* ---------------------------------
         ** Check if it's a remote URL
         */
        if value.hasPrefix("http") || value.hasPrefix("file"),
            let url = URL(string: value) {
            
            return url
        }
        
        return value
    }
}
