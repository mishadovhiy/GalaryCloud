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
        #if os(watchOS)
            .frame(maxWidth: isLoading ? 34 : nil, maxHeight: isHidden ? 0 : (type != .default ? nil : 34))
        #else
            .frame(maxWidth: isLoading ? 44 : nil, maxHeight: isHidden ? 0 : (type != .default ? nil : 44))
        #endif
            .overlay(content: {
                if isLoading {
                    LoaderView(isLoading: isLoading, tint: .primaryText, lineWidth: 3)
                        .padding(50)
                        .cornerRadius(9)
                }
            })
            .background(Color.accentColor)
            .font(font)
            .tint(isLoading ? .accentColor : .white)
            .cornerRadius(isLoading ? 50 : 9)
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
        case .middle:
                .system(size: 12, weight: .medium)
        }
    }
    
    enum `Type` {
        case `default`
        case small
        case middle
    }
}
