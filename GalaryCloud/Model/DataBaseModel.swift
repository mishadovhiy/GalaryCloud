//
//  DataBaseModel.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 23.11.2025.
//

import Foundation

struct DataBaseModel: Codable {
    var generalAppParameters: AppConfigResponse? = nil
    var test: Bool = false
    var appearence: Appearence = .init()
    
    struct Appearence: Codable {
        var photo: Photo = .init()
        
        struct Photo: Codable {
            private var compressionValues: [CompressionDestinationType: ImageQuality] = [.baseList: .low, .fullSizeGalary: .middle]
            
            mutating func setCompression(_ key: CompressionDestinationType, quality: ImageQuality) {
                compressionValues.updateValue(quality, forKey: key)
            }
            
            func qualityForCompression(_ compression: CompressionDestinationType) -> ImageQuality {
                compressionValues[compression] ?? .high
            }
            
            enum CompressionDestinationType: String, CaseIterable, Codable, Hashable {
                case baseList
                case fullSizeGalary
            }
        }
    }
}
