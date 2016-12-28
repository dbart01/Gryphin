//
//  Swift.Class.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-23.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Swift {
    final class Class: Container {
        
        let visibility:   Visibility
        let name:         String
        let inheritances: [String]?
        
        fileprivate(set) var comments: [Line]
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(visibility: Visibility = .internal, name: String, inheritances: [String]? = nil, comments: [Line]? = nil) {
            self.visibility   = visibility
            self.name         = name
            self.inheritances = inheritances
            self.comments     = comments ?? []
        }
        
        // ----------------------------------
        //  MARK: - String Representation -
        //
        override var stringRepresentation: String {
            var string = ""
            
            var inheritanceString = ""
            if let inheritances = self.inheritances, !inheritances.isEmpty {
                let interfaces    = inheritances.joined(separator: ", ")
                inheritanceString = ": \(interfaces)"
            }
            let comments   = self.comments.commentStringIndentedBy(self.indent)
            
            string += comments
            string += "\(self.indent)\(self.visibility.rawValue) final class \(self.name)\(inheritanceString) {\n\n"
            string += super.stringRepresentation
            string += "\(self.indent)}\n"
            
            return string
        }
    }
}
