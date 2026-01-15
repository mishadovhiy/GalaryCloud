//
//  SaveIconView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 25.11.2025.
//

import SwiftUI
import Combine

struct SaveIconView: View, IconViewProtocol {
    
    let isLoading: Bool
    @State var animationActive: Bool = false
    @StateObject var model: IconViewModel
    @State var id: UUID = .init()
    
    let lineWidth: CGFloat = 2
    let tint: Color = .primaryText
    
    init(isLoading: Bool,
         canPressChanged: ((_: Bool) -> Void)? = nil) {
        self.isLoading = isLoading
        self._model = StateObject(wrappedValue: .init(canPressChanged: canPressChanged))
    }
    
    var body: some View {
        ZStack(content: {
            VStack {
                arrowView(true)
                    .padding(.top, !isLoading ? 5 : 0)
            }
            UploadComponentShape()
                .trim(to: !isLoading ? 1 : (animationActive ? 1 : 0))
                .scale(isLoading ? (animationActive ? 1.05 : 0.95) : 1)
                .stroke(tint, lineWidth: lineWidth + 1)
                .padding(.bottom, 10)
                .padding(.top, 10)
            //                .padding(.vertical, 10)
            //                .padding(.horizontal, 5)
                .animation(isLoading ? .linear.repeatForever(autoreverses: true).speed(0.65) : .default, value: animationActive)
            
        })
        .offset(x: model.completed ? -10 : 0, y: model.completed ? 10 : 0)
        .scaleEffect(model.completed ? 0 : 1)
        .animation(.smooth, value: model.completed)
        .overlay {
            LoaderView(isLoading: isLoading, trim: model.completed ? 1 : 0, tint: tint, lineWidth: lineWidth)
                .padding(model.completed ? -20 : 20)
        }
        .overlay(content: {
            CheckmarkShape()
                .trim(to: model.completed ? 1 : 0)
                .fill(tint)
                .scaleEffect(model.completed ? 1 : 0.8)
                .animation(.smooth(duration: 0.9), value: model.completed)
        })
        .frame(maxWidth: 50, maxHeight: 50)
        .scaleEffect(0.7)
        .id(id)
        .onChange(of: isLoading) { newValue in
            animationActive = newValue
            if !newValue {
                model.toggleSuccessAnimation {
                    withAnimation {
                        self.id = .init()
                    }
                }
            }
        }
        .onAppear {
            if isLoading {
                animationActive.toggle()
            }
        }
    }
}
