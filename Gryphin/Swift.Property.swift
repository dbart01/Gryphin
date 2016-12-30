//
//  Swift.Property.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-29.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Swift {
    final class Property: Containable {

        var parent: Containing?
        
        let visibility:  Visibility
        let name:        String
        let returnType:  String
        let annotations: [Annotation]?
        
        fileprivate(set) var comments: [Line]
        fileprivate(set) var body:     [Line]
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(visibility: Visibility = .internal, name: String, returnType: String, annotations: [Annotation]? = nil, body: [Line]? = nil, comments: [Line]? = nil) {
            
            self.visibility  = visibility
            self.name        = name
            self.returnType  = returnType
            self.annotations = annotations
            self.body        = body     ?? []
            self.comments    = comments ?? []
        }
        
        // ----------------------------------
        //  MARK: - String Representable -
        //
        var stringRepresentation: String {
            var string = ""
            
            /* ---------------------------------
             ** Construct the method annotations
             */
            let annotations = self.annotations?.map {
                "\(self.indent)\($0.rawValue)\n"
            }.joined(separator: "") ?? ""
            
            /* ---------------------------------
             ** Construct the method body
             */
            let bodyIndent = self.indentFor(distanceToRoot: self.distanceToRoot + 1)
            let body       = self.body.map {
                "\(bodyIndent)\($0)\n"
            }.joined(separator: "")
            
            string += self.comments.commentStringIndentedBy(self.indent)
            string += annotations
            string += "\(self.indent)\(self.visibility) var \(self.name): \(self.returnType) "
            
            /* ----------------------------------------
             ** Only append body and opening / closing
             ** braces if body is non-empty. Otherwise
             ** we'll treat this like a declaration.
             */
            if !self.body.isEmpty {
                string += "{\n"
                string += body
                string += "\(self.indent)}\n"
            } else {
                string += "\n"
            }
            
            return string

        }
    }
}
