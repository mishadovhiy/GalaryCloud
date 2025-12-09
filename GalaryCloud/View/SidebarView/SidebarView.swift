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
    @State var isLoading: Bool = false

    var body: some View {
        NavigationView(content: {
            rootView
        })
        .overlay(content: {
            if isLoading {
                LoaderView(isLoading: true)
                    .frame(width: 30, height: 30)
            }
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
        VStack(alignment: .leading, spacing: spacing) {
            Text("Select directory, you would like to clear:")
                .foregroundColor(.primaryText)
            HStack(spacing: spacing) {
                ForEach(FileManagerService.URLType.allCases, id: \.url.absoluteString) { type in
                    Button("\(type.rawValue.capitalized) \(directorySize[type]?.megabytesFromBytes.formated ?? "") MB") {
                        filemamager.clear(url: type)
                        calculateDirectorySizes()
                    }
                    .modifier(LinkButtonModifier())
                }
                Spacer()
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
    
    var helpSupportView: some View {
        VStack(alignment: .leading, spacing: spacing) {
            NavigationLink("Support") {
                SupportView()
                    .navigationTitle("Support")
            }
            .modifier(LinkButtonModifier())
            
            HStack(spacing: spacing) {
                NavigationLink("Privacy policy") {
                    HTMLBlockPresenterView(urlType: .privacyPolicy)
                }
                .modifier(LinkButtonModifier())
                NavigationLink("Terms of use") {
                    HTMLBlockPresenterView(urlType: .termsOfUse)
                }
                .modifier(LinkButtonModifier())
            }
            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Constants.background)
    }
    
    var appUtilitiesView: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack(spacing: spacing) {
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
    
    var accountView: some View {
        VStack(spacing: spacing, content: {
            Text(KeychainService.username)
                .foregroundColor(.primaryText)
            Spacer()
            HStack(spacing: spacing) {
                NavigationLink("Logout") {
                    logoutView
                        .navigationTitle("Logout")
                }
                .modifier(LinkButtonModifier(type: .distructive))
                NavigationLink("Delete Account") {
                    deleteAccountView
                        .navigationTitle("Delete Account")
                }
                .modifier(LinkButtonModifier(type: .distructive))
                
            }
        })
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Constants.background)
    }
    
    let spacing: CGFloat = 15
    
    var rootView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: spacing) {
                    Spacer().frame(height: spacing)
                    HStack(spacing: spacing) {
                        NavigationLink("Account") {
                            accountView
                                .navigationTitle("Account")
                        }
                        .modifier(LinkButtonModifier())
                        NavigationLink("Local storage") {
                            fileManagerView
                                .navigationTitle("Local storage")
                        }
                        .modifier(LinkButtonModifier())
                    }
                    
                    HStack(spacing: spacing) {
                        NavigationLink("Help & Support") {
                            helpSupportView
                                .navigationTitle("Help & Support")
                        }
                        .modifier(LinkButtonModifier())
                        
                        NavigationLink("External Links") {
                            appUtilitiesView
                                .navigationTitle("App Utilities & Links")
                        }
                        .modifier(LinkButtonModifier())
                    }

                    Spacer()
                    
                }
                .frame(alignment: .leading)

            }
            NavigationLink {
                StoreKitView(db: db)
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
        confirmationMessageView(task: "Logout") {
            self.logoutPressed()
        }
    }

    var deleteAccountView: some View {
        confirmationMessageView(task: "Delete Account", title: "Are you sure you whant to delete your account?\nAll your data would be lost forewer") {
            self.deleteAccountPressed()
        }
    }
    
    func confirmationMessageView(
        task: String,
        title: String = "Are you sure?",
        didPress: @escaping()->()
    ) -> some View {
        MessageStaticView(
            message: .init(header:task, title: title,
                           buttons: [
                            .init(title: "Cancel"),
                            .init(title: task, type: .distructive, didPress: {
                                didPress()
                            })
                           ])
        )
    }
    
    @ViewBuilder
    var storageUsedView: some View {
        let subscriptionGB = db.storeKitService.activeSubscriptionGB
        HStack(spacing: spacing) {
            VStack(alignment: .leading) {
                Text("Cloud storage used")
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .tint(.secondaryText)
                    .opacity(0.4)
                    .padding(.bottom, 1)
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text((db.storageUsed.megabytesFromBytes.gbFromMegabytes.mbOrTbTitle) + " / " + "\(subscriptionGB.mbOrTbTitle)")
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
                ProgressView(value: db.storageUsed.megabytesFromBytes / Double(subscriptionGB * 1024), total: Double(subscriptionGB * 1024))
                    .progressViewStyle(.linear)
            }
            .padding(.horizontal, 10)
        })
        .background(.secondaryContainer)
        .cornerRadius(16)
    }
}

extension SidebarView {
    func calculateDirectorySizes() {
        FileManagerService.URLType.allCases.forEach { type in
            self.directorySize.updateValue(filemamager.directorySize(type), forKey: type)
        }
    }
    
    func logoutPressed() {
        FileManagerService.URLType.allCases.forEach {
            filemamager.clear(url: $0)
        }
        let _ = KeychainService.saveToken("", forKey: .userPasswordValue)
        db.checkIsUserLoggedIn = true
    }
    
    func deleteAccountPressed() {
        isLoading = true
        Task {
            let result = await URLSession.shared.resumeTask(DeleteAccountRequest(username: KeychainService.username))
            await MainActor.run {
                self.isLoading = false
                switch result {
                case .success(let success):
                    self.db.messages.append(.init(title: "Your account and all data has been deleted Successfully"))
                    self.logoutPressed()
                case .failure(let failure):
                    self.db.messages.append(.init(header: "Error", title: failure.unparcedDescription ?? "Error deleting request"))
                }
            }
        }
    }
}

extension SidebarView {
    struct Constants {
        static let background: Color = .primaryContainer
    }
}
