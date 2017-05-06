# Gryphin

[![Build Status](https://travis-ci.org/dbart01/Gryphin.svg?branch=master)](https://travis-ci.org/dbart01/Gryphin)
[![GitHub release](https://img.shields.io/github/release/dbart01/gryphin.svg)](https://github.com/dbart01/Gryphin/releases/latest)

Gryphin is a GraphQL client that easily integrates with existing applications on iOS and MacOS. Capable of automatically generating type-safe models and queries for any GraphQL schema, Gryphin is the easiest way to get started with a GraphQL API using Swift. Simply point Gryphin at a GraphQL service endpoint and compile. That's it.

## Usage

Gryphin provides a simple DSL to build GraphQL queries and mutations. It's type-safe and generated specifically for your schema. With Xcode, you'll also get built-in auto-complete and documentation. Let's build a sample query using GitHub's GraphQL API:

```swift
let query = QQuery { $0
    .viewer { $0
        .id
        .name
        .repositories(first: 10) { $0
            .edges { $0
                .node { _ = $0
                    .name
                    .createdAt
                    .path
                    .hasIssuesEnabled
                    .hasWikiEnabled
                }
            }
        }
    }
}

let task = URLSession.shared.graphQueryTask(with: query, to: "https://api.github.com/graphql") { query, response, error in
    let viewerID = query?.viewer.id
}

task.resume()
```

The above builds a query to get the current user's `id`, `name` and the first 10 `repositories` with a few properties in each. Typed, auto-generated models ensure that you'll never have to parse JSON or write another model class every again. Simply access the data using dot notation.

## Getting started

Gryphin integrates with your application's build process to parse the GraphQL schema and generate type-safe models and queries. It relies on a simple configuration file to find the GraphQL schema. 

### 1. Configuration
Create a configuration file called `.gryphin` in your project root. You can provide a local schema with a relative path to the JSON file:

```json
{
  "schema": {
    "path": "Schema/github.json"
  }
}
```
or a service endpoint:

```json
{
  "schema": {
    "url": "https://api.github.com/graphql",
    "headers": [
      "Authorization": "Bearer f31c7db44ea38abf705b8ca3663540d4ff27772a"
    ]
  }
}
```
If the service endpoint is authenticated or requires custom headers, you can provide those using using the `headers` key.

### 2. Integration

Gryphin needs to integrate with your application build process. The recommended approach is to add Gryphin as a submodule and insert it's project as a sub-project of your application. Then follow the regular steps for adding an external dynamic framework to your projects:

1. Add `Gryphin-iOS` or `Gryphin-MacOS` in `Target Dependencies`
2. Link `Gryphin.framework` in `Link Binary with Libraries`
3. Add `Gryphin.framework` in `Copy Files` where "Destination == Framework"

Building your project should now build Gryphin, fetch or load the schema, generate models and queries and link the Gryphin framework with your application. You're ready to start working with GraphQL, you'll just need to import Gryphin wherever you need it:

```swift
import Gryphin
```
