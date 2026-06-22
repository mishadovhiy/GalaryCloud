//
//  ImageQuality.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 15.06.2026.
//

import Foundation

enum ImageQuality: String, CaseIterable, Hashable, Codable {
    case upperMiddle
    case middle
    case lowerMiddle
    case low
    case lowest
    case high
    case highest
    case original
    
    var data:QualityData? {
        return switch self {
        case .highest: .init(width: 300, compression: 0.6)
        case .high: .init(width: 190, compression: 0.4)
        case .upperMiddle: .init(width: 120, compression: 0.3)
        case .middle: .init(width: 80, compression: 0.2)
        case .lowerMiddle: .init(width: 60, compression: 0.01)
        case .low: .init(width: 35, compression: 0.1)
        case .original: nil
        case .lowest:
                .init(width: 9, compression: 0.001)
        }
    }
    
    struct QualityData {
        var width:CGFloat
        var compression:CGFloat
    }
    
    var folderDirectoryName: String? {
        if self == .original {
            return nil
        } else {
            return .init(describing: self)
        }
    }
}
