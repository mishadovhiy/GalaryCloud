//
//  IconViewProtocol.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 25.11.2025.
//

import SwiftUI

protocol IconViewProtocol: View {
    var isLoading: Bool { get }
    var animationActive: Bool { get }
    var model: IconViewModel { get }
    var id: UUID { get }
    var tint: Color { get }
    var lineWidth: CGFloat { get }
}

extension View where Self: IconViewProtocol {
    
    func arrowView(_ isTop: Bool) -> some View {
        VStack {
            if !isTop {
                arrowSpacers
            }
            HStack {
                ArrowShape(top: isTop)
                    .offset(y: !isLoading ? 0 : (animationActive ? (!isTop ? -5 : -1) : (!isTop ? 0 : 10)))
//                    .scale(isLoading ? (animationActive ? 1 : 0.98) : 1)
                /**
                 ArrowShape(top: isTop)
                     .offset(y: !isLoading ? 0 : (animationActive ? (!isTop ? -5 : 0) : (!isTop ? 0 : 7)))
                     .scale(isLoading ? (animationActive ? 1 : 0.98) : 1)
                 */
                    .stroke(tint, lineWidth: lineWidth)
                    .animation(isLoading ? .linear.repeatForever(autoreverses: true).speed(0.5) : .default, value: animationActive)
                
            }
            .aspectRatio(1, contentMode: .fit)
            if isTop {
                arrowSpacers
            }
        }
        .padding(.bottom, !isTop ? 5 : -5)
        .padding(.top, !isTop ? 0 : -5)
    }
    
    @ViewBuilder
    private var arrowSpacers: some View {
        Spacer()
            .frame(maxHeight: .infinity)
        Spacer()
            .frame(maxHeight: .infinity)
    }
}
