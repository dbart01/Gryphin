//
//  URLRequest+GraphQLt.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-07.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

extension URLRequest {
    
    static func graph<Q: Field>(query: Q, to url: URL) -> URLRequest {
        let body = [
            "query": query._stringRepresentation
        ]
        
        var request                     = URLRequest(url: url)
        request.httpMethod              = "POST"
        request.httpShouldHandleCookies = false
        request.cachePolicy             = .reloadIgnoringLocalAndRemoteCacheData
        request.httpBody                = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        request.setValue("application/json",    forHTTPHeaderField: "Accept")
        request.setValue("application/graphql", forHTTPHeaderField: "Content-Type")
        
        // TODO: Handle JSON serialization errors
        
        return request
    }
    
    static func graph<M: Field>(mutation: M, to url: URL) -> URLRequest {
        return self.graph(query: mutation, to: url)
    }
}
