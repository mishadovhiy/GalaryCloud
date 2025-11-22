//
//  FileManager.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 22.11.2025.
//

import Foundation

extension FileManager {
    func clearTempFolder() {
        let temporaryDirectory = temporaryDirectory
        
        let tempFiles = try? contentsOfDirectory(at: temporaryDirectory, includingPropertiesForKeys: nil)
        
        for file in (tempFiles ?? []) {
            try? removeItem(at: file)
        }
    }
    
    func safeFile(libraryURL: URL) -> URL? {
        let filename = libraryURL.lastPathComponent
        let tempURL = temporaryDirectory.appendingPathComponent(filename)
        
        do {
            if fileExists(atPath: tempURL.path) {
                try removeItem(at: tempURL)
            }
            try copyItem(at: libraryURL, to: tempURL)
            return tempURL
        } catch {
            return nil
        }
    }

}
