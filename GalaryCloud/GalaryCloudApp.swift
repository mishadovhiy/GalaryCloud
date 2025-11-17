//
//  GalaryCloudApp.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI
import UIKit

@main
struct GalaryCloudApp: App {
    
    @StateObject var appData: AppData = .init()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appData)
                .onChange(of: appData.message) { newValue in
                    print(newValue, " htrgefd ")
                    presentAlert()
                }
            
        }
    }
    
    func presentAlert() {
        guard let first = appData.message.first else { return }
        let alert = UIAlertController(title: "Error",
                                      message: first.title,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
            appData.message.removeFirst()
        })
        
        UIApplication.shared.activeWindow?.rootViewController?.topViewController.present(alert, animated: true)
    }
}
