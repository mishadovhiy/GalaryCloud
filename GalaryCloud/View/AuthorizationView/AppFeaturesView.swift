//
//  AppFeaturesView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 23.11.2025.
//

import SwiftUI

struct AppFeaturesView: View {
    var body: some View {
        Text("Cloud Photo Storage")
            .font(.largeTitle)
        TabView {
            Text("Cheapest Cloud Pricing")
        }
        .tabViewStyle(.page)
    }
    let data: [TempFeature] = [
        .init(title: "Free up you iCloud and Device storage size", description: "Upload your photos directly to the cloud to save space on your device."),
        .init(title: "Download photos back to your photo library", description: "you can delete photos from your device and resave photos uploaded to our application"),
        .init(title: "Cheapest Cloud Pricing", description: "Store large amounts of photos at prices far lower than any cloud storage."),
        .init(title: "Ultra-Low App Size and Zero Local Storage", description: "controll how much data can be cached or torn off caching to reduce app size.\nYou can delete cach anytime"),
        .init(title: "Access From Any Device", description: "Log in from any device and instantly access your entire library.")
    ]
    struct TempFeature: Codable {
        let title: String
        let description: String
    }
}

#Preview {
    AppFeaturesView()
}
