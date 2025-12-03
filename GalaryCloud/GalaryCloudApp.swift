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
    @State var isLoading: Bool = true
    
    var body: some Scene {
        WindowGroup {
            contentView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.primaryContainer)
            .animation(.smooth, value: isLoading)
            .onAppear {
                let _ = ServiceConfig()
                fetchAppData()
            }
            
        }
    }
    
    @ViewBuilder
    var contentView: some View {
        if isLoading {
            AppLaunchView()
        } else {
            HomeView()
                .modifier(RootAlertConfigModifier())
                .environmentObject(dataBaseService)
        }
    }
    
    func fetchAppData() {
        Task {
            let result = await URLSession.shared.resumeTask(AppConfigRequest())
            await MainActor.run {
                if let response = try? result.get() {
                    dataBaseService.db?.generalAppParameters = response
                }
                self.isLoading = false
            }
        }
    }
    
}
