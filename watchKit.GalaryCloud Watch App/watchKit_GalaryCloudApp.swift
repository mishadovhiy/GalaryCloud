//
//  watchKit_GalaryCloudApp.swift
//  watchKit.GalaryCloud Watch App
//
//  Created by Mykhailo Dovhyi on 08.12.2025.
//

import SwiftUI

@main
struct watchKit_GalaryCloud_Watch_AppApp: App {
    @StateObject var dataBaseService: DataBaseService = .init()
    @State var isLoading: Bool = true
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
