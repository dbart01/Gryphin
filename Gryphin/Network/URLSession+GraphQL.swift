//
//  URLSession+GraphQL.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-06.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

public enum GraphError {
    case network(code: Int, domain: String, description: String)
    case serialization(description: String)
    case query(errors: [QueryError])
}

public extension URLSession {
        
    // ----------------------------------
    //  MARK: - Network -
    //
    func graphTask<Q: Field, R: GraphModel>(with query: Q, to url: URL, completionHandler: @escaping (R?, HTTPURLResponse?, GraphError?) -> Void) -> URLSessionDataTask {
        
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
            
            if let err = networkError as NSError? {
                error = .network(code: err.code, domain: err.domain, description: err.localizedDescription)
            }
            
            if let data = data,
                let object = try? JSONSerialization.jsonObject(with: data, options: []),
                let json = object as? JSON {
                
                networkDebug("Response: \(json)")
                
                if let errorsJson = json["errors"] as? [JSON] {
                    error = .query(errors: QueryError.collectionWith(requiredJson: errorsJson))
                }
                    
                if let data = json["data"] as? JSON {
                    root = R(json: data)
                }
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
