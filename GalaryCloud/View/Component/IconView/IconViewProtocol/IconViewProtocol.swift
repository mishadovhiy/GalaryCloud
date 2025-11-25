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
}

extension View where Self: IconViewProtocol {
    
    var shapeColor: Color {
        .red
    }
    
    var shapeWidth: CGFloat {
        2
    }
    
    func arrowView(_ isTop: Bool) -> some View {
        VStack {
            if !isTop {
                arrowSpacers
            }
            HStack {
                ArrowShape(top: isTop)
                    .offset(y: !isLoading ? 0 : (animationActive ? (!isTop ? -5 : -10) : (!isTop ? 0 : 5)))
                    .stroke(shapeColor, lineWidth: 1.5)
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

struct IconViewModifier<Content: IconViewProtocol>: ViewModifier {
    func body(content: Content) -> some View {
        content
            .offset(x: model.completed ? -10 : 0, y: model.completed ? 10 : 0)
            .scaleEffect(model.completed ? 0 : 1)
            .animation(.smooth, value: model.completed)
            .overlay {
                LoaderView(isLoading: isLoading, trim: model.completed ? 1 : 0)
                    .padding(model.completed ? -20 : 20)
            }
            .overlay(content: {
                CheckmarkShape()
                    .trim(to: model.completed ? 1 : 0)
                    .fill(shapeColor)
                    .scaleEffect(model.completed ? 1 : 0.8)
                    .animation(.smooth(duration: 0.9), value: model.completed)
            })
    }
    
    
}
