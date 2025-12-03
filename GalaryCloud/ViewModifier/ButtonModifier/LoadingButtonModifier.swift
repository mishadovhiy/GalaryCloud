//
//  LoadingButtonModifier.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 26.11.2025.
//

import SwiftUI

struct LoadingButtonModifier: ViewModifier {
    
    let isLoading: Bool
    var isHidden: Bool = false
    var type: Type = .default
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: isLoading ? 44 : nil, maxHeight: isHidden ? 0 : (type == .small ? nil : 44))
            .overlay(content: {
                if isLoading {
                    LoaderView(isLoading: isLoading, tint: .primaryText, lineWidth: 3)
                        .padding(10)
                        .cornerRadius(9)
                }
            })
            .background(.blue)
            .font(font)
            .tint(isLoading ? .blue : .white)
            .cornerRadius(9)
            .animation(.bouncy, value: isLoading)
            .clipped()
            .shadow(radius: 8)
    }
    
    var font: Font {
        switch type {
        case .default:
                .title
        case .small:
                .system(size: 9)
        }
    }
    
    enum `Type` {
        case `default`
        case small
    }
}
