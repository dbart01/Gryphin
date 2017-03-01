//
//  ConfigurationCoordinator.swift
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

class ConfigurationCoordinator {
    
    let fileName: String = "gryphin"
    
    private let fileManager: FileManager
    private let rootURL:     URL
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(at url: URL) {
        self.rootURL     = url
        self.fileManager = FileManager()
    }
    
    // ----------------------------------
    //  MARK: - Paths -
    //
    func findConfiguration() throws -> URL {
        return try self.traverseFrom(self.rootURL, lookingFor: self.fileName).last!
    }
    
    private func traverseFrom(_ url: URL, lookingFor fileName: String) throws -> [URL] {
        
        var configFiles: [URL] = []
        
        var root = url
        repeat {
            
            /* ---------------------------------
             ** Check the current contents of
             ** the directory and look for a file
             ** named: `fileName`
             */
            let allFiles   = self.filesAt(root)
            let foundFiles = allFiles.filter {
                $0.contains(fileName)
            }
            
            /* ---------------------------------
             ** If we find a file with the name,
             ** bail early returning the complete
             ** url to the file.
             */
            if !foundFiles.isEmpty {
                
                guard foundFiles.count == 1 else {
                    throw ConfigurationCoordinatorError.multipleFound
                }
                
                configFiles += root.appendingPathComponent(foundFiles.first!)
            }
            
            /* ---------------------------------
             ** If no files are found, move up
             ** to the parent directory and repeat.
             */
            root = root.deletingLastPathComponent()
            
        } while root.path.characters.count > 1
        
        guard !configFiles.isEmpty else {
            throw ConfigurationCoordinatorError.notFound
        }
        
        return configFiles
    }
    
    private func filesAt(_ url: URL) -> [String] {
        let files = try? self.fileManager.contentsOfDirectory(atPath: url.path)
        return files ?? []
    }
}
