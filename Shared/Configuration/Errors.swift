//
//  Errors.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-22.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

enum ConfigurationCoordinatorError: Error {
    case multipleFound
    case notFound
}

enum ConfigurationError: Error {
    case noSchemaLocation
}
