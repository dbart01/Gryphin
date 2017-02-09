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
        let e = self.expectation(description: "")
        
        let project = QCreateProjectInput(clientMutationId: "unique-string", ownerId: "MDEwOlJlcG9zaXRvcnk3NTk3NjE5OA==", name: "TestProject", body: "This a GraphQL generated project for testing.")
        let mutation = QMutation { $0
            .createProject(input: project) { $0
                .clientMutationId
                .project { _ = $0
                    .id
                    .name
                    .body
                    .createdAt
                    .databaseId
                }
            }
        }
        
        let task2 = self.session.graphMutationTask(with: mutation, to: self.apiURL) { (mutation, response, error) in
            if let mutation = mutation {
                DispatchQueue.main.async {
                    
                    let projectID = mutation.createProject!.project.id
                    print("Successfully created project with ID: \(projectID)")
                    
                    let previousProject = QDeleteProjectInput(clientMutationId: "unique-string", projectId: projectID)
                    let deleteMutation  = QMutation { $0
                        .deleteProject(input: previousProject) { $0
                            .owner { _ = $0
                                .id
                            }
                        }
                    }
                    
                    let task = self.session.graphMutationTask(with: deleteMutation, to: self.apiURL) { (mutation, response, error) in
                        
                        if let mutation = mutation {
                            print("Successfully deleted project with ID: \(mutation.deleteProject!.owner.repository?.id)")
                        }
                        
                        e.fulfill()
                    }
                    
                    task.resume()
                }
            }
        }
        
        //        let task = self.session.graphQueryTask(with: query, to: self.apiURL) { (query, response, error) in
        //
        //            if let query = query {
        //                print(query.node!.user!.name!)
        //            }
        //
        //            e.fulfill()
        //        }
        
        task2.resume()
        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
