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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // buy pro screen only dont store in enviroment and fecth active subscription detail when app did enter foregraund (for displaying total gb availible), and when selected photos
    @ObservedObject var dataBaseService: DataBaseService = .init()
    
    var body: some Scene {
        WindowGroup {
//            if appData.db?.generalAppParameters == nil {
//                ProgressView()
//                    .progressViewStyle(.circular)
//            } else {
//                
//            }
            HomeView()
                .environmentObject(dataBaseService)
                .onAppear {
                    let _ = ServiceConfig()
                }
                .onChange(of: dataBaseService.messages.last) { newValue in
                    
                    print("erfwedas")
                    if newValue == nil {
                        return
                    }
                    self.presentAlert()
                }
        }
    }
    
    func presentAlert() {
        guard let lastMessage = dataBaseService.messages.last else {
            return
        }
        let topVC = UIApplication.shared.activeWindow?.rootViewController?.topViewController
        if topVC is UIAlertController {
            return
        }
        let alert = UIAlertController(title: "Error", message: lastMessage.title, preferredStyle: .alert)
        if lastMessage.buttons.isEmpty {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                alert.dismiss(animated: true) {
                    if dataBaseService.messages.last != nil {
                        dataBaseService.messages.removeLast()
                    }
                }
            }))
        } else {
            lastMessage.buttons.forEach { button in
                alert.addAction(UIAlertAction(title: button.title, style: .default, handler: { _ in
                    button.didPress?()
                    alert.dismiss(animated: true) {
                        if dataBaseService.messages.last != nil {
                            dataBaseService.messages.removeLast()
                        }
                    }
                }))
            }
        }
        topVC!.present(alert, animated: true, completion: nil)
    }
    
}
