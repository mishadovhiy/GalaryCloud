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
    case privacyURL = "ds"
    case termsURL = "dsf"
    case appStoreID = "6755612916"
    
}
