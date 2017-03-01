//
//  IntrospectionQuery.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-03-01.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation



class IntrospectionCoordinator {
    
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // ----------------------------------
    //  MARK: - Request -
    //
    static func introspectAt(_ url: URL) throws -> JSON {
        
    }
    
    // ----------------------------------
    //  MARK: - Query -
    //
    let query = "" +
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
