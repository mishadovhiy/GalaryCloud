//
//  AppParametersResponse.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 23.11.2025.
//

import Foundation

struct AppParametersResponse: Codable {
    let storeKitSubscription: StoreKitSubscription
    
    struct StoreKitSubscription: Codable {
        let proGroup: [String]
    }
}
