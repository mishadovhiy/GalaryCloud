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
    @StateObject var storeKitService: StoreKitPurchaseService = .init()
    @StateObject var dataBaseService: DataBaseService = .init()
    
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
        }
    }
    
}
