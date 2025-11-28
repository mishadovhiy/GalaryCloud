//
//  Data.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 21.11.2025.
//

import UIKit

extension Data {
    var imageDate: String? {
        if let source = CGImageSourceCreateWithData(self as CFData, nil),
           let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
           let exif = metadata[kCGImagePropertyExifDictionary] as? [CFString: Any],
           let dateString = exif[kCGImagePropertyExifDateTimeOriginal] as? String
        {
            return dateString
        } else {
            return nil
        }
    }
}

extension Int {
    var megabytes: String {
        .init(format: "%.2f", Double(self) / (1024 * 1024))
    }
}
