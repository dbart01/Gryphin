//
//  GitHubTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-07.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import Gryphin

typealias QueryResult    = (query: Query?, response: HTTPURLResponse?, error: GraphError?)
typealias MutationResult = (mutation: Mutation?, response: HTTPURLResponse?, error: GraphError?)

class GitHubTests: XCTestCase {
    
    let uniqueString: String     = "com.gryphin.unique"
    let apiURL:       URL        = URL(string: "https://api.github.com/graphql")!
    let session:      URLSession = {
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Authorization": "Bearer f31c7db44ea38abf705b8ca3663540d4ff27772a"
        ]
        
        return URLSession(configuration: configuration)
    }()
    
    // ----------------------------------
    //  MARK: - Requests -
    //
    func testRepositoryProjects() {
        let projectID = self.createProject()
        self.deleteProject(projectID)
    }
    
    // ----------------------------------
    //  MARK: - Actions -
    //
    private func createProject() -> ID {
        let projectInput = QCreateProjectInput(
            clientMutationId: self.uniqueString,
            ownerId:          ID("MDEwOlJlcG9zaXRvcnk3NTk3NjE5OA=="),
            name:             "TestProject",
            body:             "This a GraphQL generated project for testing."
        )
        
        let mutationQuery = QMutation { $0
            .createProject(input: projectInput) { $0
                .clientMutationId
                .project { _ = $0
                    .id
                    .number
                    .name
                    .body
                    .bodyHTML
                    .createdAt
                    .path
                    .url
                    .owner { _ = $0
                        .id
                    }
                }
            }
        }
        
        let result = self.execute(mutationQuery)
        
        XCTAssertNotNil(result.mutation)
        XCTAssertNotNil(result.response)
        XCTAssertNil(result.error)
        
        let mutation = result.mutation!
        
        XCTAssertEqual(mutation.createProject.clientMutationId, self.uniqueString)
        
        let project = mutation.createProject.project
        
        XCTAssertTrue(project.id.string.characters.count > 0)
        XCTAssertTrue(project.number > 0)
        XCTAssertEqual(project.name, projectInput.name)
        XCTAssertEqual(project.body, projectInput.body)
        XCTAssertEqual(project.owner.id.string, projectInput.ownerId.string)
        
        return project.id
    }
    
    private func deleteProject(_ id: ID) -> MutationResult {
        let project  = QDeleteProjectInput(clientMutationId: self.uniqueString, projectId: id)
        let mutation = QMutation { $0
            .deleteProject(input: project) { $0
                .owner { _ = $0
                    .id
                }
            }
        }
        
        return self.execute(mutation)
    }
    
    // ----------------------------------
    //  MARK: - Queries -
    //
    private func execute(_ q: QQuery) -> QueryResult {
        let expectation = self.expectation(description: "Query expectation.")
        
        var query:    Query?
        var response: HTTPURLResponse?
        var error:    GraphError?
        
        let task = self.session.graphQueryTask(with: q, to: self.apiURL) { (rQuery, rResponse, rError) in
            query    = rQuery
            response = rResponse
            error    = rError
            
            expectation.fulfill()
        }
        task.resume()
        
        self.waitForExpectations(timeout: 10, handler: nil)
        return (query, response, error)
    }
    
    private func execute(_ m: QMutation) -> MutationResult {
        let expectation = self.expectation(description: "Mutation expectation.")
        
        var mutation: Mutation?
        var response: HTTPURLResponse?
        var error:    GraphError?
        
        let task = self.session.graphMutationTask(with: m, to: self.apiURL) { (rMutation, rResponse, rError) in
            mutation = rMutation
            response = rResponse
            error    = rError
            
            expectation.fulfill()
        }
        task.resume()
        
        self.waitForExpectations(timeout: 10, handler: nil)
        return (mutation, response, error)
    }
}
