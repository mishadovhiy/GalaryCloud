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
    
    @State var directorySize1: Int64 = 0
    @State var directorySize2: Int64 = 0

    var fileManagerView: some View {
        VStack {
            Button("uploaded photos \(directorySize1)") {
                FileManager.default.clearTempFolder()
                calculateDirectorySizes()
            }
            Button("cached photos \(directorySize2)") {
                FileManager.default.clearTempFolder(url: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!)
                calculateDirectorySizes()
            }
        }
        .background(Constants.background)
        .onAppear {
            calculateDirectorySizes()
        }
    }
    
    func calculateDirectorySizes() {
        directorySize1 = FileManager.default.directorySize(url: FileManager.default.temporaryDirectory)
        directorySize2 = FileManager.default.directorySize(url: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!)
    }
    
    var rootView: some View {
        VStack(spacing: 20) {
            NavigationLink("Logout") {
                logoutView
            }
            NavigationLink("Support") {
                SupportView()
            }
            NavigationLink("Privacy policy") {
                PrivacyPolicyView()
            }
            NavigationLink("Local storage") {
                fileManagerView
            }

            Button("Rate us") {
                db.storeKitService.requestAppStoreReview()
            }
            
            Button("Website") {
                if let url = URL(string: Keys.websiteURL.rawValue),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Share app") {
                sharePresenting = true
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
