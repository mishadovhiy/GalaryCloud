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
        VStack {
            ForEach(FileManagerService.URLType.allCases, id: \.url.absoluteString) { type in
                Button("uploaded photos \(directorySize[type] ?? 0)") {
                    filemamager.clear(url: type)
                    calculateDirectorySizes()
                }
            }
        }
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
        VStack {
            NavigationLink("Support") {
                SupportView()
            }
            .modifier(LinkButtonModifier())
            
            NavigationLink("Privacy policy") {
                PrivacyPolicyView()
            }
            .modifier(LinkButtonModifier())
        }
    }
    
    var appUtilitiesView: some View {
        VStack {
            NavigationLink("Local storage") {
                fileManagerView
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
        }
    }
    
    var rootView: some View {
        VStack(spacing: 20) {
            NavigationLink("Logout") {
                logoutView
            }
            .modifier(LinkButtonModifier(disctructive: true))
            
            HStack {
                NavigationLink("Help & Support") {
                    helpSupportView
                }
                .modifier(LinkButtonModifier())
                
                NavigationLink("App Utilities & Links") {
                    appUtilitiesView
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
        
        .background {
            ClearBackgroundView()
        }
        .background(.primaryContainer)
    }
    
    var logoutView: some View {
        MessageStaticView(
            message: .init(title: "Are you sure?",
                           buttons: [
                            .init(title: "Cancel"),
                            .init(title: "Logout", didPress: {
                                KeychainService.saveToken("", forKey: .userPasswordValue)
                                db.checkIsUserLoggedIn = true
                            })
                           ])
        )
    }
    
    var storageUsedView: some View {
        HStack {
            Text("MB:" + db.storageUsed.megabytesString + " / " + "\(db.storeKitService.activeSubscriptionGB)")
                .font(.title)
            Text(" | file count \(db.totalFileCount)")
                .font(.footnote)
            Spacer()
            Text("Upgrade")
        }
        .padding(.vertical, 26)
        .padding(.horizontal, 10)
        .background(.secondaryContainer)
        .cornerRadius(16)
    }
}

extension SidebarView {
    struct Constants {
        static let background: Color = .primaryContainer
    }
}
