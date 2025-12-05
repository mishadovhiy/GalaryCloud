//
//  FileManagerService.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 02.12.2025.
//

import Foundation
import UIKit

struct FileManagerService {
    
    private let manager = FileManager.default
        
    func directorySize(_ type: URLType) -> Int64 {
        var size: Int64 = 0
        let url = type.url
        if let enumerator = manager.enumerator(at: url,
                                                           includingPropertiesForKeys: [.fileSizeKey],
                                                           options: [.skipsHiddenFiles]) {
            
            for case let fileURL as URL in enumerator {
                let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey])
                size += Int64(resourceValues?.fileSize ?? 0)
            }
        }
        
        return size
    }
    
    func loadFiles(_ at: URLType) -> [URL] {
        let fileURLs = try? FileManager.default.contentsOfDirectory(
            at: at.url,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        return fileURLs ?? []
    }
    
    func clear(url: URLType? = nil) {
        let temporaryDirectory = url ?? .temporary
        
        let tempFiles = try? manager.contentsOfDirectory(at: temporaryDirectory.url, includingPropertiesForKeys: nil)
        
        for file in (tempFiles ?? []) {
            try? manager.removeItem(at: file)
        }
    }
    
    func copyFile(from url: URL) -> URL? {
        let filename = url.lastPathComponent
        let tempURL = manager.temporaryDirectory.appendingPathComponent(filename)
        
        if manager.fileExists(atPath: tempURL.path) {
            try? manager.removeItem(at: tempURL)
        }
        try? manager.copyItem(at: url, to: tempURL)
        return tempURL
    }

    func performSave(data: Data, path: String, urlType: URLType) {
        let cachesDir = urlType.url
        let fileURL = cachesDir.appendingPathComponent(path)
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print(fileURL)
            print("errorsavingtofilemanager ", error)
        }
    }
    
    func save(data: Data, path: String) {
        ImageQuality.allCases.forEach { quality in
            let image = quality.data == nil ? nil : UIImage(data: data)?.changeSize(newWidth: quality.data?.width ?? 0).jpegData(compressionQuality: quality.data?.compression ?? 0)
            self.performSave(data: image ?? data, path: quality.rawValue + "_" + path, urlType: .caches)
        }
    }
    
    private func performLoad(path: String, quality: ImageQuality) -> Data? {
        let cachesDir = Self.URLType.caches.url
        let fileURL = cachesDir.appendingPathComponent(path)
        
        guard manager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return data
    }
    
    func load(path: String, quality: ImageQuality) -> Data? {
        self.performLoad(path: quality.rawValue + "_" + path, quality: quality)
    }
    
    func performDelete(path: String, urlType: URLType) {
        let fileURL = urlType.url.appendingPathComponent(path)
        
        if manager.fileExists(atPath: fileURL.path) {
            try? manager.removeItem(at: fileURL)
        }
    }
    
    func delete(path: String) {
        ImageQuality.allCases.forEach { quality in
            self.performDelete(path: quality.rawValue + "_" + path, urlType: .caches)
        }
    }
}

extension FileManagerService {
    enum URLType: String, CaseIterable {
        case caches
        case temporary
        
        var url: URL {
            let fileManager = FileManager.default
            return switch self {
            case .caches:
                fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
            case .temporary:
                fileManager.temporaryDirectory
            }
        }
    }

    enum ImageQuality: String, CaseIterable {
        case middle
        
        var data:QualityData? {
            return switch self {
            case .middle:.init(width: 80, compression: 0.01)
            }
        }
        
        struct QualityData {
            var width:CGFloat
            var compression:CGFloat
        }
    }
}
