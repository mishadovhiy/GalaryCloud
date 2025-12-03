//
//  ServiceConfig.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 25.11.2025.
//

import Foundation

struct ServiceConfig {
    let serviceList: [AppServiceConfig] = [
        WasabiConfig(),
        AppearenceConfig(),
//        NotificationCenterConfig()
    ]
    
    init() {
        serviceList.forEach {
            $0.configure()
        }
    }
}

protocol AppServiceConfig {
    func configure()
}
