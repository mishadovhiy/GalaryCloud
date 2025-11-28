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
        VStack {
            Button("logout") {
                KeychainService.saveToken("", forKey: .userPasswordValue)
                db.checkIsUserLoggedIn = true
            }
            Spacer()
            HStack {
                Text("MB:" + db.storageUsed.megabytes)
                Text(" | \(db.totalFileCount)")
                Spacer()
                Button("Upgrade") {
                    storeKitPresenting = true
                }
            }
        }
        .padding(.horizontal, 2)
        .sheet(isPresented: $storeKitPresenting, content: {
            StoreKitView()
        })
    }
}
