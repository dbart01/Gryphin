//
//  GitHubTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-07.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
import Gryphin

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
        let projectID = self.projectCreate()
        
        var columns: [ProjectColumn] = []
        
        columns += self.projectAddColumn(named: "Backlog",     to: projectID)
        columns += self.projectAddColumn(named: "In Progress", to: projectID)
        columns += self.projectAddColumn(named: "Done",        to: projectID)
        columns += self.projectAddColumn(named: "Finished",    to: projectID)
        
        self.projectGetColumns(projectID, assertWith: columns)
        
        self.projectDeleteColumn(id: columns.last!.id)
        self.projectUpdate(projectID)
        self.projectDelete(projectID)
    }
    
    // ----------------------------------
    //  MARK: - Actions -
    //
    private func projectCreate() -> ID {
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
        XCTAssertSuccessfulMutation(result)
        
        let mutation = result.mutation!
        XCTAssertEqual(mutation.createProject.clientMutationId, projectInput.clientMutationId)
        
        let project = mutation.createProject.project
        
        XCTAssertGreaterThan(project.number, 0)
        
        XCTAssertType(of: project.createdAt, equalTo: DateTime.self)
        
        XCTAssertNonZeroLength(project.id.string)
        XCTAssertNonZeroLength(project.path.absoluteString)
        XCTAssertNonZeroLength(project.url.absoluteString)
        
        XCTAssertEqual(project.name,            projectInput.name)
        XCTAssertEqual(project.body,            projectInput.body)
        XCTAssertEqual(project.owner.id.string, projectInput.ownerId.string)
        
        return project.id
    }
    
    private func projectGetColumns(_ id: ID, assertWith columns: [ProjectColumn]) {
        let q = QQuery { $0
            .node(id: id) { $0
                .fragmentOnProject { $0
                    .columns(first: 10) { $0
                        .pageInfo { _ = $0
                            .startCursor
                            .endCursor
                            .hasNextPage
                            .hasPreviousPage
                        }
                        .edges { $0
                            .cursor
                            .node { $0
                                .id
                                .name
                                .project { _ = $0
                                    .id
                                }
                            }
                        }
                    }
                }
            }
        }
        
        let result = self.execute(q)
        XCTAssertSuccessfulQuery(result)
        
        let query = result.query!
        XCTAssertType(of: query.node.project, equalTo: Project.self)
        
        let columnConnection = query.node.project.columnsConnection
        let pageInfo         = columnConnection.pageInfo
        
        XCTAssertFalse(pageInfo.hasNextPage)
        XCTAssertFalse(pageInfo.hasPreviousPage)
        XCTAssertEqual(pageInfo.startCursor, columnConnection.edges.first!!.cursor)
        XCTAssertEqual(pageInfo.endCursor,   columnConnection.edges.last!!.cursor)
        
        let fetchedColumns = query.node.project.columns
        
        for result in zip(fetchedColumns, columns) {
            XCTAssertEqual(result.0.id.string, result.1.id.string)
            XCTAssertEqual(result.0.name,      result.1.name)
        }
    }
    
    private func projectAddColumn(named name: String, to projectID: ID) -> ProjectColumn {
        let columnInput = QAddProjectColumnInput(
            clientMutationId: self.uniqueString,
            projectId:        projectID,
            name:             name
        )
        
        let mutationQuery = QMutation { $0
            .addProjectColumn(input: columnInput) { $0
                .clientMutationId
                .columnEdge { $0
                    .node { $0
                        .id
                        .name
                        .project { _ = $0
                            .id
                        }
                    }
                }
            }
        }
        
        let result = self.execute(mutationQuery)
        XCTAssertSuccessfulMutation(result)
        
        let mutation = result.mutation!
        XCTAssertEqual(mutation.addProjectColumn.clientMutationId, columnInput.clientMutationId)
        
        let column = mutation.addProjectColumn.columnEdge.node!
        
        XCTAssertNonZeroLength(column.id.string)
        XCTAssertEqual(column.name, name)
        XCTAssertEqual(column.project.id.string, projectID.string)
        
        return column
    }
    
    private func projectDeleteColumn(id: ID) {
        let columnInput   = QDeleteProjectColumnInput(clientMutationId: self.uniqueString, columnId: id)
        let mutationQuery = QMutation { $0
            .deleteProjectColumn(input: columnInput) { _ = $0
                .clientMutationId
                .deletedColumnId
            }
        }
        
        let result = self.execute(mutationQuery)
        XCTAssertSuccessfulMutation(result)
        
        let mutation = result.mutation!
        XCTAssertEqual(mutation.deleteProjectColumn.clientMutationId, columnInput.clientMutationId)
        XCTAssertEqual(mutation.deleteProjectColumn.deletedColumnId.string, id.string)
    }
    
    private func projectUpdate(_ id: ID) {
        let projectInput = QUpdateProjectInput(
            clientMutationId: self.uniqueString,
            projectId:        id,
            name:             "TestRenamedProject"
        )
        
        let mutationQuery = QMutation { $0
            .updateProject(input: projectInput) { $0
                .clientMutationId
                .project { _ = $0
                    .id
                    .number
                    .name
                    .body
                    .createdAt
                    .path
                    .url
                }
            }
        }
        
        let result = self.execute(mutationQuery)
        XCTAssertSuccessfulMutation(result)
        
        let mutation = result.mutation!
        XCTAssertEqual(mutation.updateProject.clientMutationId, projectInput.clientMutationId)
        
        let project = mutation.updateProject.project
        
        XCTAssertGreaterThan(project.number, 0)
        
        XCTAssertType(of: project.createdAt, equalTo: DateTime.self)
        
        XCTAssertNonZeroLength(project.id.string)
        XCTAssertNonZeroLength(project.path.absoluteString)
        XCTAssertNonZeroLength(project.url.absoluteString)
        
        XCTAssertEqual(project.name, projectInput.name)
        XCTAssertEqual(project.body, projectInput.body)
    }
    
    private func projectDelete(_ id: ID) {
        let projectInput  = QDeleteProjectInput(clientMutationId: self.uniqueString, projectId: id)
        let mutationQuery = QMutation { $0
            .deleteProject(input: projectInput) { $0
                .clientMutationId
                .owner { _ = $0
                    .id
                    .fragmentOnRepository { _ = $0
                        .name
                        .description
                        .createdAt
                    }
                }
            }
        }
        
        let result = self.execute(mutationQuery)
        XCTAssertSuccessfulMutation(result)
        
        let mutation = result.mutation!
        XCTAssertEqual(mutation.deleteProject.clientMutationId, projectInput.clientMutationId)
        
        let owner = mutation.deleteProject.owner
        
        XCTAssertNonZeroLength(owner.id.string)
        
        let repository = owner.repository!
        
        XCTAssertEqual(repository.name, "HubCenter")
        XCTAssertNonZeroLength(repository.description)
        XCTAssertType(of: repository.createdAt, equalTo: DateTime.self)
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
        
        self.waitForExpectations(timeout: 30, handler: nil)
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
        
        self.waitForExpectations(timeout: 30, handler: nil)
        return (mutation, response, error)
    }
}

// ----------------------------------
//  MARK: - Assertions -
//
private func XCTAssertSuccessfulMutation(_ result: MutationResult) {
    XCTAssertNotNil(result.mutation)
    XCTAssertNotNil(result.response)
    XCTAssertNil(result.error)
}

private func XCTAssertSuccessfulQuery(_ result: QueryResult) {
    XCTAssertNotNil(result.query)
    XCTAssertNotNil(result.response)
    XCTAssertNil(result.error)
}

private func XCTAssertNonZeroLength(_ string: String) {
    XCTAssertTrue(string.characters.count > 0)
}

private func XCTAssertType<T>(of object: T, equalTo type: T.Type) {
    XCTAssertTrue(type(of: object) == T.self)
}
