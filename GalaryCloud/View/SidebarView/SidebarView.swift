//
//  SidebarView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 28.11.2025.
//

import SwiftUI

struct SidebarView: View {
    
    @EnvironmentObject private var db: DataBaseService
    @State var sharePresenting: Bool = false
    private let filemamager = FileManagerService()
    @State var directorySize: [FileManagerService.URLType: Int64] = [:]

    var body: some View {
        NavigationView(content: {
            rootView
        })
        .background {
            ClearBackgroundView()
        }
        .background(Constants.background)
        .sheet(isPresented: $sharePresenting) {
            ShareView(items: [Keys.shareAppURL])
        }
    }
    
    var fileManagerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select directory, you would like to clear:")
                .foregroundColor(.primaryText)
            ForEach(FileManagerService.URLType.allCases, id: \.url.absoluteString) { type in
                Button("\(type.rawValue.capitalized) \(directorySize[type] ?? 0) MB") {
                    filemamager.clear(url: type)
                    calculateDirectorySizes()
                }
                .modifier(LinkButtonModifier())
            }
            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Constants.background)
        .onAppear {
            calculateDirectorySizes()
        }
    }
    
    func calculateDirectorySizes() {
        FileManagerService.URLType.allCases.forEach { type in
            self.directorySize.updateValue(filemamager.directorySize(type), forKey: type)
        }
    }
    
    var helpSupportView: some View {
        VStack(alignment: .leading) {
            NavigationLink("Support") {
                SupportView()
                    .navigationTitle("Support")
            }
            .modifier(LinkButtonModifier())
            
            NavigationLink("Privacy policy") {
                PrivacyPolicyView()
            }
            .modifier(LinkButtonModifier())
            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Constants.background)
    }
    
    var appUtilitiesView: some View {
        VStack(alignment: .leading) {
            NavigationLink("Local storage") {
                fileManagerView
                    .navigationTitle("Local storage")
            }
            .modifier(LinkButtonModifier())

            HStack {
                Button("Rate us") {
                    db.storeKitService.requestAppStoreReview()
                }
                .modifier(LinkButtonModifier())
                
                Button("Website") {
                    if let url = URL(string: Keys.websiteURL.rawValue),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
                .modifier(LinkButtonModifier())
                
                Button("Share app") {
                    sharePresenting = true
                }
                .modifier(LinkButtonModifier())
            }
            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Constants.background)
    }
    
    var rootView: some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink("Logout") {
                logoutView
                    .navigationTitle("Logout")
            }
            .modifier(LinkButtonModifier(type: .distructive))
            
            HStack(spacing: 10) {
                NavigationLink("Help & Support") {
                    helpSupportView
                        .navigationTitle("Help & Support")
                }
                .modifier(LinkButtonModifier())
                
                NavigationLink("App Utilities & Links") {
                    appUtilitiesView
                        .navigationTitle("App Utilities & Links")
                }
                .modifier(LinkButtonModifier())
            }
            

            Spacer()
            
            NavigationLink {
                StoreKitView()
            } label: {
                storageUsedView
            }

        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .frame(alignment: .leading)
        .background {
            ClearBackgroundView()
        }
        .background(.primaryContainer)
    }
    
    var logoutView: some View {
        MessageStaticView(
            message: .init(header:"Logout", title: "Are you sure?",
                           buttons: [
                            .init(title: "Cancel"),
                            .init(title: "Logout", type: .distructive, didPress: {
                                KeychainService.saveToken("", forKey: .userPasswordValue)
                                db.checkIsUserLoggedIn = true
                            })
                           ])
        )
    }
    
    @ViewBuilder
    var storageUsedView: some View {
        let subscriptionGB = db.storeKitService.activeSubscriptionGB
        HStack() {
            VStack(alignment: .leading) {
                Text("Cloud storage used")
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .tint(.secondaryText)
                    .opacity(0.4)
                    .padding(.bottom, 1)
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text((db.storageUsed.megabytes / 1024).formated + " / " + "\(subscriptionGB)")
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .tint(.primaryText)
                    Text("MB")
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .tint(.primaryText)
                }
                .frame(alignment: .leading)
                Text("Number of files: \(db.totalFileCount)")
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .tint(.secondaryText)
                    .frame(alignment: .leading)
            }
            Spacer()
            Text("Upgrade")
                .modifier(LinkButtonModifier(type: .link))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .padding(.horizontal, 10)
        .overlay(content: {
            VStack {
                Spacer()
                ProgressView(value: db.storageUsed.megabytes / Double(subscriptionGB * 1024), total: Double(subscriptionGB * 1024))
                    .progressViewStyle(.linear)
            }
            .padding(.horizontal, 10)
        })
        .background(.secondaryContainer)
        .cornerRadius(16)
    }
}

extension SidebarView {
    struct Constants {
        static let background: Color = .primaryContainer
    }
}
