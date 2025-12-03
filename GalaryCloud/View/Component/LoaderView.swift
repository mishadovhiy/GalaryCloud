//
//  LoaderShape.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 25.11.2025.
//

import SwiftUI

struct LoaderView: View {
    let isLoading: Bool
    let trim: CGFloat?
    let tint: Color
    let lineWidth: CGFloat
    
    init(isLoading: Bool,
         trim: CGFloat? = nil,
         tint: Color = .primaryText,
         lineWidth: CGFloat = 1
    ) {
        self.isLoading = isLoading
        self.trim = trim
        self.tint = tint
        self.lineWidth = lineWidth
    }
    
    @State private var animationActive: Bool = false
    
    var body: some View {
        Circle()
            .trim(to: isLoading ? 0.3 : (trim ?? 0))
            .stroke(tint, lineWidth: lineWidth)
            .background(.clear)
            .rotationEffect(!animationActive ? .degrees(0) : .degrees(360))
            .animation(isLoading ? .linear(duration: 1.3).repeatForever(autoreverses: false).speed(1.2) : .default, value: animationActive)
        .onChange(of: isLoading) { newValue in
            animationActive = newValue
        }
        .onAppear {
            if isLoading {
                animationActive.toggle()
            }
        }
    }
}
