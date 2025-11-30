//
//  SidebarView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 28.11.2025.
//

import SwiftUI

struct SidebarView: View {
    
    @EnvironmentObject private var db: DataBaseService
    @State var storeKitPresenting: Bool = false

    var body: some View {
        NavigationView(content: {
            VStack {
                NavigationLink("Logout") {
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
                Spacer()
                
                NavigationLink {
                    StoreKitView()
                } label: {
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
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            
            .background {
                ClearBackgroundView()
            }
            .background(.primaryContainer)
        })
        .background {
            ClearBackgroundView()
        }
        .background(.primaryContainer)
    }
}
