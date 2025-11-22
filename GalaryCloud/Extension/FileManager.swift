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
    
    func copyFile(from url: URL) -> URL? {
        let filename = url.lastPathComponent
        let tempURL = temporaryDirectory.appendingPathComponent(filename)
        
        if fileExists(atPath: tempURL.path) {
            try? removeItem(at: tempURL)
        }
        try? copyItem(at: url, to: tempURL)
        return tempURL
    }

    func save(data: Data, path: String) {
        let cachesDir = self.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileURL = cachesDir.appendingPathComponent(path)
        try? data.write(to: fileURL, options: .atomic)
    }
    
    func load(path: String) -> Data? {
        let cachesDir = self.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileURL = cachesDir.appendingPathComponent(path)
        
        guard self.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return data
    }
    
    func delete(path: String) {
        let cachesDir = urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileURL = cachesDir.appendingPathComponent(path)
        
        if fileExists(atPath: fileURL.path) {
            try? removeItem(at: fileURL)
        }
    }
}
