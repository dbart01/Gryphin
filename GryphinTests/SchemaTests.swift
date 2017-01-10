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
        let document  = generator.generate()
        let string    = document.stringRepresentation
        
        let path = URL(fileURLWithPath: "/Users/dbart/Desktop/API.swift")
        try! string.write(to: path, atomically: true, encoding: .utf8)
    }
    
    func testQuery() {
        let query = Query { $0
            .repository(owner: "dbart01", name: "someName") { $0
                .owner { $0
                    .fragmentOnOrganization { $0
                        .id
                        .login
                    }
                    .fragmentOnUser { $0
                        .id
                        .login
                        .isViewer
                        .isEmployee
                    }
                }
                .alias("ownerAlias").owner { $0
                    .id
                    .login
                }
                .alias("issueAlias").issues(first: 20) { $0
                    .edges { $0
                        .node { $0
                            .body
                            .createdAt
                            .id
                        }
                    }
                }
                .ref(qualifiedName: "/ref/branch/master") { $0
                    .associatedPullRequests(first: 20, states: [.OPEN, .CLOSED]) { $0
                        .edges { $0
                            .node { $0
                                .bodyHTML
                                .body
                            }
                        }
                    }
                }
                .issues { $0
                    .totalCount
                    .edges { $0
                        .node { $0
                            .assignees { $0
                                .edges { $0
                                    .node { $0
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
                .forks { $0
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
        print("")
    }
}
