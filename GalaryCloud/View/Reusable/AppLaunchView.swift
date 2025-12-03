//
//  AppLaunchView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 03.12.2025.
//

import SwiftUI

struct AppLaunchView: View {
    var body: some View {
        VStack(spacing: 80) {
            Image(.appIcon)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200)
                .cornerRadius(18)
            LoaderView(isLoading: true)
                .frame(width: 30, height: 30)
        }
    }
}

#Preview {
    AppLaunchView()
}
