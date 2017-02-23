//
//  Executable.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-22.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

class Executable {

    let args = Arguments()
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init() {
        
    }
    
    // ----------------------------------
    //  MARK: - Execution -
    //
    private func findConfiguration() throws -> Configuration {
        guard let rootPath = args.rootPath, !rootPath.isEmpty else {
            print("A path to the root directory is required.")
            exit(1)
        }
        
        let rootURL       = URL(fileURLWithPath: rootPath)
        let coordinator   = ConfigurationCoordinator(at: rootURL)
        
        let configURL     = try coordinator.findConfiguration()
        let configuration = try Configuration(at: configURL)
        
        return configuration
    }
    
    private func schemaJSON(using configuration: Configuration) throws -> JSON {
        if let schemaPath: URL = configuration.valueFor("schemaPath") {
            
            return try JSON.from(fileAt: schemaPath)
            
        } else if let schemaURL: URL = configuration.valueFor("schemaURL") {
            
            // TODO: Send introspection query to URL
            return [:]
            
        } else {
            print("Failed to generate schema. The configuration must provide a `schemaPath` or a `schemaURL` parameter.")
            exit(1)
        }
    }
    
    func execute() {
        
        let prefix = "Gen$"
        let suffix = ".swift"
        
        guard let destinationPath = args.destinationPath, !destinationPath.isEmpty else {
            print("A destination path for the generated files directory is required.")
            exit(1)
        }
        
        let destinationURL = URL(fileURLWithPath: destinationPath)
        
        do {
            let configuration = try self.findConfiguration()
            let schemaJSON    = try self.schemaJSON(using: configuration)
            let generator     = Swift.Generator(withSchema: schemaJSON)
            
            let files = generator.generate()
            try files.forEach { file in
                let content = file.container.stringRepresentation
                let fileURL = destinationURL.appendingPathComponent("\(prefix)\(file.name)\(suffix)")
                
                try content.write(to: fileURL, atomically: true, encoding: .utf8)
            }
            
            print("Schema generated to: \(destinationURL)")
            
        } catch ConfigurationError.readFailed {
            
            print("Failed to read configuration file. Check that you have a .gryphin configuration file somewhere in a parent directory.")
            exit(1)
            
        } catch ConfigurationError.emptyFile {
            
            print("Failed to read configuration file. It appears to be empty.")
            exit(1)
            
        } catch JsonError.readFailed {
            
            print("Failed to read schema at URL.")
            exit(1)
            
        } catch JsonError.invalidFormat {
            
            print("Failed to parse schema JSON. The format is invalid.")
            exit(1)
            
        } catch JsonError.invalidSchema {
            
            print("Failed to parse schema JSON. The schema layout is invalid.")
            exit(1)
            
        } catch ConfigurationCoordinatorError.notFound {
            
            print("Failed to find configuration file. Bypassing generation...")
            print("To enable schema generation, create a config file name: .grypin in your project root.")
            exit(0)
            
        } catch ConfigurationCoordinatorError.multipleFound {
            
            print("Failed to load .gryphin configuration, multiple files found. There must only be one configuration file.")
            exit(1)
            
        } catch let error {
            print("Failed to generate schema: \(error)")
            exit(1)
        }
    }
}
