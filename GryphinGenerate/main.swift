//
//  main.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-10.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

let args = Arguments()

guard let schemaPath = args.schemaPath, !schemaPath.isEmpty else {
    print("A path to the schema file in .json format is required.")
    exit(1)
}

guard let destinationPath = args.destinationPath, !destinationPath.isEmpty else {
    print("A destination path for the generated files directory is required.")
    exit(1)
}

print("Schema: \(schemaPath)")
print("Destination: \(destinationPath)")

let schemaURL      = URL(fileURLWithPath: schemaPath)
let destinationURL = URL(fileURLWithPath: destinationPath)
let genSchemaURL   = destinationURL.appendingPathComponent("APISchema.swift")
let genModelsURL   = destinationURL.appendingPathComponent("APIModels.swift")

do {
    let generator = try Swift.Generator(withSchemaAt: schemaURL)
    let result    = generator.generate()
    let schema    = result.schema.stringRepresentation
    let models    = result.models.stringRepresentation
    
    try schema.write(to: genSchemaURL, atomically: true, encoding: .utf8)
    try models.write(to: genModelsURL, atomically: true, encoding: .utf8)
    
    print("Schema generated to: \(destinationURL)")
    
} catch let error {
    print("Failed to generate schema: \(error)")
    exit(1)
}
