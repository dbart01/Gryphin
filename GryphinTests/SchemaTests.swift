//
//  SchemaTests.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-24.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

import XCTest
@testable import Gryphin

class SchemaTests: XCTestCase {

    func testSchema() {
        let bundle = Bundle(for: self.classForCoder)
        let url    = bundle.url(forResource: "schema", withExtension: "json")!
        
        let generator = try! Swift.Generator(withSchemaAt: url)
        let result    = generator.generate()
        let schema    = result.schema.stringRepresentation
        let models    = result.models.stringRepresentation
        
        let schemaPath = URL(fileURLWithPath: "/Users/dbart/Desktop/APISchema.swift")
        let modelsPath = URL(fileURLWithPath: "/Users/dbart/Desktop/APIModels.swift")
        
        try! schema.write(to: schemaPath, atomically: true, encoding: .utf8)
        try! models.write(to: modelsPath, atomically: true, encoding: .utf8)
    }
    
    func testMutation() {
        let project = QCreateProjectInput(clientMutationId: "some123", ownerId: "owner123", name: "Wobbly Bear", body: "Nothing to pu here")
        
        let mutation = QMutation { $0
            .createProject(input: project) { $0
                .clientMutationId
                .project { _ = $0
                    .id
                    .name
                    .body
                    .url
                }
            }
        }
        
        print(mutation._stringRepresentation)
    }
    
    func testQuery() {
        let order = QRepositoryOrder(field: .createdAt, direction: .asc)
        let query = QQuery { $0
            .repository(owner: "dbart01", name: "someName") { $0
                .owner { $0
                    .fragmentOnOrganization { _ = $0
                        .id
                        .login
                    }
                    .fragmentOnUser { _ = $0
                        .id
                        .login
                        .isViewer
                        .isEmployee
                    }
                    .repositories(first: 15, orderBy: order) { $0
                        .edges { $0
                            .node { _ = $0
                                .createdAt
                                .name
                                .description
                            }
                        }
                    }
                }
                .alias("ownerAlias").owner { _ = $0
                    .id
                    .login
                }
                .alias("issueAlias").issues(first: 20) { $0
                    .edges { $0
                        .node { _ = $0
                            .body
                            .createdAt
                            .id
                        }
                    }
                }
                .ref(qualifiedName: "/ref/branch/master") { $0
                    .associatedPullRequests(first: 20, states: [.open, .closed]) { $0
                        .edges { $0
                            .node { _ = $0
                                .bodyHTML
                                .body
                            }
                        }
                    }
                }
                .issues(first: 20) { $0
                    .totalCount
                    .edges { $0
                        .node { $0
                            .assignees(first: 20) { $0
                                .edges { $0
                                    .node { _ = $0
                                        .name
                                        .id
                                        .isViewer
                                        .isEmployee
                                        .isSiteAdmin
                                        .isBountyHunter
                                    }
                                }
                            }
                        }
                    }
                }
                .forks(first: 20) { $0
                    .edges { $0
                        .cursor
                        .node { _ = $0
                            .createdAt
                            .description
                            .descriptionHTML
                            .id
                            .name
                            .homepageURL
                        }
                    }
                }
            }
        }
    
        print(query._stringRepresentation)
    }
}
