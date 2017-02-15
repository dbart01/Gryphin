//
//  Swift.Annotation.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-29.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Swift {
    enum Annotation: StringRepresentable, Equatable {
        
        struct Parameter: StringRepresentable, Equatable {
            
            enum Value: StringRepresentable, Equatable {
                case `default`(String)
                case quoted(String)
                
                var stringRepresentation: String {
                    switch self {
                    case .default(let value):
                        return value
                    case .quoted(let value):
                        return "\"\(value)\""
                    }
                }
            }
            
            enum Platform: String {
                case any = "*"
                case iOS
                case macOS
                case tvOS
                case watchOS
            }
            
            enum Name: String {
                case deprecated
                case unavailable
                case obsolete
                case message
            }
            
            let name:  String?
            let value: Value?
            
            init(name: Name, value: Value? = nil) {
                self.init(name: name.rawValue, value: value)
            }
            
            init(platform: Platform) {
                self.init(name: nil, value: .default(platform.rawValue))
            }
            
            private init(name: String?, value: Value?) {
                self.name  = name
                self.value = value
            }
            
            var stringRepresentation: String {
                var valueString = ""
                var nameString  = ""
                
                if let name = self.name,
                    let value = self.value {
                    
                    valueString = ": \(value.stringRepresentation)"
                    nameString  = name
                    
                } else if let name = self.name {
                    nameString = name
                    
                } else if let value = self.value {
                    valueString = value.stringRepresentation
                }
                
                return "\(nameString)\(valueString)"
            }
        }
        
        case discardableResult
        case available([Parameter])
        
        var stringRepresentation: String {
            switch self {
            case .discardableResult:
                return "@discardableResult"
                
            case .available(let parameters):
                
                var paramString = ""
                if !parameters.isEmpty {
                    let joined = parameters.map { $0.stringRepresentation }.joined(separator: ", ")
                    paramString = "(\(joined))"
                }
                
                return "@available\(paramString)"
            }
        }
    }
}

extension Swift.Annotation.Parameter.Value {
    static func ==(lhs: Swift.Annotation.Parameter.Value, rhs: Swift.Annotation.Parameter.Value) -> Bool {
        return lhs.stringRepresentation == rhs.stringRepresentation
    }
}

extension Swift.Annotation.Parameter {
    static func ==(lhs: Swift.Annotation.Parameter, rhs: Swift.Annotation.Parameter) -> Bool {
        return lhs.stringRepresentation == rhs.stringRepresentation
    }
}

extension Swift.Annotation {
    static func ==(lhs: Swift.Annotation, rhs: Swift.Annotation) -> Bool {
        switch (lhs, rhs) {
        case (.discardableResult, .discardableResult):
            return true
        case (.available(let lParameters), .available(let rParameters)) where lParameters == rParameters:
            return true
        default:
            return false
        }
    }
}
