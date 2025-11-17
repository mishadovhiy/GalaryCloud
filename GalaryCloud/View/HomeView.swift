//
//  ContentView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var appData: AppData
    
    var body: some View {
        NavigationView {
            TabView {
                FileListView()
                    .tabItem {
                        Text("uploaded")
                    }
            }
        }
    }
}

#Preview {
    HomeView()
}
