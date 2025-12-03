//
//  AppParametersResponse.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 23.11.2025.
//

import Foundation

struct AppConfigResponse: Codable {
    let storeKitSubscription: StoreKitSubscription
    
    struct StoreKitSubscription: Codable {
        let proGroup: [ProGroupModel]
        
        struct ProGroupModel: Codable {
            let id: String
            let imagePath: String
            let best: Bool?
        }
    }
}
