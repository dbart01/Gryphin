//
//  Swift.Enum.Case.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-30.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation


extension Swift  {
    final class EnumCase: Containable {
            
        enum CaseValue: StringRepresentable {
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
        
        var parent: Containing?
        
        let name:  String
        let value: CaseValue?
        
        fileprivate(set) var comments: [Line]
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(name: String, value: CaseValue? = nil, comments: [Line]? = nil) {
            self.name     = name
            self.value    = value
            self.comments = comments ?? []
        }
        
        // ----------------------------------
        //  MARK: - String Representable -
        //
        var stringRepresentation: String {
            var string = ""
            
            let value = self.value != nil ? " = \(self.value!.stringRepresentation)" : ""
            
            string += self.comments.commentStringIndentedBy(self.indent)
            string += "\(self.indent)case \(self.name)\(value)\n"
            
            return string
        }
    }
}
