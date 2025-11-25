//
//  ContentView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI

struct HomeView: View {
    
    @State var isLoading = true
    @State var canPress = true
    
    var body: some View {
        TabView {
            SaveIconView(isLoading: isLoading,
                         canPressChanged: {
                canPress = $0
            })
                .frame(width: 50, height: 50)
            UploadIconView(isLoading: isLoading, canPressChanged: {
                canPress = $0
            })
            .frame(width: 50, height: 50)
            FileListView()
        }
        .tabViewStyle(.page)
        .onTapGesture {
            if canPress {
                withAnimation(.smooth) {
                    isLoading.toggle()
                }
            }
        }
        .background(.black)
        //        TabView {
        //            FileListView()
        //            LoaderView(isLoading: isLoading)
        //                .padding(10)
        //                .onAppear {
        //                    isLoading = true
        //                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
        //                        self.isLoading = false
        //                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
        //                            self.isLoading = true
        //                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
        //                                self.isLoading = false
        //                            })
        //                        })
        //
        //                    })
        //                }
        //        }
        //        .tabViewStyle(.page)
    }
}

#Preview {
    HomeView()
}
