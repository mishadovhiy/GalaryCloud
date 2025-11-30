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
                    VStack {
                        Text("Are you sure?")
                        HStack {
                            Button("confirm") {
                                KeychainService.saveToken("", forKey: .userPasswordValue)
                                db.checkIsUserLoggedIn = true

                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        ClearBackgroundView()
                    }
                    .background(.primaryContainer)

                    
                }
                Spacer()
                
                NavigationLink {
                    StoreKitView()
                } label: {
                    HStack {
                        Text("MB:" + db.storageUsed.megabytes)
                        Text(" | \(db.totalFileCount)")
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
