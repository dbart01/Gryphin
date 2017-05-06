//
//  IntrospectionQuery.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-03-01.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

typealias Headers = [String : String]

enum IntrospectionError: Error {
    case http(code: Int)
    case requestFailed(reason: String)
    case invalidJson
}

class IntrospectionCoordinator {
    
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // ----------------------------------
    //  MARK: - Request -
    //
    static func introspectAt(_ url: URL, additionalHeaders: Headers? = nil) throws -> JSON {
        
        var data:     Data?
        var response: HTTPURLResponse?
        var error:    NSError?
        
        let semaphore = DispatchSemaphore(value: 0)
        let request   = try self.requestWith(url, query: self.query, additionalHeaders: additionalHeaders)
        let task      = URLSession.shared.dataTask(with: request) { rData, rResponse, rError in
            
            data     = rData
            response = rResponse as? HTTPURLResponse
            error    = rError    as  NSError?
            
            semaphore.signal()
        }
        
        print("Introspection query headers: \(request.allHTTPHeaderFields ?? [:])")
        
        task.resume()
        semaphore.wait()
        
        if let response = response, response.statusCode / 100 != 2 {
            throw IntrospectionError.http(code: response.statusCode)
        }
        
        guard let jsonData = data else {
            throw IntrospectionError.requestFailed(reason: error?.localizedDescription ?? "Unknown reason")
        }
        
        guard let json = (try? JSONSerialization.jsonObject(with: jsonData, options: [])) as? JSON else {
            throw IntrospectionError.invalidJson
        }
        
        return json
    }
    
    static func requestWith(_ url: URL, query: String, additionalHeaders: Headers? = nil) throws -> URLRequest {
        let json = [
            "query": query,
        ]
        
        var request        = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20.0)
        request.httpMethod = "POST"
        request.httpBody   = try JSONSerialization.data(withJSONObject: json, options: [])
        
        additionalHeaders?.forEach { header in
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    // ----------------------------------
    //  MARK: - Query -
    //
    static let query = "" +
    "query IntrospectionQuery {" +
    "  __schema {" +
    "    queryType {" +
    "      name" +
    "    }" +
    "    mutationType {" +
    "      name" +
    "    }" +
    "    subscriptionType {" +
    "      name" +
    "    }" +
    "    types {" +
    "      ...FullType" +
    "    }" +
    "    directives {" +
    "      name" +
    "      description" +
    "      locations" +
    "      args {" +
    "        ...InputValue" +
    "      }" +
    "    }" +
    "  }" +
    "}" +
    
    "fragment FullType on __Type {" +
    "  kind" +
    "  name" +
    "  description" +
    "  ofType {" +
    "    name" +
    "  }" +
    "  fields(includeDeprecated: true) {" +
    "    name" +
    "    description" +
    "    args {" +
    "      ...InputValue" +
    "    }" +
    "    type {" +
    "      ...TypeRef" +
    "    }" +
    "    isDeprecated" +
    "    deprecationReason" +
    "  }" +
    "  inputFields {" +
    "    ...InputValue" +
    "  }" +
    "  interfaces {" +
    "    ...TypeRef" +
    "  }" +
    "  enumValues(includeDeprecated: true) {" +
    "    name" +
    "    description" +
    "    isDeprecated" +
    "    deprecationReason" +
    "  }" +
    "  possibleTypes {" +
    "    ...TypeRef" +
    "  }" +
    "}" +
    
    "fragment InputValue on __InputValue {" +
    "  name" +
    "  description" +
    "  type {" +
    "    ...TypeRef" +
    "  }" +
    "  defaultValue" +
    "}" +
    
    "fragment TypeRef on __Type {" +
    "  kind" +
    "  name" +
    "  ofType {" +
    "    kind" +
    "    name" +
    "    ofType {" +
    "      kind" +
    "      name" +
    "      ofType {" +
    "        kind" +
    "        name" +
    "        ofType {" +
    "          kind" +
    "          name" +
    "          ofType {" +
    "            kind" +
    "            name" +
    "            ofType {" +
    "              kind" +
    "              name" +
    "              ofType {" +
    "                kind" +
    "                name" +
    "              }" +
    "            }" +
    "          }" +
    "        }" +
    "      }" +
    "    }" +
    "  }" +
    "}"
}
