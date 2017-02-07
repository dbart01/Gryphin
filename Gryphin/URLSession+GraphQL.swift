//
//  URLSession+GraphQL.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-06.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

enum GraphError {
    case network(code: Int, domain: String, description: String)
    case serialization(description: String)
}

extension URLSession {
    
    // ----------------------------------
    //  MARK: - Query -
    //
    func graphQueryTask(with query: QQuery, to url: URL, completionHandler: @escaping (Query?, HTTPURLResponse?, GraphError?) -> Void) -> URLSessionDataTask {
        return self.graphTask(with: query, to: url, completionHandler: completionHandler)
    }
    
    // ----------------------------------
    //  MARK: - Mutation -
    //
    func graphMutationTask(with mutation: QMutation, url: URL, completionHandler: @escaping (Mutation?, HTTPURLResponse?, GraphError?) -> Void) -> URLSessionDataTask {
        return self.graphTask(with: mutation, to: url, completionHandler: completionHandler)
    }
    
    // ----------------------------------
    //  MARK: - Network -
    //
    private func graphTask<Q: Field, R: GraphModel>(with query: Q, to url: URL, completionHandler: @escaping (R?, HTTPURLResponse?, GraphError?) -> Void) -> URLSessionDataTask {
        
        networkDebug(query._stringRepresentation)
        
        return self.dataTask(with: URLRequest.graph(query: query, to: url)) { (data, originalResponse, networkError) in
            
            var root:     R?
            var response: HTTPURLResponse?
            var error:    GraphError?
            
            defer {
                completionHandler(root, response, error)
            }
            
            if let res = originalResponse as? HTTPURLResponse {
                response = res
            }
            
            if let err = networkError as? NSError {
                error = .network(code: err.code, domain: err.domain, description: err.localizedDescription)
            }
            
            networkDebug(data)
            
            if let data = data,
                let object = try? JSONSerialization.jsonObject(with: data, options: []),
                let json = object as? JSON {
                
                if let _ = json["errors"] as? JSON {
                    // TODO: Handle GraphQL errors
                }
                    
                if let data = json["data"] as? JSON {
                    root = R(json: data)
                }
                
                networkDebug("Response: \(json)")
            }
        }
    }
}

private func networkDebug(_ data: Data?) {
    networkDebug(String(data: data ?? Data(), encoding: .utf8)!)
}

private func networkDebug(_ string: String) {
    if Environment.networkDebug {
        print(string)
    }
}
