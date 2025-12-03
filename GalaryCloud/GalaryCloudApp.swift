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
                .modifier(RootAlertConfigModifier())
                .environmentObject(dataBaseService)
                .onAppear {
                    let _ = ServiceConfig()
                }

        }
    }
        
}
