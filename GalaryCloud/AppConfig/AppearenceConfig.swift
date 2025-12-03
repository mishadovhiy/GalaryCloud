//
//  AppearenceConfig.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 03.12.2025.
//

import UIKit

struct AppearenceConfig: AppServiceConfig {
    func configure() {
        navigation()
    }
    
    private func navigation() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(resource: .primaryText)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(resource: .primaryText)]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
