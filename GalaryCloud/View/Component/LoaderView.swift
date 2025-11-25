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
    
    init(isLoading: Bool, trim: CGFloat? = nil) {
        self.isLoading = isLoading
        self.trim = trim
    }
    
    @State private var animationActive: Bool = false
    
    var body: some View {
        Circle()
            .trim(to: isLoading ? 0.3 : (trim ?? 0))
            .stroke(.red, lineWidth: 1)
            .background(.clear)
            .rotationEffect(!animationActive ? .degrees(0) : .degrees(360))
            .animation(isLoading ? .linear(duration: 1.3).repeatForever(autoreverses: false).speed(1.2) : .default, value: animationActive)
        .onChange(of: isLoading) { newValue in
            print(newValue, " yhrtgerfsda ")
            animationActive = newValue
        }
        .onAppear {
            if isLoading {
                animationActive.toggle()
            }
        }
    }
}
