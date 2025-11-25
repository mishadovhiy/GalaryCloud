//
//  GalaryCloudApp.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI
import UIKit
import AWSS3
import AWSCore

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
                .environmentObject(dataBaseService)
                .onAppear {
                    let credentials = AWSStaticCredentialsProvider(
                        accessKey: "TU596PAI2YD1KVSINVOY",
                        secretKey: "2PGVASzVVFHqLaXFPuGPL6KZ7tgCXdYXKfMbjFXQ"
                    )

                    let endpoint = AWSEndpoint(
                        region: .APNortheast2,
                        service: .S3,
                        url: URL(string: "https://s3.ap-northeast-2.wasabisys.com")!
                    )

                    let config = AWSServiceConfiguration(
                        region: .USEast1,
                        endpoint: endpoint,
                        credentialsProvider: credentials
                    )

                    AWSServiceManager.default().defaultServiceConfiguration = config

                }
        }
    }
    
}
