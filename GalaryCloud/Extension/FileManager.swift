//
//  FileManager.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 22.11.2025.
//

import Foundation
import UIKit

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

    private func performSave(data: Data, path: String, quality: ImageQuality) {
        let cachesDir = self.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileURL = cachesDir.appendingPathComponent(path)
        try? data.write(to: fileURL, options: .atomic)
    }
    
    func save(data: Data, path: String) {
        ImageQuality.allCases.forEach { quality in
            let image = quality.data == nil ? nil : UIImage(data: data)?.changeSize(newWidth: quality.data?.width ?? 0).jpegData(compressionQuality: quality.data?.compression ?? 0)
            self.performSave(data: image ?? data, path: quality.rawValue + "_" + path, quality: quality)
        }
    }
    
    func load(path: String, quality: ImageQuality) -> Data? {
        self.performLoad(path: quality.rawValue + "_" + path, quality: quality)
    }
    
    func delete(path: String) {
        ImageQuality.allCases.forEach { quality in
            self.performDelete(path: quality.rawValue + "_" + path, quality: quality)
        }
    }
    
    private func performLoad(path: String, quality: ImageQuality) -> Data? {
        let cachesDir = self.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileURL = cachesDir.appendingPathComponent(path)
        
        guard self.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return data
    }
    
    func performDelete(path: String, quality: ImageQuality) {
        let cachesDir = urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileURL = cachesDir.appendingPathComponent(path)
        
        if fileExists(atPath: fileURL.path) {
            try? removeItem(at: fileURL)
        }
    }
}

extension FileManager {
    enum ImageQuality: String, CaseIterable {
//        case belowLowest
        case middle
        
        var data:QualityData? {
            return switch self {
//            case .belowLowest:.init(width: 40, compression: 0.01)
            case .middle:.init(width: 90, compression: 0.1)
            }
        }
        struct QualityData {
            var width:CGFloat
            var compression:CGFloat
        }
    }
}

extension UIImage {
    func changeSize(newWidth:CGFloat, from:CGSize? = nil, origin:CGPoint = .zero) -> UIImage {
#if os(iOS)
        let widthPercent = newWidth / (from?.width ?? self.size.width)
        let proportionalSize: CGSize = .init(width: newWidth, height: widthPercent * (from?.height ?? self.size.height))
        let renderer = UIGraphicsImageRenderer(size: proportionalSize)
        let newImage = renderer.image { _ in
            self.draw(in: CGRect(origin: origin, size: proportionalSize))
        }
        return newImage
#else
        return self
#endif

    }
}
