//
//  Swift.Property.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-29.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Swift {
    final class Property: Container {
        
        let visibility:  Visibility
        let name:        String
        let returnType:  String
        let annotations: [Annotation]?
        
        fileprivate(set) var comments: [Line]
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(visibility: Visibility = .internal, name: String, returnType: String, annotations: [Annotation]? = nil, body: [Line]? = nil, comments: [Line]? = nil) {
            
            self.visibility  = visibility
            self.name        = name
            self.returnType  = returnType
            self.annotations = annotations
            self.comments    = comments ?? []
            
            super.init()
            
            if let body = body {
                self.add(children: body)
            }
        }
        
        // ----------------------------------
        //  MARK: - String Representable -
        //
        override var stringRepresentation: String {
            var string = ""
            
            /* ---------------------------------
             ** Construct the method annotations
             */
            let annotations = self.annotations?.map {
                "\(self.indent)\($0.rawValue)\n"
            }.joined(separator: "") ?? ""
            
            string += self.comments.commentStringIndentedBy(self.indent)
            string += annotations
            string += "\(self.indent)\(self.visibility) var \(self.name): \(self.returnType) "
            
            /* ----------------------------------------
             ** Only append body and opening / closing
             ** braces if body is non-empty. Otherwise
             ** we'll treat this like a declaration.
             */
            if !self.children.isEmpty {
                string += "{\n"
                string += "\(super.stringRepresentation)\n"
                string += "\(self.indent)}\n"
            } else {
                string += "\n"
            }
            
            return string

        }
    }
}
