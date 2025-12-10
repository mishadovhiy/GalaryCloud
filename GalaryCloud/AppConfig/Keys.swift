//
//  Keys.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Foundation

enum Keys: String {
    case serverURL = "https://mishadovhiy.com/apps/other-apps-db/galaryCloud/"
    
    case galaryURLComponent = "file/uploads/"
    case appGroup = "group.com.dovhiy.galaryCloudGroup"
    
    static var shareAppURL = "https://apps.apple.com/app/id\(Keys.appStoreID.rawValue)"
    case websiteURL = "https://mishadovhiy.com/#cloud"
    case directWebsiteURL = "https://mishadovhiy.com/apps/previews/cloud.html"
    case termsURL = "https://mishadovhiy.com/apps/previews/cloud-links/terms"
    case privacyURL = "https://mishadovhiy.com/apps/previews/cloud-links/privacy"

    case appStoreID = "6755612916"
    
    enum Service {
        enum Wasabi: String {
            case secretKey = "2PGVASzVVFHqLaXFPuGPL6KZ7tgCXdYXKfMbjFXQ"
            case token = "TU596PAI2YD1KVSINVOY"
            case regionURL = "https://s3.ap-northeast-2.wasabisys.com"
            case buketName = "galary-cloud-dovhyi"
            case fileDirectory = "uploads"
        }
    }
}
