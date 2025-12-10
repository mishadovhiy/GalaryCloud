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
        .navigationViewStyle(StackNavigationViewStyle())
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
#if !os(watchOS)
        .sheet(isPresented: $sharePresenting) {
            ShareView(items: [Keys.shareAppURL])
        }
        .sheet(isPresented: isPrivacyPresenting) {
            HTMLBlockPresenterView(urlType: privacyPresentingType ?? .privacyPolicy)
                .presentationDetents([.medium])
        }
        #endif
    }
    
    @ViewBuilder
    var fileManagerOptions: some View {
        ForEach(FileManagerService.URLType.allCases, id: \.url.absoluteString) { type in
            Button("\(type.rawValue.capitalized) \(directorySize[type]?.megabytesFromBytes.formated ?? "") MB") {
                filemamager.clear(url: type)
                calculateDirectorySizes()
            }
            .modifier(LinkButtonModifier())
        }
    }
    
    var fileManagerView: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text("Select directory, you would like to clear:")
                .foregroundColor(.primaryText)
            #if os(watchOS)
            fileManagerOptions
            #else
            HStack(spacing: spacing) {
                fileManagerOptions
                Spacer()
            }
            #endif
            
            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Constants.background)
        .onAppear {
            calculateDirectorySizes()
        }
    }
    
    @State var privacyPresentingType: HTMLBlockPresenterView.URLType?
    var isPrivacyPresenting: Binding<Bool> {
        .init(get: {
            privacyPresentingType != nil
        }, set: {
            if !$0 {
                privacyPresentingType = nil
            }
        })
    }
    var helpSupportView: some View {
        #if !os(watchOS)
        VStack(alignment: .leading) {
            NavigationLink("Support") {
                SupportView()
                    .navigationTitle("Support")
            }
            .modifier(LinkButtonModifier())
            
            HStack(spacing: spacing) {
                Button("Privacy policy", action: {
                    privacyPresentingType = .privacyPolicy
                })
                .modifier(LinkButtonModifier())
                Button("Terms of use", action: {
                    privacyPresentingType = .termsOfUse
                })
                .modifier(LinkButtonModifier())
            }
            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Constants.background)
        #else
        EmptyView()
        #endif
    }
    
    var appUtilitiesView: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack(spacing: spacing) {
                Button("Rate us") {
                    db.storeKitService.requestAppStoreReview()
                }
                .modifier(LinkButtonModifier())
                
                Button("Website") {
#if !os(watchOS)
                    if let url = URL(string: Keys.websiteURL.rawValue),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                    #endif
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
    
    @ViewBuilder
    var generalSettingsList: some View {
        NavigationLink("Account") {
            accountView
                .navigationTitle("Account")
        }
        .modifier(LinkButtonModifier())
        NavigationLink("Local storage") {
            #if os(watchOS)
            ScrollView(.vertical) {
                fileManagerView
                    .navigationTitle("Local storage")
            }
            #else
            fileManagerView
                .navigationTitle("Local storage")
            #endif
        }
        .modifier(LinkButtonModifier())
    }
    
    @ViewBuilder
    var allSettingsList: some View {
        HStack(spacing: spacing) {
            generalSettingsList
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
    }
    
    var rootView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: spacing) {
                    Spacer().frame(height: spacing)
                    #if os(watchOS)
                    generalSettingsList
                    #else
                    allSettingsList
                    #endif
                    

                    Spacer()
                    
                }
                .frame(alignment: .leading)

            }
            #if os(iOS)
            NavigationLink {
                StoreKitView(db: db, privacyPresentingType: $privacyPresentingType)
            } label: {
                storageUsedView
            }
            #else
            storageUsedView
            #endif
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .frame(alignment: .leading)
        .background {
            ClearBackgroundView()
        }
        .background(.primaryContainer)
        .navigationViewStyle(StackNavigationViewStyle())
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
#if os(iOS)
                Text("Number of files: \(db.totalFileCount)")
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .tint(.secondaryText)
                    .frame(alignment: .leading)
#endif
            }
            #if os(iOS)
            Spacer()
            Text("Upgrade")
                .modifier(LinkButtonModifier(type: .link))
            #endif
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
