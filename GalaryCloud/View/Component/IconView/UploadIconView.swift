//
//  UploadIconView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 25.11.2025.
//

import SwiftUI

struct UploadIconView: View, IconViewProtocol {
    
    let isLoading: Bool
    @State var animationActive: Bool = false
    @StateObject var model: IconViewModel
    @State var id: UUID = .init()

    init(isLoading: Bool,
         canPressChanged: ((_: Bool) -> Void)? = nil) {
        self.isLoading = isLoading
        self._model = StateObject(wrappedValue: .init(canPressChanged: canPressChanged))
    }
    
    var body: some View {
        contentView
            .offset(x: model.completed ? -10 : 0, y: model.completed ? 10 : 0)
            .scaleEffect(model.completed ? 0 : 1)
            .animation(.smooth, value: model.completed)
            .overlay {
                LoaderView(isLoading: isLoading, trim: model.completed ? 1 : 0)
                    .padding(-10)
            }
            .overlay(content: {
                CheckmarkShape()
                    .trim(to: model.completed ? 1 : 0)
                    .fill(shapeColor)
                    .scaleEffect(model.completed ? 1 : 0.8)
                    .animation(.smooth(duration: 0.9), value: model.completed)
            })
            .id(id)
            .frame(maxWidth: 40, maxHeight: 40)
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
    
    var contentView: some View {
        VStack {
            Spacer()
            CloudShape()
                .trim(to: !isLoading ? 1 : (animationActive ? 1 : 0))
                .scale(isLoading ? (animationActive ? 1.05 : 0.95) : 1)
                .stroke(shapeColor, lineWidth: 1.5)
                .padding(.bottom, 10)
                .animation(isLoading ? .linear.repeatForever(autoreverses: true).speed(0.3) : .default, value: animationActive)
            
                .overlay {
                    arrowView(false)
                }
                .aspectRatio(1, contentMode: .fit)
            Spacer()
        }
    }
}
