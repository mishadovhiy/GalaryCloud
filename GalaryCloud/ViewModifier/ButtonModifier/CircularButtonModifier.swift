//
//  ButtonModifier.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 30.11.2025.
//

import SwiftUI

struct CircularButtonModifier: ViewModifier {
    
    var color: ColorScheme = .dark
    var cornerRadius: CGFloat? = nil
    var isHidden: Bool = false
    var isAspectRatio: Bool = false
    var maxHeight: CGFloat? = .infinity
    func body(content: Content) -> some View {
        content
            .tint(.primaryText)
            .frame(maxWidth: isAspectRatio ? .infinity : nil, maxHeight: maxHeight)
            //.frame(width: width, height: height)
            .background(content: {
                #if !os(watchOS)
                BlurView()
                    .background(background.opacity(0.5))
                #else
                EmptyView()
                #endif
            })

            .cornerRadius(cornerRadius ?? .infinity / 2)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius ?? .infinity / 2)
                    .stroke(.outline, lineWidth: 1)
            }
            .clipped()
            .shadow(radius: isHidden ? .zero : 8)
    }
    
    var background: Color {
        switch color {
        case .light:
                .primaryText
        case .dark:
                .primaryContainer
        @unknown default:
                .primaryContainer
        }
    }
    
    var tint: Color {
        switch color {
        case .light:
                .secondaryContainer
        case .dark:
                .primaryText
        @unknown default:
                .primaryText
        }
    }
}
