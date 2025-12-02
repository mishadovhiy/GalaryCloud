//
//  AppFeaturesView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 23.11.2025.
//

import SwiftUI

struct AppFeaturesView: View {
    let isKeyboardFocused: Bool
    
    var body: some View {
        VStack {
            Text("Cloud Photo Storage")
                .font(.largeTitle)
                .frame(height: isKeyboardFocused ? 0 : nil)
                .clipped()
            TabView {
                ForEach(data, id: \.title) { data in
                    VStack(alignment: .center) {
                        LottieView(name: data.gifURL)
                            .frame(width: 150, height: isKeyboardFocused ? 0 : 150)
                            .clipped()
                        Text(data.title)
                            .font(.headline)
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        Spacer().frame(height: 5)
                        Text(data.description)
                            .font(.footnote)
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 30)
                }
            }
            .tabViewStyle(.page)
        }
        .animation(.smooth, value: isKeyboardFocused)
    }
    
#warning("todo: fetch in general request")
    let data: [FeatureModel] = [
        .init(title: "Free up you iCloud and Device storage size", description: "Upload your photos directly to the cloud to save space on your device.", gifURL: "cloudStorage"),
        .init(title: "Download photos back to your photo library", description: "you can delete photos from your device and resave photos uploaded to our application", gifURL: "save"),
        .init(title: "Cheapest Cloud Pricing", description: "Store large amounts of photos at prices far lower than any cloud storage.", gifURL: "giftDiscount"),
        .init(title: "Ultra-Low App Size and Zero Local Storage", description: "controll how much data can be cached or torn off caching to reduce app size.\nYou can delete cach anytime", gifURL: "uploading"),
        .init(title: "Access From Any Device", description: "Log in from any device and instantly access your entire library.", gifURL: "morphing")
    ]
    
    struct FeatureModel: Codable {
        let title: String
        let description: String
        let gifURL: String
    }
}
