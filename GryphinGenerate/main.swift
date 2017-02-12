//
//  main.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-10.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

let prefix = "Gen$"
let suffix = ".swift"
let args   = Arguments()

guard let schemaPath = args.schemaPath, !schemaPath.isEmpty else {
    print("A path to the schema file in .json format is required.")
    exit(1)
}

guard let destinationPath = args.destinationPath, !destinationPath.isEmpty else {
    print("A destination path for the generated files directory is required.")
    exit(1)
}

let schemaURL      = URL(fileURLWithPath: schemaPath)
let destinationURL = URL(fileURLWithPath: destinationPath)

do {
    let generator = try Swift.Generator(withSchemaAt: schemaURL)
    let files     = generator.generate()
    
    try files.forEach { file in
        let content = file.container.stringRepresentation
        let fileURL = destinationURL.appendingPathComponent("\(prefix)\(file.name)\(suffix)")
        
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    print("Schema generated to: \(destinationURL)")
    
} catch let error {
    print("Failed to generate schema: \(error)")
    exit(1)
}
