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
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appData)
                .onChange(of: appData.message) { newValue in
                    print(newValue, " htrgefd ")
                    presentAlert()
                }
                .onChange(of: scenePhase) { newValue in
                    switch newValue {
                    case .background:
                        clearTempFolder()
                    default: break
                    }
                }
        }
    }
    
#warning("todo: move to services")

    func clearTempFolder() {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        
        let tempFiles = try? FileManager.default.contentsOfDirectory(at: temporaryDirectory, includingPropertiesForKeys: nil)
        
        for file in (tempFiles ?? []) {
            try? FileManager.default.removeItem(at: file)
        }
    }
    
    func presentAlert() {
        guard let first = appData.message.first else { return }
        let alert = UIAlertController(title: "Error",
                                      message: first.title,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
            if appData.message.isEmpty {
                return
            }
            appData.message.removeFirst()
            presentAlert()
        })
        
        UIApplication.shared.activeWindow?.rootViewController?.topViewController.present(alert, animated: true)
    }
}
