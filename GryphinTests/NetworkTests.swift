//
//  NetworkTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-07.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

class NetworkTests: XCTestCase {
    
    let apiURL:  URL        = URL(string: "https://api.github.com/graphql")!
    let session: URLSession = {
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Authorization": "Bearer f31c7db44ea38abf705b8ca3663540d4ff27772a"
        ]
        
        return URLSession(configuration: configuration)
    }()
    
    // ----------------------------------
    //  MARK: - Requests -
    //
    func testQuery() {
        let e     = self.expectation(description: "")
        let query = QQuery { $0
            .viewer { _ = $0
                .id
                .name
            }
        }
        
        let task = self.session.graphQueryTask(with: query, to: self.apiURL) { (query, response, error) in
        
            if let query = query {
                print(query.viewer.name!)
            }
            
            e.fulfill()
        }
        
        task.resume()
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
