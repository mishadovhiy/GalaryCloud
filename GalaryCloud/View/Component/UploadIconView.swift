//
//  UploadIconView.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 25.11.2025.
//

import SwiftUI

struct UploadIconView: View {
    let isLoading: Bool
    let canPressChanged: (_ canPress: Bool)->()
    @State private var animationActive: Bool = false
    @State private var completed: Bool = false
    
    var body: some View {
        contentView
            .offset(x: completed ? -10 : 0, y: completed ? 10 : 0)
            .scaleEffect(completed ? 0 : 1)
            .animation(.smooth, value: completed)
            .overlay {
                LoaderView(isLoading: isLoading, trim: completed ? 1 : 0)
                    .padding(-10)
            }
            .overlay(content: {
                CheckmarkShape()
                    .trim(to: completed ? 1 : 0)
                    .fill(.red)
                    .scaleEffect(completed ? 1 : 0.8)
                    .animation(.smooth(duration: 0.9), value: completed)
            })
            .onChange(of: isLoading) { newValue in
                animationActive = newValue
                if !newValue {
                    toggleSuccessAnimation()
                }
            }
            .onAppear {
                if isLoading {
                    animationActive.toggle()
                }
            }
    }
    
    func toggleSuccessAnimation() {
        canPressChanged(false)
        withAnimation(.bouncy(duration: 0.7)) {
            completed = true
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000), execute: {
            withAnimation(.bouncy(duration: 0.3)) {
                completed = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(900), execute: {
                canPressChanged(true)
            })
        })
    }
    
    var contentView: some View {
        VStack {
            Spacer()
            CloudShape()
                .trim(to: !isLoading ? 1 : (animationActive ? 1 : 0))
                .scale(isLoading ? (animationActive ? 1.05 : 0.95) : 1)
                .stroke(.red, lineWidth: 1.5)
                .padding(.bottom, 10)
                .animation(isLoading ? .linear.repeatForever(autoreverses: true).speed(0.3) : .default, value: animationActive)
            
                .overlay {
                    arrowView
                }
                .aspectRatio(1, contentMode: .fit)
            Spacer()
        }
    }
    
    var arrowView: some View {
        VStack {
            Spacer()
                .frame(maxHeight: .infinity)
            Spacer()
                .frame(maxHeight: .infinity)
            HStack {
                ArrowShape(top: false)
                    .offset(y: !isLoading ? 0 : (animationActive ? -5 : 0))
                    .stroke(.red, lineWidth: 1.5)
                    .animation(isLoading ? .linear.repeatForever(autoreverses: true).speed(0.5) : .default, value: animationActive)
                
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .padding(.bottom, 5)
    }
}
