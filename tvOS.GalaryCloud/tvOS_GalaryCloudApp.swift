//
//  tvOS_GalaryCloudApp.swift
//  tvOS.GalaryCloud
//
//  Created by Mykhailo Dovhyi on 08.12.2025.
//

import SwiftUI
import UIKit

@main
struct tvOS_GalaryCloudApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // buy pro screen only dont store in enviroment and fecth active subscription detail when app did enter foregraund (for displaying total gb availible), and when selected photos
    @StateObject var dataBaseService: DataBaseService = .init()
    @State var isLoading: Bool = true
    @StateObject var backgroundService: BackgroundTaskService = .init()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            contentView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.primaryContainer)
            .animation(.smooth, value: isLoading)
            .onAppear {
                let _ = ServiceConfig()
                fetchAppData()
                dataBaseService.storeKitService.listenForTransactions()
                backgroundService.configure()
            }
            .onChange(of: scenePhase) { newValue in
                switch newValue {
                case .background:
                    backgroundService.scheduleTask(time: 2*60)
                default: break
                }
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
                .environmentObject(backgroundService)
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
