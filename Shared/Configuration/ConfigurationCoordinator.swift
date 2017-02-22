//
//  ConfigurationCoordinator.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-02-22.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

enum ConfigurationCoordinatorError: Error {
    case multipleConfigurations
}

class ConfigurationCoordinator {
    
    let fileName: String = "gryphin"
    
    private let fileManager: FileManager
    private let rootURL:     URL
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(fromt url: URL) {
        self.rootURL     = url
        self.fileManager = FileManager()
    }
    
    // ----------------------------------
    //  MARK: - Paths -
    //
    func findConfiguration() throws -> URL? {
        return try self.traverseFrom(self.rootURL, lookingFor: self.fileName)
    }
    
    private func traverseFrom(_ url: URL, lookingFor fileName: String) throws -> URL? {
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
                    throw ConfigurationCoordinatorError.multipleConfigurations
                }
                
                return root.appendingPathComponent(foundFiles[0])
            }
            
            /* ---------------------------------
             ** If no files are found, move up
             ** to the parent directory and repeat.
             */
            root = root.deletingLastPathComponent()
            
        } while !root.path.isEmpty
        
        return nil
    }
    
    private func filesAt(_ url: URL) -> [String] {
        let files = try? self.fileManager.contentsOfDirectory(atPath: url.path)
        return files ?? []
    }
}
