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
    @State var appeared = false
    var body: some View {
        VStack {
            if !appeared {
                AppLaunchView()
            } else {
                if isLoggedIn {
                    FileListView()
                        .modifier(
                            SidebarModifier(
                                targedBackgroundView: SidebarView(),
                                disabled: false)
                        )
                } else {
                    AuthorizationView()
                }
            }
            
        }
        .animation(.bouncy, value: isLoggedIn)
        .onChange(of: db.checkIsUserLoggedIn) { newValue in
            if newValue {
                db.checkIsUserLoggedIn = false
                checkAuthorization()
            }
            
        }
        .onAppear {
            db.checkIsUserLoggedIn = true
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.primaryContainer)
    }
    
    func checkAuthorization() {
        let credinails = [
            KeychainService.getToken(forKey: .userNameValue),
            KeychainService.getToken(forKey: .userPasswordValue)
        ]
        withAnimation(.bouncy(duration: 0.9)) {
            self.isLoggedIn = !credinails.contains(where: {$0?.isEmpty ?? true})
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(900), execute: {
            withAnimation(.bouncy) {
                appeared = true
            }
        })
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
        .modifier(SidebarModifier( targedBackgroundView: SidebarView(), disabled: false))
    }
}

#Preview {
    HomeView()
}
