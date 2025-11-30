//
//  ButtonModifier.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 30.11.2025.
//

import SwiftUI

struct CircularButtonModifier: ViewModifier {
    var width: CGFloat? = nil
    var height: CGFloat = 40
    
    func body(content: Content) -> some View {
        content
            .tint(.primaryText)
            .frame(width: width, height: height)
            .background(content: {
                BlurView()
                    .background(.primaryContainer.opacity(0.5))
            })

            .cornerRadius(height / 2)
            .overlay {
                RoundedRectangle(cornerRadius: height / 2)
                    .stroke(.outline, lineWidth: 1)
            }
            .clipped()
            .shadow(radius: width == .zero ? .zero : 8)
    }
}
