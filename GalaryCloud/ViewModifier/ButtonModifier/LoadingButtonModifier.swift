//
//  LoadingButtonModifier.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 26.11.2025.
//

import SwiftUI

struct LoadingButtonModifier: ViewModifier {
    
    let isLoading: Bool
    let isHidden: Bool
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: isLoading ? 44 : .infinity, maxHeight: isHidden ? 0 : 44)
            .overlay(content: {
                LoaderView(isLoading: isLoading, tint: .blue)
            })
            .background(.blue)
            .font(.title)
            .tint(isLoading ? .blue : .white)
            .cornerRadius(9)
            .animation(.bouncy, value: isLoading)
            .shadow(radius: 8)
    }
}
