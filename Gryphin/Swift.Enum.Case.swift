//
//  Swift.Enum.Case.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-30.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation


extension Swift  {
    struct Enum {
        final class Case: Containable {
            var parent: Containing?
            
            let name: String
            
            fileprivate(set) var comments: [Line]
            
            // ----------------------------------
            //  MARK: - Init -
            //
            init(name: String, comments: [Line]? = nil) {
                self.name     = name
                self.comments = comments ?? []
            }
            
            // ----------------------------------
            //  MARK: - String Representable -
            //
            var stringRepresentation: String {
                var string = ""
                
                string += self.comments.commentStringIndentedBy(self.indent)
                string += "\(self.indent)case \(self.name)\n"
                
                return string
            }
        }
    }
}
