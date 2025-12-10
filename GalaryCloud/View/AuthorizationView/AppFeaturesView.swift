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
                .foregroundColor(.primaryText)
            TabView {
                ForEach(data, id: \.title) { data in
                    VStack(alignment: .center) {
#if !os(watchOS)
                        LottieView(name: data.gifURL)
                            .frame(width: 150, height: isKeyboardFocused ? 0 : 150)
                            .clipped()
#endif
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
#if !os(tvOS)
#if !os(watchOS)
            links
#endif
#endif
        }
        .animation(.smooth, value: isKeyboardFocused)
    }
    
    var links: some View {
#if !os(watchOS)
        HStack {
            NavigationLink ("Support" ) {
                SupportView()
                    .padding (.bottom, 20)
            }
            .frame(maxWidth: .infinity)
            Spacer ()
            VStack {
                NavigationLink("Privacy policy") {
                    HTMLBlockPresenterView(urlType:
                            .privacyPolicy)
                }
            }
            .frame(maxWidth: .infinity)
            Spacer ()
            VStack{
                NavigationLink("Terms Of Use") {
                    HTMLBlockPresenterView(urlType:
                            .termsOfUse)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .tint(.secondaryText)
        .font (.system(size: 10))
        .frame(maxWidth: .infinity, maxHeight:
                isKeyboardFocused ? 0: nil)
        .padding(.bottom, isKeyboardFocused ? 0 : 20)
        .clipped()
#else
        EmptyView()
#endif
    }
    
#warning("todo: fetch in general request")
    let data: [FeatureModel] = [
        .init(title: "Free up you Device storage", description: "Upload your photos directly to the cloud to save space on your device.", gifURL: "cloudStorage"),
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
