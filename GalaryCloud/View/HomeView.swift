//
//  ContentView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI

struct HomeView: View {
    
    @State var isLoading = false
    @State var canPress = true
    @State var isLoggedIn: Bool = false
    @EnvironmentObject private var db: DataBaseService
    
    var body: some View {
        VStack {
            if isLoggedIn {
//                homeView
                FileListView()
                    .modifier(
                        SidebarModifier(
                            viewWidth: 500,
                            targedBackgroundView: SidebarView(),
                            disabled: false)
                    )
            } else {
                AuthorizationView()
            }
        }
        .onChange(of: db.checkIsUserLoggedIn) { newValue in
            checkAuthorization()
        }
        .onAppear {
            db.checkIsUserLoggedIn = true
        }
    }
    
    func checkAuthorization() {
        let credinails = [
            KeychainService.getToken(forKey: .userNameValue),
            KeychainService.getToken(forKey: .userPasswordValue)
        ]
            
        self.isLoggedIn = !credinails.contains(where: {$0?.isEmpty ?? true})
    }
    @State var id: UUID = .init()
    
    var homeView: some View {
        TabView {
            HStack(spacing: 20) {
                TrashIconView(isLoading: isLoading,
                             canPressChanged: {
                    canPress = $0
                })
                    .frame(width: 50, height: 50)
                SaveIconView(isLoading: isLoading,
                             canPressChanged: {
                    canPress = $0
                })
                    .frame(width: 50, height: 50)
                    .scaleEffect(0.7)
                UploadIconView(isLoading: isLoading, canPressChanged: {
                    canPress = $0
                })
                .frame(width: 50, height: 50)
            }
            FileListView()
        }
        .tabViewStyle(.page)
        .onTapGesture {
            if canPress {
                withAnimation(.smooth) {
                    isLoading.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    isLoading = false
                })
            }
        }
        .modifier(SidebarModifier(viewWidth: 500, targedBackgroundView: SidebarView(), disabled: false))
    }
}

#Preview {
    HomeView()
}
