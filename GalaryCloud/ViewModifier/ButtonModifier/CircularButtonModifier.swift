//
//  ButtonModifier.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 30.11.2025.
//

import SwiftUI

struct CircularButtonModifier: ViewModifier {
    var isHidden: Bool = false
    var isAspectRatio: Bool = false
    func body(content: Content) -> some View {
        content
            .tint(.primaryText)
            .frame(maxWidth: isAspectRatio ? .infinity : nil, maxHeight: .infinity)
            //.frame(width: width, height: height)
            .background(content: {
                BlurView()
                    .background(.primaryContainer.opacity(0.5))
            })

            .cornerRadius(.infinity / 2)
            .overlay {
                RoundedRectangle(cornerRadius: .infinity / 2)
                    .stroke(.outline, lineWidth: 1)
            }
            .clipped()
            .shadow(radius: isHidden ? .zero : 8)
    }
}
